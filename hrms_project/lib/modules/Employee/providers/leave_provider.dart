import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request.dart';

class LeaveProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<LeaveRequest> _leaveRequests = [];

  List<LeaveRequest> get leaveRequests => _leaveRequests;

  Stream<List<LeaveRequest>> getLeaveRequests(String employeeId) {
    return _firestore
        .collection('leaveRequests')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _leaveRequests = snapshot.docs
          .map((doc) => LeaveRequest.fromMap(doc.data(), doc.id))
          .toList();
      return _leaveRequests;
    });
  }

  Future<void> submitLeaveRequest({
    required String employeeId,
    required String employeeName,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    try {
      final request = LeaveRequest(
        employeeId: employeeId,
        employeeName: employeeName,
        fromDate: fromDate,
        toDate: toDate,
        reason: reason,
      );

      await _firestore.collection('leaveRequests').add(request.toMap());
    } catch (e) {
      debugPrint('Error submitting leave request: $e');
      rethrow;
    }
  }
}