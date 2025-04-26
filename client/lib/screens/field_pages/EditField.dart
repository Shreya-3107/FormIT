import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';

class EditFieldsPage extends StatefulWidget {
  final String fieldId;
  final String initialFieldName;
  final String fieldType; // always 'text'

  const EditFieldsPage({Key? key, required this.fieldId, required this.initialFieldName, required this.fieldType}) : super(key: key);

  @override
  _EditFieldsPageState createState() => _EditFieldsPageState();
}

class _EditFieldsPageState extends State<EditFieldsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _loading = false;
  double _scale = 1.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFieldName);
  }

  Future<void> _updateField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _error = "No token found.";
        _loading = false;
      });
      return;
    }

    try {

      final response = await http.put(
        Uri.parse('${ApiConstants.updateFieldDetails}${widget.fieldId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'type': widget.fieldType
        }),
      );

      if (response.statusCode == 200)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully')),
        );
        Navigator.pop(context, true); // <= return true to trigger refresh
      }
      else
      {
        setState(() {
          _error = "Failed to update field";
        });
      }
    }
    catch (e)
    {
      setState(() {
        _error = "Something went wrong";
      });
    }
    finally
    {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                                  "Edit Field",
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
                          controller: TextEditingController(text: widget.fieldType),
                          labelText: 'Field Type',
                          readOnly: true,
                          enabled: false,
                          validator: (_) => null,
                        ),

                        const SizedBox(height: 24),

                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),

                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: _loading ? null : _updateField,
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
                                child: _loading
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
      ),
    );
  }
}
