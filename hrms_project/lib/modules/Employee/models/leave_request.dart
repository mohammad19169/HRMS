class LeaveRequest {
  String? id;
  final String employeeId;
  final String employeeName;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime submittedAt;

  LeaveRequest({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.status = 'Pending',
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  factory LeaveRequest.fromMap(Map<String, dynamic> data, String id) {
    return LeaveRequest(
      id: id,
      employeeId: data['employeeId'] ?? '',
      employeeName: data['employeeName'] ?? '',
      fromDate: data['fromDate'].toDate(),
      toDate: data['toDate'].toDate(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'Pending',
      submittedAt: data['submittedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'fromDate': fromDate,
      'toDate': toDate,
      'reason': reason,
      'status': status,
      'submittedAt': submittedAt,
    };
  }

  int get durationInDays => toDate.difference(fromDate).inDays + 1;
}