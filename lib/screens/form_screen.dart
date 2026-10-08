import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // เพิ่มแพ็กเกจสำหรับคุม Input Formatter
import 'package:form_field_validator/form_field_validator.dart';
import 'package:exam_3_125/models/patient_model.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  Patient myPatient = Patient(
      referralId: '',
      patientName: '',
      doctorEmail: '',
      triageScore: '',
      spo2: '');

  final CollectionReference _patientCollection =
      FirebaseFirestore.instance.collection("referrals");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("รหัสส่งต่อผู้ป่วย (Referral ID)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  validator: RequiredValidator(errorText: "กรุณาป้อนรหัสส่งต่อ"),
                  onSaved: (val) => myPatient.referralId = val!,
                ),
                const SizedBox(height: 15),
                const Text("ชื่อ-นามสกุล / รหัส HN",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนชื่อหรือรหัสผู้ป่วย"),
                  onSaved: (val) => myPatient.patientName = val!,
                ),
                const SizedBox(height: 15),
                const Text("อีเมลแพทย์ผู้ส่งตัว", style: TextStyle(fontSize: 18)),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                  ]),
                  onSaved: (val) => myPatient.doctorEmail = val!,
                ),
                const SizedBox(height: 15),
                
                // --- แก้ไขช่อง Triage Score ---
                const Text("ระดับความเร่งด่วน (Triage Score 1-5)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // บล็อกตัวอักษร บังคับพิมพ์ได้เฉพาะตัวเลข
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณาป้อนระดับความเร่งด่วน";
                    }
                    final score = int.tryParse(value);
                    if (score == null || score < 1 || score > 5) {
                      return "กรุณากรอกตัวเลขช่วง 1-5 เท่านั้น";
                    }
                    return null;
                  },
                  onSaved: (val) => myPatient.triageScore = val!,
                ),
                const SizedBox(height: 15),
                
                // --- แก้ไขช่อง SpO2 ---
                const Text("ค่า SpO2 (%)", style: TextStyle(fontSize: 18)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // บล็อกตัวอักษร บังคับพิมพ์ได้เฉพาะตัวเลข
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณาป้อนค่าออกซิเจน";
                    }
                    final spo2 = int.tryParse(value);
                    if (spo2 == null || spo2 < 0 || spo2 > 100) {
                      return "กรุณากรอกค่าออกซิเจนช่วง 0-100 เท่านั้น";
                    }
                    return null;
                  },
                  onSaved: (val) => myPatient.spo2 = val!,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("บันทึกข้อมูลคัดกรอง",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();
                        await _patientCollection.add({
                          "referralId": myPatient.referralId,
                          "patientName": myPatient.patientName,
                          "doctorEmail": myPatient.doctorEmail,
                          "triageScore": myPatient.triageScore,
                          "spo2": myPatient.spo2
                        });
                        formKey.currentState?.reset();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("บันทึกข้อมูลสำเร็จ")));
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}