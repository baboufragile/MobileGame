import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/widget/Bottom_nav.dart';

class ApiCard extends StatefulWidget {
  final String id; // add this line

  ApiCard({required this.id}); // and this line
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
      Uri.parse(
          'https://apigame.baptistefremaux.fr/card/${widget.id}'), // Remplacez par l'URL de votre API
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IiAgdGVzdEBnbWFpbC5jb20iLCJpYXQiOjE2OTA0OTA3MTZ9.3Pxi7ujy0zoh89Zrjl4l1z5n1KijpdzqnzRDfK-3ta8', // Remplacez par votre Bearer token
      },
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      // Si le serveur retourne une réponse 200 OK, parsez le JSON.
      setState(() {
        data = jsonDecode(response.body);
      });
    } else {
      // Si la réponse n'est pas OK, lancez une exception.
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Affiche les données en format brut
              if (data.containsKey(
                  'id')) // Check if the 'id' key exists in the data
                Text("Salut je crois que ta pioché ça : ",
                    style: TextStyle(
                        fontSize: 24.0) // Increase the font size to 24
                    ),

              FractionallySizedBox(
                widthFactor: 0.6,
                child: Image.asset('assets/${data['id']}.png'),
              ),
              Text(data['action'],
                  style:
                      TextStyle(fontSize: 24.0) // Increase the font size to 24
                  ), // Load the image from the assets
              // Utilisez les différentes clés de votre réponse JSON pour afficher les données spécifiques.
              // Exemple : Text('Name: ${data['name']}'),
            ],
          ),
        ),
      ),
    );
  }
}
