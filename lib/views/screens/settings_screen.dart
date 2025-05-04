import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/backup_service.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final BackupService _backupService = Get.find<BackupService>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          _buildSettingsCard(
            title: 'Appearance',
            icon: Icons.color_lens,
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme Settings'),
                subtitle: const Text('Customize app theme and colors'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.to(() => ThemeSettingsScreen());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Backup & Restore
          _buildSettingsCard(
            title: 'Data Management',
            icon: Icons.backup,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Create Backup'),
                subtitle: const Text('Save your tasks and tags'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _backupService.createBackup(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore from Backup'),
                subtitle: const Text('Load tasks and tags from a backup file'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _backupService.restoreBackup(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // About
          _buildSettingsCard(
            title: 'About',
            icon: Icons.info_outline,
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              const Divider(),
              const ListTile(
                title: Text('Made with Flutter'),
                subtitle: Text('Offline-first task management app'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
