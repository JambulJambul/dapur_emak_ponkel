import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'cart.dart';

class ViewCustomMenu extends StatefulWidget {
  const ViewCustomMenu({Key? key}) : super(key: key);

  @override
  State<ViewCustomMenu> createState() => _ViewCustomMenuState();
}

class _ViewCustomMenuState extends State<ViewCustomMenu> {
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _lastDay = DateTime.now().add(const Duration(days: 2));
  List<CartItem> cartItems = [];
  List<CartItem> mainCourse = [];
  List<CartItem> menuPackage = [];
  List<CartItem> sideDish = [];
  List<CartItem> riceOption = [];
  List<bool> mainCourseItemStates = [];
  List<bool> menuPackageItemStates = [];
  List<bool> sideDishItemStates = [];
  List<bool> riceOptionItemStates = [];
  String selectedSquare = 'Square 1';
  int numberOfDays = 2;

  Widget _buildOneDayCards() {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.4;
    DateTime selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar(
          firstDay: DateTime.now().add(const Duration(days: 1)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {CalendarFormat.week: 'Week'},
          headerStyle: const HeaderStyle(titleCentered: true),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _lastDay = selectedDay.add(const Duration(days: 1));
              Duration difference = _lastDay!.difference(_selectedDay!);
              numberOfDays = difference.inDays + 1;
              print(numberOfDays);
            });
            const CircularProgressIndicator();
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
        const Row(
          children: [
            Text(
              "Main Course",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "• Select 1",
            ),
          ],
        ),
        const SizedBox(height: 10),
        Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('foodmenu')
                    .where("eventmenu", isEqualTo: true)
                    .where("eventtype", isEqualTo: "maincourse")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          'Menu is not available for this date',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (mainCourseItemStates.isEmpty) {
                      mainCourseItemStates = List.generate(
                          snapshot.data!.docs.length, (index) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = documents[index];
                        String label = doc['menutitle'];
                        String imgUrl = doc['imageurl'];
                        String itemDesc = doc['menudesc'];
                        var price = doc['price'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 2,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    mainCourseItemStates[
                                                            index] =
                                                        !mainCourseItemStates[
                                                            index];
                                                    if (mainCourseItemStates[
                                                        index]) {
                                                      CartItem cartItem =
                                                          CartItem(
                                                        label: label,
                                                        imgUrl: imgUrl,
                                                        itemDesc: itemDesc,
                                                        quantity: 10,
                                                        price: price,
                                                      );
                                                      cartItems.add(cartItem);
                                                      mainCourse.add(cartItem);
                                                    } else {
                                                      cartItems.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                      mainCourse.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  mainCourseItemStates[index]
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                      color:
                                                          mainCourseItemStates[
                                                                  index]
                                                              ? Colors.white
                                                              : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ButtonStyle(
                                                    side:
                                                        const MaterialStatePropertyAll(
                                                            BorderSide(
                                                      color: Colors.orange,
                                                      width: 1.5,
                                                      strokeAlign: 1,
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) {
                                                      if (mainCourseItemStates[
                                                              index] ==
                                                          true) {
                                                        return Colors.orange;
                                                      } else if (mainCourseItemStates[
                                                              index] ==
                                                          false) {
                                                        return Colors.white;
                                                      }
                                                      return Colors.white;
                                                    }))),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.network(
                                                              imgUrl,
                                                              height: 200,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Text(
                                                              label,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              itemDesc,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })),
        const SizedBox(height: 10),
        const Row(
          children: [
            Text(
              "Side Dish",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "• Select up to 2",
            ),
          ],
        ),
        Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('foodmenu')
                    .where("eventmenu", isEqualTo: true)
                    .where("eventtype", isEqualTo: "sidedish")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          'Menu is not available for this date',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (sideDishItemStates.isEmpty) {
                      sideDishItemStates = List.generate(
                          snapshot.data!.docs.length, (index) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = documents[index];
                        String label = doc['menutitle'];
                        String imgUrl = doc['imageurl'];
                        String itemDesc = doc['menudesc'];
                        var price = doc['price'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 2,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    sideDishItemStates[index] =
                                                        !sideDishItemStates[
                                                            index];
                                                    if (sideDishItemStates[
                                                        index]) {
                                                      CartItem cartItem =
                                                          CartItem(
                                                        label: label,
                                                        imgUrl: imgUrl,
                                                        itemDesc: itemDesc,
                                                        quantity: 10,
                                                        price: price,
                                                      );
                                                      cartItems.add(cartItem);
                                                      sideDish.add(cartItem);
                                                    } else {
                                                      cartItems.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                      sideDish.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  sideDishItemStates[index]
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                      color: sideDishItemStates[
                                                              index]
                                                          ? Colors.white
                                                          : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ButtonStyle(
                                                    side:
                                                        const MaterialStatePropertyAll(
                                                            BorderSide(
                                                      color: Colors.orange,
                                                      width: 1.5,
                                                      strokeAlign: 1,
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) {
                                                      if (sideDishItemStates[
                                                              index] ==
                                                          true) {
                                                        return Colors.orange;
                                                      } else if (sideDishItemStates[
                                                              index] ==
                                                          false) {
                                                        return Colors.white;
                                                      }
                                                      return Colors.white;
                                                    }))),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.network(
                                                              imgUrl,
                                                              height: 200,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Text(
                                                              label,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              itemDesc,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })),
        const SizedBox(height: 10),
        const Row(
          children: [
            Text(
              "Rice Option",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "• Select 1",
            ),
          ],
        ),
        Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('foodmenu')
                    .where("eventmenu", isEqualTo: true)
                    .where("eventtype", isEqualTo: "riceoption")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          'Menu is not available for this date',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (riceOptionItemStates.isEmpty) {
                      riceOptionItemStates = List.generate(
                          snapshot.data!.docs.length, (index) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = documents[index];
                        String label = doc['menutitle'];
                        String imgUrl = doc['imageurl'];
                        String itemDesc = doc['menudesc'];
                        var price = doc['price'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 2,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    riceOptionItemStates[
                                                            index] =
                                                        !riceOptionItemStates[
                                                            index];
                                                    if (riceOptionItemStates[
                                                        index]) {
                                                      CartItem cartItem =
                                                          CartItem(
                                                        label: label,
                                                        imgUrl: imgUrl,
                                                        itemDesc: itemDesc,
                                                        quantity: 10,
                                                        price: price,
                                                      );
                                                      cartItems.add(cartItem);
                                                      riceOption.add(cartItem);
                                                    } else {
                                                      cartItems.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                      riceOption.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  riceOptionItemStates[index]
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                      color:
                                                          riceOptionItemStates[
                                                                  index]
                                                              ? Colors.white
                                                              : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ButtonStyle(
                                                    side:
                                                        const MaterialStatePropertyAll(
                                                            BorderSide(
                                                      color: Colors.orange,
                                                      width: 1.5,
                                                      strokeAlign: 1,
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) {
                                                      if (riceOptionItemStates[
                                                              index] ==
                                                          true) {
                                                        return Colors.orange;
                                                      } else if (riceOptionItemStates[
                                                              index] ==
                                                          false) {
                                                        return Colors.white;
                                                      }
                                                      return Colors.white;
                                                    }))),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.network(
                                                              imgUrl,
                                                              height: 200,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Text(
                                                              label,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              itemDesc,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })),
        SizedBox(height: size.height * 0.05),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () {
              _checkOneDaySubmit(context, _selectedDay!, formattedDate);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500)),
            child: const Text('Add To Cart'),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiDayCards() {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.4;
    DateTime selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    DateTime selectedLastDate =
        DateTime(_lastDay!.year, _lastDay!.month, _lastDay!.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String formattedLastDate =
        DateFormat('yyyy-MM-dd').format(selectedLastDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA500),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Choose First Date",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ))),
            SizedBox(
              width: size.width * 0.05,
            ),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Select Date',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TableCalendar(
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month'
                          },
                          headerStyle: const HeaderStyle(titleCentered: true),
                          firstDay: DateTime.now().add(const Duration(days: 1)),
                          lastDay:
                              DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _selectedDay ?? DateTime.now(),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _lastDay =
                                  selectedDay.add(const Duration(days: 1));
                              Duration difference =
                                  _lastDay!.difference(_selectedDay!);
                              numberOfDays = difference.inDays + 1;
                              print(numberOfDays);
                            });
                            Navigator.pop(
                                context); // Close the dialog after selecting a date
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
                      ],
                    ),
                  ),
                ),
              ),
              child: Text(
                _selectedDay != null
                    ? DateFormat('yMMMMd').format(_selectedDay!)
                    : 'No date selected',
                style: const TextStyle(
                  color: Colors.orange,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.orange,
                  width: 1.5,
                  strokeAlign: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA500),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Choose Last Date",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ))),
            SizedBox(
              width: size.width * 0.05,
            ),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Select Date',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TableCalendar(
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month'
                          },
                          headerStyle: const HeaderStyle(titleCentered: true),
                          firstDay: selectedDate.add(const Duration(days: 1)),
                          lastDay:
                              DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _lastDay ?? DateTime.now(),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _lastDay = selectedDay;
                              Duration difference =
                                  _lastDay!.difference(_selectedDay!);
                              numberOfDays = difference.inDays + 1;
                              print(numberOfDays);
                            });
                            Navigator.pop(
                                context); // Close the dialog after selecting a date
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
                      ],
                    ),
                  ),
                ),
              ),
              child: Text(
                _lastDay != null
                    ? DateFormat('yMMMMd').format(_lastDay!)
                    : 'No date selected',
                style: const TextStyle(
                  color: Colors.orange,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.orange,
                  width: 1.5,
                  strokeAlign: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              "Package Option",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "• Select 1",
            ),
          ],
        ),
        Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('foodmenu')
                    .where("eventmenu", isEqualTo: true)
                    .where("eventtype", isEqualTo: "multiday")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          'Menu is not available for this date',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (menuPackageItemStates.isEmpty) {
                      menuPackageItemStates = List.generate(
                          snapshot.data!.docs.length, (index) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = documents[index];
                        String label = doc['menutitle'];
                        String imgUrl = doc['imageurl'];
                        String itemDesc = doc['menudesc'];
                        var price = doc['price'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 2,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    menuPackageItemStates[
                                                            index] =
                                                        !menuPackageItemStates[
                                                            index];
                                                    if (menuPackageItemStates[
                                                        index]) {
                                                      CartItem cartItem =
                                                          CartItem(
                                                        label: label,
                                                        imgUrl: imgUrl,
                                                        itemDesc: itemDesc,
                                                        quantity: 10,
                                                        price: price,
                                                      );
                                                      cartItems.add(cartItem);
                                                      menuPackage.add(cartItem);
                                                    } else {
                                                      cartItems.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                      menuPackage.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  menuPackageItemStates[index]
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                      color:
                                                          menuPackageItemStates[
                                                                  index]
                                                              ? Colors.white
                                                              : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ButtonStyle(
                                                    side:
                                                        const MaterialStatePropertyAll(
                                                            BorderSide(
                                                      color: Colors.orange,
                                                      width: 1.5,
                                                      strokeAlign: 1,
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) {
                                                      if (menuPackageItemStates[
                                                              index] ==
                                                          true) {
                                                        return Colors.orange;
                                                      } else if (menuPackageItemStates[
                                                              index] ==
                                                          false) {
                                                        return Colors.white;
                                                      }
                                                      return Colors.white;
                                                    }))),
                                            SizedBox(
                                              width: size.width * 0.05,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.network(
                                                              imgUrl,
                                                              height: 200,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Text(
                                                              label,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              itemDesc,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })),
        const SizedBox(height: 10),
        const Row(
          children: [
            Text(
              "Rice Option",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "• Select 1",
            ),
          ],
        ),
        Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('foodmenu')
                    .where("eventmenu", isEqualTo: true)
                    .where("eventtype", isEqualTo: "riceoption")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          'Menu is not available for this date',
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ));
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;
                    if (riceOptionItemStates.isEmpty) {
                      riceOptionItemStates = List.generate(
                          snapshot.data!.docs.length, (index) => false);
                    }
                    return ListView.builder(
                      shrinkWrap: true, // Add this line
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = documents[index];
                        String label = doc['menutitle'];
                        String imgUrl = doc['imageurl'];
                        String itemDesc = doc['menudesc'];
                        var price = doc['price'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  fit: FlexFit.loose,
                                  flex: 1,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16.0),
                                        bottomLeft: Radius.circular(16.0),
                                      ),
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 2,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    riceOptionItemStates[
                                                            index] =
                                                        !riceOptionItemStates[
                                                            index];
                                                    if (riceOptionItemStates[
                                                        index]) {
                                                      CartItem cartItem =
                                                          CartItem(
                                                        label: label,
                                                        imgUrl: imgUrl,
                                                        itemDesc: itemDesc,
                                                        quantity: 10,
                                                        price: price,
                                                      );
                                                      cartItems.add(cartItem);
                                                      riceOption.add(cartItem);
                                                    } else {
                                                      cartItems.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                      riceOption.removeWhere(
                                                          (cartItem) =>
                                                              cartItem.label ==
                                                              label);
                                                    }
                                                  });
                                                },
                                                child: Text(
                                                  riceOptionItemStates[index]
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                      color:
                                                          riceOptionItemStates[
                                                                  index]
                                                              ? Colors.white
                                                              : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ButtonStyle(
                                                    side:
                                                        const MaterialStatePropertyAll(
                                                            BorderSide(
                                                      color: Colors.orange,
                                                      width: 1.5,
                                                      strokeAlign: 1,
                                                    )),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                (states) {
                                                      if (riceOptionItemStates[
                                                              index] ==
                                                          true) {
                                                        return Colors.orange;
                                                      } else if (riceOptionItemStates[
                                                              index] ==
                                                          false) {
                                                        return Colors.white;
                                                      }
                                                      return Colors.white;
                                                    }))),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.network(
                                                              imgUrl,
                                                              height: 200,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Text(
                                                              label,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              itemDesc,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                })),
        SizedBox(height: size.height * 0.05),
        SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () {
              _checkMultiDaySubmit(
                  context, _selectedDay!, _lastDay!, formattedDate);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500)),
            child: const Text('Add To Cart'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width * 0.4;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Event Catering'),
          backgroundColor: const Color(0xFFFFA500),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.1,
              vertical: size.height * 0.05,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            _checkItemState();
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
                            _checkItemState();
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
                if (selectedSquare == 'Square 1')
                  _buildOneDayCards()
                else if (selectedSquare == 'Square 2')
                  _buildMultiDayCards(),
              ],
            ),
          ),
        ));
  }

  void _checkItemState() {
    setState(() {
      mainCourseItemStates =
          List.generate(mainCourseItemStates.length, (index) => false);
      sideDishItemStates =
          List.generate(sideDishItemStates.length, (index) => false);
      riceOptionItemStates =
          List.generate(riceOptionItemStates.length, (index) => false);
      menuPackageItemStates =
          List.generate(menuPackageItemStates.length, (index) => false);
      cartItems.clear();
      menuPackage.clear();
      mainCourse.clear();
      sideDish.clear();
      riceOption.clear();
    });
  }

  void _checkOneDaySubmit(
      BuildContext context, DateTime selectedDay, String formattedDate) async {
    DateTime selectedDate = selectedDay;
    DateTime currentDate = DateTime.now();

    if (selectedDay.isBefore(currentDate)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Date'),
            content:
                const Text('Order must be made 1 day before the delivery date'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } /* else if (cartItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please select Item'),
            content: const Text('You have not selected any item'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } */
    else if (mainCourse.length != 1 ||
        sideDish.length > 2 ||
        riceOption.length != 1 ||
        cartItems.isEmpty) {
      String title = 'Item amount incorrect';
      String content = '';
      if (cartItems.isEmpty) {
        content += 'You have not selected any item.\n\n';
      }
      if (mainCourse.length != 1) {
        content += 'Please select 1 main course.\n';
      }
      if (sideDish.length > 2) {
        content += 'Please select no more than 2 side dishes.\n';
      }
      if (riceOption.length != 1) {
        content += 'Please select 1 rice option.\n';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CartPage(
            orderType: "daily",
            cartItems: cartItems,
            deliveryDay: selectedDate,
          ),
        ),
      );
    }
  }

  void _checkMultiDaySubmit(BuildContext context, DateTime selectedDay,
      DateTime lastDay, String formattedDate) async {
    DateTime selectedDate = selectedDay;
    DateTime currentDate = DateTime.now();

    if (selectedDay.isBefore(currentDate)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Date'),
            content:
                const Text('Order must be made 1 day before the delivery date'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } /* else if (cartItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please select Item'),
            content: const Text('You have not selected any item'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } */
    else if (menuPackage.length != 1 ||
        riceOption.length != 1 ||
        cartItems.isEmpty) {
      String title = 'Item amount incorrect';
      String content = '';
      if (cartItems.isEmpty) {
        content += 'You have not selected any item.\n\n';
      }
      if (menuPackage.length != 1) {
        content += 'Please select 1 package.\n';
      }
      if (riceOption.length != 1) {
        content += 'Please select 1 rice option.\n';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _checkItemState();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CartPage(
              cartItems: cartItems,
              orderType: "multiday",
              deliveryDay: selectedDate,
              numberOfDays: numberOfDays),
        ),
      );
    }
  }
}
