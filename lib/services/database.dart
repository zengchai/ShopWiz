import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // Reference to the users collection
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');
       final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');
  final CollectionReference storesCollection =
      FirebaseFirestore.instance.collection('stores');
        final CollectionReference reviewCollection =
      FirebaseFirestore.instance.collection('reviews');

  Future<void> setUserData(
      String username, String email, String phonenum, String uid) async {
    // Add user data to Firestore
    return await usersCollection.doc(uid).set({
      'username': username,
      'email': email,
      'phonenum': phonenum,
      'uid': uid,
    });
  }

// Get username and email for a specific user
  Future<Map<String, dynamic>> getUserData() async {
    try {
      DocumentSnapshot<Object?> snapshot =
          await usersCollection.doc(uid).get() as DocumentSnapshot<Object?>;
      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        return {
          'username': userData['username'],
          'email': userData['email'],
          'order': userData['orders'],
          'phonenum': userData['phonenum'],
          'uid': userData['uid'],
          'imageUrl': await getProfileImageURL(uid),
        };
      }
      return {};
    } catch (e) {
      print("Error retrieving user data: $e");
      return {};
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserData(
      String uid, String username, String phonenum, String imageUrl) async {
    return await usersCollection.doc(uid).update({
      'username': username,
      'phonenum': phonenum,
      'imageUrl': imageUrl,
      // Add a field to indicate the password was updated
      'passwordUpdated': true,
    });
  }

  // Upload profile image to Firebase Storage
  Future<String?> uploadProfileImage(File image, String uid) async {
    try {
      // Create a reference to the location in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('ProfileImages')
          .child('$uid.jpg');

      // Upload the file to Firebase Storage
      await storageReference.putFile(image);

      // Return the download URL of the uploaded image
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Retrieve profile image URL from Firebase Storage
  Future<String?> getProfileImageURL(String uid) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('ProfileImages')
          .child('$uid.jpg');

      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  // Delete user
  Future<void> deleteUserData() async {
    try {
      await usersCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Error deleting user data');
    }
  }

//Create store
  Future<void> createStore(
    String sname,
    String saddress,
    String imagePath,
  ) async {
    try {
      // Check if the store already exists in Firestore
      QuerySnapshot existingStores = await storesCollection
          .where('sname', isEqualTo: sname) // Checking by store name
          .get();

      if (existingStores.docs.isNotEmpty) {
        print("Store already exists with the name: $sname");
        return; // Exit if the store already exists
      }

      // Check if the image file exists
      Uint8List imageBytes = await _getImageAssetBytes(imagePath);
      if (imageBytes.isEmpty) {
        print("Image file does not exist at path: $imagePath");
        return; // If the file doesn't exist, stop the process
      }

      // Generate a unique store ID
      String sid = storesCollection.doc().id;

      // Upload the image to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('StoreImages/$sid.jpg');
      UploadTask uploadTask = storageRef.putData(imageBytes);

      // Get the download URL for the uploaded image
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String simageUrl = await storageTaskSnapshot.ref.getDownloadURL();

      // Create the store document in Firestore
      await storesCollection.doc(sid).set({
        'sid': sid,
        'sname': sname,
        'saddress': saddress,
        'simageurl': simageUrl,
        'products': [], // Initialize products list to empty
      });
      await updateStoreProduct(); // Update store products after store creation

      print("Store created successfully");
    } catch (e) {
      print("Error creating store: $e");
    }
  }

  Future<void> updateStoreProduct() async {
    try {
      // Get products from productsCollection
      QuerySnapshot productSnapshot = await productsCollection.get();

      // Get all stores
      QuerySnapshot storeSnapshot = await storesCollection.get();

      // Update each store with the latest products
      for (var storeDoc in storeSnapshot.docs) {
        List<Map<String, dynamic>> existingProducts =
            List.from(storeDoc['products']);

        // Update existing products with the latest product list
        for (var productDoc in productSnapshot.docs) {
          String pid = productDoc['pid'] ?? '';
          String pname = productDoc['pname'] ?? '';
          bool found = false;

          // Update product information in existing products list
          for (var existingProduct in existingProducts) {
            if (existingProduct['pid'] == pid) {
              existingProduct['pname'] = pname; // Update product name
              found = true;
              break;
            }
          }
          existingProducts.removeWhere((product) => productSnapshot.docs
              .every((productDoc) => productDoc['pid'] != product['pid']));

          // If the product is not found in existing products, add it
          if (!found) {
            existingProducts.add({
              'pid': pid,
              'pname': pname,
              'storestock': 0, // Initialize storestock to zero
            });
          }
        }

        // Update the store document with the updated products list
        await storeDoc.reference.update({'products': existingProducts});
      }

      print("Store products updated successfully");
    } catch (e) {
      print("Error updating store products: $e");
    }
  }

// retrieve list of store
  Stream<List<Map<String, dynamic>>> getAllStores() {
    try {
      return storesCollection.snapshots().map((querySnapshot) {
        List<Map<String, dynamic>> storeList = [];

        // Loop through each document and add to store list
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            data['sid'] = doc.id;
            storeList.add(data); // Create Store object and add to list
          }
        }

        return storeList; // Return the list of stores
      });
    } catch (e, stackTrace) {
      print('Error retrieving stores: $e');
      print(stackTrace);
      throw e; // Rethrow the error for the caller to handle
    }
  }

  Future<int> getStockForProduct(String storeId, String productId) async {
    try {
      // Retrieve the store document
      DocumentSnapshot<Map<String, dynamic>?> storeSnapshot =
          await FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .get();

      // Check if the store document exists
      if (!storeSnapshot.exists) {
        // Print debug message and return a default stock value
        print('Store document not found for storeId: $storeId');
        return 0;
      }

      // Get the 'products' array from the store document
      List<dynamic>? products = storeSnapshot.data()?['products'];

      // Debug statement to print the product array

      // Check if the 'products' array exists and is not empty
      if (products == null || products.isEmpty) {
        // Print debug message and return a default stock value
        print('Products array is empty or not found in store document');
        return 0;
      }

      // Find the product object within the 'products' array where 'productId' matches 'pid'
      var product = products.firstWhere(
        (product) => product['pid'] == productId,
        orElse: () => null,
      );

      // Check if the product object is found
      if (product == null) {
        // Print debug message and return a default stock value
        print('Product not found in the products array');
        return 0;
      }

      // Retrieve the stock number from the product object
      int stock = (product as Map<String, dynamic>)['storestock'] ?? 0;
      print('Stock: $stock');
      return stock;
    } catch (e) {
      // Print the error message if an exception occurs
      print('Error retrieving stock for product: $e');
      return 0; // Return 0 in case of any errors
    }
  }

  void transferStock(
      String storeId, String productId, int transferQuantity) async {
    try {
      // Get the current store data
      final storeSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();

      if (!storeSnapshot.exists) {
        print('Store document not found for storeId: $storeId');
        return;
      }

      // Get the products array from the store document
      List<dynamic>? products = storeSnapshot.data()?['products'];

      // Check if the 'products' array exists and is not empty
      if (products == null || products.isEmpty) {
        print('Products array is empty or not found in store document');
        return;
      }

      // Find the product object within the 'products' array where 'productId' matches 'pid'
      var product = products.firstWhere(
        (product) => product['pid'] == productId,
        orElse: () => null,
      );

      // Check if the product object is found
      if (product == null) {
        print('Product not found in the products array');
        return;
      }

      // Retrieve the current store stock from the product object
      int currentStoreStock = product['storestock'] ?? 0;

      // Calculate new store stock after transfer
      int newStoreStock = currentStoreStock + transferQuantity;

      // Update the store stock in the product object
      product['storestock'] = newStoreStock;

      // Update the entire products array in the store document
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .update({'products': products});

      // Deduct the transfer quantity from product quantity in the products collection
      final productData = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      int currentProductQuantity = productData['pquantity'] ?? 0;
      int newProductQuantity = currentProductQuantity - transferQuantity;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'pquantity': newProductQuantity});
    } catch (e) {
      print('Error transferring stock: $e');
    }
  }

  Future<Uint8List> _getImageAssetBytes(String assetName) async {
    final ByteData data = await rootBundle.load('assets/images/$assetName');
    final Uint8List bytes = data.buffer.asUint8List();
    return bytes;
  }

  //upload image for product
  Future<String?> uploadProductImage(File image, String pid) async {
    try {
      // Create a reference to the location in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('ProductImages')
          .child(
              '$pid.jpg'); // Use the product ID as the unique identifier for the image

      // Upload the image to Firebase Storage
      await storageReference.putFile(image);

      // Get the download URL of the uploaded image
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading product image: $e');
      return null;
    }
  }
  Future updateReviewData(String productID, String orderID, String userID,
      String review, double rating, String userName) async {
    try {
      var docRef = await reviewCollection.add({
        'userID': uid,
        'orderID': orderID,
        'userName': userName,
        'rating': rating,
        'review': review,
      });

      String docId = docRef.id;
      await productCollection.doc(productID).update({
        'review': FieldValue.arrayUnion([docId]),
      });

      return null; // Return the document ID
    } catch (e) {
      print('Error adding review: $e');
      return null;
    }
  }

  Future<String?> getProductImageURL(String pid) async {
    try {
      if (pid == null || pid.isEmpty) {
        print("Invalid PID");
        return null; // Return null for invalid PID
      }

      Reference storageReference = FirebaseStorage.instance.ref().child(
          'ProductImages/$pid.jpg'); // Using product ID for the image path

      return await storageReference.getDownloadURL(); // Return the image URL
    } catch (e) {
      print('Error getting product image URL: $e');
      return null; // Return null on error
    }
  }

  // Function to create new product
  Future<void> createProduct(
    String pid,
    String pname,
    double pprice,
    int pquantity,
    String pdescription,
    String pimageUrl,
  ) async {
    await productsCollection.doc(pid).set({
      'pid': pid,
      'pname': pname,
      'pprice': pprice,
      'pquantity': pquantity,
      'pdescription': pdescription,
      'pimageUrl': pimageUrl,
    });
    await updateStoreProduct();
  }

  Future<void> editProduct(
    String pid,
    String pname,
    double pprice,
    int pquantity,
    String pdescription,
    String pimageUrl,
  ) async {
    try {
      await productsCollection.doc(pid).update({
        'pid': pid,
        'pname': pname,
        'pprice': pprice,
        'pquantity': pquantity,
        'pdescription': pdescription,
        'pimageUrl': pimageUrl,
      });

      // After editing the product, update the product attribute of each store
      await updateStoreProduct();
    } catch (e) {
      print("Error editing product: $e");
    }
  }

  Future<void> deleteProduct(String pid) async {
    try {
      await productsCollection.doc(pid).delete();
      await updateStoreProduct();
    } catch (e, stackTrace) {
      print('Error deleting product data: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error deleting product data');
    }
  }

  //return products in a list
  Stream<List<Map<String, dynamic>>> retrieveProductList() {
    try {
      // Return a stream that listens to changes in the products collection
      return productsCollection.snapshots().map((querySnapshot) {
        List<Map<String, dynamic>> productList = [];

        // Loop through each document and add to product list
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            data['pid'] = doc.id; // Store the product ID
            productList.add(data); // Add to list
          }
        }

        return productList; // Return the list of products
      });
    } catch (e) {
      print('Error retrieving product list stream: $e');
      // Return an empty stream if there's an error
      return Stream.value([]);
    }
  }

//to retrieve single product
  Future<Map<String, dynamic>> getProductData(String pid) async {
    try {
      if (pid == null || pid.isEmpty) {
        return {}; // Return empty map if PID is invalid
      }

      DocumentSnapshot<Object?> snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(pid)
          .get();

      if (!snapshot.exists) {
        print("Product does not exist: $pid");
        return {}; // Return empty map if the document doesn't exist
      }

      Map<String, dynamic>? productData =
          snapshot.data() as Map<String, dynamic>?;
      if (productData == null) {
        return {}; // Return empty map if product data is null
      }

      String? imageUrl = await getProductImageURL(pid);

      return {
        'pname': productData['pname'],
        'pprice': productData['pprice'],
        'pquantity': productData['pquantity'],
        'pdescription': productData['pdescription'],
        'imageUrl': imageUrl, // The image URL fetched earlier
      };
    } catch (e) {
      print("Error retrieving product data: $e");
      return {}; // Return an empty map on error
    }
  }

  Future<void> updateProductData(int transferQuantity, String productId) async {
    final Map<String, dynamic> productData = await getProductData(productId);
    final int updatedQuantity = productData['pquantity'] - transferQuantity;
    // Update product quantity
    editProduct(
      productId,
      productData['pname'],
      productData['pprice'],
      updatedQuantity,
      productData['pdescription'],
      productData['imageUrl'],
    );
  }
  
}
