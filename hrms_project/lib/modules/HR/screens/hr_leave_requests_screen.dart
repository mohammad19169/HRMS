import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrms_project/modules/HR/providers/hr_leave_requests_provider.dart';

class HrLeaveRequestsScreen extends StatelessWidget {
  const HrLeaveRequestsScreen({super.key});

  String _formatDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      return DateFormat('dd MMM yyyy').format(value);
    }
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy').format(value.toDate());
    }
    return value.toString();
  }

  String _calculateDuration(dynamic fromDate, dynamic toDate) {
    if (fromDate == null || toDate == null) return '';
    
    DateTime from, to;
    if (fromDate is Timestamp) from = fromDate.toDate();
    else if (fromDate is DateTime) from = fromDate;
    else return '';
    
    if (toDate is Timestamp) to = toDate.toDate();
    else if (toDate is DateTime) to = toDate;
    else return '';
    
    final days = to.difference(from).inDays + 1;
    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HrLeaveRequestsProvider>(context);
    final filteredRequests = provider.leaveRequests;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
     appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 1,
  title: const Text(
    'Leave Requests',
    style: TextStyle(
      color: Colors.black, // force dark text
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.black, // force dark icons
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh_rounded),
      color: Colors.black, // force dark icon
      onPressed: () => provider.listenToRequests(),
      tooltip: 'Refresh',
    ),
    const SizedBox(width: 8),
  ],
),

      body: Column(
        children: [
          // Modern filter section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _modernFilterChip(context, provider, 'All', Icons.list_rounded),
                      const SizedBox(width: 12),
                      _modernFilterChip(context, provider, 'Pending', Icons.schedule_rounded),
                      const SizedBox(width: 12),
                      _modernFilterChip(context, provider, 'Approved', Icons.check_circle_rounded),
                      const SizedBox(width: 12),
                      _modernFilterChip(context, provider, 'Rejected', Icons.cancel_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats summary
          if (!provider.isLoading && filteredRequests.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsSummary(context, filteredRequests),
            ),
          
          const SizedBox(height: 16),
          
          // Content area
          Expanded(
            child: provider.isLoading
                ? _buildLoadingState()
                : filteredRequests.isEmpty
                    ? _buildEmptyState(context)
                    : _buildRequestsList(context, filteredRequests, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, List filteredRequests) {
    final theme = Theme.of(context);
    final pending = filteredRequests.where((r) => r['status'] == 'Pending').length;
    final approved = filteredRequests.where((r) => r['status'] == 'Approved').length;
    final rejected = filteredRequests.where((r) => r['status'] == 'Rejected').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.secondaryContainer.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(context, 'Total', filteredRequests.length.toString(), Icons.all_inbox_rounded),
          _statItem(context, 'Pending', pending.toString(), Icons.schedule_rounded),
          _statItem(context, 'Approved', approved.toString(), Icons.check_circle_rounded),
          _statItem(context, 'Rejected', rejected.toString(), Icons.cancel_rounded),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading requests...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Leave Requests',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No leave requests match the current filter.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, List requests, HrLeaveRequestsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: requests.length,
      itemBuilder: (ctx, i) {
        final req = requests[i];
        return _modernRequestCard(context, req, provider);
      },
    );
  }

  Widget _modernRequestCard(BuildContext context, Map<String, dynamic> req, HrLeaveRequestsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final name = req['employeeName'] ?? 'Unknown Employee';
    final reason = req['reason'] ?? 'No reason provided';
    final from = _formatDate(req['fromDate']);
    final to = _formatDate(req['toDate']);
    final duration = _calculateDuration(req['fromDate'], req['toDate']);
    final status = req['status'] ?? 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _statusBadge(context, status),
                    ],
                  ),
                ),
                if (duration.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      duration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Reason section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.comment_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Reason',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reason,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Date range
            Row(
              children: [
                Expanded(
                  child: _dateInfo(context, 'From', from, Icons.today_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateInfo(context, 'To', to, Icons.event_rounded),
                ),
              ],
            ),
            
            // Action buttons for pending requests
            if (status == 'Pending') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => provider.updateLeaveStatus(req['id'], 'Approved'),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => provider.updateLeaveStatus(req['id'], 'Rejected'),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Reject'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case 'Approved':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_rounded;
        break;
      case 'Rejected':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_rounded;
        break;
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateInfo(BuildContext context, String label, String date, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date.isEmpty ? 'Not set' : date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernFilterChip(BuildContext context, HrLeaveRequestsProvider provider, String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = provider.selectedFilter == label;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => provider.setFilter(label),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.outline.withOpacity(0.3),
        ),
      ),
      elevation: isSelected ? 4 : 0,
      shadowColor: colorScheme.primary.withOpacity(0.3),
    );
  }
}