
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personaltaskmanagerapp/home_screen.dart';
import 'package:personaltaskmanagerapp/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system); // Default to system theme
}

final themeNotifier = ThemeNotifier();

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Personal Task",
          theme: ThemeData.light(), // Light theme
          darkTheme: ThemeData.dark(), // Dark theme
          themeMode: themeMode, // Control theme mode here
          home: _auth.currentUser != null ? HomeScreen() : LoginScreen(),
        );
      },
    );
  }
}
