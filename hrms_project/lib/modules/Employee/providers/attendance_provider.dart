import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceProvider extends ChangeNotifier {
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
        _showEnableLocationDialog(context);
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
      _setError(null);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully!'), backgroundColor: Colors.green),
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

 void _showEnableLocationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.cyan.shade50,
                Colors.cyan.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade600,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.shade300.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your location service is turned off.\nPlease enable it in settings to mark your attendance.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.settings, color: Colors.white),
                    label: const Text(
                      'Open Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await Geolocator.openLocationSettings();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void resetAttendance() {
    _attendanceMarked = false;
    _errorMessage = null;
    _currentPosition = null;
    notifyListeners();
  }
}
