import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page_user/permission_page.dart';
import 'login_page_user/login_page.dart';
import 'splash/splash_page.dart';
import 'home_page_user/cart_provider.dart';
import 'home_page_user/address_provider.dart';

void main() {
  runApp(FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
      ],
      child: MaterialApp(
        title: 'Food Delivery',
        theme: ThemeData(primarySwatch: Colors.orange),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => SplashPage(),
          '/login': (_) => LoginPage(),
          '/permissions': (_) => PermissionPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}




