import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FormIT/screens/record_pages/RecordsList.dart';
import '../../constants/api_constants.dart';
import 'EditRecord.dart';

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

  Future<void> _confirmDelete(BuildContext context, String moduleId, String recordId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteRecord(moduleId, recordId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Recordslist(moduleId: widget.moduleId, moduleName: widget.moduleName),
        ),
      );
    }
  }

  Future<void> _deleteRecord(String moduleId, String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.delete(
      Uri.parse('${ApiConstants.deleteRecordDetails}$moduleId/$recordId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Record deleted")),
      );
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete record")),
      );
    }
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.indigo.shade100],
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
          child: GlassContainer2(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [Colors.indigo, Colors.grey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          'Record Details',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixel',
                            color: Colors.white,
                          ),
                        ),
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
            bottom: 8,
            right: 8,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRecordPage(
                          moduleId: widget.moduleId,
                          recordId: widget.recordId,
                          moduleName: widget.moduleName,
                          fieldData: fieldData,
                        ),
                      ),
                    );

                    if (updated == true) {
                      fetchRecordDetails(); // your method to reload the record!
                    }

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
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _confirmDelete(context, widget.moduleId, widget.recordId);
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

class GlassContainer2 extends StatelessWidget {
  final Widget child;
  const GlassContainer2({super.key, required this.child});

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
