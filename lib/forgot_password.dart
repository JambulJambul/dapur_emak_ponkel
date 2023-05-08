import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFA500),
          automaticallyImplyLeading: false,
          title: Text('Forgot Password'),
        ),
        body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
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
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      SizedBox(
                        width: textFieldWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            _forgotPasswordPressed(context);
                          },
                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFA500),
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
                    ]))));
  }

  void _forgotPasswordPressed(BuildContext context) async {
    String email = _emailController.text.trim();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Password reset email has been sent'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Exit'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Email not found'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Exit'),
              ),
            ],
          );
        },
      );
    }
  }

  void _loginButton(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
