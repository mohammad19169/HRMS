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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Approved':
        return Colors.green.shade600;
      case 'Rejected':
        return Colors.red.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HrLeaveRequestsProvider>(context);
    final filteredRequests = provider.leaveRequests;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _filterChip(context, provider, 'All'),
                const SizedBox(width: 8),
                _filterChip(context, provider, 'Pending'),
                const SizedBox(width: 8),
                _filterChip(context, provider, 'Approved'),
                const SizedBox(width: 8),
                _filterChip(context, provider, 'Rejected'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? const Center(child: Text('No leave requests found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRequests.length,
                        itemBuilder: (ctx, i) {
                          final req = filteredRequests[i];
                          final name = req['employeeName'] ?? 'Unknown';
                          final reason = req['reason'] ?? 'N/A';
                          final from = _formatDate(req['fromDate']);
                          final to = _formatDate(req['toDate']);
                          final status = req['status'] ?? 'Pending';

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Reason: $reason', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.date_range, size: 18),
                                      const SizedBox(width: 6),
                                      Text('From: $from', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.date_range_outlined, size: 18),
                                      const SizedBox(width: 6),
                                      Text('To: $to', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (status == 'Pending')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            provider.updateLeaveStatus(req['id'], 'Approved');
                                          },
                                          icon: const Icon(Icons.check_circle),
                                          label: const Text('Approve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            provider.updateLeaveStatus(req['id'], 'Rejected');
                                          },
                                          icon: const Icon(Icons.cancel),
                                          label: const Text('Reject'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, HrLeaveRequestsProvider provider, String label) {
    final isSelected = provider.selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setFilter(label),
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
