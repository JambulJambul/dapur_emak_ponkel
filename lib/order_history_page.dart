import 'dart:ffi';
import 'package:dapur_emak_ponkel/home_page.dart';
import 'package:go_router/go_router.dart';
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

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          title: const Text('Order History'),
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
            child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1,
                  vertical: size.height * 0.05,
                ),
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('payment')
                          .where("uid", isEqualTo: _auth.currentUser?.uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                        final List<QueryDocumentSnapshot> documents =
                            snapshot.data!.docs;
                        documents.sort((b, a) {
                          final DateFormat dateFormat = DateFormat('MMMM d, y');
                          final DateTime dateA =
                              dateFormat.parse(a['deliveryDate']);
                          final DateTime dateB =
                              dateFormat.parse(b['deliveryDate']);
                          return dateA.compareTo(dateB);
                        });

                        // Extract the data from the snapshot and build your UI here
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            // Access the data for each document and build your row
                            final doc = documents[index];
                            final documentId = doc.id;
                            final date = doc['deliveryDate'];
                            final amount = doc['amount'];
                            DateTime lastDay =
                                DateFormat('MMMM d, y').parse(date);
                            String processStatus = doc['processStatus'];
                            String refundUrl =
                                "https://firebasestorage.googleapis.com/v0/b/dapuremakponkel-2c750.appspot.com/o/asset%2FNicePng_restaurant-icon-png_2018040.png?alt=media&token=779fb08e-112b-42d3-a501-6a7331e9e16a";
                            if (processStatus == 'cancelled') {
                              refundUrl = doc['cancelUrl'] ?? refundUrl;
                            }
                            final List<dynamic> cartItems =
                                doc['cartItems'] as List<dynamic>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (doc.data() is Map<String, dynamic> &&
                                        (doc.data() as Map<String, dynamic>)
                                            .containsKey('numberOfDays')) ...[
                                      const Text(" - "),
                                      Text(
                                        DateFormat.yMMMMd().format(lastDay.add(
                                            Duration(
                                                days: doc['numberOfDays']))),
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                if (processStatus == 'checkingpayment') ...[
                                  const Text(
                                      "Order Status: Checking your payment"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'beforeprocess') ...[
                                  const Text(
                                      "Order Status: Preparing your order"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'processing') ...[
                                  const Text(
                                      "Order Status: Processing your order"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'delivering') ...[
                                  const Text(
                                      "Order Status: Delivering your order"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'ordercompleted') ...[
                                  const Text("Order Status: Food has arrived"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'cancelled') ...[
                                  const Text(
                                      "Order Status: Order has been cancelled"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                                if (processStatus == 'cancelrequested') ...[
                                  const Text("Order Status: Refund in process"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
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
                                  height: 140, // Se
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
                                if (processStatus == 'checkingpayment' ||
                                    processStatus == 'beforeprocess') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: IntrinsicWidth(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Are you sure to cancel your order?",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .grey),
                                                            ),
                                                            child: const Text(
                                                                "No"),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'payment')
                                                                  .doc(
                                                                      documentId)
                                                                  .update({
                                                                'processStatus':
                                                                    'cancelrequested',
                                                              }).then((value) {
                                                                print(
                                                                    'Value updated successfully');
                                                              }).catchError(
                                                                      (error) {
                                                                print(
                                                                    'Error updating value: $error');
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .red),
                                                            ),
                                                            child: const Text(
                                                                "Yes"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text("Cancel Order"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                    ),
                                  )
                                ] else if (processStatus ==
                                    'cancelrequested') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: IntrinsicWidth(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Your refund is in process",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .orange),
                                                            ),
                                                            child: const Text(
                                                                "Ok"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text("Cancel Order"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey),
                                    ),
                                  )
                                ] else if (processStatus == 'cancelled') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: IntrinsicWidth(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 16, 0, 16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Refund Proof",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    ClipRRect(
                                                      child: Image.network(
                                                        refundUrl,
                                                        fit: BoxFit
                                                            .cover, // Adjust the fit mode as needed
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .orange),
                                                            ),
                                                            child: const Text(
                                                                "Ok"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text("Refund Proof"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.orange),
                                    ),
                                  )
                                ] else ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: IntrinsicWidth(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Your order is already processed and cannot be cancelled.",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .orange),
                                                            ),
                                                            child: const Text(
                                                                "Ok"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text("Cancel Order"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.grey),
                                    ),
                                  )
                                ],
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ))));
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
