import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodservice/login.dart';
import 'package:foodservice/product.dart';
import 'package:foodservice/services.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class checkoutPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pincode;
  const checkoutPage({super.key, required this.pincode});

  @override
  // ignore: library_private_types_in_public_api
  _checkoutPage createState() => _checkoutPage();
}

// ignore: camel_case_types
class _checkoutPage extends State<checkoutPage> {
  String name = "";
  String roomnumber = "";
  double grandtotal = 0.00;
  @override
  void initState() {
    super.initState();
    // Fetch data based on the provided UID when the widget initializes
    fetchData();
    _updateGrandTotal();
    fetchLocation();
  }

  String location = "";

  Future<void> fetchLocation() async {
    try {
      String? deviceId;
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
      }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('location')
          .where('deviceId', isEqualTo: deviceId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            location = userData['location'] ?? '';
          });
        } else {}
      } else {}

      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('pincode', isEqualTo: widget.pincode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;

        if (userData != null) {
          setState(() {
            name = userData['name'] ?? '';
            roomnumber = userData['roomnumber'] ?? '';

            // Update other controllers for other fields accordingly
          });
        } else {}
      } else {}

      // ignore: empty_catches
    } catch (e) {}
  }

  void _updateGrandTotal() async {
    var data = await FirebaseFirestore.instance
        .collection('orders')
        .where('pincode', isEqualTo: widget.pincode)
        .where('status', isEqualTo: 5)
        .get();

    setState(() {
      grandtotal = calculateGrandTotal(data.docs);
    });
  }

  void _increaseQuantity(
      String docId, double price, double quantity, double addonstotal) async {
    // Increase the quantity in Firestore
    await Services().checkoutincreasequantity(docId);

    // Update the grand total after increasing quantity
    _updateGrandTotal();
  }

  void _decreaseQuantity(
      String docId, double price, double quantity, double addonstotal) async {
    // Increase the quantity in Firestore
    await Services().checkoutdecreasequantity(docId);

    // Update the grand total after increasing quantity
    _updateGrandTotal();
  }

  double calculateGrandTotal(List<DocumentSnapshot> data) {
    double total = 0.0;
    for (var doc in data) {
      var docData = doc.data() as Map<String, dynamic>;
      double price =
          double.tryParse(docData['price'].replaceAll(',', '')) ?? 0.0;
      double quantity =
          double.tryParse(docData['quantity'].replaceAll(',', '')) ?? 0.0;

      final addonsPriceString = doc['addonsprice'] as String? ?? '';

      // Process the addonsPrice string
      final prices = addonsPriceString
          .replaceAll(RegExp(r'\s*,\s*'), ',')
          .split(',')
          .where((price) => price.isNotEmpty) // Filter out empty strings
          .map((price) => double.tryParse(price) ?? 0.0)
          .toList();

      // Calculate the total
      final addonsprice =
          // ignore: avoid_types_as_parameter_names
          prices.fold<double>(0.0, (sum, price) => sum + (price * quantity));
      total += (price * quantity) + addonsprice;
    }
    return total;
  }

  void _removeProduct(String docId) async {
    await Services().removeproduct(docId);
    _updateGrandTotal(); // Refresh grand total after removing product
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    if (deviceWidth <= 320) {
    } else if (deviceWidth <= 360) {
    } else if (deviceWidth <= 412) {
    } else if (deviceWidth <= 480) {
// Default size for smaller devices
    } else if (deviceWidth <= 600) {
// Default size for smaller devices
    } else if (deviceWidth <= 900) {
// Default size for smaller devices
    }
    return Scaffold(
      body: Column(
        children: [
          // Row(
          //   children: [
          //     Text(
          //       roomnumber,
          //       style: const TextStyle(fontSize: 20),
          //     ),
          //     const Text(
          //       ' & ',
          //       style: TextStyle(fontSize: 20),
          //     ),
          //     Text(
          //       name,
          //       style: const TextStyle(fontSize: 20),
          //     ),
          //   ],
          // ),
          // const SizedBox(
          //   height: 20,
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('pincode', isEqualTo: widget.pincode)
                  .where('status', isEqualTo: 5)
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
                      double quantity = double.tryParse(
                              doc['quantity'].replaceAll(',', '')) ??
                          0.0;
                      double addonstotal = double.tryParse(
                              doc['addonstotal'].replaceAll(',', '')) ??
                          0.0;

                      final addonsPriceString =
                          doc['addonsprice'] as String? ?? '';

                      // Process the addonsPrice string
                      final prices = addonsPriceString
                          .replaceAll(RegExp(r'\s*,\s*'), ',')
                          .split(',')
                          .where((price) =>
                              price.isNotEmpty) // Filter out empty strings
                          .map((price) => double.tryParse(price) ?? 0.0)
                          .toList();

                      // Calculate the total
                      final addonsprice = prices.fold<double>(
                          // ignore: avoid_types_as_parameter_names
                          0.0,
                          // ignore: avoid_types_as_parameter_names
                          (sum, price) => sum + (price * quantity));

                      // double overalladdons = addonstotal;
                      double total = price * quantity + addonsprice;

                      final numberFormat = NumberFormat('#,##0.00', 'en_US');

                      // Format the price and total with commas
                      String formattedPrice = numberFormat.format(price);
                      String formattedTotal = numberFormat.format(total);

                      grandtotal += total;

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
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(5),
                                    child: Image.network(
                                      doc['image'] ?? '',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
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
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        addons == ""
                                            ? const Text('')
                                            : Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: const Text(
                                                        "Add-ons: ",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Text(
                                                        addons,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'QTY: ',
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.all(10),
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: int.parse(doc['quantity']) >
                                                    1
                                                ? const Color(0xddc64a45)
                                                : Colors
                                                    .grey, // Grey out if disabled
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              _decreaseQuantity(data[index].id,
                                                  price, quantity, addonstotal);
                                            },
                                            child: const FaIcon(
                                                FontAwesomeIcons.minus),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.all(10),
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            doc['quantity'].toString(),
                                            style:
                                                const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: const EdgeInsets.all(10),
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xddc64a45),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              _increaseQuantity(data[index].id,
                                                  price, quantity, addonstotal);
                                            },
                                            child: const FaIcon(
                                                FontAwesomeIcons.plus),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xddc64a45),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        _removeProduct(data[index].id);
                                      },
                                      child: const FaIcon(
                                        // ignore: deprecated_member_use
                                        FontAwesomeIcons.remove,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "\$$formattedTotal",
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
                    },
                  );
                } else {
                  return const Center(child: Text('no data'));
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                '\$${NumberFormat('#,##0.00', 'en_US').format(grandtotal)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
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
              const SizedBox(
                width: 10,
              ),
              const Text(
                '|',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const loginPage(),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(10),
                  width: 150,
                  decoration: BoxDecoration(
                      color: const Color(0xddc64a45),
                      borderRadius: BorderRadius.circular(5)),
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
        ],
      ),
    );
  }
}
