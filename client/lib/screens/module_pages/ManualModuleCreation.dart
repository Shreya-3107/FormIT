import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:trial/screens/dashboard/Dashboard.dart';
import 'package:trial/constants/api_constants.dart';
import '../field_pages/FieldCreation.dart';
import '../../widgets/GlassContainer.dart';

class ManualModuleCreation extends StatefulWidget {
  const ManualModuleCreation({super.key});

  @override
  State<ManualModuleCreation> createState() => _ManualModuleCreationState();
}

class _ManualModuleCreationState extends State<ManualModuleCreation> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;
  double _scale = 1.0;

  void createModule() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgId = prefs.getString('orgId');

    final name = _nameController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty || description.isEmpty || token == null || orgId == null) return;

    setState(() => _isLoading = true);

    final moduleRes = await http.post(
      Uri.parse(ApiConstants.createModule),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        "name": name,
        "description": description,
        "orgId": orgId,
      }),
    );

    if (moduleRes.statusCode == 201) {
      final responseData = json.decode(moduleRes.body);
      final moduleMap = responseData['module'];
      String moduleId = moduleMap['_id'];
      print('Module $name created successfully with ID $moduleId');

      // Step 2: Navigate to FieldCreation for this module
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FieldCreation(
            moduleId: moduleId,
            moduleName: name,
            moduleDescription: description,
          ),
        ),
      );
    } else {
      print('Failed to create module $name: ${moduleRes.body}');
    }

    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.indigo.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth < 600 ? double.infinity : 500,
                    ),
                    child: GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                IconButton(
                                    icon: Icon(Icons.navigate_before),
                                    color: Colors.indigo[800],
                                    onPressed: () => {
                                      Navigator.pop(context)
                                    }
                                ),
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
                                      "Create Module",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontFamily: 'Pixel',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Module Name",
                                labelStyle: TextStyle(color: Colors.indigo),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                ),
                              ),
                              style: const TextStyle(color: Colors.indigo),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descController,
                              decoration: const InputDecoration(
                                labelText: "Module Description",
                                labelStyle: TextStyle(color: Colors.indigo),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                ),
                              ),
                              style: const TextStyle(color: Colors.indigo),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 30),
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              GestureDetector(
                                onTap: createModule,
                                onTapDown: (_) => setState(() => _scale = 0.9),
                                onTapUp: (_) => setState(() => _scale = 1.0),
                                onTapCancel: () => setState(() => _scale = 1.0),
                                child: Transform.scale(
                                  scale: _scale,
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.indigo.shade300, Colors.indigo.shade100],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Create Module',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
