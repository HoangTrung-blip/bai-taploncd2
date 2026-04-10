import '../models/history.dart';
import 'api_service.dart';

class HistoryService {
  static Future<List<MedicineHistory>> getAll({
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await ApiService.get('history?$queryString');
    final data = response['data'] as Map<String, dynamic>;
    final list = data['data'] as List;
    return list.map((e) => MedicineHistory.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<MedicineHistory>> getByDate(String date) async {
    final response = await ApiService.get('history/date/$date');
    final list = response['data'] as List;
    return list.map((e) => MedicineHistory.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<MedicineHistory> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('history', data);
    return MedicineHistory.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<MedicineHistory> markAsTaken(String id) async {
    final response = await ApiService.patch('history/$id/taken', {});
    return MedicineHistory.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<MedicineHistory> markAsSkipped(String id) async {
    final response = await ApiService.patch('history/$id/skipped', {});
    return MedicineHistory.fromJson(response['data'] as Map<String, dynamic>);
  }
}
