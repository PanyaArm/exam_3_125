import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayScreen extends StatefulWidget {
  final String role; // ตัวรับสิทธิ์การใช้งานจาก HomeScreen
  
  const DisplayScreen({super.key, required this.role});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final CollectionReference _patientCollection =
      FirebaseFirestore.instance.collection("referrals");

  // ฟังก์ชันแก้ไขข้อมูลผู้ป่วย
  Future<void> _editPatient(String docId, Map<String, dynamic> data) async {
    TextEditingController nameController =
        TextEditingController(text: data["patientName"] ?? '');
    TextEditingController emailController =
        TextEditingController(text: data["doctorEmail"] ?? '');
    TextEditingController scoreController =
        TextEditingController(text: data["triageScore"]?.toString() ?? '');
    TextEditingController spo2Controller =
        TextEditingController(text: data["spo2"]?.toString() ?? '');

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("แก้ไขข้อมูลผู้ป่วย"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "ชื่อผู้ป่วย"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "อีเมลแพทย์"),
                ),
                TextField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Triage Score (1-5)"),
                ),
                TextField(
                  controller: spo2Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "ค่า SpO2 (0-100)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("บันทึก", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await _patientCollection.doc(docId).update({
                  "patientName": nameController.text.trim(),
                  "doctorEmail": emailController.text.trim(),
                  "triageScore": scoreController.text.trim(),
                  "spo2": spo2Controller.text.trim(),
                });
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อยแล้ว')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันลบข้อมูลผู้ป่วย
  Future<void> _deletePatient(String documentId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการลบข้อมูล"),
          content: const Text("คุณต้องการลบข้อมูลผู้ป่วยรายนี้ใช่หรือไม่?"),
          actions: [
            TextButton(
              child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("ลบข้อมูล", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _patientCollection.doc(documentId).delete();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ลบข้อมูลสำเร็จ')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _patientCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการดึงข้อมูล"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีข้อมูลผู้ป่วย"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String docId = document.id;

              // กำหนดสี Triage Score 1-5
              Color scoreColor = Colors.grey;
              String scoreStr = data["triageScore"].toString();
              if (scoreStr == "1") scoreColor = Colors.red;
              else if (scoreStr == "2") scoreColor = Colors.orange;
              else if (scoreStr == "3") scoreColor = Colors.yellow;
              else if (scoreStr == "4") scoreColor = Colors.green;
              else if (scoreStr == "5") scoreColor = Colors.blue;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scoreColor,
                    child: Text(
                      scoreStr,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text("${data["patientName"]} (${data["referralId"]})", 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "SpO2: ${data["spo2"]}% | Email: ${data["doctorEmail"]}"),
                  
                  // เงื่อนไขซ่อน/แสดงปุ่ม (RBAC)
                  trailing: widget.role == 'ADMIN'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editPatient(docId, data), // เรียกใช้งานฟังก์ชันแก้ไข
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePatient(docId),
                            ),
                          ],
                        )
                      : null, // ถ้าเป็น OPERATOR ให้ซ่อนปุ่ม
                ),
              );
            },
          );
        },
      ),
    );
  }
}