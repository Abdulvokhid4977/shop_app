import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route_transition.dart';
import '../provider/auth.dart';
import '../provider/orders.dart';
import '../provider/products.dart';
import '../provider/cart.dart';
import '../screens/products_overview_page.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousItems) => Products(
              auth.token,auth.userId, previousItems == null ? [] : previousItems.items),
          create: (ctx) => Products('','', []),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
              auth.token, auth.userId, previousOrders == null ? [] : previousOrders.orders),
          create: (ctx) => Orders('','' ,[]),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop App',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
            },
            ),
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
          ),
          home:
          auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapshot) =>
            authResultSnapshot.connectionState ==
                ConnectionState.waiting
                ? SplashScreen()
                : const AuthScreen(),
          ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProduct.routeName: (ctx) => const EditProduct(),
          },
        ),
      ),
    );
  }
}
