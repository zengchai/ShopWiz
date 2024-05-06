import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';

class CustomBottomAdminNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomAdminNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _CustomBottomAdminNavigationBarState createState() =>
      _CustomBottomAdminNavigationBarState();
}

class _CustomBottomAdminNavigationBarState extends State<CustomBottomAdminNavigationBar> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Set type to fixed
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Stock',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex:
          Provider.of<BottomNavigationBarModel>(context).selectedIndex,
      selectedItemColor:
          Color.fromARGB(255, 108, 74, 255), // Set selected icon color to blue
      unselectedItemColor: Colors.black, // Set unselected icon color to black
      onTap: (index) {
        Provider.of<BottomNavigationBarModel>(context, listen: false)
            .updateSelectedIndex(index);
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/stock');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/order');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
    );
  }
}
