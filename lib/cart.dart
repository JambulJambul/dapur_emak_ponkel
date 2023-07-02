import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'google_maps_page.dart';
import 'edit_profile_page.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String orderType;
  final DateTime deliveryDay;
  final int? numberOfDays;
  // ignore: prefer_const_constructors_in_immutables
  CartPage(
      {Key? key,
      required this.cartItems,
      required this.orderType,
      required this.deliveryDay,
      this.numberOfDays})
      : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItem {
  final String label;
  final String imgUrl;
  final String itemDesc;
  int quantity;
  int price;
  CartItem({
    required this.imgUrl,
    required this.itemDesc,
    required this.label,
    required this.quantity,
    required this.price,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': label,
      'price': price,
      'quantity': quantity,
      'imgUrl': imgUrl,
    };
  }
}

class _CartPageState extends State<CartPage> {
  int bulkQuantity = 10;
  late GeoPoint destinationCoordinate;
  late double markerLatitude;
  late double markerLongtitude;
  TextEditingController _addressInfoController = TextEditingController();
  String existingAddressInfo = "";
  bool coordinateUpdated = false;

  void _checkPersonalAddress(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('addressgeolocation')) {
        // 'addressgeolocation' field exists in the user document
        destinationCoordinate = userData['addressgeolocation'] as GeoPoint;
        setState(() {
          existingAddressInfo = userData['address'];
        });
        // Perform any further operations with the latitude and longitude values
        // or use them for reverse geocoding if desired.
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
                child: AlertDialog(
                  title: const Text('Address coordinate not found'),
                  content: const Text('Please update your address coordinate'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Go to profile page'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const EditProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
                onWillPop: () async {
                  return false; // Disable back button press
                });
          },
        );
      }
    }
  }

  void handleGeoPointSelected(GeoPoint geoPoint) {
    destinationCoordinate = geoPoint;
    coordinateUpdated = true;
  }

  List<CartItem> _cartItems = [];
  @override
  void initState() {
    super.initState();
    _cartItems = widget.cartItems;
    _checkPersonalAddress(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.6;
    final textFieldWidth = size.width * 0.8;
    DateTime lastDate =
        widget.deliveryDay.add(Duration(days: widget.numberOfDays ?? 0));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: const Color(0xFFFFA500),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1,
              vertical: size.height * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                item.imgUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (widget.orderType == "daily") ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Rp${item.price * item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  if (item.quantity > 0) {
                                                    item.quantity--;
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  item.quantity++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ] else ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Rp${item.price} x ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          '= Rp${item.price * item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.05),
                if (widget.orderType == "event")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Number of orders: "),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (bulkQuantity > 10) {
                              bulkQuantity--;
                              for (final item in _cartItems) {
                                item.quantity = bulkQuantity;
                              }
                            }
                          });

                          if (bulkQuantity == 10) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content:
                                      Text("10 is the minimum amount of order"),
                                );
                              },
                            );
                          }
                        },
                      ),
                      Text(
                        '$bulkQuantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            bulkQuantity++;
                            for (final item in _cartItems) {
                              item.quantity = bulkQuantity;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                if (widget.numberOfDays == null) ...[
                  Text(
                      'Order Date: ${DateFormat.yMMMMd().format(widget.deliveryDay)}'),
                  SizedBox(height: size.height * 0.02),
                  Text('Total Price: Rp${_calculateTotalPrice()}'),
                ],
                if (widget.numberOfDays != null) ...[
                  Text(
                      'First Date: ${DateFormat.yMMMMd().format(widget.deliveryDay)}'),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text('Last Date: ${DateFormat.yMMMMd().format(lastDate)}'),
                  SizedBox(height: size.height * 0.02),
                  Text('Total Price: Rp${_calculateTotalMultiPrice()}'),
                ],
                SizedBox(height: size.height * 0.05),
                SizedBox(
                  width: textFieldWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Address Details: ",
                      ),
                      TextField(
                        controller: _addressInfoController,
                        decoration:
                            InputDecoration(hintText: existingAddressInfo),
                      )
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  child: Text(coordinateUpdated == false
                      ? "Pin is using your address"
                      : "Pin has been updated"),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: textFieldWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GoogleMapsPage(
                            mapContext: 'destination',
                            onGeoPointSelected: handleGeoPointSelected,
                          ),
                        ),
                      );
                    },
                    child: const Text('Pinpoint Map'),
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
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      print(destinationCoordinate.latitude.toString());
                      print(destinationCoordinate.longitude.toString());
                      String addressInfo = _addressInfoController.text.trim();
                      if (addressInfo.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Address details missing'),
                              content: const Text(
                                  'Please insert the detail of your destination address'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        if (widget.numberOfDays == null) {
                          [
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  cartItems: _cartItems,
                                  totalPrice: _calculateTotalPrice(),
                                  deliveryDay: widget.deliveryDay,
                                  orderType: widget.orderType,
                                  destinationCoordinate: destinationCoordinate,
                                  destinationInformation:
                                      _addressInfoController.text.trim(),
                                ),
                              ),
                            )
                          ];
                        } else {
                          [
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  cartItems: _cartItems,
                                  totalPrice: _calculateTotalMultiPrice(),
                                  deliveryDay: widget.deliveryDay,
                                  numberOfDays: widget.numberOfDays,
                                  orderType: widget.orderType,
                                  destinationCoordinate: destinationCoordinate,
                                  destinationInformation:
                                      _addressInfoController.text.trim(),
                                ),
                              ),
                            )
                          ];
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500)),
                    child: const Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  int _calculateTotalPrice() {
    int totalPrice = 0;
    for (final item in _cartItems) {
      totalPrice += item.price * item.quantity;
    }
    return totalPrice;
  }

  int _calculateTotalMultiPrice() {
    int totalPrice = 0;
    for (final item in _cartItems) {
      totalPrice += item.price * item.quantity * ((widget.numberOfDays! + 1));
    }
    return totalPrice;
  }
}
