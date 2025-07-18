import 'package:flutter/material.dart';
import 'package:hrms_project/modules/auth/login.dart';

class CeoDashboard extends StatelessWidget {
  const CeoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CEO Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      
    );
  }
}