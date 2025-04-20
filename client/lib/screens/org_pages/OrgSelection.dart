import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/widgets/GlassContainer.dart'; // Assuming this widget is available

class OrgSelection extends StatefulWidget {
  final orgs;
  const OrgSelection({super.key, required this.orgs});

  @override
  _OrgSelectionState createState() => _OrgSelectionState();
}

class _OrgSelectionState extends State<OrgSelection> {

  Future<void> setOrgAndNavigate(String orgId, String orgName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('orgId', orgId);
    await prefs.setString('orgName', orgName);

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Organization'),
        backgroundColor: Colors.indigo[200], // Adjust as per your theme
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.indigo.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassContainer(
              child: ListView.builder(
                itemCount: widget.orgs.length,
                itemBuilder: (context, index) {
                  final org = widget.orgs[index];
                  return GestureDetector(
                    onTap: () {
                      setOrgAndNavigate(org['_id'], org['orgName']);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      color: Colors.indigo.shade50, // Set the background color for the card
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          org['orgName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Tap to select this organization',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}