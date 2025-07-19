class Candidate {
  String? id;
  String fullName;
  String email;
  String phone;
  String domainPreference;
  String? resumeUrl;
  DateTime submissionDate;
  String status;

  Candidate({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.domainPreference,
    this.resumeUrl,
    DateTime? submissionDate,
    this.status = 'Pending',
  }) : submissionDate = submissionDate ?? DateTime.now();

  factory Candidate.fromMap(Map<String, dynamic> data, String id) {
    return Candidate(
      id: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      domainPreference: data['domainPreference'] ?? '',
      resumeUrl: data['resumeUrl'],
      submissionDate: data['submissionDate'] != null
          ? DateTime.parse(data['submissionDate'])
          : DateTime.now(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'domainPreference': domainPreference,
      'resumeUrl': resumeUrl,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status,
    };
  }

  bool get isComplete {
    return fullName.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        domainPreference.isNotEmpty &&
        resumeUrl != null;
  }
}
