import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_pages/NewUser.dart';
import 'screens/auth_pages/LoginPage.dart';
import 'screens/org_pages/OrgCreation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormIT: Custom App Builder',
      debugShowCheckedModeBanner: false,
      routes: {
        '/signup': (context) => const NewUser(),
        '/login': (context) => LoginPage(),
        '/orgCreation': (context) => OrgCreation(),
      },
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
             return OrgCreation(); //replace this to homepage call
          }
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}