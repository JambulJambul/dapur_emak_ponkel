import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: formPadding,
            left: formPadding,
            right: formPadding,
            bottom: size.height - (appBarHeight * 2) - (formPadding * 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05),
              SizedBox(
                width: textFieldWidth,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
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
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginPressed(BuildContext context) {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
  }
}
