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
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFA500),
        title: Text('Login Page'),
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
              SizedBox(height: size.height * 0.05),
              SizedBox(
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFA500)),
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              TextButton(
                onPressed: () {
                  // Forgot Password logic
                },
                child: Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Create New Account logic
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
    );
  }

  void _loginPressed(BuildContext context) {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
  }
}
