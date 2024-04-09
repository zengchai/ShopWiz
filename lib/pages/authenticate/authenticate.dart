// import 'package:flutter/material.dart';
// import 'package:shopwiz/pages/authenticate/forgot_password.dart';
// import 'package:shopwiz/pages/authenticate/sign_in.dart';
// import 'package:shopwiz/pages/authenticate/register.dart';
// import 'package:shopwiz/pages/authenticate/loading_screen.dart';

// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// class Authenticate {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case '/loading':
//         return MaterialPageRoute(builder: (_) => LoadingScreen());
//       case '/sign_in':
//         return MaterialPageRoute(builder: (_) => SignInScreen());
//       case '/register':
//         return MaterialPageRoute(builder: (_) => RegisterScreen());
//       case '/forgot_password':
//         return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
//       default:
//         return MaterialPageRoute(builder: (_) => LoadingScreen());
//     }
//   }

//   static bool shouldShowNavigationBar(String routeName) {
//     List<String> excludedRoutes = ['/loading', '/sign_in', '/register', '/forgot_password'];
//     return !excludedRoutes.contains(routeName);
//   }
// }