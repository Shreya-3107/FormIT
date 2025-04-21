import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/screens/module_pages/ModuleRecords.dart';
import '../../constants/api_constants.dart';

class RecordDetailsPage extends StatefulWidget {
  final String moduleId;
  final String recordId;
  final String moduleName;

  const RecordDetailsPage({
    super.key,
    required this.moduleId,
    required this.recordId,
    required this.moduleName,
  });

  @override
  State<RecordDetailsPage> createState() => _RecordDetailsPageState();
}

class _RecordDetailsPageState extends State<RecordDetailsPage> {
  List<dynamic> fieldData = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRecordDetails();
  }

  Future<void> fetchRecordDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
        error = "No token found. Please log in.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getRecordDetails + "${widget.moduleId}/${widget.recordId}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['record']['data'];
        setState(() {
          fieldData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.navigate_before),
                        onPressed: () => {
                          Navigator.pop(context)
                        }
                    ),
                     Text(
                      "Record Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: fieldData.length,
                    itemBuilder: (context, index) {
                      final item = fieldData[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${item['fieldName']}: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item['value'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: 55,
            right: 16,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    //TODO: decide this
                  },
                  label: const Icon(
                    Icons.edit,
                    color: Color(0xEEEEEEFF), // Icon color
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[400], // Background color of the button
                    shape: CircleBorder(), // Makes the button circular
                    padding: const EdgeInsets.all(20), // Adjust padding for circular shape
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    //TODO: decide this
                  },
                  label: const Icon(
                    Icons.delete,
                    color: Color(0xEEEEEEFF), // Icon color
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAB4646), // Background color of the button
                    shape: CircleBorder(), // Makes the button circular
                    padding: const EdgeInsets.all(20), // Adjust padding for circular shape
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }
}
