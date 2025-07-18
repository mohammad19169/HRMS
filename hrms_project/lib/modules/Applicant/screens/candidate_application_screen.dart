import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrms_project/main.dart';
import 'package:hrms_project/modules/auth/login.dart';
import '../providers/candidate_provider.dart';

class CandidateApplicationScreen extends StatefulWidget {
  const CandidateApplicationScreen({super.key});

  @override
  State<CandidateApplicationScreen> createState() => _CandidateApplicationScreenState();
}

class _CandidateApplicationScreenState extends State<CandidateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _domainOptions = const [
    'Software Development',
    'Data Science',
    'UX/UI Design',
    'Digital Marketing',
    'Project Management',
    'Quality Assurance',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CandidateProvider>(context);
    final candidate = provider.candidate;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Job Application'),
        elevation: 4,
        shadowColor: Colors.cyan.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan.shade50,
              Colors.cyan.shade100,
              Colors.cyan.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.cyan.shade100,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan.shade600,
                                Colors.cyan.shade800,
                              ],
                            ),
                          ),
                          child: const Icon(Icons.work, color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Apply for a Job",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Fill out the form below to submit your application",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        context,
                        initialValue: candidate.fullName,
                        label: 'Full Name',
                        icon: Icons.person,
                        keyboard: TextInputType.name,
                        onChanged: provider.updateFullName,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        context,
                        initialValue: candidate.email,
                        label: 'Email',
                        icon: Icons.email,
                        keyboard: TextInputType.emailAddress,
                        onChanged: provider.updateEmail,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        context,
                        initialValue: candidate.phone,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboard: TextInputType.phone,
                        onChanged: provider.updatePhone,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: candidate.domainPreference.isNotEmpty
                            ? candidate.domainPreference
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Domain Preference',
                          labelStyle: TextStyle(color: textColor),
                          prefixIcon: Icon(Icons.work, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant,
                        ),
                        style: TextStyle(color: textColor),
                        dropdownColor: theme.colorScheme.surface,
                        items: _domainOptions
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d, style: TextStyle(color: textColor)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) provider.updateDomainPreference(v);
                        },
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Please select a domain' : null,
                      ),
                      const SizedBox(height: 24),

                      _fileButton(
                        context,
                        icon: Icons.description,
                        label: 'Upload Resume',
                        fileLabel: candidate.resumeUrl,
                        onPressed: provider.uploadResume,
                      ),
                      const SizedBox(height: 16),
                      _fileButton(
                        context,
                        icon: Icons.credit_card,
                        label: 'Upload CNIC',
                        fileLabel: candidate.cnicUrl,
                        onPressed: provider.uploadCnic,
                      ),
                      const SizedBox(height: 16),
                      _fileButton(
                        context,
                        icon: Icons.badge,
                        label: 'Upload Certificates',
                        fileLabel: candidate.certificatesUrls.isNotEmpty
                            ? '${candidate.certificatesUrls.length} files uploaded'
                            : null,
                        onPressed: provider.uploadCertificates,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: Colors.cyan.shade300,
                          ),
                          child: const Text(
                            'Submit Application',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We will notify you about your interview status via the app.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String initialValue,
    required String label,
    required IconData icon,
    required TextInputType keyboard,
    required Function(String) onChanged,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboard,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyan.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
      onChanged: onChanged,
    );
  }

  Widget _fileButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? fileLabel,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.cyan.shade400),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    )),
                if (fileLabel != null && fileLabel.isNotEmpty)
                  Text(
                    fileLabel.contains('http') ? 'File uploaded' : fileLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
              ],
            ),
          ),
          Icon(Icons.upload_file, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<CandidateProvider>(context, listen: false);

    if (!provider.candidate.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required files')),
      );
      return;
    }

    try {
      await provider.submitApplication();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
