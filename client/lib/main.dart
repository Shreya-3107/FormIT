import 'package:flutter/material.dart';
import 'package:trial/DashBoard.dart';
import 'package:trial/NewUser.dart';
import 'dart:ui';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In & Sign Up',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const SignInSignUpPage(),
    );
  }
}

class SignInSignUpPage extends StatefulWidget {
  const SignInSignUpPage({super.key});

  @override
  _SignInSignUpPageState createState() => _SignInSignUpPageState();
}

class _SignInSignUpPageState extends State<SignInSignUpPage> {
  bool isSignIn = true;

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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/header_image.png',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.yellow.shade900,
                              Colors.yellowAccent.shade700,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          isSignIn ? 'Login' : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (isSignIn)
                        LoginForm(
                          onSwitch: () {
                            setState(() {
                              isSignIn = false;
                            });
                          },
                          onSignIn: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  DashBoard()),
                            );
                          },
                        )
                      else
                        SignUpForm(
                          onSwitch: () {
                            setState(() {
                              isSignIn = true;
                            });
                          },
                          onSignUp: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NewUser()),
                            );
                          },
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

class LoginForm extends StatelessWidget {
  final VoidCallback onSwitch;
  final VoidCallback onSignIn;

  const LoginForm(
      {Key? key, required this.onSwitch, required this.onSignIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientLabelTextField(labelText: 'Email'),
        const SizedBox(height: 10),
        const GradientLabelTextField(labelText: 'Password', obscureText: true),
        const SizedBox(height: 20),
        GradientButton(
          onPressed: onSignIn,
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onSwitch,
          child: const Text(
            "Don't have an account? Sign up",
            style: TextStyle(color: Colors.indigo),
          ),
        ),
      ],
    );
  }
}

class SignUpForm extends StatelessWidget {
  final VoidCallback onSwitch;
  final VoidCallback onSignUp;

  const SignUpForm(
      {Key? key, required this.onSwitch, required this.onSignUp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientLabelTextField(labelText: 'Full Name'),
        const SizedBox(height: 10),
        const GradientLabelTextField(labelText: 'Company Name'),
        const SizedBox(height: 10),
        const GradientLabelTextField(labelText: 'Email'),
        const SizedBox(height: 10),
        const GradientLabelTextField(labelText: 'Password', obscureText: true),
        const SizedBox(height: 10),
        const GradientLabelTextField(
          labelText: 'Confirm Password',
          obscureText: true,
        ),
        const SizedBox(height: 20),
        GradientButton(
          onPressed: onSignUp,
          child: const Text(
            'Sign Up',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onSwitch,
          child: const Text(
            "Already have an account? Sign in",
            style: TextStyle(color: Colors.indigo),
          ),
        ),
      ],
    );
  }
}

class GradientLabelTextField extends StatelessWidget {
  final String labelText;
  final bool obscureText;

  const GradientLabelTextField({
    Key? key,
    required this.labelText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.indigo.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.indigo.shade800,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const GradientButton(
      {super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade300, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;

  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(100),
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(
            color: Colors.white.withAlpha(100),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: child,
        ),
      ),
    );
  }
}

