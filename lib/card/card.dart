import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiCard extends StatefulWidget {
  final String id;
  final Function() resetScanner;
  final String selectedRoomId;
  ApiCard({
    required this.id,
    required this.resetScanner,
    required this.selectedRoomId,
  });

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  Map<String, dynamic> data = {};
  final controller = TextEditingController();
  late DetailsDialogContent dialogContent;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImEiLCJpYXQiOjE2OTEwMDYwNTF9.YzSufVn_6GkacafbWtPSeak4avgVUAevpHFbB-w7xwM';
    final response = await http.post(
      Uri.parse(
          'https://apigame.baptistefremaux.fr/sessions/${widget.selectedRoomId}/cards'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"label": widget.id}),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        data = data['card'];
        if (data['serv_action'] == 'randomDice') {
          data['diceRoll'] = Random().nextInt(6) + 1;
        } else if (data['serv_action'] == 'random') {
          data['coinFlip'] = Random().nextBool() ? 'Pile' : 'Face';
        }
        dialogContent = DetailsDialogContent(data: data);
        switch (data['serv_action']) {
          case 'hasGoodJoker':
            callApiForAction('good_joker');
            break;
          case 'hasBadJoker':
            callApiForAction('bad_joker');
            break;
          case 'stillNoAces':
            callApiForAction('no_aces');
            break;
          default:
            break;
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> callApiForAction(String action) async {
    final response = await http.post(
      Uri.parse('https://apigame.baptistefremaux.fr/card/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'action': action,
      }),
    );

    if (response.statusCode == 200) {
      print('Response body for $action: ${response.body}');
    } else {
      throw Exception('Failed to send data');
    }
  }

  Future<void> postData() async {
    final response = await http.post(
      Uri.parse('https://apigame.baptistefremaux.fr/card/${widget.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'input': controller.text,
      }),
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
    } else {
      throw Exception('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building ApiCard with id: ${widget.id}");
    bool shouldShowInputField =
        ['LinkEnum', 'rule'].contains(data['serv_action']);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (data.containsKey('label'))
              Text(
                "Salut je crois que ta pioché ça : ",
                style: TextStyle(fontSize: 24.0),
              ),
            if (data.containsKey('label'))
              Expanded(
                flex: 3,
                child: Image.asset('assets/${data['label']}.png',
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
            if (shouldShowInputField)
              TextField(
                controller: controller,
              ),
            if (shouldShowInputField)
              ElevatedButton(
                onPressed: postData,
                child: Text('Valider'),
              ),
            ElevatedButton(
              child: Text('Détails'),
              onPressed: () {
                if (data.containsKey('detail')) {
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
    String dialogContent = widget.data['detail'];

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
        dialogContent += '\n' + widget.data['detail'];
        return Text(dialogContent);
    }
  }

  @override
  void dispose() {
    timerSubscription.cancel();
    super.dispose();
  }
}
