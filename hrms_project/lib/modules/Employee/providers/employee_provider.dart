import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class EmployeeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  Stream<List<Announcement>> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _announcements = snapshot.docs
          .map((doc) => Announcement.fromMap(doc.data(), doc.id))
          .toList();
      return _announcements;
    });
  }
}