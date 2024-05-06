import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayoutAdmin(
      child: Center(
        child: Text(
          'Order Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
