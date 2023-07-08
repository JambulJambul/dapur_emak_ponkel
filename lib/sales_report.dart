import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({Key? key}) : super(key: key);

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Catering'),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.1,
            vertical: size.height * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weekly Sales",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payment')
                    .where('processStatus', isNotEqualTo: 'cancelled')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot paymentSnapshot = snapshot.data!;
                    Map<int, int> weeklySales =
                        calculateWeeklySales(paymentSnapshot, 'daily');

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: weeklySales.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        int weekNumber = weeklySales.keys.elementAt(index);
                        int totalSales = weeklySales.values.elementAt(index);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week $weekNumber',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Total Sales: Rp${totalSales.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Daily Sales",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payment')
                    .where('processStatus', isNotEqualTo: 'cancelled')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot paymentSnapshot = snapshot.data!;
                    Map<DateTime, int> dailySales =
                        calculateDailySales(paymentSnapshot, 'daily');

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: dailySales.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        DateTime date = dailySales.keys.elementAt(index);
                        int totalSales = dailySales.values.elementAt(index);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("MMMM d, yyyy").format(date),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Total Sales: Rp${totalSales.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Multiday Sales",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payment')
                    .where('processStatus', isNotEqualTo: 'cancelled')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot paymentSnapshot = snapshot.data!;
                    Map<DateTime, int> dailySales =
                        calculateDailySales(paymentSnapshot, 'multiday');

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: dailySales.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        DateTime date = dailySales.keys.elementAt(index);
                        int totalSales = dailySales.values.elementAt(index);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat("MMMM d, yyyy").format(date),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Total Sales: Rp${totalSales.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, int> calculateWeeklySales(
      QuerySnapshot paymentSnapshot, String orderType) {
    Map<int, int> weeklySales = {};

    for (QueryDocumentSnapshot doc in paymentSnapshot.docs) {
      int totalPrice = doc['amount'];
      String dateString = doc['deliveryDate'];
      String docOrderType = doc['orderType'];

      DateFormat format = DateFormat("MMMM d, yyyy");
      DateTime deliveryDate = format.parse(dateString);

      int weekNumber = getWeekNumber(deliveryDate);

      if (weekNumber == null || docOrderType != orderType) {
        continue;
      }

      if (weeklySales.containsKey(weekNumber)) {
        weeklySales[weekNumber] = weeklySales[weekNumber]! + totalPrice;
      } else {
        weeklySales[weekNumber] = totalPrice;
      }
    }

    return weeklySales;
  }

  Map<DateTime, int> calculateDailySales(
      QuerySnapshot paymentSnapshot, String orderType) {
    Map<DateTime, int> dailySales = {};

    for (QueryDocumentSnapshot doc in paymentSnapshot.docs) {
      int totalPrice = doc['amount'];
      String dateString = doc['deliveryDate'];
      String docOrderType = doc['orderType'];

      DateFormat format = DateFormat("MMMM d, yyyy");
      DateTime deliveryDate = format.parse(dateString);

      DateTime dateOnly =
          DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

      if (dateOnly == null || docOrderType != orderType) {
        continue;
      }

      if (dailySales.containsKey(dateOnly)) {
        dailySales[dateOnly] = dailySales[dateOnly]! + totalPrice;
      } else {
        dailySales[dateOnly] = totalPrice;
      }
    }

    return dailySales;
  }

  int getWeekNumber(DateTime date) {
    int daysSinceFirstMonday =
        date.difference(getFirstMondayOfYear(date.year)).inDays;
    return (daysSinceFirstMonday / 7).ceil();
  }

  DateTime getFirstMondayOfYear(int year) {
    DateTime firstDayOfYear = DateTime(year, 1, 1);
    int firstWeekday = firstDayOfYear.weekday;

    if (firstWeekday <= DateTime.monday) {
      return firstDayOfYear;
    } else {
      return firstDayOfYear.add(Duration(days: 7 - firstWeekday + 1));
    }
  }
}
