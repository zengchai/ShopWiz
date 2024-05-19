import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/firebase_options.dart';
import 'package:shopwiz/pages/authenticate/authenticate.dart';
import 'package:shopwiz/pages/authenticate/forgot_password.dart';
import 'package:shopwiz/pages/authenticate/register.dart';
import 'package:shopwiz/pages/authenticate/sign_in.dart';
import 'package:shopwiz/pages/cart/cart_page.dart';
import 'package:shopwiz/pages/home/home.dart';
import 'package:shopwiz/pages/order/order_page.dart';
import 'package:shopwiz/pages/product/product.dart';
import 'package:shopwiz/pages/product/stock_page.dart';
import 'package:shopwiz/pages/profile/profile.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/pages/home/productdetails.dart';
import 'package:shopwiz/shared/loading_screen.dart';
import 'package:shopwiz/shared/wrapper.dart';

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
    if (route.settings.name == '/register' ||
        route.settings.name == '/forgot_password') {
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    print('Main function is run');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final DatabaseService _dbService = DatabaseService(uid: '');

  List<Map<String, dynamic>> stores = [
    {
      'name': 'Vitacare Taman Impian Emas',
      'address': '135/2 Jalan Impiana Emas',
      'imagePath': 'VitacareTamanImpianEmas.png',
    },
    {
      'name': 'Vitacare Taman Pelangi',
      'address': '332/21 Jalan Pelangi, 5/6 Taman Pelangi',
      'imagePath': 'VitacareTamanPelangi.png',
    },
    {
      'name': 'Vitacare Taman Universiti',
      'address': '6 Blok 3/2 Taman Universiti',
      'imagePath': 'VitacareTamanUniversiti.png',
    },
  ];

  for (var store in stores) {
    await _dbService.createStore(
      store['name'],
      store['address'],
      store['imagePath'],
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // to prevent user logout when restart device
            create: (_) => CustomAuthProvider()..checkUserLoggedIn()),
        ChangeNotifierProvider(create: (_) => BottomNavigationBarModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavigationBarModel()),
      ],
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
          '/authenticate': (context) => Authenticate(),
          '/wrapper': (context) => Wrapper(),
          '/loading': (context) => LoadingScreen(),
          '/sign_in': (context) => SignInScreen(),
          '/register': (context) => RegisterScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/explore': (context) => OrderScreen(),
          '/cart': (context) => CartScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          // Provide the productId when navigating to ExploreScreen
          '/pdetails': (context) {
            final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            final String productId = args['productId'];
            return ProductDetailsScreen(productId: productId, userId: '',);
          },
          // '/order': (context) => OrderScreen(),
          '/product': (context) => ProductScreen(),
          '/stock': (context) => StockScreen(),
        },
      ),
    );
  }
}
