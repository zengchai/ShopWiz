import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/cart/cart_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopwiz/commons/BaseLayout.dart';

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

void _placeOrder() async {
  try {
    // Calculate total selected subtotal
    double totalSelectedSubtotal = _calculateTotalSelectedSubtotal(cartItems);

    // Get the current user's UID
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }
    String userId = currentUser.uid;

    // Call placeOrder function from CartController to place the order
    await _cartController.placeOrder(cartItems, totalSelectedSubtotal, userId);

    // Delete the selected items from the cart
    List<String> selectedPids = _selectedItems.toList();
    for (String pid in selectedPids) {
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
                    // Add subtotal to total

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
                            Text(cartItem.name),
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
                    onPressed: _placeOrder,
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
