import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class orderedItem {
  final String label;
  final String imgUrl;
  int quantity;
  var price;
  String deliveryDate;
  String status;
  orderedItem({
    required this.imgUrl,
    required this.label,
    required this.quantity,
    required this.price,
    required this.deliveryDate,
    required this.status,
  });
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<orderedItem> orderedItems = [];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          title: const Text('Order History'),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1,
            vertical: size.height * 0.05,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('payment')
                .where("uid", isEqualTo: _auth.currentUser?.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        'assets/images/NicePng_restaurant-icon-png_2018040.png', // Replace with the path to your image
                        width: 150.0,
                        height: 150.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'You have not made any order',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ],
                ));
              }

              // Extract the data from the snapshot and build your UI here
              final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
              return SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height, // Set a fixed height for the ListView.builder
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    // Access the data for each document and build your row
                    final doc = documents[index];
                    final date = doc['deliveryDate'];
                    final amount = doc['amount'];
                    final List<dynamic> cartItems =
                        doc['cartItems'] as List<dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Total Price: Rp$amount",
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context)
                              .size
                              .width, // Set the width to the screen width
                          height: 150, // Se
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              if (item is Map<String, dynamic>) {
                                return _buildFoodItemRow(item);
                              }
                              return const SizedBox
                                  .shrink(); // Return an empty SizedBox if item is not a valid map
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ));
  }

  Widget _buildFoodItemRow(Map<String, dynamic> item) {
    final String name = item['name'] as String;
    final int quantity = item['quantity'] as int;
    final String imgUrl = item['imgUrl'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imgUrl,
              width: 70.0,
              height: 70.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Amount: $quantity',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
