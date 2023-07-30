import 'package:flutter/material.dart';
import 'package:app/navbar/navbar.dart'; // Assurez-vous d'avoir bien importé votre widget ici
import 'package:status_bar_control/status_bar_control.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: BottomBar(),
      ),
    );
  }
}
