import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';

class EditUser extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialUsername;

  const EditUser({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialUsername,
  });

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();
  double _scale = 1.0;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _usernameController = TextEditingController(text: widget.initialUsername);
  }

  Future<void> _updateUser() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() => _error = "You are not logged in.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.put(
        Uri.parse(ApiConstants.updateUserDetails),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
        }),
      );

      setState(() => _loading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      }
      else {
        final data = json.decode(response.body);

        // Extract duplicate error code
        final errorResponse = data['error']?['errorResponse'];
        if (errorResponse != null && errorResponse['code'] == 11000) {
          final conflictField = errorResponse['keyPattern']?.keys.first ?? 'field';
          setState(() {
            _error = "This $conflictField is already taken.";
          });
        } else {
          setState(() {
            _error = data['message'] ?? "Something went wrong.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Something went wrong.";
      });
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
          child: SingleChildScrollView(
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.navigate_before),
                              color: Colors.indigo[800],
                              onPressed: () => {
                                Navigator.pop(context, true)
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
                              child: const Text(
                                "Edit User",
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
                      const SizedBox(height: 24),

                      GradientLabelTextField(
                          controller: _nameController,
                          labelText: 'Name',
                          validator: (value) =>
                            value == null || value.isEmpty ? "Name is required" : null,
                      ),

                      const SizedBox(height: 16),

                      GradientLabelTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Email is required";
                            final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
                            return !emailRegex.hasMatch(value) ? "Enter a valid email" : null;
                          },
                      ),

                      const SizedBox(height: 16),
                      
                      GradientLabelTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          validator: (value) =>
                            value == null || value.isEmpty ? "Username is required" : null,
                      ),

                      const SizedBox(height: 24),

                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: _loading ? null : _updateUser,
                        onTapDown: (_) => setState(() => _scale = 0.9),
                        onTapUp: (_) => setState(() => _scale = 1.0),
                        onTapCancel: () => setState(() => _scale = 1.0),
                        child: Transform.scale(
                          scale: _scale,
                          child: Container(
                            width: 100,
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
                                'Save',
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
