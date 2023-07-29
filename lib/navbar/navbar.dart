import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../login/login.dart';
import '../card/card.dart'; // assuming you have 'card.dart' in the 'card' directory
import '../camera/camera.dart';
import 'package:app/home/changelog.dart';
import '../nfc.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  final scanPageKey = GlobalKey<ScanPageState>();
  final nfcPageKey = GlobalKey<SensorsState>();
  ValueNotifier<String> lastScannedValue = ValueNotifier<String>('');

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
  Widget build(BuildContext context) {
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
            return ApiCard(
                id: value,
                resetScanner: () => scanPageKey.currentState!.resetScanner());
          },
        );
      case 3:
        return ScanPage(
          key: scanPageKey,
          resetScanner: () => scanPageKey.currentState!.resetScanner(),
          onScannedValue: onScannedValue,
        );
      default:
        return SizedBox.shrink(); // default, should not occur
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
  ];
}
