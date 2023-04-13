import 'package:flutter/material.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({Key? key}) : super(key: key);

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemWidth = size.width * 0.4;
    final double itemHeight = size.height * 0.2;
    final double itemPadding = size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFA500),
        title: Text('Owner Homepage'),
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
                  _buildGridItem(
                      context, 'Manage Menu', 'assets/images/chef-hat-64.png'),
                  _buildGridItem(
                      context, 'View Report', 'assets/images/chef-hat-64.png'),
                  _buildGridItem(context, 'Process History',
                      'assets/images/chef-hat-64.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String label, String imgUrl) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFA500),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(imgUrl)),
            SizedBox(
              height: 20,
            ),
            Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
