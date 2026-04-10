import '../models/schedule.dart';
import 'api_service.dart';

class ScheduleService {
  static Future<List<MedicineSchedule>> getAll() async {
    final response = await ApiService.get('schedules');
    final list = response['data'] as List;
    return list.map((e) => MedicineSchedule.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<MedicineSchedule> create(Map<String, dynamic> data) async {
    final response = await ApiService.post('schedules', data);
    return MedicineSchedule.fromJson(response['data'] as Map<String, dynamic>);
  }

  static Future<void> delete(String id) async {
    await ApiService.delete('schedules/$id');
  }
}
