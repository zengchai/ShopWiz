import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/models/product_model.dart';
import 'package:shopwiz/services/database.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String? _imagePath;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser; // Get the current user

    bool showCustomer = currentUser?.uid != '7aXevcNf3Cahdmk9l5jLRASw5QO2';

    return BaseLayoutAdmin(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
          Expanded(
            child: ProductItemScreen(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddProductDialog(
              context); // The button to trigger adding a product
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productPriceController =
        TextEditingController();
    final TextEditingController productQuantityController =
        TextEditingController();
    final TextEditingController productDescriptionController =
        TextEditingController();

    File? selectedImage;

    Future<void> pickImage() async {
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Product',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            await pickImage();
                            setState(() {});
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey,
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : const Center(child: Text('Product Image')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: productNameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: productPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Product Price',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product price';
                            }
                            final double? price = double.tryParse(value);
                            if (price == null) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: productQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Product Quantity',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product quantity';
                            }
                            final int? quantity = int.tryParse(value);
                            if (quantity == null) {
                              return 'Please enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: productDescriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Product Description',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        const SizedBox(height: 20),
                                        Text('Adding Product...'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            final String pid = FirebaseFirestore.instance
                                .collection('products')
                                .doc()
                                .id;
                            final String pname = productNameController.text;
                            final double pprice =
                                double.tryParse(productPriceController.text) ??
                                    0.0;
                            final int pquantity =
                                int.tryParse(productQuantityController.text) ??
                                    0;

                            final String pdescription =
                                productDescriptionController.text;

                            try {
                              final String? imageUrl = selectedImage != null
                                  ? await DatabaseService(uid: '')
                                      .uploadProductImage(selectedImage!, pid)
                                  : null;

                              await DatabaseService(uid: '').createProduct(
                                pid,
                                pname,
                                pprice,
                                pquantity,
                                pdescription,
                                imageUrl!,
                              );

                              Navigator.of(context)
                                  .pop(); // Close the loading dialog
                              Navigator.of(context)
                                  .pop(); // Close the add product dialog
                            } catch (error) {
                              print('Error adding product: $error');
                              Navigator.of(context)
                                  .pop(); // Close the loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to add product: $error'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          child: const Text('Add Product'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ProductItemScreen extends StatelessWidget {
  final DatabaseService _dbService =
      DatabaseService(uid: ''); // Database service instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.retrieveProductList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Loading state
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading products"), // Error state
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No products available"), // Empty state
            );
          } else if (snapshot.hasData) {
            List<Product> products = snapshot.data!.map((data) {
              return Product.fromMap(data);
            }).toList();

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  // Wrap the Container with GestureDetector
                  onTap: () {
                    // Navigate to StockScreen when the item is tapped
                    navigateToStockScreen(context, product.pid);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    // Define a specific width to reduce the container size
                    width: MediaQuery.of(context).size.width *
                        0.9, // 90% of the screen width
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 3, // Spread of shadow
                          blurRadius: 5, // Blurring effect
                          offset: const Offset(
                              0, 3), // Position of the shadow (x, y)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          10), // Padding inside the container
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width *
                                0.2, // 20% of screen width
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  10), // Match outer border radius
                              child: Image.network(
                                product.pimageUrl,
                                fit: BoxFit
                                    .cover, // Ensure the image covers the container
                              ),
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Space between image and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.pname,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Price: \RM${product.pprice.toStringAsFixed(2)}',
                                ),
                                Text('Stock: ${product.pquantity}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("Unexpected error"), // Fallback case
            );
          }
        },
      ),
    );
  }

  void navigateToStockScreen(BuildContext context, String productId) {
    Navigator.pushNamed(
      context,
      '/stock',
      arguments: {'productId': productId}, // Pass the product ID in arguments
    );
  }
}
