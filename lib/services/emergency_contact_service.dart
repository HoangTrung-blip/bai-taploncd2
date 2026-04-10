import '../models/emergency_contact.dart';
import 'api_service.dart';

class EmergencyContactService {
  static Future<List<EmergencyContact>> getAll() async {
    final response = await ApiService.get('emergency-contacts');
    final list = response['data'] as List;
    return list.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<EmergencyContact> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('emergency-contacts', data);
    return EmergencyContact.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<EmergencyContact> update(String id, Map<String, dynamic> data) async {
    final response = await ApiService.patch('emergency-contacts/$id', data);
    return EmergencyContact.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiService.delete('emergency-contacts/$id');
  }
}
