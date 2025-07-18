import 'package:flutter/material.dart';
import 'package:hrms_project/modules/Employee/models/announcement.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: employeeProvider.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements yet'));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                child: ListTile(
                  title: Text(announcement.title),
                  subtitle: Text(announcement.content),
                  trailing: Text(
                    announcement.postedAt.toLocal().toString().split(' ')[0],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}