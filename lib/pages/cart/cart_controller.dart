import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopwiz/models/user_model.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';

import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwiz/models/user_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<void> addToCart(CartItem cartItem) async {
  try {
    // Retrieve the current user
    FirebaseAuth.User? currentUser = FirebaseAuth.FirebaseAuth.instance.currentUser;
    
    // Check if the current user is authenticated
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    // Get the user ID
    String userId = currentUser.uid;

    // Get a reference to the user's document
    DocumentReference userDocRef = _firestore.collection('users').doc(userId);

    // Check if the cart item already exists
    DocumentSnapshot cartItemSnapshot = await userDocRef.collection('cart').doc(cartItem.pid).get();
    if (cartItemSnapshot.exists) {
      // Cart item exists, update its quantity by adding the new quantity
      int existingQuantity = cartItemSnapshot['quantity'];
      await userDocRef.collection('cart').doc(cartItem.pid).update({
        'quantity': existingQuantity + cartItem.quantity,
      });
    } else {
      // Cart item doesn't exist, create a new one
      await userDocRef.collection('cart').doc(cartItem.pid).set(cartItem.toJson());
    }
  } catch (error) {
    print("Error adding to cart: $error");
    throw error;
  }
}
Stream<List<CartItem>> getCartItems(String userId) {
  try {
    // Get a reference to the user's document
    DocumentReference userDocRef = _firestore.collection('users').doc(userId);

    // Return a stream of cart items from the 'cart' subcollection
    return userDocRef.collection('cart').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CartItem.fromSnapshot(doc))
        .toList());
  } catch (error) {
    print("Error getting cart items: $error");
    throw error;
  }
}
 Future<void> updateCartItemQuantity(String pid, int quantity, String userId) async {
    try {
      // Get a reference to the user's document
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Update the quantity of the cart item
      await userDocRef.collection('cart').doc(pid).update({
        'quantity': quantity,
      });
    } catch (error) {
      print("Error updating cart item quantity: $error");
      throw error;
    }
  }

  Future<void> deleteCartItem(String pid, String userId) async {
    try {
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.collection('cart').doc(pid).delete();
    } catch (error) {
      print("Error deleting cart item: $error");
      throw error;
    }
  }


  Future<int> getCartItemQuantity(String pid, String userId) async {
    try {
      // Get a reference to the cart item document
      DocumentSnapshot cartItemSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(pid)
          .get();

      // Check if the cart item exists
      if (cartItemSnapshot.exists) {
        // Return the quantity from the cart item document
        return cartItemSnapshot['quantity'] ?? 0;
      } else {
        // Cart item not found, return 0
        return 0;
      }
    } catch (error) {
      print("Error getting cart item quantity: $error");
      throw error;
    }
    
  }
 Future<void> placeOrder(
      List<CartItem> cartItems, double totalSelectedSubtotal, String userId) async {
    try {
      // Generate a new order ID
      String orderId = _firestore.collection('orders').doc().id;

      // Prepare the order data
      Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': userId,
        'status': 'Received',
        'totalPrice': totalSelectedSubtotal,
        'totalQuantity': cartItems.fold(0, (sum, item) => sum + item.quantity),
        'store': cartItems.map((item) => {
          'storeId': item.storeId,
          'items': [
            {
              'productId': item.pid,
              'productName': item.name,
              'quantity': item.quantity,
              'price': item.price,
            }
          ],
        }).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save the order data to Firestore
      await _firestore.collection('orders').doc(orderId).set(orderData);
    } catch (error) {
      print("Error placing order: $error");
      throw error;
    }
  }



}
