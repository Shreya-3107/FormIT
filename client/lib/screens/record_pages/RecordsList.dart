import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';
import 'package:trial/screens/dashboard/Dashboard.dart';
import 'package:trial/widgets/GlassContainer.dart';
import '../field_pages/FieldsList.dart';
import '../record_pages/RecordCreation.dart';
import '../record_pages/RecordDetails.dart';

class Recordslist extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const Recordslist({super.key, required this.moduleId, required this.moduleName});

  @override
  State<Recordslist> createState() => RecordslistState();

}

class RecordslistState extends State<Recordslist> {
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
          records = data['records'];
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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.home),
                        color: Colors.indigo[800],
                        onPressed: () => {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => DashBoard()),
                            (Route<dynamic> route) => false,  // This removes all previous routes
                          )
                        }
                    ),
                    SizedBox(width: 10),
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
                          widget.moduleName,
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : records.isEmpty
                      ? const Center(child: Text('No records found'))
                      : GlassContainer(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final id = record['recordId'] ?? '';
                        final title = record['title'] ?? '';

                        return GestureDetector(
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
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade50,
                                  Colors.indigo.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.shade100,
                                  blurRadius: 8,
                                  offset: const Offset(0, 1),
                                )]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Title: $title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ID: $id',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 8,
            right: 8,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FieldsList(
                          moduleId: widget.moduleId,
                          moduleName: widget.moduleName,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.indigo[400],
                  child: const Icon(Icons.dashboard_rounded, color: Color(0xEEEEEEFF)),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
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
                      fetchRecords();
                    }
                  },
                  backgroundColor: Colors.indigo[400],
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
