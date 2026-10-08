import 'package:flutter/material.dart';
import 'package:exam_3_125/screens/form_screen.dart'; // แก้ไขชื่อไฟล์ให้ตรง
import 'package:exam_3_125/screens/display_screen.dart'; // แก้ไขชื่อไฟล์ให้ตรง
import 'package:exam_3_125/screens/login_screen.dart'; // แก้ไขชื่อไฟล์ให้ตรง
class HomeScreen extends StatelessWidget {
  final String userRole; // รับค่า Role จากหน้า Login
  const HomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("TeleTriage (${userRole.toUpperCase()})"),
          backgroundColor: Colors.red.shade200,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Sign Out",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "บันทึกคัดกรอง", icon: Icon(Icons.add_box)),
              Tab(text: "บอร์ดผู้ป่วย", icon: Icon(Icons.list_alt)),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: TabBarView(
          children: [
            const FormScreen(),
            DisplayScreen(userRole: userRole), // ส่งสิทธิ์ไปตรวจสอบที่หน้าแสดงผล
          ],
        ),
      ),
    );
  }
}