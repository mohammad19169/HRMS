import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hrms_project/modules/HR/screens/hr_candidate_status_screen.dart';
import 'package:hrms_project/modules/HR/screens/hr_leave_requests_screen.dart';
import 'package:hrms_project/modules/HR/screens/hr_employee_status_screen.dart';
import 'package:hrms_project/modules/HR/screens/hr_attendance_screen.dart';

class HrDashboardScreen extends StatelessWidget {
  const HrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'HR Dashboard',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  elevation: 0,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      tooltip: 'Logout',
      onPressed: () async {
        // Firebase logout
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    ),
    const SizedBox(width: 8),
  ],
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.cyan.shade800, Colors.cyan.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to HR Portal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your workforce efficiently',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // fixed aspect ratio to give more vertical space
                  childAspectRatio: 0.95,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Leave Requests',
                      Icons.event_note_outlined,
                      const HrLeaveRequestsScreen(),
                      Colors.orange.shade400,
                    ),
                    _buildDashboardCard(
                      context,
                      'Candidate Status',
                      Icons.person_search_outlined,
                      const HrCandidateStatusScreen(),
                      Colors.purple.shade400,
                    ),
                    _buildDashboardCard(
                      context,
                      'Employee Status',
                      Icons.groups_outlined,
                      const HrEmployeeStatusScreen(),
                      Colors.green.shade400,
                    ),
                    _buildDashboardCard(
                      context,
                      'Attendance',
                      Icons.access_time_outlined,
                      const HrAttendanceScreen(),
                      Colors.blue.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
    Color accentColor,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.shade100.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.cyan.shade100,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12), // reduced padding
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 40, // reduced size
                      color: accentColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.cyan.shade400,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
