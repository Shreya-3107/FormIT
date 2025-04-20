import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For storing JWT
import '../module_pages//ModuleCreation.dart'; // Adjust this to your correct import for ModuleCreation
import '../../constants/api_constants.dart';
import '../../widgets/GlassContainer.dart';
import '../../widgets/GradientTextField.dart';

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  double _scale = 1.0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method to handle user creation (signup)
  Future<void> createUser() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.signup),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'email': _emailController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201)
      {
        final responseData = json.decode(response.body);
        final loginResponse = await http.post(
          Uri.parse(ApiConstants.login),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (loginResponse.statusCode == 200)
        {
          final loginData = json.decode(loginResponse.body);
          final token = loginData['token'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          Navigator.pushReplacementNamed(context, '/orgCreation'); // 👈 Route to OrgCreation
        }
        else
        {
          // Login failed after signup
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Auto-login Failed"),
              content: Text("Please try logging in manually."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    }
    catch (e)
    {
      print('Signup error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Network Error"),
          content: Text("Could not reach server. Try again later."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Method to handle login and obtain JWT token
  Future<void> loginUser() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200)
      {
        final data = json.decode(response.body);
        String jwtToken = data['token'];

        // Save JWT token in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', jwtToken);

        // Navigate to dashboard screen
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ModuleCreation()),
        // );
      }
      else
      {
        final error = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Login Failed"),
            content: Text(error['message'] ?? 'Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
    catch (e)
    {
      print('Login error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Network Error"),
          content: Text("Could not reach server. Try again later."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 40),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [Colors.indigo, Colors.grey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'Pixel',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientLabelTextField(controller: _nameController, labelText: 'Full Name'),
                      const SizedBox(height: 10),
                      GradientLabelTextField(controller: _emailController, labelText: 'Email'),
                      const SizedBox(height: 10),
                      GradientLabelTextField(controller: _usernameController, labelText: 'Username'),
                      const SizedBox(height: 10),
                      GradientLabelTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade700)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              "Login here",
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: createUser,
          onTapDown: (_) => setState(() => _scale = 0.9),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          child: Transform.scale(
            scale: _scale,
            child: Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.indigo.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}