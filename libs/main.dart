import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VyshuTutorApp());
}

class VyshuTutorApp extends StatelessWidget {
  const VyshuTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vyshu AI Tutor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
