import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/models/users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a user object based on FirebaseUser
  AppUsers? _userFromFirebaseUser(User? user) {
    return user != null ? AppUsers(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<AppUsers?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Register with email and password
  Future registerWithEmailAndPassword(
      String username, String email, String password, String phonenum) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Update user profile with the provided username
    User? user = result.user;
    await result.user!.updateDisplayName(username);

    // Store user data in Firestore
    await DatabaseService(uid: result.user!.uid)
        .setUserData(username, email, phonenum, result.user!.uid);

    return _userFromFirebaseUser(user);
  }

// Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Get the current user
  User getCurrentUser() {
    User user = _auth.currentUser!;
    return user;
  }
}
