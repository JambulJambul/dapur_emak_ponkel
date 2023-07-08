import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final String uid = users[index].id;
                final String fullName = userData['fullname'] as String? ?? '';
                final String email = userData['email'] as String? ?? '';
                String userType = userData['usertype'] as String? ?? '';
                List<String?> selectedUserTypes =
                    List.filled(users.length, null);
                return ListTile(
                  title: Text(fullName),
                  subtitle: Text(email),
                  trailing: DropdownButton<String>(
                    value: selectedUserTypes[
                        index], // Use the selected user type from the list
                    onChanged: (newValue) {
                      setState(() {
                        selectedUserTypes[index] =
                            newValue; // Update the selected user type in the list
                      });
                      _updateUserType(uid, newValue!);
                    },
                    items: <String>['Customer', 'Admin', 'User']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value.toLowerCase(),
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error: Unable to fetch users');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> _updateUserType(String uid, String userType) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'usertype': userType});
      // Show a success message or perform any additional actions
    } catch (e) {
      // Handle error
      print('Error updating user type: $e');
    }
  }
}
