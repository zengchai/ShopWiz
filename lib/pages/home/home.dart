import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopwiz/commons/BaseLayout.dart'; // Base layout for customers
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/models/product.dart';
import 'package:shopwiz/services/database.dart'; // Base layout for admins

class HomeScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All products'; // Added state variables
  String? _imagePath;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _categories = [
    'All products',
    'Supplements',
    'Medicines',
    'External use'
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser; // Get the current user

    bool showCustomer = currentUser?.uid != '7aXevcNf3Cahdmk9l5jLRASw5QO2';

    return showCustomer
        ? BaseLayout(
            child: const Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Customer View",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    'Content for customers',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          )
        : BaseLayoutAdmin(
            // ignore: sort_child_properties_last
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
                  // Ensures ProductScreen has appropriate space in the Column
                  child:
                      ProductScreen(), // Include ProductScreen within the Column
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

  void _showAddProductDialog(BuildContext context) {
    final DatabaseService _databaseService =
        DatabaseService(uid: ''); // Database service

    final GlobalKey<FormState> _formKey =
        GlobalKey<FormState>(); // For input validation

    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productPriceController =
        TextEditingController();
    final TextEditingController productQuantityController =
        TextEditingController();
    final TextEditingController productCategoryController =
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
                    key: _formKey, // Use a form key for validation
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
                            await pickImage(); // Select the image
                            setState(() {}); // Update the UI
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey,
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : const Center(
                                    child: Text(
                                        'Product Image'), // Placeholder if no image
                                  ),
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
                          controller: productCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Product Category',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product category';
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
                              return; // Exit if the form is not valid
                            }

                            final String pid = FirebaseFirestore.instance
                                .collection('products')
                                .doc()
                                .id; // Create a new product ID
                            final String pname = productNameController.text;
                            final double pprice =
                                double.tryParse(productPriceController.text) ??
                                    0.0;
                            final int pquantity =
                                int.tryParse(productQuantityController.text) ??
                                    0;
                            final String pcategory =
                                productCategoryController.text;
                            final String pdescription =
                                productDescriptionController.text;

                            if (selectedImage != null) {
                              final String? imageUrl = await _databaseService
                                  .uploadProductImage(selectedImage!, pid);

                              if (imageUrl != null) {
                                await _databaseService.createProduct(
                                  pid,
                                  pname,
                                  pprice,
                                  pquantity,
                                  pcategory,
                                  pdescription,
                                  imageUrl,
                                );

                                print("Product created successfully");
                              } else {
                                print("Failed to upload image");
                              }
                            } else {
                              print("No image selected");
                            }

                            Navigator.of(context).pop(); // Close the dialog
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

void _showAddProductDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      var _imagePath;
      return Dialog(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                    ),
                  ],
                ),
                const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Display selected image or show placeholder
                Container(
                    height: 100, // Adjust height as needed
                    width: 100, // Adjust width as needed
                    color: Colors.grey, // Placeholder for product image
                    child: const Text('Product Image')),
                const SizedBox(height: 20),
                // Your text fields for product details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.grey[200], // Light grey background
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200], // Light grey background
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Product Price',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200], // Light grey background
                      child: const TextField(
                        decoration: InputDecoration(
                          labelText: 'Product Quantity',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Save changes
                    Navigator.of(context).pop(); // Close dialog
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
}

class ProductScreen extends StatelessWidget {
  final DatabaseService _dbService =
      DatabaseService(uid: ''); // Database service instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbService.retrieveProductList(),
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

                return Container(
                  margin: const EdgeInsets.all(10),
                  // Define a specific width to reduce the container size
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of the screen width
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 3, // Spread of shadow
                        blurRadius: 5, // Blurring effect
                        offset:
                            const Offset(0, 3), // Position of the shadow (x, y)
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        10), // Padding inside the container
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Smaller container width to fit within reduced container size
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                  'Price: \$${product.pprice.toStringAsFixed(2)}'),
                              Text('Stock: ${product.pquantity}'),
                            ],
                          ),
                        ),
                        const SizedBox(
                            width: 10), // Space between text and buttons
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditProductDialog(
                                context, product); // Open edit dialog
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                context, product); // Open delete confirmation
                          },
                        ),
                      ],
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

  void _showEditProductDialog(BuildContext context, Product product) {
    final TextEditingController productNameController =
        TextEditingController(text: product.pname);
    final TextEditingController productPriceController =
        TextEditingController(text: product.pprice.toString());
    final TextEditingController productQuantityController =
        TextEditingController(text: product.pquantity.toString());
    final TextEditingController productCategoryController =
        TextEditingController(text: product.pcategory);
    final TextEditingController productDescriptionController =
        TextEditingController(text: product.pdescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey,
                    child: Image.network(
                      product.pimageUrl,
                      fit: BoxFit.cover,
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
                        controller: productCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Product Category',
                        ),
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
                    onPressed: () {
                      // Edit the product
                      _dbService.editProduct(
                        product.pid,
                        productNameController.text,
                        double.tryParse(productPriceController.text) ??
                            product.pprice,
                        int.tryParse(productQuantityController.text) ??
                            product.pquantity,
                        productCategoryController.text,
                        productDescriptionController.text,
                        product.pimageUrl,
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
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _dbService.deleteProduct(); // Delete the product
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text('Yes'),
                    ),
                    const SizedBox(width: 10),
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
        );
      },
    );
  }
}
