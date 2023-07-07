import 'dart:ffi';
import 'owner_home_page.dart';
import 'fixed_google_maps_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'google_maps_page.dart';

class OwnerProcessOrderPage extends StatefulWidget {
  const OwnerProcessOrderPage({Key? key}) : super(key: key);

  @override
  State<OwnerProcessOrderPage> createState() => _OwnerProcessOrderPageState();
}

class _OwnerProcessOrderPageState extends State<OwnerProcessOrderPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String selectedSquare = 'Square 1';
  bool isItSquareOne = true;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    DateTime selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    String formattedDate = DateFormat('MMMM d, y').format(selectedDate);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFA500),
          title: const Text('Process Order'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to the homepage when the back button is pressed
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OwnerHomePage(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSquare = 'Square 1';
                                isItSquareOne = true;
                              });
                            },
                            child: Container(
                              height: 40,
                              color: selectedSquare == 'Square 1'
                                  ? const Color.fromARGB(255, 255, 123, 0)
                                  : const Color.fromARGB(255, 255, 198, 112),
                              child: const Center(
                                child: Text(
                                  "One Day",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSquare = 'Square 2';
                                isItSquareOne = false;
                              });
                            },
                            child: Container(
                              height: 40,
                              color: selectedSquare == 'Square 2'
                                  ? const Color.fromARGB(255, 255, 123, 0)
                                  : const Color.fromARGB(255, 255, 198, 112),
                              child: const Center(
                                child: Text(
                                  "Multi Day",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (selectedSquare == 'Square 1') ...[
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 01, 01),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Week'
                        },
                        headerStyle: const HeaderStyle(titleCentered: true),
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          const CircularProgressIndicator();
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 195, 65),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    StreamBuilder<QuerySnapshot>(
                      stream: isItSquareOne == true
                          ? FirebaseFirestore.instance
                              .collection('payment')
                              .where("deliveryDate", isEqualTo: (formattedDate))
                              .where("orderType", isEqualTo: "daily")
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('payment')
                              .where("orderType", isEqualTo: "multiday")
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
                        documents.sort((a, b) {
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
                            final List<dynamic> cartItems =
                                doc['cartItems'] as List<dynamic>;
                            final uid = doc['uid'];
                            final destinationInfo =
                                doc['destinationinformation'];
                            final GeoPoint destinationCoordinate =
                                doc['geoPoint'];
                            String processStatus = doc['processStatus'];
                            String paymentUrl =
                                "https://firebasestorage.googleapis.com/v0/b/dapuremakponkel-2c750.appspot.com/o/asset%2FNicePng_restaurant-icon-png_2018040.png?alt=media&token=779fb08e-112b-42d3-a501-6a7331e9e16a";
                            if (processStatus == 'checkingpayment') {
                              paymentUrl = doc['paymentUrl'] ?? paymentUrl;
                            }
                            ;
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final user = snapshot.data!;
                                final userName =
                                    user['fullname']; // Get the user's name

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Customer Name: $userName",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (doc.data()
                                                is Map<String, dynamic> &&
                                            (doc.data() as Map<String, dynamic>)
                                                .containsKey(
                                                    'numberOfDays')) ...[
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(" - "),
                                          Text(
                                            DateFormat.yMMMMd().format(
                                                lastDay.add(Duration(
                                                    days:
                                                        doc['numberOfDays']))),
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                            child: Wrap(
                                                alignment: WrapAlignment.start,
                                                children: [
                                              const Text("Status: "),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              if (processStatus ==
                                                  'checkingpayment') ...[
                                                const Text(
                                                    "Payment proof received"),
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        16),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(16.0),
                                                                        topRight:
                                                                            Radius.circular(16.0),
                                                                      ),
                                                                      child: Image
                                                                          .network(
                                                                        paymentUrl,
                                                                        fit: BoxFit
                                                                            .cover, // Adjust the fit mode as needed
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    const Text(
                                                                      "Confirm Payment",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                                            ),
                                                                            child:
                                                                                const Text("No"),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              FirebaseFirestore.instance.collection('payment').doc(documentId).update({
                                                                                'processStatus': 'beforeprocess',
                                                                              }).then((value) {
                                                                                print('Value updated successfully');
                                                                              }).catchError((error) {
                                                                                print('Error updating value: $error');
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                                                                            ),
                                                                            child:
                                                                                const Text("Yes"),
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
                                                    child: const Text(
                                                        'View payment proof'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFFA500),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (processStatus ==
                                                  'beforeprocess') ...[
                                                const Text("Payment Confirmed"),
                                                const SizedBox(width: 30),
                                                SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        16,
                                                                        16,
                                                                        16,
                                                                        16),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Text(
                                                                      "Process Order",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                                            ),
                                                                            child:
                                                                                const Text("No"),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              FirebaseFirestore.instance.collection('payment').doc(documentId).update({
                                                                                'processStatus': 'processing',
                                                                              }).then((value) {
                                                                                print('Value updated successfully');
                                                                              }).catchError((error) {
                                                                                print('Error updating value: $error');
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                                                                            ),
                                                                            child:
                                                                                const Text("Yes"),
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
                                                    child: const Text(
                                                        'Process Order'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFFA500),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (processStatus ==
                                                  'processing') ...[
                                                const Text("Processing order"),
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        16,
                                                                        16,
                                                                        16,
                                                                        16),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Text(
                                                                      "Deliver item?",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                                            ),
                                                                            child:
                                                                                const Text("No"),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              FirebaseFirestore.instance.collection('payment').doc(documentId).update({
                                                                                'processStatus': 'delivering',
                                                                              }).then((value) {
                                                                                print('Value updated successfully');
                                                                              }).catchError((error) {
                                                                                print('Error updating value: $error');
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                                                                            ),
                                                                            child:
                                                                                const Text("Yes"),
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
                                                    child: const Text(
                                                        'Deliver item'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFFA500),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (processStatus ==
                                                  'delivering') ...[
                                                const Text("Delivering order"),
                                                const SizedBox(
                                                  width: 50,
                                                ),
                                                SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child:
                                                                IntrinsicWidth(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        16,
                                                                        16,
                                                                        16,
                                                                        16),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Text(
                                                                      "Item has arrived?",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                                            ),
                                                                            child:
                                                                                const Text("No"),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              FirebaseFirestore.instance.collection('payment').doc(documentId).update({
                                                                                'processStatus': 'ordercompleted',
                                                                              }).then((value) {
                                                                                print('Value updated successfully');
                                                                              }).catchError((error) {
                                                                                print('Error updating value: $error');
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style:
                                                                                ButtonStyle(
                                                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                                                                            ),
                                                                            child:
                                                                                const Text("Yes"),
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
                                                    child: const Text(
                                                        'Item has arrived'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFFA500),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (processStatus ==
                                                  'ordercompleted') ...[
                                                const Text("Order completed"),
                                              ]
                                            ]))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Total Price: Rp$amount",
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
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
                                    Text(
                                      "Destination Information: $destinationInfo",
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GoogleMapPageFixed(
                                                markerKey:
                                                    destinationCoordinate,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                            'View Destination on Map'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFA500),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                  ],
                                );
                              },
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
