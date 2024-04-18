import 'package:flutter/material.dart';
import 'package:shopwiz/shared/wrapper.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start the fade in animation
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Delay the navigation by 2 seconds
    Future.delayed(Duration(seconds: 3), () {
      // Start the fade out animation
      setState(() {
        _opacity = 0.0;
      });

      // Navigate to the next screen after the fade out animation completes
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Wrapper(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 500),
          child: Image.asset('assets/images/VitaCare_logo.png', width: 150.0),
        ),
      ),
    );
  }
}
