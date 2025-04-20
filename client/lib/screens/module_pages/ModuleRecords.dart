import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';

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
          records = data;
          _isLoading = false;
        });
      } else {
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
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Record ${record['name']}'),
              subtitle: Text('Data: ${record['data']}'),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0), // Adjust the margin around the button
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/recordCreation');
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