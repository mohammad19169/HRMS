import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hrms_project/modules/HR/providers/hr_attendance_provider.dart';

class HrAttendanceScreen extends StatelessWidget {
  const HrAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              // Navigate to attendance history
            },
            tooltip: 'Attendance History',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<HrAttendanceProvider>(context, listen: false).loadTodayAttendanceStatus(),
        builder: (ctx, snap) {
          final provider = Provider.of<HrAttendanceProvider>(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDateTimeHeader(context),
                const SizedBox(height: 24),
                _buildMainAttendanceCard(context, provider),
                const SizedBox(height: 24),
                if (provider.attendanceMarked)
                  _buildTodayStats(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.secondaryContainer.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.today_rounded, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            dateFormat.format(now),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            timeFormat.format(now),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAttendanceCard(BuildContext context, HrAttendanceProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: provider.attendanceMarked
                    ? Colors.green.shade50
                    : colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: provider.attendanceMarked
                      ? Colors.green.shade200
                      : colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  provider.attendanceMarked
                      ? Icons.check_circle_rounded
                      : Icons.fingerprint_rounded,
                  key: ValueKey(provider.attendanceMarked),
                  size: 64,
                  color: provider.attendanceMarked
                      ? Colors.green.shade600
                      : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                provider.attendanceMarked
                    ? 'Attendance Marked!'
                    : 'Ready to Check In',
                key: ValueKey(provider.attendanceMarked),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: provider.attendanceMarked
                      ? Colors.green.shade700
                      : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.attendanceMarked
                  ? 'Great! You\'re all set for today. Have a productive day!'
                  : 'Tap the button below to mark your attendance for today',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (provider.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.checkAndMarkAttendance(context),
                style: FilledButton.styleFrom(
                  backgroundColor: provider.attendanceMarked
                      ? Colors.green.shade600
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: provider.attendanceMarked ? 2 : 4,
                  shadowColor: (provider.attendanceMarked
                          ? Colors.green.shade600
                          : colorScheme.primary)
                      .withOpacity(0.4),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          key: ValueKey(provider.attendanceMarked),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              provider.attendanceMarked
                                  ? Icons.check_circle_rounded
                                  : Icons.touch_app_rounded,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              provider.attendanceMarked
                                  ? 'Marked Successfully'
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats(BuildContext context, HrAttendanceProvider provider) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.timeline_rounded, color: Colors.green.shade600, size: 28),
          const SizedBox(height: 12),
          Text(
            'Today\'s Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn(context, 'Check In', '9:00 AM', Icons.login_rounded),
              Container(height: 40, width: 1, color: Colors.green.shade300),
              _statColumn(context, 'Status', 'Present', Icons.check_circle_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade600, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.green.shade600,
          ),
        ),
      ],
    );
  }
}
