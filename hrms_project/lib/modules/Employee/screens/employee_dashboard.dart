import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrms_project/modules/auth/auth_service.dart';
import 'package:hrms_project/modules/Employee/screens/leave_request_screen.dart';
import 'package:hrms_project/modules/Employee/screens/announcements_screen.dart';
import 'package:hrms_project/modules/Employee/screens/profile_screen.dart';
import 'package:hrms_project/modules/Employee/screens/chat_screen.dart';
import 'package:hrms_project/modules/Employee/providers/attendance_provider.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final theme = Theme.of(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Employee Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<AttendanceProvider>(context, listen: false).loadTodayAttendanceStatus(),
        builder: (context, napshot) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Welcome Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
                          : [Colors.cyan.shade600, Colors.cyan.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${auth.currentUser?.displayName ?? 'Employee'}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Here is your dashboard to manage your work, stay updated and access all features easily.',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
          
                // Attendance Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: attendanceProvider.attendanceMarked
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : isDarkMode
                            ? [Colors.grey.shade800, Colors.grey.shade700]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: attendanceProvider.attendanceMarked
                                  ? Colors.green.shade500
                                  : theme.primaryColor,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (attendanceProvider.attendanceMarked
                                              ? Colors.green
                                              : theme.primaryColor)
                                          .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              attendanceProvider.attendanceMarked
                                  ? Icons.check_circle
                                  : Icons.location_on,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            attendanceProvider.attendanceMarked
                                ? 'Attendance Marked!'
                                : 'Mark Your Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: attendanceProvider.attendanceMarked
                                  ? Colors.green.shade700
                                  : theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            attendanceProvider.attendanceMarked
                                ? 'You\'re all set for today!'
                                : 'Tap the button below to mark your presence',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(
                                0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
          
                          if (attendanceProvider.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      attendanceProvider.errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
          
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: attendanceProvider.isLoading
                                  ? null
                                  : () => attendanceProvider.checkAndMarkAttendance(
                                      context,
                                    ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: attendanceProvider.attendanceMarked
                                    ? Colors.green.shade600
                                    : theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: attendanceProvider.attendanceMarked
                                    ? 2
                                    : 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor:
                                    (attendanceProvider.attendanceMarked
                                            ? Colors.green
                                            : theme.primaryColor)
                                        .withOpacity(0.3),
                              ),
                              child: attendanceProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          attendanceProvider.attendanceMarked
                                              ? Icons.check_circle
                                              : Icons.fingerprint,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          attendanceProvider.attendanceMarked
                                              ? 'Attendance Marked'
                                              : 'Mark Attendance',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
          
                          if (attendanceProvider.attendanceMarked)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.green.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Marked at ${DateTime.now().toString().substring(11, 16)}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
          
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
          
                LayoutBuilder(
                  builder: (context, constraints) {
                    double itemWidth = (constraints.maxWidth - 16) / 2;
                    double itemHeight = itemWidth * 0.9;
          
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: itemWidth / itemHeight,
                      children: [
                        _buildActionCard(
                          context: context,
                          icon: Icons.calendar_today_outlined,
                          title: 'Request Leave',
                          subtitle: 'Apply for time off',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaveRequestScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          context: context,
                          icon: Icons.announcement_outlined,
                          title: 'Announcements',
                          subtitle: 'Company updates',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnnouncementsScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          subtitle: 'View & edit info',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(user: auth.currentUser!),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          context: context,
                          icon: Icons.chat_outlined,
                          title: 'Chat Support',
                          subtitle: 'HR & Manager chat',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.cyan.shade800.withOpacity(0.2)
                      : Colors.cyan.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isDarkMode
                      ? Colors.cyan.shade300
                      : Colors.cyan.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
