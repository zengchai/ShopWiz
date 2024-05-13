import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/models/product_model.dart';
import 'package:shopwiz/models/store.dart';
import 'package:shopwiz/services/database.dart';

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late final DatabaseService _dbService;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService(uid: '');
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the product ID from the route arguments
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String productId = arguments['productId'];

    return BaseLayoutAdmin(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future:
              _dbService.getProductData(productId), // Fetch the product data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading product"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No product data found"));
            }

            // Display the product data
            final productData = snapshot.data!;

            void reloadStockScreen() {
              print(productData['pquantity']); // Add parentheses for print
              setState(() {});
            }

            final product = Product(
              pid: productId,
              pname: productData['pname'],
              pprice: productData['pprice'],
              pquantity: productData['pquantity'],
              pdescription: productData['pdescription'],
              pimageUrl: productData['imageUrl'],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // The product image
                    Align(
                      alignment:
                          Alignment.center, // Aligns in the center horizontally
                      child: Padding(
                        // Add padding around the image to avoid overlap
                        padding: const EdgeInsets.only(
                            top: 30), // Adds space at the top
                        child: Image.network(
                          productData['imageUrl'],
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0, // Position the Row with some offset
                      right: 0, // Position at the top-right
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, right: 10), // Add padding for spacing
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditProductDialog(context, product);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, product);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Space below the image
                // Product name
                Text(
                  productData['pname'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Product quantity and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity: ${productData['pquantity']}',
                      style: TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.w500, // Slightly bolder
                      ),
                    ),
                    Text(
                      '\RM${double.parse(productData['pprice'].toString()).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.w500, // Slightly bolder
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Product description
                Align(
                  alignment:
                      Alignment.centerLeft, // Right-aligning within its parent
                  child: Text(
                    productData['pdescription'],
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left, // Right-align the text itself
                  ),
                ),
                Expanded(
                  child: StoreList(
                    productId: productId,
                    reloadCallback: reloadStockScreen,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final TextEditingController productNameController =
        TextEditingController(text: product.pname);
    final TextEditingController productPriceController =
        TextEditingController(text: product.pprice.toString());
    final TextEditingController productQuantityController =
        TextEditingController(text: product.pquantity.toString());

    final TextEditingController productDescriptionController =
        TextEditingController(text: product.pdescription);

    File? selectedImage;
    Future<void> pickImage(String pid) async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      ),
                      const Text(
                        'Edit Product',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          await pickImage(product.pid); // Select the image
                          setState(() {}); // Update the UI
                        },
                        // Trigger image selection
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey,
                          child: selectedImage != null
                              ? Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  product.pimageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: productNameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: productPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Product Price',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: productQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Product Quantity',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: productDescriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Product Description',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // If an image is selected, upload it and get the image URL
                          String? imageUrl;
                          if (selectedImage != null) {
                            imageUrl = await _dbService.uploadProductImage(
                                selectedImage!, product.pid);
                          }

                          // Edit the product
                          _dbService.editProduct(
                            product.pid,
                            productNameController.text,
                            double.tryParse(productPriceController.text) ??
                                product.pprice,
                            int.tryParse(productQuantityController.text) ??
                                product.pquantity,
                            productDescriptionController.text,
                            imageUrl ??
                                product
                                    .pimageUrl, // Use selected image URL if available, otherwise use the existing product image URL
                          );

                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 200), // Set maximum width and height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delete Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Are you sure you want to delete this product?',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _dbService
                              .deleteProduct(product.pid); // Delete the product
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushReplacementNamed('/home'); // Go back to home
                          // Close dialog
                        },
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreList extends StatelessWidget {
  final String productId;
  final Function reloadCallback; // Callback function

  final DatabaseService _dbService = DatabaseService(uid: '');

  StoreList({required this.productId, required this.reloadCallback});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getAllStores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("Error loading stores: ${snapshot.error}");
          return Center(
            child: Text("Error loading stores: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No stores available"));
        } else {
          List<Map<String, dynamic>> stores = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                return StoreItem(
                  store: Store.fromMap(stores[index]),
                  productId: productId,
                  dbService: _dbService,
                  reloadCallback:
                      reloadCallback, // Pass callback function to StoreItem
                );
              },
            ),
          );
        }
      },
    );
  }
}

class StoreItem extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService(uid: '');

  final Store store;
  final String productId;
  final DatabaseService dbService;
  final Function reloadCallback; // Callback function

  StoreItem({
    required this.store,
    required this.productId,
    required this.dbService,
    required this.reloadCallback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  store.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.storeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<int>(
                      future: dbService.getStockForProduct(
                          store.storeId, productId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Stock: Loading...',
                            style: TextStyle(fontSize: 14),
                          );
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Stock: Error',
                            style: TextStyle(fontSize: 14),
                          );
                        } else {
                          final int stock = snapshot.data ?? 0;
                          return Text(
                            'Stock: $stock',
                            style: const TextStyle(fontSize: 14),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showStockTransferDialog(context, reloadCallback);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStockTransferDialog(BuildContext context, Function reloadCallback) {
    final TextEditingController stockQuantityController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transfer Stock'),
          content: TextField(
            controller: stockQuantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Stock Quantity'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int transferQuantity =
                    int.tryParse(stockQuantityController.text) ?? 0;

                // Retrieve the current product data
                final productData = await _dbService.getProductData(productId);
                final int currentQuantity = productData['pquantity'];

                if (transferQuantity > currentQuantity) {
                  // Display an alert dialog if transfer quantity exceeds current quantity
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Transfer quantity cannot exceed current quantity.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Transfer stock and update product data if transfer quantity is valid
                  _dbService.transferStock(
                      store.storeId, productId, transferQuantity);
                  await _dbService.updateProductData(
                      transferQuantity, productId);

                  Navigator.of(context).pop();
                  reloadCallback(); // Reload the StockScreen
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }
}
