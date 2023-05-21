import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_menu.dart';
import 'package:flutter/services.dart';
import 'order_history_page.dart';
import 'edit_profile_page.dart';

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

    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String useremail = "not logged in";
    if (user != null) {
      useremail = user.email!;
    }

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFA500),
            automaticallyImplyLeading: false,
            title: Text("Homepage"),
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
                    child: const CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/attachment_121740866.png'),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildGridItem(context, 'Menu',
                          'assets/images/chef-hat-64.png', const ViewMenu()),
                      _buildGridItem(
                          context,
                          'Order Process',
                          'assets/images/chef-hat-64.png',
                          const OrderHistoryPage()),
                      _buildGridItem(
                          context,
                          'Order History',
                          'assets/images/chef-hat-64.png',
                          const OrderHistoryPage()),
                      _buildGridItem(
                          context,
                          'My Profile',
                          'assets/images/chef-hat-64.png',
                          const EditProfilePage()),
                    ],
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

  Widget _buildGridItem(
      BuildContext context, String label, String imgUrl, constructor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA500),
          minimumSize: const Size(0, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => constructor,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(imgUrl)),
            const SizedBox(
              height: 20,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
