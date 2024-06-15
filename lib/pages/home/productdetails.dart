import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/cart/cart_controller.dart';
import 'package:shopwiz/services/firebase_service.dart';
import 'package:shopwiz/pages/home/model/product.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String userId;

  ProductDetailsScreen({required this.productId, required this.userId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  int _quantity = 1; // Default quantity to 1
  final CartController _cartController = CartController();
  bool _isLoading = false; // To manage loading state
  List<Map<String, dynamic>> _stores = []; // List to store the store data
  String _selectedStoreName = 'Select a location'; // Default selection
  String _selectedStoreId = ''; // Define _selectedStoreId variable to hold the selected store ID

  @override
  void initState() {
    super.initState();
    _fetchProductInfo();
  }

  void _fetchProductInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final product = await FirebaseService().getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _fetchStoreDataForProduct(widget.productId);
        });
      }
    } catch (error) {
      print("Error fetching product: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fetchStoreDataForProduct(String productId) async {
    try {
      List<Map<String, dynamic>> stores = await FirebaseService().getAllStoresWithProductStock(productId);
      setState(() {
        _stores = stores;
      });
    } catch (error) {
      print('Error fetching store data for product: $error');
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart(String storeId) async { // Change parameter to storeId
    if (_quantity <= 0) {
      _showDialog('Error', 'Quantity must be greater than 0.');
      return;
    }

    try {
      if (_product != null) {
        setState(() {
          _isLoading = true;
        });

        final cartItem = CartItem(
          pid: _product!.pid,
          name: _product!.pname,
          image: _product!.pimageUrl,
          quantity: _quantity,
          price: _product!.pprice,
          store: _selectedStoreName,
          storeId: storeId, // Pass selected store ID
        );

        await _cartController.addToCart(cartItem);
        _showDialog(
          'Success',
          '$_quantity ${_product!.pname} added to cart successfully from $_selectedStoreName!',
        );
      } else {
        _showDialog('Error', 'Failed to fetch product information.');
      }
    } catch (error) {
      print("Error adding to cart: $error");
      _showDialog(
        'Error',
        'Failed to add product to cart. Please try again later.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
void _openMap(double latitude, double longitude, String storeName) async {
  final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$storeName&query=$latitude,$longitude';
  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else {
    throw 'Could not launch $googleMapsUrl';
  }
}

void _showAvailabilityList(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Store Availability'),
        content: Container(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseService().getAllStoresWithProductStock(widget.productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show loading indicator while data is fetched
              } else if (snapshot.hasError) {
                 return Text(
                      'Error: ${snapshot.error}'); // Show error message if there's an error
              } else {
                List<Map<String, dynamic>>? stores = snapshot.data;
                if (stores != null && stores.isNotEmpty) {
                  return ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          stores[index]['sname'] as String,
                          style: TextStyle(fontWeight: FontWeight.bold),
     
                        ),
                        subtitle: Text(
                          'Stock Quantity: ${stores[index]['storestock'] as int}',
 
                        ),
                        trailing: Tooltip(
                          message: 'GPS',
                          child: IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () {
                              double latitude = stores[index]['latitude'];
                              double longitude = stores[index]['longitude'];
                              String storeName = stores[index]['sname'];
                              _openMap(latitude, longitude, storeName);
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedStoreName = stores[index]['sname'] as String;
                            _selectedStoreId = stores[index]['sid'] as String? ?? ''; // Handle null value
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No stores available'));
                }
              }
            },
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  _product != null && _product!.pimageUrl.isNotEmpty
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_product!.pimageUrl),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {
                                setState(() {
                                  _product!.pimageUrl = ''; // Set the image URL to empty string to trigger the fallback UI
                                });
                              },
                            ),
                          ),
                          child: _product!.pimageUrl.isEmpty
                              ? Icon(Icons.broken_image, size: 100, color: Colors.grey)
                              : null,
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product?.pname ?? 'Loading...',
                          style: TextStyle(fontSize: 24.0, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              _product != null
                                  ? 'RM ${_product!.pprice.toStringAsFixed(2)}'
                                  : 'Loading...',
                              style: TextStyle(fontSize: 16.0, color: Colors.green),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              _product != null ? 'Quantity: ${_product!.pquantity}' : 'Loading...',
                              style: TextStyle(fontSize: 16.0, color: Colors.black87),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          _product?.pdescription ?? 'Loading...',
                          style: TextStyle(fontSize: 16.0, color: Colors.black87),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Select Location:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        InkWell(
                          onTap: () {
                            _showAvailabilityList(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _selectedStoreName,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: _decrementQuantity,
                            ),
                            Container(
                              width: 60.0,
                              height: 40.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                '$_quantity',
                                style: TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _incrementQuantity,
                            ),
                            SizedBox(width: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                _addToCart(_selectedStoreId); // Pass the store ID
                              },
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String storeName;
  final String storeId; // New parameter for store ID
  final int stockQuantity;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.storeName,
    required this.storeId,
    required this.stockQuantity,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(storeName),
        subtitle: Text('Stock Quantity: $stockQuantity'),
        onTap: onTap,
      ),
    );
  }
}
