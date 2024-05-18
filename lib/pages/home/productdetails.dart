import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/models/user_model.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/cart/cart_controller.dart';
import 'package:shopwiz/services/firebase_service.dart';
import 'package:shopwiz/pages/home/model/product.dart';
class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String userId;

  ProductDetailsScreen ({required this.productId, required this.userId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen > {
  Product? _product;
  int _quantity = 0;
  final CartController _cartController = CartController();

  @override
  void initState() {
    super.initState();
    _fetchProductInfo();
  }

  void _fetchProductInfo() async {
    try {
      _product = await FirebaseService().getProductById(widget.productId);
      setState(() {});
    } catch (error) {
      print("Error fetching product: $error");
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

 void _addToCart() async {
  try {
    // Check if the product is fetched successfully
    if (_product != null) {
      // Create a CartItem object using the Product information
      CartItem cartItem = CartItem(
        pid: _product!.pid,
        name: _product!.pname,
        image: _product!.pimageUrl,
        quantity: _quantity,
        price: _product!.pprice,
      );

      // Call the addToCart method in the CartController to add the item to the cart
      await _cartController.addToCart(cartItem);

      // Show a success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("$_quantity ${_product!.pname} added to cart successfully!"),
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
    } else {
      // Product is not fetched, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to fetch product information."),
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
  } catch (error) {
    // Show an error message if adding to cart fails
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to add product to cart. Please try again later."),
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
}

  Future<String?> _getCurrentUserId() async {
    return widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: SingleChildScrollView(
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
            _product != null && _product!.pimageUrl != null
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_product!.pimageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    color: Colors.grey[300],
                  ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      _product != null ? _product!.pname : 'Loading...',
                      style: TextStyle(fontSize: 24.0, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          _product != null
                              ? '\$${_product!.pprice.toStringAsFixed(2)}'
                              : 'Loading...',
                          style: TextStyle(fontSize: 16.0, color: Colors.green),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          _product != null
                              ? 'Quantity: ${_product!.pquantity}'
                              : 'Loading...',
                          style: TextStyle(fontSize: 16.0, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      _product != null ? _product!.pdescription : 'Loading...',
                      style: TextStyle(fontSize: 16.0, color: Colors.black87),
                    ),
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 40.0,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        width: 60.0,
                        height: 40.0,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 40.0,
                        color: Colors.grey[300],
                        child: TextButton(
                          onPressed: _addToCart,
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                    ],
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
