import '../models/prescription.dart';
import 'api_service.dart';

class PrescriptionService {
  static Future<List<Prescription>> getAll() async {
    final response = await ApiService.get('prescriptions');
    final list = response['data'] as List;
    return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Prescription>> getActive() async {
    final response = await ApiService.get('prescriptions/active');
    final list = response['data'] as List;
    return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Prescription> getById(String id) async {
    final response = await ApiService.get('prescriptions/$id');
    return Prescription.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<Prescription> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('prescriptions', data);
    return Prescription.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<Prescription> update(String id, Map<String, dynamic> data) async {
    final response = await ApiService.patch('prescriptions/$id', data);
    return Prescription.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiService.delete('prescriptions/$id');
  }

  static Future<void> deactivate(String id) async {
    await ApiService.patch('prescriptions/$id/deactivate', {});
  }
}
