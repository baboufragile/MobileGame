import 'dart:async';
import 'dart:io' show Platform, sleep;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:logging/logging.dart';
import 'package:ndef/ndef.dart' as ndef;

class Sensors extends StatefulWidget {
  final Function(String) onNfcScanned;
  Sensors({Key? key, required this.onNfcScanned}) : super(key: key);
  @override
  SensorsState createState() => SensorsState();
}

class SensorsState extends State<Sensors> with SingleTickerProviderStateMixin {
  String _platformVersion = '';
  NFCAvailability _availability = NFCAvailability.not_supported;
  NFCTag? _tag;
  String? _result, _writeResult;
  late TabController _tabController;
  List<ndef.NDEFRecord>? _records;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb)
      _platformVersion =
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    else
      _platformVersion = 'Web';
    initPlatformState();
    _tabController = new TabController(length: 2, vsync: this);
    _records = [];
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NFCAvailability availability;
    try {
      availability = await FlutterNfcKit.nfcAvailability;
    } on PlatformException {
      availability = NFCAvailability.not_supported;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
      _availability = availability;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC Flutter Kit Example App'),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
              const SizedBox(height: 20),
              Text('Running on: $_platformVersion\nNFC: $_availability'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    NFCTag tag = await FlutterNfcKit.poll();
                    setState(() {
                      _tag = tag;
                    });
                    await FlutterNfcKit.setIosAlertMessage("Working on it...");
                    if (tag.standard == "ISO 14443-4 (Type B)") {
                      String result1 =
                          await FlutterNfcKit.transceive("00B0950000");
                      String result2 = await FlutterNfcKit.transceive(
                          "00A4040009A00000000386980701");
                      setState(() {
                        _result = '1: $result1\n2: $result2\n';
                      });
                    } else if (tag.type == NFCTagType.iso18092) {
                      String result1 =
                          await FlutterNfcKit.transceive("060080080100");
                      setState(() {
                        _result = '1: $result1\n';
                      });
                    } else if (tag.type == NFCTagType.mifare_ultralight ||
                        tag.type == NFCTagType.mifare_classic ||
                        tag.type == NFCTagType.iso15693) {
                      var ndefRecords = await FlutterNfcKit.readNDEFRecords();
                      var ndefString = '';
                      for (int i = 0; i < ndefRecords.length; i++) {
                        ndefString += '${i + 1}: ${ndefRecords[i]}\n';
                        String extractedText =
                            extractText(ndefRecords[i].toString());
                        if (extractedText.isNotEmpty) {
                          widget.onNfcScanned(extractedText);
                        }
                      }
                      setState(() {
                        _result = ndefString;
                      });
                    } else if (tag.type == NFCTagType.webusb) {
                      var r = await FlutterNfcKit.transceive(
                          "00A4040006D27600012401");
                      print(r);
                    }
                  } catch (e) {
                    setState(() {
                      _result = 'error: $e';
                    });
                  }

                  // Pretend that we are working
                  if (!kIsWeb) sleep(new Duration(seconds: 1));
                  await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
                },
                child: Text('Start polling'),
              ),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _tag != null
                      ? Text(
                          'ID: ${_tag!.id}\nStandard: ${_tag!.standard}\nType: ${_tag!.type}\nATQA: ${_tag!.atqa}\nSAK: ${_tag!.sak}\nHistorical Bytes: ${_tag!.historicalBytes}\nProtocol Info: ${_tag!.protocolInfo}\nApplication Data: ${_tag!.applicationData}\nHigher Layer Response: ${_tag!.hiLayerResponse}\nManufacturer: ${_tag!.manufacturer}\nSystem Code: ${_tag!.systemCode}\nDSF ID: ${_tag!.dsfId}\nNDEF Available: ${_tag!.ndefAvailable}\nNDEF Type: ${_tag!.ndefType}\nNDEF Writable: ${_tag!.ndefWritable}\nNDEF Can Make Read Only: ${_tag!.ndefCanMakeReadOnly}\nNDEF Capacity: ${_tag!.ndefCapacity}\n\n Transceive Result:\n$_result')
                      : const Text('No tag polled yet.')),
            ])))),
      ),
    );
  }

  String extractText(String input) {
    var index = input.indexOf('text=');
    if (index != -1) {
      return input.substring(index + 5).trim(); // 5 is length of 'text='
    } else {
      return ""; // return empty string if 'text=' is not found
    }
  }
}
