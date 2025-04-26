import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FormIT/constants/api_constants.dart';
import 'package:FormIT/screens/module_pages/EditModule.dart';
import 'package:FormIT/screens/module_pages/ManualModuleCreation.dart';
import 'package:FormIT/screens/record_pages/RecordsList.dart';
import '../../widgets/GlassContainer.dart';
import '../auth_pages/NewUser.dart';
import '../auth_pages/ViewUser.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Added ScaffoldKey
  List<dynamic> modules = [];
  bool _isLoading = true;
  String orgName = '';

  @override
  void initState() {
    super.initState();
    fetchModulesForOrg();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _confirmDelete(BuildContext context, String moduleId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Module"),
        content: const Text("Are you sure you want to delete this module?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteModule(moduleId);
    }
  }

  Future<void> _deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.delete(
      Uri.parse(ApiConstants.deleteUser),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200)
    {
      // Ensure token is cleared
      await prefs.remove('token');  // Explicitly remove the token

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewUser()), // Navigate to signup
      );
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user")),
      );
    }
  }


  Future<void> _deleteModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.delete(
      Uri.parse(ApiConstants.deleteModule + moduleId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        modules.removeWhere((module) => module['_id'] == moduleId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Module deleted")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete module")),
      );
    }
  }

  Future<void> fetchModulesForOrg() async {
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
      Uri.parse(ApiConstants.getModulesForOrg + orgId),
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
      key: _scaffoldKey, // Assign ScaffoldKey to the Scaffold
      endDrawer: Builder(
        builder: (BuildContext context) {
          return Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.indigo.shade100],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      orgName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () async {
                    Navigator.of(context).pop(); // close the drawer
                    await _logout();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outlined),
                  title: const Text("View user"),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer first

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewUser(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_off_outlined, color: Color(0xFFAB4646),),
                  title: const Text("Delete user"),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer first

                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) =>
                          AlertDialog(
                            title: const Text("Delete Account"),
                            content: const Text(
                                "Are you sure you want to delete your account? This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                    );

                    if (shouldDelete == true) {
                      await _deleteUser();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewUser(),
                        ),
                      );
                    }
                  }
                ),
              ],
            ),
          );
        },
      ),

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
                          icon: Icon(Icons.settings, color: Colors.indigo[800]),
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer(); // Open the drawer directly using the key
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: modules.isEmpty ? Center(child: Text("No modules found")) :
                      GridView.builder(
                        itemCount: modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Recordslist(
                                    moduleId: module['_id'],
                                    moduleName: module['name'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50,
                                    Colors.indigo.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.folder_open_rounded,
                                            size: 40, color: Colors.indigo.shade900),
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
                                  Positioned(
                                      top: 4,
                                      right: 4,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditModule(
                                                moduleId: module['_id'], // <-- Your actual variable here
                                                currentName: module['name'], // <-- Your actual variable here
                                                currentDescription: module['description'], // <-- Your actual variable here
                                              ),
                                            ),
                                          );

                                          if (updated == true) {
                                            fetchModulesForOrg(); // your method to reload the record!
                                          }
                                        },

                                        label: const Icon(
                                          Icons.edit,
                                          color: Color(0xEEEEEEFF), // Icon color
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo[400], // Background color of the button
                                          shape: CircleBorder(), // Makes the button circular
                                          padding: const EdgeInsets.all(16), // Adjust padding for circular shape
                                        ),
                                      )
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        _confirmDelete(context, module['_id']);
                                      },
                                      label: const Icon(
                                        Icons.delete,
                                        color: Color(0xEEEEEEFF), // Icon color
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFAB4646), // Background color of the button
                                        shape: CircleBorder(), // Makes the button circular
                                        padding: const EdgeInsets.all(16), // Adjust padding for circular shape
                                      ),
                                    )
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
          heroTag: null,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManualModuleCreation(),
              ),
            );

            if (result == true) {
              fetchModulesForOrg(); // refresh modules after successful creation
            }
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
