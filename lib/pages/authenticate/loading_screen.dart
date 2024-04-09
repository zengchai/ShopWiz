import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Start a timer to hide the logo after 2 seconds
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isVisible = false;
      });
      // Navigate to the sign-in screen after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/sign_in');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/VitaCare_logo.png', width: 150.0),
            ],
          ),
        ),
      ),
    );
  }
}
