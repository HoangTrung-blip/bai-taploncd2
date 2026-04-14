import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/schedule.dart';

void main() {
  group('MedicineSchedule Model', () {
    final sampleJson = {
      'id': 'sch-001',
      'medicineName': 'Paracetamol',
      'dosage': '1 viên',
      'times': ['08:00', '12:00', '20:00'],
      'frequency': 'daily',
      'weekDays': [1, 3, 5],
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'isActive': true,
    };

    test('fromJson tạo đối tượng MedicineSchedule chính xác', () {
      final schedule = MedicineSchedule.fromJson(sampleJson);

      expect(schedule.id, 'sch-001');
      expect(schedule.medicineName, 'Paracetamol');
      expect(schedule.dosage, '1 viên');
      expect(schedule.times, ['08:00', '12:00', '20:00']);
      expect(schedule.frequency, 'daily');
      expect(schedule.weekDays, [1, 3, 5]);
      expect(schedule.startDate, DateTime(2025, 1, 1));
      expect(schedule.endDate, DateTime(2025, 1, 31));
      expect(schedule.isActive, isTrue);
    });

    test('fromJson xử lý trường nullable khi null', () {
      final minimalJson = {
        'id': 'sch-002',
        'medicineName': 'Amoxicillin',
        'startDate': '2025-02-01',
      };

      final schedule = MedicineSchedule.fromJson(minimalJson);

      expect(schedule.dosage, isNull);
      expect(schedule.endDate, isNull);
      expect(schedule.weekDays, isNull);
      expect(schedule.frequency, 'daily'); // giá trị mặc định
      expect(schedule.isActive, isTrue); // giá trị mặc định
    });

    test('fromJson xử lý times là danh sách rỗng', () {
      final json = {
        'id': 'sch-003',
        'medicineName': 'Test',
        'startDate': '2025-01-01',
      };

      final schedule = MedicineSchedule.fromJson(json);

      expect(schedule.times, isEmpty);
    });

    test('toJson trả về Map đúng định dạng', () {
      final schedule = MedicineSchedule.fromJson(sampleJson);
      final json = schedule.toJson();

      expect(json['medicineName'], 'Paracetamol');
      expect(json['dosage'], '1 viên');
      expect(json['times'], ['08:00', '12:00', '20:00']);
      expect(json['frequency'], 'daily');
      expect(json['weekDays'], [1, 3, 5]);
      expect(json['startDate'], '2025-01-01');
      expect(json['endDate'], '2025-01-31');
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson xử lý endDate null', () {
      final json = {
        'id': 'sch-004',
        'medicineName': 'Test',
        'times': ['09:00'],
        'frequency': 'alternate',
        'startDate': '2025-03-01',
      };

      final schedule = MedicineSchedule.fromJson(json);
      final output = schedule.toJson();

      expect(output['endDate'], isNull);
    });

    test('fromJson chấp nhận tần suất khác nhau', () {
      for (final freq in ['daily', 'alternate', 'weekly']) {
        final json = {
          'id': 'sch-test',
          'medicineName': 'Test',
          'frequency': freq,
          'startDate': '2025-01-01',
        };
        final schedule = MedicineSchedule.fromJson(json);
        expect(schedule.frequency, freq);
      }
    });
  });
}
