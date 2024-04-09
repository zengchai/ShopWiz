import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/commons/navBar.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  BaseLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'assets/images/Top_logo.png',
            height: 40.0,
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: Consumer<BottomNavigationBarModel>(
        builder: (context, model, _) => CustomBottomNavigationBar(
          selectedIndex: model.selectedIndex,
          onItemTapped: (index) {
            model.updateSelectedIndex(index);
          },
        ),
      ),
    );
  }
}
