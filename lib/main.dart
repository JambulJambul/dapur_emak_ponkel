import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'inc/dynamic_link_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password.dart';
import 'home_page.dart';
import 'view_menu.dart';
import 'view_custom_menu.dart';
import 'payment_page.dart';
import 'cart.dart';
import 'google_maps_page.dart';
import 'edit_profile_page.dart';
import 'order_history_page.dart';
import 'owner_home_page.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  runApp(MyApp(user: user));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        if (user == null) {
          return const LoginPage();
        } else {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          DocumentReference userRef =
              firestore.collection('users').doc(user?.uid);

          return StreamBuilder<DocumentSnapshot>(
            stream: userRef.snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error retrieving user data');
              } else {
                String? userType = snapshot.data?.get('usertype') as String?;

                if (userType == 'customer') {
                  return const HomePage();
                } else if (userType == 'owner') {
                  return const OwnerHomePage();
                } else {
                  return const LoginPage();
                }
              }
            },
          );
        }
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: 'loginPage',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: 'editProfile',
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfilePage();
          },
        ),
        GoRoute(
          path: 'forgotPassword',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPassword();
          },
        ),
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: 'orderHistory',
          builder: (BuildContext context, GoRouterState state) {
            return const OrderHistoryPage();
          },
        ),
        GoRoute(
          path: 'ownerHome',
          builder: (BuildContext context, GoRouterState state) {
            return const OwnerHomePage();
          },
        ),
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: 'viewMenu',
          builder: (BuildContext context, GoRouterState state) {
            return const ViewMenu();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({Key? key, this.user}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Dapur Emak Ponkel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
    );
  }
}
