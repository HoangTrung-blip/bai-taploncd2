import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _pushNotificationEnabled = true;
  bool _cloudSyncEnabled = false;
  int _snoozeMinutes = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final data = await SettingsService.getAll();
      setState(() {
        _soundEnabled = data['sound_enabled'] == 'true';
        _vibrationEnabled = data['vibration_enabled'] == 'true';
        _pushNotificationEnabled = data['push_notification_enabled'] == 'true';
        _cloudSyncEnabled = data['cloud_sync_enabled'] == 'true';
        _snoozeMinutes = int.tryParse(data['snooze_minutes'] ?? '10') ?? 10;
      });
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSetting(String key, String value) async {
    try {
      await SettingsService.set(key, value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // Notification settings
          _buildSectionHeader('Thông báo'),
          SwitchListTile(
            title: const Text('Âm thanh báo thức'),
            subtitle: const Text('Phát âm thanh khi đến giờ uống thuốc'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound_enabled', value.toString());
            },
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('Rung'),
            subtitle: const Text('Rung thiết bị khi có nhắc nhở'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _saveSetting('vibration_enabled', value.toString());
            },
            secondary: const Icon(Icons.vibration),
          ),
          SwitchListTile(
            title: const Text('Thông báo đẩy'),
            subtitle: const Text('Hiển thị thông báo trên thanh trạng thái'),
            value: _pushNotificationEnabled,
            onChanged: (value) {
              setState(() => _pushNotificationEnabled = value);
              _saveSetting('push_notification_enabled', value.toString());
            },
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.snooze),
            title: const Text('Thời gian nhắc lại'),
            subtitle: Text('$_snoozeMinutes phút'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSnoozePicker(),
          ),
          const Divider(),

          // Data settings
          _buildSectionHeader('Dữ liệu'),
          SwitchListTile(
            title: const Text('Đồng bộ đám mây'),
            subtitle: const Text('Sao lưu dữ liệu lên đám mây'),
            value: _cloudSyncEnabled,
            onChanged: (value) {
              setState(() => _cloudSyncEnabled = value);
              _saveSetting('cloud_sync_enabled', value.toString());
            },
            secondary: const Icon(Icons.cloud_sync),
          ),
          const Divider(),

          // About
          _buildSectionHeader('Thông tin'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản ứng dụng'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Đồ án môn học'),
            subtitle: const Text('Ứng dụng nhắc uống thuốc - Flutter'),
          ),
          const SizedBox(height: 24),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showSnoozePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thời gian nhắc lại'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [5, 10, 15, 30].map((minutes) {
              return RadioListTile<int>(
                title: Text('$minutes phút'),
                value: minutes,
                groupValue: _snoozeMinutes,
                onChanged: (value) {
                  setState(() {
                    _snoozeMinutes = value!;
                  });
                  _saveSetting('snooze_minutes', value.toString());
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
