import 'package:flutter/material.dart';
import 'package:shopwiz/pages/authenticate/authenticate.dart';
import 'package:shopwiz/pages/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    final authProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    await authProvider.checkUserLoggedIn();
    // Navigate to the appropriate screen based on the user's sign-in status
    if (authProvider.isSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Authenticate(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Authenticate(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
