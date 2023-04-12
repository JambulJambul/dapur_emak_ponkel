import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Password Reset"),
                                  content: Text(
                                      "An email has been sent to your inbox with instructions to reset your password."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFFFA500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextButton(
                        onPressed: () {
                          // Login logic
                        },
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ]))));
  }

  void _forgotPasswordPressed(BuildContext context) {
    String email = _emailController.text.trim();
  }
}
