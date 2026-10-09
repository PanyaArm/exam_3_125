import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    spo2: '',
  );

  final CollectionReference _patientCollection =
      FirebaseFirestore.instance.collection("referrals");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("รหัสส่งต่อ (Referral ID)"),
                TextFormField(
                  validator: RequiredValidator(errorText: "กรุณากรอกรหัสส่งต่อ"),
                  onSaved: (String? referralId) {
                    myPatient.referralId = referralId ?? '';
                  },
                ),
                const SizedBox(height: 15),
                const Text("ชื่อผู้ป่วย (Patient Name)"),
                TextFormField(
                  validator: RequiredValidator(errorText: "กรุณากรอกชื่อผู้ป่วย"),
                  onSaved: (String? patientName) {
                    myPatient.patientName = patientName ?? '';
                  },
                ),
                const SizedBox(height: 15),
                const Text("อีเมลแพทย์ผู้ส่ง (Doctor Email)"),
                TextFormField(
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณากรอกอีเมลแพทย์"),
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                  ]),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (String? doctorEmail) {
                    myPatient.doctorEmail = doctorEmail ?? '';
                  },
                ),
                const SizedBox(height: 15),
                const Text("ระดับความเร่งด่วน Triage Score (1-5)"),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณากรอก Triage Score";
                    }
                    int? score = int.tryParse(value);
                    if (score == null || score < 1 || score > 5) {
                      return "กรุณากรอกค่าระหว่าง 1 ถึง 5 เท่านั้น";
                    }
                    return null;
                  },
                  onSaved: (String? triageScore) {
                    myPatient.triageScore = triageScore ?? '';
                  },
                ),
                const SizedBox(height: 15),
                const Text("ค่า SpO2 (0-100)"),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณากรอกค่า SpO2";
                    }
                    int? spo2Val = int.tryParse(value);
                    if (spo2Val == null || spo2Val < 0 || spo2Val > 100) {
                      return "กรุณากรอกค่าระหว่าง 0 ถึง 100 เท่านั้น";
                    }
                    return null;
                  },
                  onSaved: (String? spo2) {
                    myPatient.spo2 = spo2 ?? '';
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                    child: const Text("บันทึกข้อมูล", style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        await _patientCollection.add({
                          "referralId": myPatient.referralId,
                          "patientName": myPatient.patientName,
                          "doctorEmail": myPatient.doctorEmail,
                          "triageScore": myPatient.triageScore,
                          "spo2": myPatient.spo2,
                        });
                        formKey.currentState!.reset();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}