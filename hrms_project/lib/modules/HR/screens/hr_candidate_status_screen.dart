import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrms_project/modules/HR/providers/hr_employee_provider.dart';

class HrEmployeeStatusScreen extends StatefulWidget {
  const HrEmployeeStatusScreen({super.key});

  @override
  State<HrEmployeeStatusScreen> createState() => _HrEmployeeStatusScreenState();
}

class _HrEmployeeStatusScreenState extends State<HrEmployeeStatusScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<HrEmployeeProvider>(context, listen: false).fetchEmployees());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HrEmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Status'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : provider.employees.isEmpty
                  ? const Center(child: Text('No employees found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.employees.length,
                      itemBuilder: (ctx, i) {
                        final item = provider.employees[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.cyan,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              item['name'] ?? 'No Name',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['email'] ?? ''),
                                Text(item['phone'] ?? ''),
                                Text(item['department'] ?? ''),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
