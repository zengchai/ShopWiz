import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Center(
        child: Text(
          'Home Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
