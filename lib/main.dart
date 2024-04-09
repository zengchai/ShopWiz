import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/pages/cart/cart_page.dart';
import 'package:shopwiz/pages/explore/explore_page.dart';
import 'package:shopwiz/pages/home/home.dart';
import 'package:shopwiz/pages/authenticate/forgot_password.dart';
import 'package:shopwiz/pages/authenticate/sign_in.dart';
import 'package:shopwiz/pages/authenticate/register.dart';
import 'package:shopwiz/pages/authenticate/loading_screen.dart';
import 'package:shopwiz/pages/profile/profile.dart';
import 'package:shopwiz/pages/authenticate/authenticate.dart';

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Check if the route is for login, register, or forgot password screens
    if (route.settings.name == '/sign_in' ||
        route.settings.name == '/register' ||
        route.settings.name == '/forgot_password' ) {
      // Apply a slide transition from right to left for these screens
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    } else {
      // No transition for other screens
      return child;
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BottomNavigationBarModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomNavigationBarModel(),
      child: MaterialApp(
        title: 'ShopWiz',
        theme: ThemeData(
          // Set a custom PageTransitionsTheme
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionsBuilder(),
            TargetPlatform.macOS: CustomPageTransitionsBuilder(),
            TargetPlatform.windows: CustomPageTransitionsBuilder(),
          }),
        ),
        initialRoute: '/loading',
        routes: {
          '/loading': (context) => LoadingScreen(),
          '/sign_in': (context) => SignInScreen(),
          '/register': (context) => RegisterScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/explore': (context) => ExploreScreen(),
          '/cart': (context) => CartScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}
