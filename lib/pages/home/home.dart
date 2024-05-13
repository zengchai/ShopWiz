import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String adminUid = '7aXevcNf3Cahdmk9l5jLRASw5QO2';
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return currentUid == adminUid
        ? BaseLayoutAdmin(
            child: Center(
              child: Text(
                'Home Screen - Admin',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          )
        : BaseLayout(
            child: Center(
              child: Text(
                'Home Screen - User',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          );
  }
}
