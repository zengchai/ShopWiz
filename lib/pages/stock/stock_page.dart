import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseLayoutAdmin(
      child: Center(
        child: Text(
          'Stock Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
