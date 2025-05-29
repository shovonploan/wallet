import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController scannerController = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan the App Key")),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (BarcodeCapture capture) {
          {
            if (capture.barcodes.isNotEmpty) {
              final scannedData = capture.barcodes.first.rawValue;
              Navigator.pop(context, scannedData);
            }
          }
        },
      ),
    );
  }
}
