import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../card/card.dart'; // assuming you have 'card.dart' in the 'card' directory
import 'dart:io' show Platform; // Required for Platform.isAndroid/isIOS

class ScanPage extends StatefulWidget {
  final Function() resetScanner;

  ScanPage({Key? key, required this.resetScanner}) : super(key: key);

  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  bool shouldResumeCamera = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.pauseCamera();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${(result!.format)}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          ),
          ElevatedButton(
            onPressed: resetScanner,
            child: Text('Reset Scanner'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void resetScanner() {
    setState(() {
      result = null;
      shouldResumeCamera = true;
    });
    controller?.resumeCamera();
  }
}
