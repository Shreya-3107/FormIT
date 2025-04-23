import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';
import 'package:trial/screens/dashboard/Dashboard.dart';
import 'package:trial/screens/field_pages/FieldCreation.dart';
import 'package:trial/widgets/GlassContainer.dart';

class ModuleCreation extends StatefulWidget {
  final List<Map<String, String>> modules;

  ModuleCreation({Key? key, required this.modules}) : super(key: key);

  @override
  _ModuleCreationState createState() => _ModuleCreationState();
}

class _ModuleCreationState extends State<ModuleCreation> {
  List<bool> _selectedModules = [];
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedModules = List.generate(widget.modules.length, (_) => false);
  }

  Future<void> createModuleAndStartFieldCreation(String moduleName, String moduleDescription) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgId = prefs.getString('orgId');

    // Step 1: Create the module
    final response = await http.post(
      Uri.parse(ApiConstants.createModule),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': moduleName,
        'description': moduleDescription,
        'orgId': orgId
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final moduleMap = responseData['module'];
      String moduleId = moduleMap['_id'];
      print('Module $moduleName created successfully with ID $moduleId');

      // Step 2: Navigate to FieldCreation for this module
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FieldCreation(
            moduleId: moduleId,
            moduleName: moduleName,
            moduleDescription: moduleDescription,
          ),
        ),
      );
    } else {
      print('Failed to create module $moduleName: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 40),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [Colors.indigo, Colors.grey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          "Select Modules",
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'Pixel',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.modules.length,
                        itemBuilder: (context, index) {
                          final module = widget.modules[index];
                          return ListTile(
                            title: Text(
                              module['name'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              module['description'] ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Checkbox(
                              value: _selectedModules[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedModules[index] = value!;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          List<Map<String, String>> selectedModules = [];
          for (int i = 0; i < widget.modules.length; i++) {
            if (_selectedModules[i]) {
              selectedModules.add(widget.modules[i]);
            }
          }

          for (int i = 0; i < selectedModules.length; i++) {
            String moduleName = selectedModules[i]['name']!;
            String moduleDescription = selectedModules[i]['description']!;
            await createModuleAndStartFieldCreation(moduleName, moduleDescription);
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashBoard()
            ),
          );
        },
        onTapDown: (_) => setState(() => _scale = 0.9),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Transform.scale(
          scale: _scale,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade300, Colors.indigo.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Create Modules',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
