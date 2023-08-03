import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../card/card.dart'; // assuming you have 'card.dart' in the 'card' directory
import '../camera/camera.dart';
import 'package:app/home/changelog.dart';
import '../nfc.dart';
import 'package:flutter/services.dart'; // Importez la bibliothèque flutter/services.dart pour utiliser SystemChrome
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert';
import '../stats/statpage.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  String _selectedRoomId = "";
  String _selectedUsername = "";
  int _selectedIndex = 0;
  final scanPageKey = GlobalKey<ScanPageState>();
  final nfcPageKey = GlobalKey<SensorsState>();
  ValueNotifier<String> lastScannedValue = ValueNotifier<String>('');

  bool _userLoggedIn =
      false; // Ajoutez cette variable pour suivre l'état de connexion de l'utilisateur

  String _username = ""; // Variable pour stocker le nom d'utilisateur
  String _roomId = ""; // Variable pour stocker le roomId

  final _usernameController = TextEditingController();
  final _roomIdController = TextEditingController();

  void updateIndex(int index, [String? scanValue]) {
    print(
        "updateIndex method triggered with index $index and scanValue $scanValue");
    if (index == 3 && _selectedIndex != 3 && scanPageKey.currentState != null)
      scanPageKey.currentState!.resetScanner();
    setState(() {
      _selectedIndex = index;
      if (scanValue != null) {
        print('Scanned value received in Navbar: $scanValue');
      }
      if (index == 4) {
        _selectedRoomId =
            _roomId; // Assuming _roomId is already set in your code
        _selectedUsername = _username;
      }
    });
  }

  void onScannedValue(String value) async {
    print("onScannedValue method triggered with value $value");
    await Future.delayed(Duration.zero);

    if (!mounted)
      return; // Add this line to check if the widget is still mounted

    setState(() {
      _selectedIndex = 2; // Assuming API Card is at index 2
    });
    lastScannedValue.value = value; // Update the ValueNotifier
    updateIndex(_selectedIndex, value);
  }

  @override
  void initState() {
    super.initState();
    // Cacher la barre de notification lorsque le widget est créé
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Rétablir l'affichage de la barre de notification lorsque le widget est détruit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _login() async {
    _username = _usernameController.text;
    var token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImEiLCJpYXQiOjE2OTEwMDYwNTF9.YzSufVn_6GkacafbWtPSeak4avgVUAevpHFbB-w7xwM';

    // Premier appel API POST pour créer l'utilisateur
    var response = await http.post(
      Uri.parse('https://apigame.baptistefremaux.fr/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': _username,
      }),
    );

    if (response.statusCode == 201) {
      // Si la création de l'utilisateur réussit (code 201), décoder la réponse JSON
      var jsonResponse = json.decode(response.body);

      // Extraire l'ID de l'utilisateur de la réponse
      var userId = jsonResponse['id'];
      _roomId = _roomIdController.text;

      // Deuxième appel API PUT pour ajouter l'utilisateur à la session (room)
      var response2 = await http.put(
        Uri.parse(
            'https://apigame.baptistefremaux.fr/sessions/$_roomId/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response2.statusCode == 200) {
        // Si l'ajout à la session réussit (code 200), mettez à jour l'état _userLoggedIn pour afficher la barre de navigation
        setState(() {
          _userLoggedIn = true;
        });

        // Troisième appel API POST pour effectuer l'action souhaitée après la création de l'utilisateur et son ajout à la session
        var response3 = await http.post(
          Uri.parse(
              'https://apigame.baptistefremaux.fr/sessions/$_roomId/etats'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            // Mettez ici les données que vous souhaitez envoyer dans la requête POST
          }),
        );

        // Gérez la réponse de la troisième requête si nécessaire
        if (response3.statusCode == 200) {
          // Traitement de la réponse si besoin
        } else {
          // Gestion des erreurs si la troisième requête échoue
          print('Échec de la troisième requête : ${response3.statusCode}');
        }
      } else {
        // Gestion des erreurs si l'ajout à la session échoue
        print('Échec de l\'ajout à la session : ${response2.statusCode}');
      }
    } else {
      // Gestion des erreurs si la création de l'utilisateur échoue
      print('Échec de la création de l\'utilisateur : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_userLoggedIn) {
      // Si l'utilisateur n'est pas connecté, affichez la page de connexion
      return LoginPage(
        usernameController: _usernameController,
        roomIdController: _roomIdController,
        onLoginSuccess: _login,
      );
    } else {
      // Si l'utilisateur est connecté, affichez la barre de navigation inférieure et les autres pages
      return Scaffold(
        bottomNavigationBar: SalomonBottomBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xff6200ee),
            unselectedItemColor: const Color(0xff757575),
            onTap: (index) {
              if (index == 3 && scanPageKey.currentState != null)
                scanPageKey.currentState!.resetScanner();
              updateIndex(index);
            },
            items: _navBarItems),
        body: _buildBody(_selectedIndex),
      );
    }
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return ChangelogPage();
      case 1:
        return Sensors(
          key: nfcPageKey,
          onNfcScanned: onScannedValue,
        );
      case 2:
        return ValueListenableBuilder<String>(
          valueListenable: lastScannedValue,
          builder: (context, value, child) {
            print("Rebuilding ApiCard with value: $value");
            print("Rebuilding ApiCard with room id: $_roomId");
            return ApiCard(
                id: value,
                resetScanner: () => scanPageKey.currentState!.resetScanner(),
                selectedRoomId: _roomId);
          },
        );
      case 3:
        return ScanPage(
          key: scanPageKey,
          resetScanner: () => scanPageKey.currentState!.resetScanner(),
          onScannedValue: onScannedValue,
        );
      case 4: // Ajoutez cette condition pour afficher la page des statistiques
        return StatsPage(selectedRoomId: _roomId, selectedUsername: _username);
      default:
        return Container(); // Remplacez ceci par une page par défaut si nécessaire
    }
  }

  final _navBarItems = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text("Home"),
      selectedColor: Colors.purple,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.favorite_border),
      title: const Text("Likes"),
      selectedColor: Colors.pink,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.search),
      title: const Text("Search"),
      selectedColor: Colors.orange,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.person),
      title: const Text("User"),
      selectedColor: Colors.teal,
    ),
    SalomonBottomBarItem(
      // Ajoutez cet élément pour représenter la page des statistiques
      icon: const Icon(Icons.bar_chart),
      title: const Text("Stats"),
      selectedColor: Colors.blue,
    ),
  ];
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController roomIdController;
  final VoidCallback onLoginSuccess;

  LoginPage({
    required this.usernameController,
    required this.roomIdController,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: roomIdController,
              decoration: InputDecoration(
                labelText: "Room ID",
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Appeler la fonction de rappel pour indiquer que l'utilisateur s'est connecté avec succès
                onLoginSuccess();
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
