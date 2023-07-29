import 'package:flutter/material.dart';

class ChangelogPage extends StatelessWidget {
  final String versionNumber =
      "1.0.0"; // Remplacez cela par votre numéro de version réel

  final List<String> changelogs = [
    "Version 1.0.0 - Added new feature A",
    "Version 0.9.0 - Fixed bug B",
    "Version 0.8.0 - Updated UI for screen C",
    // Ajoutez d'autres journaux de modifications ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Version Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Version Number: $versionNumber",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              "Changelogs:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: changelogs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(changelogs[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
