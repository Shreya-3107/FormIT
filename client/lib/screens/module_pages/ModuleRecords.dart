import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';

import '../record_pages/RecordCreation.dart';
import '../record_pages/RecordDetails.dart';

class ModuleRecords extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const ModuleRecords({super.key, required this.moduleId, required this.moduleName});

  @override
  State<ModuleRecords> createState() => _ModuleRecordsState();
}

class _ModuleRecordsState extends State<ModuleRecords> {
  List<dynamic> records = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No token found. Please login.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getRecordsForModule + widget.moduleId),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          records = data['records']; // ✅ fix here
          _isLoading = false;
        });
      }
      else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load records: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching data. Please try again later.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
        backgroundColor: Colors.indigo[200],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : records.isEmpty
          ? const Center(child: Text('No records found'))
          : ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final id = record['recordId'] ?? '';
            final title = record['title'] ?? '';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('$id : $title'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordDetailsPage(
                        moduleId: widget.moduleId,
                        recordId: record['recordId'].toString(),
                        moduleName: widget.moduleName,
                      ),
                    ),
                  );
                },

              ),
            );
          }


      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust the margin around the button
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordCreation(
                  moduleId: widget.moduleId,
                  moduleName: widget.moduleName,
                ),
              ),
            );

            if (result == true) {
              fetchRecords(); // Or whatever your refresh logic is
            }
          },

          backgroundColor: Colors.indigo[400], // Background color
          child: const Icon(
            Icons.add,
            color: Colors.white, // White color for the icon
          ),
        ),
      ),
    );
  }
}