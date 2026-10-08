import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayScreen extends StatefulWidget {
  final String userRole; // รับ Role เพื่อเอามาเช็คสิทธิ์
  const DisplayScreen({super.key, required this.userRole});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันลบข้อมูล
  Future<void> deletePatient(String documentId) async {
    await _firestore.collection('referrals').doc(documentId).delete();
  }

  // แจ้งเตือนยืนยันการลบ
  Future<void> showDeleteConfirmation(String documentId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบข้อมูล'),
          content: const Text('ต้องการปิดเคสส่งต่อ / ย้ายผู้ป่วย ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await deletePatient(documentId);
                Navigator.pop(context);
              },
              child: const Text('ลบข้อมูล', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันอัปเดตข้อมูล Triage และ SpO2
  Future<void> showEditDialog(
      String documentId, String currentScore, String currentSpO2) async {
    TextEditingController scoreController = TextEditingController(text: currentScore);
    TextEditingController spo2Controller = TextEditingController(text: currentSpO2);

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('อัปเดตสัญญาณชีพ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Triage Score (1-5)'),
              ),
              TextField(
                controller: spo2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SpO2 (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('referrals').doc(documentId).update({
                  'triageScore': scoreController.text,
                  'spo2': spo2Controller.text,
                });
                Navigator.pop(context);
              },
              child: const Text('บันทึกการแก้ไข'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.userRole == 'admin'; // เช็คว่าเป็น Admin หรือไม่

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("referrals").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red.shade100,
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Triage", style: TextStyle(fontSize: 10)),
                          Text(document["triageScore"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  title: Text("${document["patientName"]} (SpO2: ${document["spo2"]}%)",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("หมอ: ${document["doctorEmail"]}"),
                  
                  // แสดงปุ่ม แก้ไข และ ลบ เฉพาะสิทธิ์ Admin (ถ้าไม่ใช่ ซ่อนปุ่ม)
                  trailing: isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => showEditDialog(
                                  document.id,
                                  document["triageScore"],
                                  document["spo2"]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  showDeleteConfirmation(document.id),
                            ),
                          ],
                        )
                      : null, // ถ้าเป็น Operator ไม่แสดงอะไรเลยที่ด้านขวา
                ),
              );
            },
          );
        },
      ),
    );
  }
}