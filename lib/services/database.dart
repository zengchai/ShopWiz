import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopwiz/models/user_model.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // Reference to the users collection
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

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
}
