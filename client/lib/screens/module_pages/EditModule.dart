import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';
import '../../constants/api_constants.dart';

class EditModule extends StatefulWidget {
  final String moduleId;
  final String currentName;
  final String currentDescription;

  const EditModule({
    super.key,
    required this.moduleId,
    required this.currentName,
    required this.currentDescription,
  });

  @override
  State<EditModule> createState() => _EditModuleState();
}

class _EditModuleState extends State<EditModule> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool isLoading = false;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descController = TextEditingController(text: widget.currentDescription);
  }

  Future<void> updateModule() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${ApiConstants.updateModuleDetails}${widget.moduleId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Pass true to indicate success
      } else {
        final error = json.decode(response.body);
        _showError(error['message'] ?? 'Update failed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Error updating module: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          child: const Text(
                            "Edit Module",
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Pixel',
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    GradientLabelTextField(
                        controller: _nameController,
                        labelText: 'Module Name'
                    ),

                    const SizedBox(height: 12),

                    GradientLabelTextField(
                        controller: _descController,
                        labelText: 'Description',
                      minLines: 3,
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: isLoading ? null : updateModule,
                      onTapDown: (_) => setState(() => _scale = 0.9),
                      onTapUp: (_) => setState(() => _scale = 1.0),
                      onTapCancel: () => setState(() => _scale = 1.0),
                      child: Transform.scale(
                        scale: _scale,
                        child: Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade400, Colors.indigo.shade200],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
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
    );
  }
}
