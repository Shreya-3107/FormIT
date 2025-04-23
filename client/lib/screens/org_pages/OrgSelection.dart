import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/widgets/GlassContainer.dart';
import 'OrgCreation.dart';

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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Select Organization',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GlassContainer(
                    child: ListView.builder(
                      itemCount: widget.orgs.length,
                      itemBuilder: (context, index) {
                        final org = widget.orgs[index];
                        return GestureDetector(
                          onTap: () {
                            setOrgAndNavigate(org['_id'], org['orgName']);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade50,
                                  Colors.indigo.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org['orgName'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to select this organization',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrgCreation(),
            ),
          );
        },
        backgroundColor: Colors.indigo[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}