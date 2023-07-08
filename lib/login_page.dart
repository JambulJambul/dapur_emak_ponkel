import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'forgot_password.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'owner_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var errormessage = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFA500),
            automaticallyImplyLeading: false,
            title: const Text('Login Page'),
          ),
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                top: formPadding,
                left: formPadding,
                right: formPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.05),
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/attachment_121740866.png'),
                    ),
                  ),
                  SizedBox(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  SizedBox(
                    width: textFieldWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        _loginPressed(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500)),
                      child: const Text('Login'),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  if (errormessage == 1)
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(
                            8,
                          ),
                          child: Center(
                            child: Text(
                              "Please enter a correct email and password",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )),
                  SizedBox(height: size.height * 0.02),
                  TextButton(
                    onPressed: () {
                      _forgotPasswordButton(context);
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _registerButton(context);
                    },
                    child: Text(
                      'Create New Account',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          // Show a confirmation dialog
          bool shouldClose = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Are you sure you want to exit?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );

          // Return the result of the confirmation dialog
          return shouldClose;
        });
  }

  void _loginPressed(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: username, password: password);
      String uid = userCredential.user!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        String userType = userSnapshot.get('usertype');

        if (userType == 'owner') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OwnerHomePage(),
            ),
          );
        } else if (userType == 'customer') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      errormessage = 1;
    }
  }

  void _forgotPasswordButton(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ForgotPassword()));
  }

  void _registerButton(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RegisterPage()));
  }
}
