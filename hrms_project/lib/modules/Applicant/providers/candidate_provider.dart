import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/candidate_model.dart';

class CandidateProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Candidate _candidate = Candidate(
    fullName: '',
    email: '',
    phone: '',
    domainPreference: '',
    resumeUrl: '',
    status: 'Pending',
  );

  Candidate get candidate => _candidate;
  Stream<QuerySnapshot> get candidatesStream => _firestore.collection('candidates').snapshots();

  void updateFullName(String name) {
    _candidate.fullName = name;
    notifyListeners();
  }

  void updateEmail(String email) {
    _candidate.email = email;
    notifyListeners();
  }

  void updatePhone(String phone) {
    _candidate.phone = phone;
    notifyListeners();
  }

  void updateDomainPreference(String domain) {
    _candidate.domainPreference = domain;
    notifyListeners();
  }

  Future<void> uploadResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final url = await _uploadFile(filePath, 'resumes');
      _candidate.resumeUrl = url;
      notifyListeners();
    }
  }

  Future<String> _uploadFile(String filePath, String folder) async {
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref().child('$folder/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> submitApplication() async {
    if (!_candidate.isComplete) {
      throw Exception('Please fill all required fields and upload resume');
    }
    await _firestore.collection('candidates').add(_candidate.toMap());
    _resetForm();
  }

  Future<void> updateStatus(String candidateId, String newStatus) async {
    await _firestore.collection('candidates').doc(candidateId).update({'status': newStatus});
  }

  void _resetForm() {
    _candidate = Candidate(
      fullName: '',
      email: '',
      phone: '',
      domainPreference: '',
      resumeUrl: '',
      status: 'Pending',
    );
    notifyListeners();
  }
}
