import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodservice/home.dart';
import 'package:foodservice/login.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class ordersPage2 extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  const ordersPage2({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ordersPage2 createState() => _ordersPage2();
}

// ignore: camel_case_types
class _ordersPage2 extends State<ordersPage2> {
  String? _deviceId;
  double overallTotal = 0.0;
  @override
  void initState() {
    super.initState();
    _getDeviceIdentifier();
  }

  Future<void> _getDeviceIdentifier() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        setState(() {
          _deviceId = androidInfo.id; // Unique ID on Android
        });
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        setState(() {
          _deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double prodnameSize = 0;

    // Adjust font size based on device width
    if (deviceWidth <= 320) {
      prodnameSize = 15;
    } else if (deviceWidth <= 360) {
      prodnameSize = 15;
    } else if (deviceWidth <= 412) {
      prodnameSize = 20;
    } else if (deviceWidth <= 480) {
      prodnameSize = 25;
    } else if (deviceWidth <= 600) {
      prodnameSize = 25;
    } else if (deviceWidth <= 900) {
      prodnameSize = 25;
    }
    double total = 0.0;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xddc64a45),
          title: Row(
            children: [
              GestureDetector(
                child: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const homePage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Text(
                'My Orders',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('status')
                    .where('pincode', isEqualTo: _deviceId)
                    .where('status', isEqualTo: 5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> data = snapshot.data!.docs;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              var doc =
                                  data[index].data() as Map<String, dynamic>;
                              double price = double.tryParse(
                                      doc['price'].replaceAll(',', '')) ??
                                  0.0;
                              double quantity = double.tryParse(
                                      doc['quantity'].replaceAll(',', '')) ??
                                  0.0;
                              double addonstotal = double.tryParse(
                                      doc['addonstotal'].replaceAll(',', '')) ??
                                  0.0;

                              double overalladdons = addonstotal * quantity;
                              double itemTotal =
                                  price * quantity + overalladdons;

                              total += itemTotal;

                              final numberFormat =
                                  NumberFormat('#,##0.00', 'en_US');
                              String formattedPrice =
                                  numberFormat.format(price);
                              String formattedTotal =
                                  numberFormat.format(itemTotal);

                              String addonsString = doc['addons'].toString();
                              List<String> addonsList =
                                  addonsString.split('\n');
                              String addons = addonsList.join(' ');

                              if (doc['pincode'] == _deviceId) {
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                              255, 244, 244, 244),
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
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Text(
                                                      doc['name'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: prodnameSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    doc['description'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
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
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Add-ons:",
                                                      style: TextStyle(
                                                        fontSize: prodnameSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                            0xddc64a45),
                                                      ),
                                                    ),
                                                    Text(
                                                      addons,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Container(); // Return an empty container if pincode doesn't match
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Overall Total: ${NumberFormat('#,##0.00', 'en_US').format(total)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xddc64a45),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const loginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
