import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemWidth = size.width * 0.4;
    final double itemHeight = size.height * 0.2;
    final double itemPadding = size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFA500),
        title: Text('Homepage'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.05,
          ),
          child: Column(
            children: [
              SizedBox(
                height: size.width * 0.5,
                width: size.width * 0.5,
                child: CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/attachment_121740866.png'),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(context, 'Button 1', Colors.blue),
                  _buildGridItem(context, 'Button 2', Colors.red),
                  _buildGridItem(context, 'Button 3', Colors.green),
                  _buildGridItem(context, 'Button 4', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String label, Color color) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: Size(0, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(label),
          ));
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
