import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../camera/camera.dart';

class ApiCard extends StatefulWidget {
  final String id;
  final Function() resetScanner;

  ApiCard({required this.id, required this.resetScanner});

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final response = await http.get(
      Uri.parse('https://apigame.baptistefremaux.fr/card/${widget.id}'),
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IiAgdGVzdEBnbWFpbC5jb20iLCJpYXQiOjE2OTA0OTA3MTZ9.3Pxi7ujy0zoh89Zrjl4l1z5n1KijpdzqnzRDfK-3ta8',
      },
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building ApiCard with id: ${widget.id}");
    return Scaffold(
      appBar: AppBar(
        title: Text('API Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (data.containsKey('id'))
                Text("Salut je crois que ta pioché ça : ",
                    style: TextStyle(fontSize: 24.0)),
              if (data.containsKey('id'))
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Image.asset('assets/${data['id']}.png'),
                ),
              if (data.containsKey('action'))
                Text(data['action'], style: TextStyle(fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}
