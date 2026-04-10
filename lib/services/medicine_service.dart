import '../models/medicine.dart';
import 'api_service.dart';

class MedicineService {
  static Future<List<Medicine>> getAll() async {
    final response = await ApiService.get('medicines');
    final list = response['data'] as List;
    return list.map((e) => Medicine.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Medicine> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('medicines', data);
    return Medicine.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<Medicine> update(String id, Map<String, dynamic> data) async {
    final response = await ApiService.patch('medicines/$id', data);
    return Medicine.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiService.delete('medicines/$id');
  }
}
