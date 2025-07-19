import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HrCandidatesProvider extends ChangeNotifier {
  String selectedFilter = 'All';
  bool isLoading = false;
  List<Map<String, dynamic>> _allCandidates = [];

  List<Map<String, dynamic>> get candidates {
    if (selectedFilter == 'All') return _allCandidates;
    return _allCandidates.where((c) => (c['status'] ?? '') == selectedFilter).toList();
  }

  HrCandidatesProvider() {
    listenToCandidates();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void listenToCandidates() {
    isLoading = true;
    notifyListeners();

    FirebaseFirestore.instance.collection('candidates').snapshots().listen((snapshot) {
      _allCandidates = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateCandidateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('candidates').doc(docId).update({'status': newStatus});
  }
}
