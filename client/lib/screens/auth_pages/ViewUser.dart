import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FormIT/constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import 'EditUser.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Main content area with glass effect
              Expanded(
                child: GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.navigate_before),
                                color: Colors.indigo[800],
                                onPressed: () => Navigator.pop(context)
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
                                  "View User",
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
                        SizedBox(height: 20),
                        // Fields displayed with fixed height instead of Expanded
                        Column(
                          children: List.generate(3, (index) {
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
                          }),
                        ),
                        // Spacer pushes the button to the bottom
                        Spacer(),
                        // Edit button at the bottom center
                        Center(
                          child: GestureDetector(
                            onTap: ()  async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditUser(
                                    initialName: userDetails['name'],
                                    initialEmail: userDetails['email'],
                                    initialUsername: userDetails['username'],
                                  ),
                                ),
                              );

                              if (updated == true) {
                                _fetchUserDetails(); // your method to reload the record!
                              }
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
                                    colors: [Colors.indigo.shade400, Colors.indigo.shade200],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Edit User',
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}