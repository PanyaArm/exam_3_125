import 'package:flutter/material.dart';
import 'package:exam_3_125/screens/form_screen.dart'; 
import 'package:exam_3_125/screens/display_screen.dart'; 
import 'package:exam_3_125/screens/login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final String role; // ตัวรับสิทธิ์การใช้งาน
  
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // จำนวนแท็บ (ฟอร์ม และ บอร์ด)
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TeleTriage (${widget.role})', 
            style: const TextStyle(color: Color.fromARGB(221, 236, 232, 232)),
          ),
          backgroundColor: const Color.fromARGB(255, 200, 99, 99),
          centerTitle: true,
          actions: [
            // ปุ่ม Sign Out บน AppBar
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black87),
              tooltip: 'Sign Out',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  // เอา const ออกจาก LoginScreen() แล้ว
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.red,
            tabs: [
              Tab(icon: Icon(Icons.add_box), text: "บันทึกคัดกรอง"),
              Tab(icon: Icon(Icons.view_list), text: "บอร์ดผู้ป่วย"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // เอา const ออกจาก FormScreen() แล้ว
            FormScreen(), 
            DisplayScreen(role: widget.role), 
          ],
        ),
      ),
    );
  }
}