import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Center(
        child: Text(
          'Cart Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
