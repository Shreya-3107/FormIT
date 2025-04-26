import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualFieldCreation extends StatefulWidget {
  final String moduleId;

  const ManualFieldCreation({Key? key, required this.moduleId}) : super(key: key);

  @override
  State<ManualFieldCreation> createState() => _ManualFieldCreationState();
}

class _ManualFieldCreationState extends State<ManualFieldCreation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  String? _error;
  double _scale = 1.0;

  Future<void> _createField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final orgId = prefs.getString('orgId');

      final response = await http.post(
        Uri.parse(ApiConstants.createField),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'type': 'text',
          'moduleId': widget.moduleId,
          'orgId': orgId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field created successfully')),
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        setState(() => _error = data['message'] ?? 'Error creating field');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.navigate_before),
                            color: Colors.indigo[800],
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [Colors.indigo, Colors.grey],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                              },
                              child: const Text(
                                "Create Field",
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
                      const SizedBox(height: 24),

                      GradientLabelTextField(
                        controller: _nameController,
                        labelText: 'Field Name',
                        validator: (value) =>
                        value == null || value.isEmpty ? "Field name is required" : null,
                      ),

                      const SizedBox(height: 16),

                      GradientLabelTextField(
                        controller: TextEditingController(text: 'text'),
                        labelText: 'Field Type',
                        enabled: false,
                      ),

                      const SizedBox(height: 24),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: _loading ? null : _createField,
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
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Save',
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
      ),
    );
  }
}
