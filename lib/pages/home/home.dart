import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayoutAdmin(
      child: Center(
        child: Text(
          'Home Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
