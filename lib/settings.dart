import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodservice/home.dart';

// ignore: camel_case_types
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

// ignore: camel_case_types
class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController locationController = TextEditingController();
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
                  height: 250,
                  color: Colors.white,
                  width: containerWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                  ),
                  child: ListView(
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(fontSize: 23),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Location:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        color: Colors.grey.shade300,
                        child: TextField(
                          controller: locationController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buttonWidget('Cancel'),
                          const SizedBox(height: 20),
                          _buttonWidget('Save'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
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
      onTap: () async {
        if (label == "Save") {
          String? deviceId;
          final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

          try {
            if (Platform.isAndroid) {
              AndroidDeviceInfo androidInfo =
                  await deviceInfoPlugin.androidInfo;
              deviceId = androidInfo.id;
            }

            try {
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('location')
                  .where('deviceId', isEqualTo: deviceId)
                  .get();

              if (querySnapshot.size > 0) {
                for (var document in querySnapshot.docs) {
                  await document.reference
                      .update({'location': locationController.text});
                }
              } else {
                FirebaseFirestore.instance.collection('location').doc().set({
                  'deviceId': deviceId,
                  'location': locationController.text
                });
              }
              // ignore: empty_catches
            } catch (e) {}
            // ignore: empty_catches
          } catch (e) {}
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => homePage()));
        }
      },
    );
  }
}
