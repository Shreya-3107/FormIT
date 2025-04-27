import 'package:formit/screens/splash_screen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:formit/screens/dashboard/Dashboard.dart';
import 'package:formit/screens/module_pages/ManualModuleCreation.dart';
import 'screens/auth_pages/NewUser.dart';
import 'screens/auth_pages/LoginPage.dart';
import 'screens/org_pages/OrgCreation.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Splashscreen(),
));

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
        '/dashboard': (context) => DashBoard(),
        '/signup': (context) => const NewUser(),
        '/login': (context) => LoginPage(),
        '/orgCreation': (context) => OrgCreation(),
        '/manualModuleCreation': (context) => ManualModuleCreation(),
      },
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Check if user is logged in
          if (snapshot.hasData && snapshot.data == true) {
             return DashBoard();
          }
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}