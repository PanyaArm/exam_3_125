// ignore_for_file: unused_import

import 'package:exam_3_125/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:exam_3_125/models/patient_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // บัญชีจำลอง
  final String adminEmail = "admin@test.com";
  final String operatorEmail = "operator@test.com";

  void _login(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(userRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เข้าสู่ระบบ TeleTriage"),
        backgroundColor: Colors.red.shade200,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_heart, size: 100, color: Colors.red),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("Login as Admin (ทำได้ทุกอย่าง)"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 50),
                  backgroundColor: Colors.red.shade100),
              onPressed: () => _login("admin"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("Login as Operator (เพิ่ม/ดู เท่านั้น)"),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 50),
                  backgroundColor: Colors.blue.shade100),
              onPressed: () => _login("operator"),
            ),
          ],
        ),
      ),
    );
  }
}