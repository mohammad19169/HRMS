import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HrAttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _attendanceMarked = false;
  String? _errorMessage;
  Position? _currentPosition;

  bool get isLoading => _isLoading;
  bool get attendanceMarked => _attendanceMarked;
  String? get errorMessage => _errorMessage;
  Position? get currentPosition => _currentPosition;

  static const double officeLatitude = 24.895015;
  static const double officeLongitude = 67.072207;
  static const double allowedRadius = 20000.0;

  Future<void> loadTodayAttendanceStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('attendances')
        .where('userId', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    _attendanceMarked = snapshot.docs.isNotEmpty;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setAttendanceMarked(bool marked) {
    _attendanceMarked = marked;
    notifyListeners();
  }

  Future<void> checkAndMarkAttendance(BuildContext context) async {
  if (_attendanceMarked) return;
  _setLoading(true);
  _setError(null);

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLoading(false);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Location Disabled'),
              content: const Text(
                'Your location services are turned off. Please enable location to mark attendance.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Geolocator.openLocationSettings();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLoading(false);
        _setError('Location permission denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _setLoading(false);
      _setError('Location permission permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );

    if (distance > allowedRadius) {
      _setLoading(false);
      _setError('You are not within the office premises.');
      return;
    }

    await _markAttendance(position.latitude, position.longitude);
    _setAttendanceMarked(true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance marked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    _setError('An error occurred: $e');
  } finally {
    _setLoading(false);
  }
}

  Future<void> _markAttendance(double lat, double lon) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('attendances').add({
      'userId': user.uid,
      'email': user.email,
      'name': user.displayName,
      'timestamp': FieldValue.serverTimestamp(),
      'lat': lat,
      'lon': lon,
    });

    _attendanceMarked = true;
    notifyListeners();
  }

  void resetAttendance() {
    _attendanceMarked = false;
    _errorMessage = null;
    _currentPosition = null;
    notifyListeners();
  }
}
