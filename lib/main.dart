import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exam_3_125/screens/login_screen.dart'; // import หน้า login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // เชื่อมต่อฐานข้อมูล
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleTriage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // เปลี่ยนหน้าแรกให้เป็น LoginScreen
    );
  }
}