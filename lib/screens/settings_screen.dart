import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSection(title: 'Account', children: [
                  _buildUserInfoTile(context, settings),
                ]),
                _buildSection(title: 'Notifications', children: [
                  _buildSwitchTile(
                    title: 'Enable Notifications',
                    subtitle: 'Receive medicine reminders',
                    value: settings.notificationsEnabled,
                    onChanged: settings.setNotificationsEnabled,
                  ),
                  if (settings.notificationsEnabled) ...[
                    _buildTimeTile(
                      context: context,
                      title: 'Reminder Time',
                      subtitle: 'Daily reminder at',
                      value: settings.remindersAt,
                      onChanged: settings.setRemindersAt,
                    ),
                    _buildSwitchTile(
                      title: 'Sound',
                      subtitle: 'Play sound for notifications',
                      value: settings.soundEnabled,
                      onChanged: settings.setSoundEnabled,
                    ),
                    _buildSwitchTile(
                      title: 'Vibration',
                      subtitle: 'Vibrate on notifications',
                      value: settings.vibrationEnabled,
                      onChanged: settings.setVibrationEnabled,
                    ),
                  ],
                ]),
                _buildSection(title: 'Quiet Hours', children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No notifications during quiet hours',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                  _buildTimeTile(
                    context: context,
                    title: 'Start Time',
                    subtitle: 'Quiet hours start at',
                    value: settings.quietHoursStart,
                    onChanged: settings.setQuietHoursStart,
                  ),
                  _buildTimeTile(
                    context: context,
                    title: 'End Time',
                    subtitle: 'Quiet hours end at',
                    value: settings.quietHoursEnd,
                    onChanged: settings.setQuietHoursEnd,
                  ),
                ]),
                _buildSection(title: 'Alerts', children: [
                  _buildSwitchTile(
                    title: 'Low Stock Alert',
                    subtitle: 'Notify when stock count is low',
                    value: settings.lowStockAlert,
                    onChanged: settings.setLowStockAlert,
                  ),
                ]),
                _buildSection(title: 'Appearance', children: [
                  _buildThemeSelector(context, settings),
                ]),
                _buildSection(title: 'About', children: [
                  _buildListTile(title: 'App Version', subtitle: '1.0.0'),
                  _buildListTile(title: 'Build Number',  subtitle: '1'),
                ]),
                _buildSection(title: 'Danger Zone', children: [
                  _buildDangerButton(
                    title: 'Clear All Data',
                    subtitle: 'Remove all medicines and history',
                    context: context,
                    onPressed: () async {
                      await settings.clearAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data cleared')),
                        );
                      }
                    },
                  ),
                  _buildDangerButton(
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    context: context,
                    onPressed: () async {
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            // ✅ Fixed: activeColor is not deprecated, activeThumbColor is
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _parseTime(value),
            );
            if (picked != null) {
              onChanged(
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // ✅ Fixed: withValues instead of withOpacity
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: ThemeMode.values.map((mode) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => settings.setThemeMode(mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: settings.themeMode == mode
                          ? AppColors.primary
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getThemeName(mode),
                        style: TextStyle(
                          color: settings.themeMode == mode
                              ? AppColors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoTile(
      BuildContext context, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                child: Text(
                  settings.userName.isNotEmpty
                      ? settings.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Name',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(settings.userName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showEditNameDialog(context, settings),
              child: const Icon(Icons.edit, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
      {required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildDangerButton({
    required String title,
    required String subtitle,
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title,
            style: const TextStyle(color: Colors.red)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward, color: Colors.red),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(title),
              content: Text('Are you sure you want to $title?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onPressed();
                  },
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:  return 'Light';
      case ThemeMode.dark:   return 'Dark';
      case ThemeMode.system: return 'System';
    }
  }

  void _showEditNameDialog(
      BuildContext context, SettingsProvider settings) {
    final controller =
        TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await settings.setUserName(controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}