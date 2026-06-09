// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'data/customer_database.dart';
import 'data/task_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Assuming google-services.json is in android/app)
  await Firebase.initializeApp();

  // Load Local Data
  await CustomerDatabase.loadData();
  await TaskDatabase.loadData();

  runApp(const TailerApp());
}

class TailerApp extends StatelessWidget {
  const TailerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M Khalil Tailors',
      theme: ThemeData(
        primaryColor: const Color(0xFF2F4F4F),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2F4F4F),
          secondary: Colors.orange,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // <--- STARTS HERE
    );
  }
}
