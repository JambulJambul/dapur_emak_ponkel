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
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('payment')
                .where("uid", isEqualTo: _auth.currentUser?.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final documents = snapshot.data!.docs;
                orderedItems = documents
                    .map((doc) => _createOrderedItemFromData(
                        doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.builder(
                  itemCount: orderedItems.length,
                  itemBuilder: (context, index) {
                    final item = orderedItems[index];
                    return _buildFoodItemRow(item);
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ));
  }

  orderedItem _createOrderedItemFromData(dynamic data) {
    final Map<String, dynamic>? dataMap = data as Map<String, dynamic>?;

    if (dataMap == null || dataMap['cartItems'] == null) {
      return orderedItem(
        imgUrl: '',
        label: '',
        quantity: 0,
        price: '',
        deliveryDate: '',
        status: '',
      );
    }

    final List<dynamic> cartItems = dataMap['cartItems'] as List<dynamic>;

    if (cartItems.isEmpty) {
      return orderedItem(
        imgUrl: '',
        label: '',
        quantity: 0,
        price: '',
        deliveryDate: '',
        status: '',
      );
    }

    final Map<String, dynamic> firstCartItem =
        cartItems[0] as Map<String, dynamic>;

    if (firstCartItem['imgUrl'] == null ||
        firstCartItem['name'] == null ||
        firstCartItem['quantity'] == null ||
        firstCartItem['price'] == null) {
      return orderedItem(
        imgUrl: '',
        label: '',
        quantity: 0,
        price: '',
        deliveryDate: '',
        status: '',
      );
    }

    final String deliveryDate = dataMap['deliveryDate'] as String? ?? '';
    final String status = dataMap['status'] as String? ?? '';

    return orderedItem(
      imgUrl: firstCartItem['imgUrl'] as String,
      label: firstCartItem['name'] as String,
      quantity: firstCartItem['quantity'] as int,
      price: firstCartItem['price'] as int,
      deliveryDate: deliveryDate,
      status: status,
    );
  }

  Widget _buildFoodItemRow(orderedItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              item.imgUrl,
              width: 70.0,
              height: 70.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(item.label),
          const SizedBox(width: 8.0),
          Text(item.deliveryDate),
        ],
      ),
    );
  }
}
