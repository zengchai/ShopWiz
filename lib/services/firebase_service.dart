import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwiz/pages/cart/Cart.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/home/model/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    List<Product> products = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      querySnapshot.docs.forEach((doc) {
        products.add(Product(
          pid: doc['pid'],
          pname: doc['pname'],
          pcategory: doc['pcategory'],
          pdescription: doc['pdescription'],
          pimageUrl: doc['pimageUrl'],
          pprice: doc['pprice'].toDouble(),
          pquantity: doc['pquantity'],
        ));
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
    return products;
  }

  Future<Product> getProductById(String productId) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('products').doc(productId).get();

      if (docSnapshot.exists) {
        return Product(
          pid: docSnapshot['pid'],
          pname: docSnapshot['pname'],
          pcategory: docSnapshot['pcategory'],
          pdescription: docSnapshot['pdescription'],
          pimageUrl: docSnapshot['pimageUrl'],
          pprice: docSnapshot['pprice'].toDouble(),
          pquantity: docSnapshot['pquantity'],
        );
      } else {
        throw Exception('Product not found with ID: $productId');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
  Future<void> updateCart(String userId, Cart cart) async {
    try {
      await _firestore.collection('carts').doc(userId).set(cart.toJson());
    } catch (error) {
      print("Error updating cart: $error");
      throw error;
    }
  }

  Future<void> deleteCart(String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).delete();
    } catch (error) {
      print("Error deleting cart: $error");
      throw error;
    }
  }

  Future<Cart?> getCart(String userId) async {
    try {
      DocumentSnapshot cartSnapshot =
          await _firestore.collection('carts').doc(userId).get();

      if (cartSnapshot.exists) {
        return Cart.fromJson(cartSnapshot.data() as Map<String, dynamic>);
      } else {
        return null; // Cart not found for the user
      }
    } catch (error) {
      print("Error getting cart: $error");
      throw error;
    }
  }

Future<void> addToCart(String userId, CartItem cartItem) async {
  try {
    // Get a reference to the user's document
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the user's cart data
    await userDocRef.collection('cart').doc(cartItem.pid).set(cartItem.toJson());
  } catch (error) {
    print("Error adding to cart: $error");
    throw error;
  }
}

}
