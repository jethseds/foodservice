import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class ordersPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pincode;
  const ordersPage({super.key, required this.pincode});

  @override
  // ignore: library_private_types_in_public_api
  _ordersPage createState() => _ordersPage();
}

// ignore: camel_case_types
class _ordersPage extends State<ordersPage> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double prodnameSize = 0;
    if (deviceWidth <= 320) {
      prodnameSize = 15;
    } else if (deviceWidth <= 360) {
      prodnameSize = 15;
    } else if (deviceWidth <= 412) {
      prodnameSize = 20;
    } else if (deviceWidth <= 480) {
      prodnameSize = 25; // Default size for smaller devices
    } else if (deviceWidth <= 600) {
      prodnameSize = 25; // Default size for smaller devices
    } else if (deviceWidth <= 900) {
      prodnameSize = 25; // Default size for smaller devices
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('pincode', isEqualTo: widget.pincode)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                final List<DocumentSnapshot> data = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var doc = data[index].data() as Map<String, dynamic>;
                    double price =
                        double.tryParse(doc['price'].replaceAll(',', '')) ??
                            0.0;
                    double quantity =
                        double.tryParse(doc['quantity'].replaceAll(',', '')) ??
                            0.0;
                    double addonstotal = double.tryParse(
                            doc['addonstotal'].replaceAll(',', '')) ??
                        0.0;

                    double overalladdons = addonstotal;
                    double total = price * quantity + overalladdons;

                    final numberFormat = NumberFormat('#,##0.00', 'en_US');

                    // Format the price and total with commas
                    String formattedPrice = numberFormat.format(price);
                    String formattedTotal = numberFormat.format(total);

                    String addonsString = doc['addons'].toString();
                    List<String> addonsList = addonsString.split('\n');
                    String addons = addonsList.join(' ');

                    return GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 244, 244, 244),
                              width: 5.0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Text(
                                          doc['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: prodnameSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        doc['description'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Price: ',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              formattedPrice,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'x${doc['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  child: Image.network(
                                    doc['image'] ?? '',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            addons == ""
                                ? const Text('')
                                : Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Add-ons:",
                                          style: TextStyle(
                                            fontSize: prodnameSize,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xddc64a45),
                                          ),
                                        ),
                                        Text(
                                          addons,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    )),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Total: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    formattedTotal,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: 80,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: doc['status'].toString() == "0"
                                      ? Colors.green
                                      : doc['status'].toString() == "1"
                                          ? Colors.green
                                          : const Color.fromARGB(
                                              255, 250, 171, 0),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                doc['status'].toString() == "1"
                                    ? 'Pending'
                                    : doc['status'].toString() == "1"
                                        ? 'Approved'
                                        : 'Completed',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('no data'));
              }
            },
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(10),
                  width: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xddc64a45),
                      borderRadius: BorderRadius.circular(5)),
                  child: const Text(
                    "Return To Menu",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
