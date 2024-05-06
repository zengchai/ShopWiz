import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // Reference to the users collection
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

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
    String pcategory,
    String pdescription,
    String pimageUrl,
  ) async {
    await productsCollection.doc(pid).set({
      'pid': pid,
      'pname': pname,
      'pprice': pprice,
      'pquantity': pquantity,
      'pcategory': pcategory,
      'pdescription': pdescription,
      'pimageUrl': pimageUrl,
    });
  }

  // Function to create new product with pic
  Future<void> createProductWithImage(
    File image,
    String pid,
    String pname,
    double pprice,
    int pquantity,
    String pcategory,
    String pdescription,
  ) async {
    try {
      // First, upload the product image and get the download URL
      String? imageUrl = await uploadProductImage(image, pid);

      if (imageUrl == null) {
        throw Exception("Image upload failed");
      }

      // Create the product in Firestore with the obtained image URL
      await createProduct(
        pid,
        pname,
        pprice,
        pquantity,
        pcategory,
        pdescription,
        imageUrl,
      );

      print("Product created successfully");
    } catch (e) {
      print('Error creating product with image: $e');
    }
  }

  Future<void> editProduct(
    String pid,
    String pname,
    double pprice,
    int pquantity,
    String pcategory,
    String pdescription,
    String pimageUrl,
  ) async {
    return await productsCollection.doc(uid).update({
      'pid': pid,
      'pname': pname,
      'pprice': pprice,
      'pquantity': pquantity,
      'pcategory': pcategory,
      'pdescription': pdescription,
      'pimageUrl': pimageUrl,
    });
  }

  Future<void> deleteProduct() async {
    try {
      await productsCollection.doc(uid).delete();
    } catch (e) {
      print('Error deleting product data: $e');
      throw Exception('Error deleting product data');
    }
  }

  //return products in a list
  Future<List<Map<String, dynamic>>> retrieveProductList() async {
    try {
      QuerySnapshot querySnapshot =
          await productsCollection.get(); // Fetch all documents

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
    } catch (e) {
      print('Error retrieving product list: $e');
      return []; // Return empty list if there's an error
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
        'pcategory': productData['pcategory'],
        'pdescription': productData['pdescription'],
        'imageUrl': imageUrl, // The image URL fetched earlier
      };
    } catch (e) {
      print("Error retrieving product data: $e");
      return {}; // Return an empty map on error
    }
  }
}
