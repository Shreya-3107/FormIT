import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../module_pages/ModuleRecords.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<dynamic> modules = [];
  bool _isLoading = true;
  String orgName = '';

  @override
  void initState() {
    super.initState();
    fetchModulesAndOrg();
  }

  Future<void> fetchModulesAndOrg() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgId = prefs.getString('orgId');
    final storedOrgName = prefs.getString('orgName')!.toUpperCase();

    setState(() {
      orgName = storedOrgName;
    });

    if (token == null || orgId == null) {
      print("No token or orgId found.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getModulesForOrg + orgId!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        modules = data;
        _isLoading = false;
      });
    } else {
      print("Error fetching modules: ${response.body}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Builder(
        builder: (BuildContext context) {
          return Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade100, Colors.indigo.shade300],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      orgName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // More drawer items can be added here
              ],
            ),
          );
        },
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
            padding: const EdgeInsets.all(20.0),
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading ? const Center(child: CircularProgressIndicator()) :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [Colors.indigo, Colors.grey],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                            },
                            child: Text(
                              orgName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pixel',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.indigo),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: modules.isEmpty ? Center(child: Text("No modules found")) :
                      GridView.builder(
                        itemCount: modules.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the ModuleRecords page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModuleRecords(moduleId: module['_id'], moduleName: module['name']),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.shade100.withOpacity(0.6),
                                    Colors.indigo.shade500.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.shade200,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_copy_rounded, size: 40, color: Colors.indigo.shade900),
                                  const SizedBox(height: 8),
                                  Text(
                                    module['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust the margin around the button
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/manualModuleCreation');
          },
          backgroundColor: Colors.indigo[400], // Background color
          child: const Icon(
            Icons.add,
            color: Colors.white, // White color for the icon
          ),
        ),
      ),
    );
  }
}
