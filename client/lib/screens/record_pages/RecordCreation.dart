import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';

class RecordCreation extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const RecordCreation({super.key, required this.moduleId, required this.moduleName});

  @override
  State<RecordCreation> createState() => _RecordCreationState();
}

class _RecordCreationState extends State<RecordCreation> {
  List<Map<String, dynamic>> fields = [];
  Map<String, TextEditingController> controllers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  void suggestFieldValue(String fieldName, String fieldType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgName = prefs.getString('orgName');
    final orgDescription = prefs.getString('orgDescription');

    if (token == null) return;

    final response = await http.post(
      Uri.parse(ApiConstants.suggestFieldValues),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "name": fieldName,
        "type": fieldType,
        "moduleName": widget.moduleName,
        "orgName": orgName,
        "orgDescription": orgDescription
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final suggestion = data['value'] ?? '';

      setState(() {
        controllers[fieldName]?.text = suggestion;
      });
    } else {
      print("Failed to suggest field value: ${response.body}");
    }
  }


  Future<void> fetchFields() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("No token found in SharedPreferences");
      return;
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getFieldsForModule + widget.moduleId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List fieldList = data['fields'];

      setState(() {
        fields = fieldList.map((f) => {
          'name': f['name'],
          'type': f['type'],
        }).toList();
        for (var field in fields) {
          controllers[field['name']] = TextEditingController();
          controllers[field['type']] = TextEditingController();
        }
        isLoading = false;
      });
    } else {
      print("Failed to load fields: ${response.statusCode} ${response.body}");
    }
  }


  Future<void> submitRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final orgId = prefs.getString('orgId');

    if (token == null || orgId == null) return;

    final data = fields.map((f) => {
      "fieldName": f['name'],
      "value": controllers[f['name']]?.text ?? '',
    }).toList();

    final response = await http.post(
      Uri.parse(ApiConstants.createRecord),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "orgId": orgId,
        "moduleId": widget.moduleId,
        "data": data,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true); // Signal success
    } else {
      print("Failed to create record: ${response.body}");
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                "New ${widget.moduleName} Record",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Pixel',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...fields.map((field) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: GradientLabelTextField(
                          controller: controllers[field['name']]!,
                          labelText: field['name'],
                          suffixIcon: IconButton(
                              icon: Icon(Icons.lightbulb_outline_rounded),
                              onPressed: () => suggestFieldValue(field['name'], field['type']),
                              color: Colors.indigo),
                        ),
                      )),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: submitRecord,
                        child: Container(
                          width: 160,
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
                              'Submit Record',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ),
                        ),
                      )
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
