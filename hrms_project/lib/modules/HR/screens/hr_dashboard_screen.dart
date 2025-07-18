import 'package:flutter/material.dart';
import 'package:hrms_project/modules/HR/screens/hr_leave_requests_screen.dart';
import 'package:hrms_project/modules/HR/screens/hr_candidate_status_screen.dart';
import 'package:hrms_project/modules/HR/screens/hr_attendance_screen.dart';

class HrDashboardScreen extends StatelessWidget {
  const HrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HR Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _card(context, 'Leave Requests', Icons.list_alt, const HrLeaveRequestsScreen()),
          _card(context, 'Employee Status', Icons.people_alt, const HrEmployeeStatusScreen()),
          _card(context, 'Attendance', Icons.location_on, const HrAttendanceScreen()),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
