import 'package:flutter/material.dart';
import 'package:app/navbar/navbar.dart'; // Assurez-vous d'avoir bien importé votre widget ici

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomBar(),
    );
  }
}
