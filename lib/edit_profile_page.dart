import 'package:dapur_emak_ponkel/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_maps_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  String _existingFullName = "Default Name";
  String _existingAddress = "Default Address";
  String _existingPhoneNumber = "Default Number";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    var db = FirebaseFirestore.instance;
    final docRef = db.collection("users").doc(user?.uid);

    try {
      final documentSnapshot = await docRef.get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        _existingFullName = data!['fullname'];
        _existingAddress = data['address'];
        _existingPhoneNumber = data['phonenumber'];
        _fullNameController = TextEditingController(text: _existingFullName);
        _phoneNumberController =
            TextEditingController(text: _existingPhoneNumber);
        _addressController = TextEditingController(text: _existingAddress);
        setState(() {});
      }
    } catch (e) {
      print('Error getting document: $e');
    }
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formPadding = size.width * 0.1;
    final textFieldWidth = size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to the homepage when the back button is pressed
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Name",
                      ),
                      TextField(
                        controller: _fullNameController,
                        decoration:
                            InputDecoration(hintText: _existingFullName),
                      )
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phone Number",
                      ),
                      TextField(
                        controller: _phoneNumberController,
                        decoration:
                            InputDecoration(hintText: _existingPhoneNumber),
                      )
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Address",
                      ),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: _existingAddress,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GoogleMapsPage(
                            mapContext: 'profile',
                          ),
                        ),
                      );
                    },
                    child: const Text('Select Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                SizedBox(
                  width: textFieldWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      _editPressed(context);
                    },
                    child: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      _logoutPressed(context);
                    },
                    child: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _editPressed(BuildContext context) async {
    String fullName = _fullNameController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    String address = _addressController.text.trim();

    try {
      await _firestore.collection("users").doc(user?.uid).update({
        'address': address,
        'fullname': fullName,
        'phonenumber': phoneNumber
      });
    } catch (e) {
      if (e is FirebaseException) {
        print('Firebase error: ${e.message}');
      } else {
        print('Error: $e');
      }
    }
  }

  void _logoutPressed(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
