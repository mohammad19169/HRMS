import 'package:flutter/material.dart';
import 'package:hrms_project/modules/Admin/admin_dashboard.dart';
import 'package:hrms_project/modules/Applicant/screens/candidate_application_screen.dart';
import 'package:hrms_project/modules/CEO/ceo_dashboard.dart';
import 'package:hrms_project/modules/Employee/screens/employee_dashboard.dart';
import 'package:hrms_project/modules/HR/screens/hr_dashboard_screen.dart';
import 'package:hrms_project/modules/auth/auth_service.dart';
import 'package:hrms_project/modules/auth/login.dart';
import 'package:hrms_project/modules/auth/unknownscreen.dart';
import 'package:hrms_project/modules/project_manager/screens/project_dashboard.dart';
import 'package:hrms_project/modules/shared_screens/shared/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const UnknownRoleScreen();
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>?;

              if (data == null || !data.containsKey('role')) {
                return const UnknownRoleScreen();
              }

              final role = data['role'];

              if (role == 'hr') {
                return const HrDashboardScreen();
              } else if (role == 'ceo') {
                return const CeoDashboard();
              } else if (role == 'projectmanager') {
                return const PmDashboard();
              } else if (role == 'admin') {
                return const AdminDashboard();
              } else if (role == 'employee') {
                return const EmployeeDashboard();
              } else if (role == 'applicant') {
                return const CandidateApplicationScreen();
              } else {
                return const UnknownRoleScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
