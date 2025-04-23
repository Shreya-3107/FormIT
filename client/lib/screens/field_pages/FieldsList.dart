import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';

class FieldsList extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const FieldsList({super.key, required this.moduleId, required this.moduleName});

  @override
  State<FieldsList> createState() => _FieldsListState();
}

class _FieldsListState extends State<FieldsList> {
  List<Map<String, dynamic>> _fields = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  Future<void> fetchFields() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await http.get(
      Uri.parse("${ApiConstants.getFieldsForModule}${widget.moduleId}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _fields = List<Map<String, dynamic>>.from(data['fields']);
        _loading = false;
      });
    } else {
      print("Failed to fetch fields: ${res.body}");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
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
                            return const LinearGradient(
                              colors: [Colors.indigo, Colors.grey],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                          },
                          child: Text(
                            "Fields in ${widget.moduleName}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Pixel',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _fields.isEmpty
                        ? const Center(child: Text("No fields found."))
                        : ListView.builder(
                      itemCount: _fields.length,
                      itemBuilder: (context, index) {
                        final field = _fields[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    field['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Type: ${field['type']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              FloatingActionButton.small(
                                onPressed: () => {},
                                backgroundColor: Colors.indigo[400],
                                child: const Icon(Icons.edit, color: Color(0xEEEEEEFF)),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: Colors.indigo[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
