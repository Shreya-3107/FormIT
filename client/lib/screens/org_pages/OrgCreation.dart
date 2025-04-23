import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/api_constants.dart';
import '../../widgets/GradientTextField.dart';
import '../../widgets/GlassContainer.dart';
import '../module_pages/ModuleCreation.dart'; // Import the ModuleCreation page

class OrgCreation extends StatefulWidget {
  const OrgCreation({super.key});

  @override
  State<OrgCreation> createState() => _OrgCreationState();
}

class _OrgCreationState extends State<OrgCreation> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  double _scale = 1.0;

  // Fetch module recommendations based on industry and description
  Future<List<Map<String, String>>> fetchRecommendedModules(String industry, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final moduleSuggestionResponse = await http.post(
      Uri.parse(ApiConstants.suggestModules),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'industry': _industryController.text,
        'description': _descriptionController.text,
      }),
    );

    if (moduleSuggestionResponse.statusCode == 200) {
      Map<String, dynamic> data = json.decode(moduleSuggestionResponse.body);
      List<Map<String, String>> modules = [];
      // Assuming the API returns a list of module names and descriptions
      for (var module in data['modules']) {
        modules.add({
          'name': module['name'],
          'description': module['description']
        });
      }
      return modules;
    } else {
      throw Exception('Failed to load recommended modules');
    }
  }

  // Create the organization
  Future<void> createOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(ApiConstants.createOrg),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'orgName': _orgNameController.text,
        'industry': _industryController.text,
        'description': _descriptionController.text,
      }),
    );

    if (response.statusCode == 201) {
      // After creating the org, fetch recommended modules
      final responseData = json.decode(response.body);
      final orgMap = responseData['org'];
      final orgId = orgMap['_id'];
      final orgName = orgMap['orgName'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('orgId', orgId);
      await prefs.setString('orgName', orgName);

      try {
        List<Map<String, String>> recommendedModules = await fetchRecommendedModules(
            _industryController.text, _descriptionController.text);

        // Pass the modules to the next screen (ModuleCreation)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleCreation(modules: recommendedModules),
          ),
        );
      } catch (e) {
        print('Error fetching recommended modules: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Failed to fetch module recommendations. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      final error = json.decode(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Creation Failed"),
          content: Text(error['message'] ?? 'Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
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
                                "Create Organization",
                                style: TextStyle(
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
                      GradientLabelTextField(
                        controller: _orgNameController,
                        labelText: 'Organization Name',
                      ),
                      const SizedBox(height: 10),
                      GradientLabelTextField(
                        controller: _industryController,
                        labelText: 'Industry',
                      ),
                      const SizedBox(height: 10),
                      GradientLabelTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: createOrganization,
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
                                'Create Organization',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
  }
}
