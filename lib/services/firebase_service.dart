import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwiz/pages/cart/Cart.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';
import 'package:shopwiz/pages/home/model/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    List<Product> products = [];
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      // Loop through batches if there are more than 1,000 products
      while (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          products.add(Product(
            pid: doc['pid'],
            pname: doc['pname'],
            pdescription: doc['pdescription'],
            pimageUrl: doc['pimageUrl'],
            pprice: doc['pprice'].toDouble(),
            pquantity: doc['pquantity'],
          ));
        });
        // Fetch next batch if available
        querySnapshot = await _firestore
            .collection('products')
            .startAfter([querySnapshot.docs.last]).get();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return products;
  }

  Future<Product> getProductById(String productId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('products').doc(productId).get();

      if (docSnapshot.exists) {
        return Product(
          pid: docSnapshot['pid'],
          pname: docSnapshot['pname'],
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

  // Future<void> updateCart(String userId, Cart cart) async {
  //   try {
  //     await _firestore.collection('carts').doc(userId).set(cart.toJson());
  //   } catch (error) {
  //     print("Error updating cart: $error");
  //     throw error;
  //   }
  // }

  // Future<void> deleteCart(String userId) async {
  //   try {
  //     await _firestore.collection('carts').doc(userId).delete();
  //   } catch (error) {
  //     print("Error deleting cart: $error");
  //     throw error;
  //   }
  // }

  Future<List<String>> getAllStoreNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('stores').get();
      List<String> storeNames =
          snapshot.docs.map((doc) => doc['sname'] as String).toList();
      return storeNames;
    } catch (e) {
      print('Error fetching store names: $e');
      throw e;
    }
  }

  Future<List<String>> getStoreIdsForProduct(String productId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('ProductStoreMapping')
          .where('productId', isEqualTo: productId)
          .get();

      List<String> storeIds = [];
      querySnapshot.docs.forEach((doc) {
        storeIds.add(doc['storeId']);
      });
      return storeIds;
    } catch (error) {
      print("Error getting store IDs for product: $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getStoreDataByIds(
      List<String> storeIds) async {
    try {
      List<Map<String, dynamic>> stores = [];
      for (String storeId in storeIds) {
        DocumentSnapshot storeSnapshot =
            await _firestore.collection('stores').doc(storeId).get();
        if (storeSnapshot.exists) {
          Map<String, dynamic> storeData =
              storeSnapshot.data() as Map<String, dynamic>;
          stores.add(storeData);
        }
      }
      return stores;
    } catch (error) {
      print("Error getting store data by IDs: $error");
      throw error;
    }
  }

  Future<String?> _getStoreIdByName(String storeName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .where('sname', isEqualTo: storeName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null; // Store not found
      }
    } catch (error) {
      print('Error retrieving store ID: $error');
      return null;
    }
  }

  Future<void> deductStoreStock(
      String pid, String sid, int quantityToDeduct) async {
    try {
      // Reference to the store document
      DocumentReference storeRef = _firestore.collection('stores').doc(sid);

      // Fetch the store document
      DocumentSnapshot storeSnapshot = await storeRef.get();

      if (storeSnapshot.exists) {
        // Fetch products array from the store's data
        List<dynamic> products = storeSnapshot['products'] ?? [];

        if (products != null) {
          // Find the product index in the array
          int productIndex =
              products.indexWhere((product) => product['pid'] == pid);

          if (productIndex != -1) {
            // Get the current stock for the product
            int currentStock = products[productIndex]['storestock'] ?? 0;

            // Calculate new stock after deduction
            int newStock = currentStock - quantityToDeduct;

            if (newStock >= 0) {
              // Update the stock for the specific product in the products array
              products[productIndex]['storestock'] = newStock;

              // Update the entire products array in Firestore
              await storeRef.update({
                'products': products,
              });
            } else {
              throw Exception('Insufficient stock');
            }
          } else {
            throw Exception('Product not found in store');
          }
        } else {
          throw Exception('No products found in store');
        }
      } else {
        throw Exception('Store not found');
      }
    } catch (error) {
      print('Error deducting store stock: $error');
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getAllStoresWithProductStock(
      String productId) async {
    try {
      QuerySnapshot storeSnapshot = await _firestore.collection('stores').get();
      List<Map<String, dynamic>> stores = [];

      for (var doc in storeSnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> storeData = doc.data() as Map<String, dynamic>;

          // Fetch products array from the store's data
          List<dynamic> products = storeData['products'] ?? [];

          // Find the product with the matching productId
          Map<String, dynamic>? product = products.firstWhere(
            (prod) => prod['pid'] == productId,
            orElse: () => null,
          );

          // If product is found, set the storestock
          if (product != null) {
            storeData['storestock'] = product['storestock'] ?? 0;
          } else {
            storeData['storestock'] =
                0; // Default to 0 if the product is not found in the store
          }

          stores.add(storeData);
        }
      }
      return stores;
    } catch (e) {
      print('Error fetching stores: $e');
      throw e;
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
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the user's cart data
      await userDocRef
          .collection('cart')
          .doc(cartItem.pid)
          .set(cartItem.toJson());
    } catch (error) {
      print("Error adding to cart: $error");
      throw error;
    }
  }

  Future<Map<String, List<CartItem>>> getCartItemsByStore(String userId) async {
    Map<String, List<CartItem>> cartItemsByStore = {};

    try {
      // Query the carts collection for the user's document
      QuerySnapshot userDocSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('stores')
          .get();

      // Loop through each store subcollection
      for (var storeDoc in userDocSnapshot.docs) {
        String storeId = storeDoc.id;

        // Query the store subcollection for cart items
        QuerySnapshot storeItemsSnapshot =
            await storeDoc.reference.collection('cart_items').get();

        // Convert each document to CartItem and add to the list for the store
        List<CartItem> storeCartItems = [];
        storeItemsSnapshot.docs.forEach((itemDoc) {
          storeCartItems.add(CartItem.fromSnapshot(itemDoc));
        });

        // Add the list of cart items to the map with storeId as the key
        cartItemsByStore[storeId] = storeCartItems;
      }
    } catch (error) {
      print("Error getting cart items: $error");
    }

    return cartItemsByStore;
  }
}
