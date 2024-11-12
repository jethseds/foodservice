import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:foodservice/settings.dart';

// ignore: camel_case_types
class LoginStaffPage extends HookWidget {
  const LoginStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pincodeController = useTextEditingController();
    final pin = useState("");

    void onNumberPressed(String number) {
      if (pincodeController.text.length < 4) {
        pincodeController.text += number;
        pin.value = pincodeController.text; // Update the internal state
      }
    }

    void onConfirmPressed() async {
      try {
        // Query the 'customers' collection
        QuerySnapshot customersSnapshot = await FirebaseFirestore.instance
            .collection('staff')
            .where('code', isEqualTo: pincodeController.text)
            .get();

        if (customersSnapshot.docs.isEmpty) {
          // No matching documents found, show error message
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Incorrect Code. Please try again.'),
            ),
          );
          // Clear text fields and reset input
          pincodeController.clear();
          return; // Exit the function early
        }

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsPage(),
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
                      _buildTextField(deviceWidth, pincodeController),
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
                                _buildTextField(deviceWidth, pincodeController),
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
        'Please enter Acces Code for authorization. Once confirmed, Staff Can Access Settings.',
        style: TextStyle(fontSize: title),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(
      double deviceWidth, TextEditingController pincodeController) {
    double label = deviceWidth < 600 ? 17 : 20;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Please enter Access Code:',
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
