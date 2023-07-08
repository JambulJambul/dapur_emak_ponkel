import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';
import 'cart.dart';

class EditDailyMenu extends StatefulWidget {
  const EditDailyMenu({Key? key}) : super(key: key);

  @override
  State<EditDailyMenu> createState() => _EditDailyMenuState();
}

class _EditDailyMenuState extends State<EditDailyMenu> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<CartItem> cartItems = [];

  void _showCardDialog(BuildContext context, CartItem cartItem) {
    String label = cartItem.label;
    String imgUrl = cartItem.imgUrl;
    String itemDesc = cartItem.itemDesc;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  imgUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  itemDesc,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeMenuFromDate(String formattedDate, String docid) async {
    // Get the document reference for the selected date
    DocumentReference menuDocumentRef =
        FirebaseFirestore.instance.collection('foodmenu').doc(docid);
    await menuDocumentRef.update({
      'menudatestring': FieldValue.arrayRemove([formattedDate])
    });
  }

  void _addMenuToDate(String formattedDate, String docid) async {
    // Get the document reference for the selected date
    DocumentReference menuDocumentRef =
        FirebaseFirestore.instance.collection('foodmenu').doc(docid);
    await menuDocumentRef.update({
      'menudatestring': FieldValue.arrayUnion([formattedDate])
    });
  }

  Widget _buildCardDialog(BuildContext context, CartItem cartItem,
      String formattedDate, String docid) {
    String label = cartItem.label;
    String imgUrl = cartItem.imgUrl;
    String itemDesc = cartItem.itemDesc;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: InkWell(
            onTap: () => _showCardDialog(context, cartItem),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              bottomLeft: Radius.circular(16.0),
                            ),
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              width: 64,
                              height: 90,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addMenuToDate(formattedDate, docid);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add menu to date'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.orange),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, CartItem cartItem,
      String formattedDate, String docid) {
    String label = cartItem.label;
    String imgUrl = cartItem.imgUrl;
    String itemDesc = cartItem.itemDesc;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: InkWell(
            onTap: () => _showCardDialog(context, cartItem),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                      ),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 90,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _removeMenuFromDate(formattedDate, docid);
          },
          child: const Text('Remove menu from date'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemHeight = size.height * 0.6;
    final double itemWidth = size.width * 0.8;
    final double buttonWidth = size.width * 0.4;
    DateTime selectedDate =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Catering'),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {CalendarFormat.week: 'Week'},
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
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('foodmenu')
                        .where("menudatestring", arrayContains: (formattedDate))
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
                        cartItems = snapshot.data!.docs.map((menu) {
                          String label = menu['menutitle'];
                          String imgUrl = menu['imageurl'];
                          String itemDesc = menu['menudesc'];

                          var price = menu['price'];
                          return CartItem(
                            label: label,
                            imgUrl: imgUrl,
                            itemDesc: itemDesc,
                            quantity: 1,
                            price: price,
                          );
                        }).toList();
                        return ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            final doc = documents[index];
                            String docId = doc.id;
                            CartItem cartItem = cartItems[index];
                            return _buildCard(
                                context, cartItem, formattedDate, docId);
                          },
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    })),
            SizedBox(height: size.height * 0.05),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text("Available Menu"),
                            const SizedBox(
                              height: 10,
                            ),
                            Flexible(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('foodmenu')
                                    .where('foodtype', isNotEqualTo: 'multiday')
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    final List<QueryDocumentSnapshot>
                                        documents = snapshot.data!.docs;
                                    cartItems = documents.map((menu) {
                                      String label = menu['menutitle'];
                                      String imgUrl = menu['imageurl'];
                                      String itemDesc = menu['menudesc'];
                                      var price = menu['price'];
                                      return CartItem(
                                        label: label,
                                        imgUrl: imgUrl,
                                        itemDesc: itemDesc,
                                        quantity: 1,
                                        price: price,
                                      );
                                    }).toList();
                                    return ListView.builder(
                                      itemCount: cartItems.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final doc = documents[index];
                                        String docId = doc.id;
                                        CartItem cartItem = cartItems[index];
                                        return _buildCardDialog(context,
                                            cartItem, formattedDate, docId);
                                      },
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text('Add Menu to the date'),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
