import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';

class FieldCreation extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final String moduleDescription;

  const FieldCreation({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.moduleDescription,
  });

  @override
  _FieldCreationState createState() => _FieldCreationState();
}

class _FieldCreationState extends State<FieldCreation> {
  List<String> suggestedFields = [];
  List<bool> _selectedFields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuggestedFields();
  }

  Future<void> fetchSuggestedFields() async {
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('orgId');

    final response = await http.post(
      Uri.parse(ApiConstants.suggestFields),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'moduleName': widget.moduleName,
        'description': widget.moduleDescription,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fields = List<String>.from(data['fields']);
      setState(() {
        suggestedFields = fields;
        _selectedFields = List.generate(fields.length, (_) => false);
        _isLoading = false;
      });
    } else {
      print("Error fetching fields: ${response.body}");
      setState(() => _isLoading = false);
    }
  }

  Future<void> createFields(List<String> selectedFields) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgId = prefs.getString('orgId');

    for (var fieldName in selectedFields) {
      final response = await http.post(
        Uri.parse(ApiConstants.createField),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': fieldName,
          'type': 'text',
          'moduleId': widget.moduleId,
          'orgId': orgId,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Field "$fieldName" created!');
      } else {
        print('❌ Failed to create "$fieldName": ${response.body}');
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.blueGrey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isLoading ? const Center(child: CircularProgressIndicator()) :
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Colors.indigo, Colors.grey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        child: Text(
                          "Select Fields for ${widget.moduleName}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Pixel',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: suggestedFields.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              suggestedFields[index],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _selectedFields[index],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFields[index] = value!;
                                  });
                                },
                                activeColor: Colors.indigo,
                                side: const BorderSide(color: Colors.indigo),
                              ),
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
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {
            final selected = <String>[];
            for (int i = 0; i < suggestedFields.length; i++) {
              if (_selectedFields[i]) selected.add(suggestedFields[i]);
            }

            if (selected.isNotEmpty) {
              createFields(selected);
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 300,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
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
                'Create Fields',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
