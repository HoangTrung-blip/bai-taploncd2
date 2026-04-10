import 'api_service.dart';

class SettingsService {
  static Future<Map<String, dynamic>> getAll() async {
    final response = await ApiService.get('settings');
    return response['data'] as Map<String, dynamic>;
  }

  static Future<String> get(String key) async {
    final response = await ApiService.get('settings/$key');
    final data = response['data'] as Map<String, dynamic>;
    return data['value'] as String;
  }

  static Future<void> set(String key, String value) async {
    await ApiService.put('settings/$key', {'value': value});
  }

  static Future<Map<String, dynamic>> bulkUpdate(
      Map<String, String> settings) async {
    final response = await ApiService.patch('settings/bulk', {
      'settings': settings,
    });
    return response['data'] as Map<String, dynamic>;
  }
}
