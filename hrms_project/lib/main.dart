import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hrms_project/modules/Employee/providers/attendance_provider.dart';
import 'package:hrms_project/modules/Employee/providers/employee_provider.dart';
import 'package:hrms_project/modules/Employee/providers/leave_provider.dart';
import 'package:hrms_project/modules/Employee/screens/employee_dashboard.dart';
import 'package:hrms_project/modules/HR/providers/hr_attendance_provider.dart';
import 'package:hrms_project/modules/HR/providers/hr_employee_provider.dart';
import 'package:hrms_project/modules/HR/providers/hr_leave_requests_provider.dart';
import 'package:hrms_project/modules/HR/screens/hr_dashboard_screen.dart';
import 'package:hrms_project/modules/auth/login.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'modules/auth/auth_service.dart';
import 'package:hrms_project/modules/Applicant/providers/candidate_provider.dart';

import 'package:hrms_project/modules/Admin/admin_dashboard.dart';
import 'package:hrms_project/modules/Applicant/screens/candidate_application_screen.dart';
import 'package:hrms_project/modules/CEO/ceo_dashboard.dart';
import 'package:hrms_project/modules/auth/signup.dart';
import 'package:hrms_project/modules/project_manager/screens/project_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CandidateProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => HrEmployeeProvider()),
        ChangeNotifierProvider(create: (_) => HrLeaveRequestsProvider()),
        ChangeNotifierProvider(create: (_) => HrAttendanceProvider()),

        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _lightCyanTheme,
          darkTheme: _darkCyanTheme,
          themeMode: themeProvider.themeMode,
          home: const LoginScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/hrDashboard': (_) => const HrDashboardScreen(),
            '/ceoDashboard': (_) => const CeoDashboard(),
            '/pmDashboard': (_) => const PmDashboard(),
            '/adminDashboard': (_) => const AdminDashboard(),
            '/employeeDashboard': (_) => const EmployeeDashboard(),
            '/applicantDashboard': (_) => const CandidateApplicationScreen(),
            '/signup': (_) => const ApplicantSignupScreen(),
          },
        );
      },
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // void toggleTheme() {
  //   _themeMode = _themeMode == ThemeMode.dark
  //       ? ThemeMode.light
  //       : ThemeMode.dark;
  //   notifyListeners();
  // }
}

final ThemeData _lightCyanTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.cyan.shade700,
    secondary: Colors.cyanAccent.shade400,
    surface: Colors.grey.shade50,
  ),
  scaffoldBackgroundColor: Colors.grey.shade50,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.cyan.shade800,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white, // fixed for visibility
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.cyan.shade600,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    shadowColor: Colors.cyan.shade100,
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  useMaterial3: true,
);

final ThemeData _darkCyanTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.cyan.shade400,
    secondary: Colors.cyanAccent.shade200,
    surface: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.cyanAccent),
    titleTextStyle: const TextStyle(
      color: Colors.cyanAccent,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.cyan.shade400,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  cardTheme: CardThemeData(
    color: Colors.grey.shade900,
    shadowColor: Colors.cyan.shade700,
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  useMaterial3: true,
);
