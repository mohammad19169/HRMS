class Candidate {
  String? id; // Firestore document ID
  String fullName;
  String email;
  String phone;
  String domainPreference;
  String? resumeUrl;
  String? cnicUrl;
  List<String> certificatesUrls;
  DateTime submissionDate;
  String status;

  Candidate({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.domainPreference,
    this.resumeUrl,
    this.cnicUrl,
    this.certificatesUrls = const [],
    DateTime? submissionDate,
    this.status = 'Submitted',
  }) : submissionDate = submissionDate ?? DateTime.now();

  factory Candidate.fromMap(Map<String, dynamic> data, String id) {
    return Candidate(
      id: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      domainPreference: data['domainPreference'] ?? '',
      resumeUrl: data['resumeUrl'],
      cnicUrl: data['cnicUrl'],
      certificatesUrls: List<String>.from(data['certificatesUrls'] ?? []),
      submissionDate: data['submissionDate'] != null
          ? DateTime.parse(data['submissionDate'])
          : DateTime.now(),
      status: data['status'] ?? 'Submitted',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'domainPreference': domainPreference,
      'resumeUrl': resumeUrl,
      'cnicUrl': cnicUrl,
      'certificatesUrls': certificatesUrls,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status,
    };
  }

  bool get isComplete {
    return fullName.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        domainPreference.isNotEmpty &&
        resumeUrl != null &&
        cnicUrl != null;
  }
}