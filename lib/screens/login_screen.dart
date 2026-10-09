import 'package:flutter/material.dart';
import 'package:exam_3_125/screens/home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String role = '';

      // ตรวจสอบบัญชีตามข้อกำหนด
      if (email == 'admin@test.com') {
        role = 'ADMIN';
      } else if (email == 'operator@test.com') {
        role = 'OPERATOR';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบบัญชีผู้ใช้นี้ในระบบ')),
        );
        return; 
      }

      // ส่งสิทธิ์ (role) ไปหน้า HomeScreen (แก้ไขชื่อตัวแปรให้ถูกต้องแล้ว)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: role),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ TeleTriage', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.red[200],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monitor_heart, color: Colors.red, size: 80),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล (Email)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => value!.isEmpty ? 'กรุณากรอกอีเมล' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน (Password)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value!.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _login,
                  child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("บัญชีทดสอบ: \nadmin@test.com | operator@test.com", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}