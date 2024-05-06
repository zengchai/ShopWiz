import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/commons/navBarAdmin.dart';

class BaseLayoutAdmin extends StatelessWidget {
  final Widget child; // Content for the body
  final FloatingActionButton?
      floatingActionButton; // Optional floating action button

  const BaseLayoutAdmin({
    required this.child,
    this.floatingActionButton,
  });
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
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: Consumer<BottomNavigationBarModel>(
        builder: (context, model, _) => CustomBottomAdminNavigationBar(
          selectedIndex: model.selectedIndex,
          onItemTapped: (index) {
            model.updateSelectedIndex(index);
          },
        ),
      ),
    );
  }
}
