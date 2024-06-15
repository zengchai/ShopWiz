import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/cart/cart_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Stream<List<CartItem>> _cartItemsStream;
  final CartController _cartController = CartController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId; // Variable to store user ID
  List<String> _selectedItems = []; // List to store IDs of selected items
  late List<CartItem> cartItems; // Variable to store cart items
  late StreamSubscription<List<CartItem>> _subscription;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _fetchCartItems() async {
    try {
      // Retrieve the current user
      User? currentUser = _auth.currentUser;

      // Check if the current user is authenticated
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }

      // Get the user ID
      _userId = currentUser.uid; // Store user ID

      // Get the stream of cart items for the current user
      _cartItemsStream = _cartController.getCartItems(_userId);

      // Listen to the cart items stream and update the cartItems list
      _subscription = _cartItemsStream.listen((items) {
        setState(() {
          cartItems = items;
        });
      });
    } catch (error) {
      print("Error fetching cart items: $error");
      // Handle error here
    }
  }

  void _updateQuantity(String pid, int quantity) {
    // Update the quantity in the database
    _cartController.updateCartItemQuantity(pid, quantity, _userId);
  }

  void _deleteItem(String pid) {
    // Delete the cart item from the database
    _cartController.deleteCartItem(pid, _userId);
  }

  void _addToCart() {
    // Implement logic to add item to cart
    print('Item added to cart');
  }

void _placeOrder(List<CartItem> selectedCartItems) async {
  try {
    // Check if no items are selected
    if (selectedCartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one item to place an order.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Exit function if no items are selected
    }

    // Calculate total selected subtotal
    double totalSelectedSubtotal =
        _calculateTotalSelectedSubtotal(selectedCartItems);

    // Get the current user's UID
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    String userId = currentUser.uid;

    // Call placeOrder function from CartController to place the order
    await _cartController.placeOrder(
        selectedCartItems, totalSelectedSubtotal, userId);

    // Delete the selected items from the cart
    for (String pid in _selectedItems) {
      await _cartController.deleteCartItem(pid, userId);
    }

    // Clear the selected items list after placing the order
    setState(() {
      _selectedItems.clear();
    });

    // Show a success message or navigate to a confirmation screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order placed successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (error) {
    // Handle error
    print("Error placing order: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to place order. Please try again later.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  void _subtractQuantity(String pid) async {
    // Get the current quantity of the cart item
    int currentQuantity =
        await _cartController.getCartItemQuantity(pid, _userId);

    // Ensure the quantity is not already 0
    if (currentQuantity > 0) {
      // Decrement the quantity by 1
      int newQuantity = currentQuantity - 1;

      // Update the quantity in the database
      _cartController.updateCartItemQuantity(pid, newQuantity, _userId);
    }
  }

  void _addQuantity(String pid) async {
    // Get the current quantity of the cart item
    int currentQuantity =
        await _cartController.getCartItemQuantity(pid, _userId);

    // Increment the quantity by 1
    int newQuantity = currentQuantity + 1;

    // Update the quantity in the database
    _cartController.updateCartItemQuantity(pid, newQuantity, _userId);
  }

  void _toggleSelection(String pid) {
    setState(() {
      if (_selectedItems.contains(pid)) {
        _selectedItems.remove(pid);
      } else {
        _selectedItems.add(pid);
      }
    });
  }
  void _openMap(double latitude, double longitude, String query) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($query)';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _showAvailabilityList(BuildContext context, CartItem cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Store Availability'),
          content: Container(
            width: double.maxFinite,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  FirebaseService().getAllStoresWithProductStock(cartItem.pid),
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
                          title: Text(stores[index]['sname'] as String),
                          subtitle: Text(stores[index]['saddress'] as String),
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
                          onTap: () async {
                            String selectedStore =
                                stores[index]['sname'] as String;
                            setState(() {
                              // Update the store name of the cart item
                              cartItem.store = selectedStore;
                            });
                            // Update the store in the database
                            await _cartController.updateCartItemStore(
                                cartItem.pid, selectedStore, _userId);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  } else {
                    return Text(
                        'No stores available'); // Show message if no stores are available
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  double _calculateTotalSelectedSubtotal(List<CartItem> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      if (_selectedItems.contains(item.pid)) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  @override
Widget build(BuildContext context) {
  return BaseLayout(
    child: Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No items in the cart'),
            );
          }

          List<CartItem> cartItems = snapshot.data!;
          double totalSelectedSubtotal = _calculateTotalSelectedSubtotal(cartItems);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20), // Add some spacing
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem cartItem = cartItems[index];
                    double subtotal = cartItem.price * cartItem.quantity; // Calculate subtotal for each item
                    bool isSelected = _selectedItems.contains(cartItem.pid);

                    return Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleSelection(cartItem.pid);
                            },
                          ),
                        ),
                        title: Row(
                          children: [
                            SizedBox(width: 10),
                            SizedBox(
                              width: 60, // Set a fixed width for the image
                              height: 60, // Set a fixed height for the image
                              child: Image.network(cartItem.image), // Display image for each item
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.name),
                                  InkWell(
                                    onTap: () {
                                      _showAvailabilityList(context, cartItem);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        cartItem.store ?? 'Select a location', // Display the selected store name
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Handle overflow
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                _subtractQuantity(cartItem.pid);
                              },
                            ),
                            Text('${cartItem.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                _addQuantity(cartItem.pid);
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _deleteItem(cartItem.pid);
                              },
                              child: Text('Delete'),
                            ),
                            Spacer(),
                            Text('RM ${subtotal.toStringAsFixed(2)}'), // Display subtotal for each item
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20), // Add some spacing
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      List<CartItem> selectedCartItems = cartItems
                          .where((item) => _selectedItems.contains(item.pid))
                          .toList();
                      _placeOrder(selectedCartItems);
                    },
                    child: Text('Place Order'),
                  ),
                ),
                SizedBox(height: 10), // Add some spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Total Price: RM ${totalSelectedSubtotal.toStringAsFixed(2)}', // Display total subtotal for selected items
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

}
