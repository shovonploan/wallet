import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallet/bloc/encrptionKey.dart';
import 'package:wallet/constants/common.dart';

import 'QRScannerScreen.dart';

class EncryptionKeySetupScreen extends StatefulWidget {
  const EncryptionKeySetupScreen({super.key});

  @override
  _EncryptionKeySetupScreenState createState() =>
      _EncryptionKeySetupScreenState();
}

class _EncryptionKeySetupScreenState extends State<EncryptionKeySetupScreen> {
  bool _isValidAESKey(String key) {
    try {
      final decodedKey = base64Decode(key);
      return decodedKey.length == 32;
    } catch (e) {
      return false;
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void catchKey(String key) {
    _isValidAESKey(key)
        ? context.read<EncryptionKeyBloc>().add(EncryptionKeyCatch(key))
        : showToast("Invalid Key");
  }

  Future<String?> _enterKeyManually(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Encryption Key"),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: "Paste encryption key here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                catchKey(controller.text);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _showQRCode(BuildContext context, String key) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Scan to Share Key"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             QrImageView(data: key, version: QrVersions.auto, size: 200),
  //             const SizedBox(height: 10),
  //             SelectableText(key),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Done"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Encryption Key")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isDesktop()
                ? Container()
                : const Text(
                    "Choose how to set up your encryption key:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
            isDesktop() ? Container() : const SizedBox(height: 20),
            isDesktop()
                ? Container()
                : ElevatedButton(
                    onPressed: () async {
                      final String result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QRScannerScreen()),
                      );
                      catchKey(result);
                    },
                    child: const Text("Scan QR Code"),
                  ),
            isDesktop() ? Container() : const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _enterKeyManually(context);
              },
              child: const Text("Enter Manually"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String key = await base64Encode(List<int>.generate(
                    32, (_) => Random.secure().nextInt(256)));
                context.read<EncryptionKeyBloc>().add(EncryptionKeyCatch(key));
              },
              child: const Text("Generate New Key"),
            ),
          ],
        ),
      ),
    );
  }
}
