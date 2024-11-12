import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:foodservice/product.dart';

// Define your loginPage as a HookWidget
// ignore: camel_case_types
class loginPage extends HookWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // State management with hooks
    final roomNumberController = useTextEditingController();
    final pincodeController = useTextEditingController();
    final isRoomNumberComplete = useState(false);
    final pin = useState("");

    void onNumberPressed(String number) {
      if (!isRoomNumberComplete.value) {
        // Handle input for room number
        if (roomNumberController.text.length < 4) {
          roomNumberController.text += number;
        }

        // Check if room number input is complete
        if (roomNumberController.text.length == 4) {
          isRoomNumberComplete.value = true; // Mark room number as complete
          pincodeController.text = ''; // Clear pincode field
          pin.value = ''; // Reset pincode value
        }
      } else {
        // Handle input for pincode
        if (pincodeController.text.length < 4) {
          pincodeController.text += number;
          pin.value = pincodeController.text; // Update the internal state
        }
      }
    }

    void onConfirmPressed() async {
      try {
        // Query the 'customers' collection
        QuerySnapshot customersSnapshot = await FirebaseFirestore.instance
            .collection('customers')
            .where('pincode', isEqualTo: pincodeController.text)
            .where('roomnumber', isEqualTo: roomNumberController.text)
            .where('status', isEqualTo: 'Active')
            .get();

        if (customersSnapshot.docs.isEmpty) {
          // No matching documents found, show error message
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Incorrect PIN and Room Number. Please try again.'),
            ),
          );
          // Clear text fields and reset input
          pincodeController.clear();
          roomNumberController.clear();
          isRoomNumberComplete.value =
              false; // Reset to room number input phase
          return; // Exit the function early
        }

        // Proceed with device info retrieval
        String? deviceId;
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

        try {
          if (Platform.isAndroid) {
            AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
            deviceId = androidInfo.id; // Unique ID on Android
          } else if (Platform.isIOS) {
            IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
            deviceId = iosInfo.identifierForVendor; // Unique ID on iOS
          }
          // ignore: empty_catches
        } catch (e) {}

        // Query the 'orders' collection
        var ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('pincode', isEqualTo: deviceId)
            .where('roomnumber', isEqualTo: deviceId)
            .where('status', isEqualTo: 5)
            .get();

        String location = "";

        try {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('location')
              .where('deviceId', isEqualTo: deviceId)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            var userData =
                querySnapshot.docs.first.data() as Map<String, dynamic>?;

            location = userData?['location'] ?? '';
          } else {}

          // ignore: empty_catches
        } catch (e) {}

        if (ordersSnapshot.docs.isNotEmpty) {
          // Iterate over each document and update
          for (var document in ordersSnapshot.docs) {
            await document.reference.update({
              'status': 1,
              'pincode': pincodeController.text,
              'roomnumber': roomNumberController.text,
              'location': location,
            });
          }
        }

        // If the customer is found and everything is correct, navigate to the product page
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => productPage(pincode: pincodeController.text),
          ),
        );
      } catch (error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      } finally {
        // Clear text fields in case of error
        isRoomNumberComplete.value = false; // Reset to room number input phase
      }
    }

    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    double containerWidth =
        deviceWidth < 600 ? (deviceWidth > 500 ? 500 : deviceWidth * 0.9) : 700;

    double horizontalpaddingdivide = deviceWidth < 600 ? 6.5 : 10;
    double horizontal = containerWidth / horizontalpaddingdivide;

    return Scaffold(
      body: Container(
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
            color: Colors.grey,
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (deviceWidth < 600) {
                  // Mobile layout
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInstructions(deviceWidth),
                      const SizedBox(height: 20),
                      _buildTextField(
                          deviceWidth, roomNumberController, pincodeController),
                      const SizedBox(height: 20),
                      NumericKeypad(
                        onNumberPressed: onNumberPressed,
                        onConfirmPressed: onConfirmPressed,
                      ),
                    ],
                  );
                } else {
                  // Tablet layout
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 70, bottom: 30),
                        child: _buildInstructions(deviceWidth),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildTextField(deviceWidth,
                                    roomNumberController, pincodeController),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: NumericKeypad(
                                onNumberPressed: onNumberPressed,
                                onConfirmPressed: onConfirmPressed,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(double deviceWidth) {
    double title = deviceWidth < 600 ? 17 : 23;
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Please enter PIN for billing and authorization. Once confirmed, order will be sent to kitchen and cannot be revoked.',
        style: TextStyle(fontSize: title),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(
      double deviceWidth,
      TextEditingController roomNumberController,
      TextEditingController pincodeController) {
    double label = deviceWidth < 600 ? 17 : 20;
    double heightSpacing = deviceWidth < 600 ? 10 : 20;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Please enter room number:',
            style: TextStyle(fontSize: label),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: TextField(
            controller: roomNumberController,
            decoration: const InputDecoration(border: InputBorder.none),
            enabled: false,
          ),
        ),
        SizedBox(
          height: heightSpacing,
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Please enter PIN (last 4 digits of mobile):',
            style: TextStyle(fontSize: label),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: TextField(
            controller: pincodeController, // Use pincode controller here
            decoration: const InputDecoration(border: InputBorder.none),
            enabled: false,
          ),
        )
      ],
    );
  }
}

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function onConfirmPressed;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('0'),
            _buildConfirmButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        minimumSize: const Size(64, 64), // Fixed size for buttons
      ),
      child: Text(number,
          style: const TextStyle(fontSize: 24, color: Color(0xddc64a45))),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        onConfirmPressed();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        minimumSize:
            const Size(138, 64), // Adjusted size for spanning 2 columns
      ),
      child: const Text('Confirm',
          style: TextStyle(fontSize: 24, color: Color(0xddc64a45))),
    );
  }
}
