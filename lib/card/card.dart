import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiCard extends StatefulWidget {
  final String id;
  final Function() resetScanner;

  ApiCard({required this.id, required this.resetScanner});

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  Map<String, dynamic> data = {};
  late DetailsDialogContent dialogContent;

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
        if (data['serv_action'] == 'randomDice') {
          data['diceRoll'] = Random().nextInt(6) + 1;
        } else if (data['serv_action'] == 'random') {
          data['coinFlip'] = Random().nextBool() ? 'Pile' : 'Face';
        }
        dialogContent = DetailsDialogContent(data: data);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building ApiCard with id: ${widget.id}");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (data.containsKey('id'))
              Text(
                "Salut je crois que ta pioché ça : ",
                style: TextStyle(fontSize: 24.0),
              ),
            if (data.containsKey('id'))
              Expanded(
                flex: 3,
                child: Image.asset('assets/${data['id']}.png',
                    fit: BoxFit.scaleDown),
              ),
            if (data.containsKey('action'))
              Flexible(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    data['action'],
                    style: TextStyle(fontSize: 24.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                ),
              ),
            ElevatedButton(
              child: Text('Détails'),
              onPressed: () {
                if (data.containsKey('details')) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Détails'),
                      content: SingleChildScrollView(
                        child: dialogContent,
                      ),
                      actions: [
                        TextButton(
                          child: Text('Fermer'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsDialogContent extends StatefulWidget {
  final Map<String, dynamic> data;

  DetailsDialogContent({required this.data});

  @override
  _DetailsDialogContentState createState() => _DetailsDialogContentState();
}

class _DetailsDialogContentState extends State<DetailsDialogContent> {
  late Stream<int> timerStream;
  late StreamSubscription<int> timerSubscription;
  late int counter;

  @override
  void initState() {
    super.initState();
    if (widget.data['serv_action'] == 'timer90') {
      counter = 90;
      timerStream = Stream.periodic(Duration(seconds: 1), (time) {
        return counter - time - 1;
      }).asBroadcastStream();
      timerSubscription = timerStream.take(counter).listen(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dialogContent = widget.data['details'];

    switch (widget.data['serv_action']) {
      case 'randomDice':
        dialogContent += '\nRésultat du dé: ${widget.data['diceRoll']}';
        return Text(dialogContent);
      case 'random':
        dialogContent +=
            '\nRésultat du pile ou face: ${widget.data['coinFlip']}';
        return Text(dialogContent);
      case 'timer90':
        return Column(
          children: [
            Text(dialogContent),
            SizedBox(height: 10),
            StreamBuilder<int>(
              stream: timerStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Timer: ${snapshot.data} sec');
                  }
                }
              },
            ),
          ],
        );
      default:
        dialogContent += '\n' + widget.data['details'];
        return Text(dialogContent);
    }
  }

  @override
  void dispose() {
    timerSubscription.cancel();
    super.dispose();
  }
}
