import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HrEmployeeProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> employees = [];

  Future<void> fetchEmployees() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final snap = await FirebaseFirestore.instance.collection('employees').get();
      employees = snap.docs
          .map((doc) => doc.data())
          .where((data) => (data['role'] ?? '') != 'applicant')
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load employees: $e';
      notifyListeners();
    }
  }
}
