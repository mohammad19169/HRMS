import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrms_project/modules/HR/providers/hr_attendance_provider.dart';

class HrAttendanceScreen extends StatelessWidget {
  const HrAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: FutureBuilder(
        future: Provider.of<HrAttendanceProvider>(context, listen: false).loadTodayAttendanceStatus(),
        builder: (ctx, snap) {
          final provider = Provider.of<HrAttendanceProvider>(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: provider.attendanceMarked
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : isDarkMode
                                ? [Colors.grey.shade800, Colors.grey.shade700]
                                : [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: provider.attendanceMarked
                                  ? Colors.green.shade500
                                  : theme.primaryColor,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: (provider.attendanceMarked
                                          ? Colors.green
                                          : theme.primaryColor)
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              provider.attendanceMarked
                                  ? Icons.check_circle
                                  : Icons.location_on,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.attendanceMarked
                                ? 'Attendance Marked!'
                                : 'Mark Your Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: provider.attendanceMarked
                                  ? Colors.green.shade700
                                  : theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.attendanceMarked
                                ? 'You’re all set for today!'
                                : 'Tap the button below to mark your presence',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (provider.errorMessage != null)
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
                                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.errorMessage!,
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
                              onPressed: provider.isLoading
                                  ? null
                                  : () => provider.checkAndMarkAttendance(context),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: provider.attendanceMarked
                                    ? Colors.green.shade600
                                    : theme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: provider.attendanceMarked ? 2 : 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: (provider.attendanceMarked
                                        ? Colors.green
                                        : theme.primaryColor)
                                    .withOpacity(0.3),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          provider.attendanceMarked
                                              ? Icons.check_circle
                                              : Icons.fingerprint,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          provider.attendanceMarked
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
