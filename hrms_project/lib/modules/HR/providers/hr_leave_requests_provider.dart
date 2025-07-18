import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HrLeaveRequestsProvider extends ChangeNotifier {
  String selectedFilter = 'All';
  bool isLoading = false;
  List<Map<String, dynamic>> _allRequests = [];

  List<Map<String, dynamic>> get leaveRequests {
    if (selectedFilter == 'All') return _allRequests;
    return _allRequests.where((r) => (r['status'] ?? '') == selectedFilter).toList();
  }

  HrLeaveRequestsProvider() {
    listenToRequests();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    debugPrint('Selected Filter: $filter');
    notifyListeners();
  }

  void listenToRequests() {
    isLoading = true;
    notifyListeners();

    FirebaseFirestore.instance.collection('leaveRequests').snapshots().listen((snapshot) {
      debugPrint('Fetched ${snapshot.docs.length} docs from leaveRequests');
      for (var doc in snapshot.docs) {
        debugPrint('DocID: ${doc.id} => ${doc.data()}');
      }

      _allRequests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to leaveRequests: $e');
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateLeaveStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('leaveRequests')
        .doc(docId)
        .update({'status': newStatus});
  }
}
