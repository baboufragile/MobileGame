import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsPage extends StatefulWidget {
  final String selectedRoomId; // Champ pour stocker le numéro de la room
  final String selectedUsername;
  StatsPage(
      {required this.selectedRoomId,
      required this.selectedUsername}); // Nouveau constructeur
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Future<List<dynamic>> _statsData;

  @override
  void initState() {
    super.initState();
    _statsData = fetchStatsData();
  }

  Future<List<dynamic>> fetchStatsData() async {
    var token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImEiLCJpYXQiOjE2OTEwMDYwNTF9.YzSufVn_6GkacafbWtPSeak4avgVUAevpHFbB-w7xwM';
    final response = await http.get(
      Uri.parse(
          'https://apigame.baptistefremaux.fr/sessions/${widget.selectedRoomId}/etats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load stats data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _statsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text('Error: Failed to load stats data'),
            );
          } else {
            final statsList = snapshot.data! as List<dynamic>;

            // Sort statsList by "cul_sec" and "gorgees" in descending order
            statsList.sort((a, b) {
              final int? aCulSec = a['etat']?['cul_sec'] as int?;
              final int? bCulSec = b['etat']?['cul_sec'] as int?;
              final int? aGorgees = a['etat']?['gorgees'] as int?;
              final int? bGorgees = b['etat']?['gorgees'] as int?;

              if (aCulSec != null && bCulSec != null) {
                if (aCulSec != bCulSec) {
                  return bCulSec.compareTo(aCulSec);
                } else {
                  if (aGorgees != null && bGorgees != null) {
                    return bGorgees.compareTo(aGorgees);
                  }
                }
              }
              return 0;
            });

            final List<dynamic> topThreeStats =
                statsList.take(3).toList(); // Take the top three stats

            // Check if the user is present in the list
            final userStats = statsList.firstWhere(
              (stat) => stat['user']['username'] == 'YOUR_USERNAME_HERE',
              orElse: () => null,
            );

            return ListView.builder(
              itemCount: userStats != null
                  ? topThreeStats.length + 1
                  : topThreeStats.length,
              itemBuilder: (context, index) {
                // Check if it's the user's entry
                if (index == topThreeStats.length && userStats != null) {
                  final int? culSec = userStats['etat']?['cul_sec'] as int?;
                  final int? gorgees = userStats['etat']?['gorgees'] as int?;
                  final String username = userStats['user']['username'];
                  final String? rule = userStats['etat']?['rule'];
                  final bool isMaster =
                      userStats['etat']?['is_master'] ?? false;
                  final bool hasGoodJoker =
                      userStats['etat']?['hasGoodJoker'] ?? false;
                  final bool hasBadJoker =
                      userStats['etat']?['hasBadJoker'] ?? false;

                  return ListTile(
                    title: Text("User: $username"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cul Sec: ${culSec ?? 'N/A'}"),
                        Text("Gorgees: ${gorgees ?? 'N/A'}"),
                        Text("Rule: ${rule ?? 'N/A'}"),
                        if (isMaster) Text("Is Master: Yes"),
                        if (hasGoodJoker) Text("Has Good Joker: Yes"),
                        if (hasBadJoker) Text("Has Bad Joker: Yes"),
                      ],
                    ),
                  );
                }

                final statData = topThreeStats[index];

                final int? culSec = statData['etat']?['cul_sec'] as int?;
                final int? gorgees = statData['etat']?['gorgees'] as int?;
                final String username = statData['user']['username'] ?? 'N/A';
                final String? rule = statData['etat']?['rule'] ?? 'N/A';
                final bool isMaster = statData['etat']?['is_master'] ?? false;
                final bool hasGoodJoker =
                    statData['etat']?['hasGoodJoker'] ?? false;
                final bool hasBadJoker =
                    statData['etat']?['hasBadJoker'] ?? false;

                return ListTile(
                  title: Text("User: $username"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cul Sec: ${culSec ?? 'N/A'}"),
                      Text("Gorgees: ${gorgees ?? 'N/A'}"),
                      Text("Rule: ${rule ?? 'N/A'}"),
                      if (isMaster) Text("Is Master: Yes"),
                      if (hasGoodJoker) Text("Has Good Joker: Yes"),
                      if (hasBadJoker) Text("Has Bad Joker: Yes"),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
