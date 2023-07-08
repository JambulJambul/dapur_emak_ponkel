import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          automaticallyImplyLeading: false,
          title: const Text('Register Page'),
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
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
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
                      _registerPressed(context);
                    },
                    child: const Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                TextButton(
                  onPressed: () {
                    _loginButton(context);
                  },
                  child: Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _registerPressed(BuildContext context) async {
    String fullName = _fullNameController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    String address = _addressController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (fullName.isEmpty ||
        phoneNumber.isEmpty ||
        address.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Please input correct information'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (password.length < 6) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Password should be at least 6 characters'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    RegExp emailRegExp = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    if (!emailRegExp.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Please enter a valid email address'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user?.uid).set(
        {
          'address': address,
          'fullname': fullName,
          'phonenumber': phoneNumber,
          'email': userCredential.user?.email,
          'uid': userCredential.user?.uid
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Account has been created'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HomePage())),
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('Email address already used.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Exit'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _loginButton(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
