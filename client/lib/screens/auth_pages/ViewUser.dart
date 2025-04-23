import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial/constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';

class ViewUser extends StatefulWidget {
  @override
  _ViewUserState createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  bool isLoading = true;
  bool isError = false;
  double _scale = 1.0;
  Map<String, dynamic> userDetails = {};
  late List<String> fields;
  late List<String> userMapKeys;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details using the API
  _fetchUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          isError = true;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getUserDetails),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userDetails = json.decode(response.body)['user'];
          fields = ['Full Name', 'Username', 'Email ID'];
          userMapKeys = ['name', 'username', 'email'];
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
          ? Center(child: Text("Error fetching user details"))
          : _buildUserProfile(),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.indigo.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "User Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final field = fields[index];
                            final fieldKey = userMapKeys[index];
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
                                    "${field}: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      userDetails[fieldKey].toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => {
                          //TODO: Edit user
                        },
                        onTapDown: (_) => setState(() => _scale = 0.9),
                        onTapUp: (_) => setState(() => _scale = 1.0),
                        onTapCancel: () => setState(() => _scale = 1.0),
                        child: Transform.scale(
                          scale: _scale,
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.indigo.shade300, Colors.indigo.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Edit User',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
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
    );
  }
}
