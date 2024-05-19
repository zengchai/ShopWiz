import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopwiz/pages/authenticate/sign_in.dart';
import 'package:shopwiz/pages/authenticate/register.dart';
import 'package:shopwiz/pages/home/home.dart';


class CustomAuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isRegistering = false;

  bool get isSignedIn => _isSignedIn;
  bool get isRegistering => _isRegistering;

  void toggleRegistering(bool value) {
    _isRegistering = value;
    notifyListeners();
  }

  //THESE are to make sure the account still logged in even user go to android home
  Future<void> checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool('isSignedIn') ?? false;
    notifyListeners();
  }

  Future<void> signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = true;
    await prefs.setBool('isSignedIn', true);
    await prefs.setBool('isRegistering', true);
    notifyListeners();
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = false;
    await prefs.setBool('isSignedIn', false);
    notifyListeners();
  }
}

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    //To prevent go back to sign in screenby clicking go back to android home
    if (authProvider.isSignedIn) {
      return HomeScreen();
    } else if (authProvider.isSignedIn && !authProvider.isRegistering) {
      return HomeScreen();
    } else if (authProvider.isRegistering) {
      return RegisterScreen();
    } else {
      return SignInScreen();
    }
  }
}
