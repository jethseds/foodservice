import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodservice/login.dart';
import 'package:foodservice/loginstaff.dart';
import 'package:foodservice/product.dart';

// ignore: camel_case_types
class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _homePageState createState() => _homePageState();
}

// ignore: camel_case_types
class _homePageState extends State<homePage> {
  String location = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
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

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get device width and height
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    // Adjust container width based on device width
    double containerWidth = deviceWidth > 500 ? 500 : deviceWidth * 0.9;
    double horizontal = containerWidth / 6.5;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.1),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  width: containerWidth,
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buttonWidget('Start Ordering'),
                      const SizedBox(height: 20),
                      _buttonWidget('View Pending Orders'),
                      const SizedBox(height: 20),
                      _buttonWidget('Call for Assistance'),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginStaffPage()));
                  },
                  child: const FaIcon(
                    // ignore: deprecated_member_use
                    FontAwesomeIcons.cog,
                    color: Colors.white,
                    size: 35,
                  ),
                )),
            Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'Location: $location',
                  style: const TextStyle(fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }

  _buttonWidget(String label) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 198, 73, 69),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (label == 'View Pending Orders') {
                return const loginPage();
              } else if (label == 'Start Ordering') {
                return const productPage(pincode: '0000');
              } else if (label == 'Call for Assistance') {
                return const loginPage();
              } else {
                return const loginPage();
              }
            },
          ),
        );
      },
    );
  }
}
