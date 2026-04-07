import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Notification settings
          _buildSectionHeader('Thông báo'),
          SwitchListTile(
            title: const Text('Âm thanh báo thức'),
            subtitle: const Text('Phát âm thanh khi đến giờ uống thuốc'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('Rung'),
            subtitle: const Text('Rung thiết bị khi có nhắc nhở'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
            secondary: const Icon(Icons.vibration),
          ),
          SwitchListTile(
            title: const Text('Thông báo đẩy'),
            subtitle: const Text('Hiển thị thông báo trên thanh trạng thái'),
            value: _pushNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _pushNotificationEnabled = value;
              });
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
              setState(() {
                _cloudSyncEnabled = value;
              });
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đồng bộ sẽ được tích hợp sau'),
                  ),
                );
              }
            },
            secondary: const Icon(Icons.cloud_sync),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Xuất dữ liệu'),
            subtitle: const Text('Xuất lịch sử uống thuốc ra file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng sẽ được tích hợp sau')),
              );
            },
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

          // Reset button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text(
                      'Bạn có chắc muốn xóa toàn bộ dữ liệu? '
                      'Hành động này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu')),
                          );
                        },
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Xóa toàn bộ dữ liệu',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
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
