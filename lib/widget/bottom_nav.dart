import 'package:flutter/material.dart';
// import 'package:app/screens/checkout/checkout.dart';
// import 'package:app/screens/home/home.dart';
import 'package:app/login/login.dart';
import 'package:app/camera/camera.dart';
import 'package:app/card/card.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
// import 'package:app/screens/profile/profile.dart';
// import 'package:app/screens/registration/registration.dart';
// import 'package:app/screens/salesRule/sales_rule.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  List<SalomonBottomBarItem> itemsList = [
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
      title: const Text("user"),
      selectedColor: Colors.teal,
    )
  ];

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 0;
    return Scaffold(
        bottomNavigationBar: SalomonBottomBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xff6200ee),
      unselectedItemColor: const Color(0xff757575),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: itemsList,
    ));
  }

  void onTabTapped(int index) {
    setState(() {});

    switch (itemsList[index].title) {
      case "Likes":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanPage(),
            ),
          );
        }
        break;

      // case "Profil":
      //   {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => ScanPage(),
      //       ),
      //     );
      //   }
      //   break;

      default:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApiCard(id: "2Diamond"),
            ),
          );
        }
        break;
    }
  }
}
