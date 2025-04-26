import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart'; // assuming you already have this

class EditRecordPage extends StatefulWidget {
  final String moduleId;
  final String recordId;
  final String moduleName;
  final List<dynamic> fieldData;

  const EditRecordPage({
    Key? key,
    required this.moduleId,
    required this.recordId,
    required this.moduleName,
    required this.fieldData,
  }) : super(key: key);

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> controllers;
  bool _loading = false;
  bool _saving = false;
  double _scale = 1.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var field in widget.fieldData)
        field['fieldName']: TextEditingController(text: field['value'].toString())
    };
  }

  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _error = "No token found.";
        _saving = false;
      });
      return;
    }

    List<Map<String, dynamic>> updatedData = widget.fieldData.map((field) {
      return {
        "fieldName": field['fieldName'],
        "value": controllers[field['fieldName']]!.text,
      };
    }).toList();

    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.updateRecordDetails}${widget.moduleId}/${widget.recordId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"data": updatedData}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully')),
        );
        Navigator.pop(context, true); // <= return true to trigger refresh
      } else {
        setState(() {
          _error = "Failed to update: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                                "Edit Record",
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

                      ...controllers.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GradientLabelTextField(
                          controller: entry.value,
                          labelText: entry.key,
                          validator: (value) =>
                          value == null || value.isEmpty ? "${entry.key} is required" : null,
                        ),
                      )),

                      const SizedBox(height: 8),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: _saving ? null : _updateRecord,
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
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
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
