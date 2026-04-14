import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/history.dart';

void main() {
  group('MedicineHistory Model', () {
    final sampleJson = {
      'id': 'hist-001',
      'medicineId': 'med-001',
      'medicineName': 'Paracetamol',
      'dosage': '1 viên',
      'scheduledTime': '2025-01-15T08:00:00.000Z',
      'takenTime': '2025-01-15T08:15:00.000Z',
      'status': 'taken',
      'period': 'morning',
    };

    test('fromJson tạo đối tượng MedicineHistory chính xác', () {
      final history = MedicineHistory.fromJson(sampleJson);

      expect(history.id, 'hist-001');
      expect(history.medicineId, 'med-001');
      expect(history.medicineName, 'Paracetamol');
      expect(history.dosage, '1 viên');
      expect(history.scheduledTime, DateTime.utc(2025, 1, 15, 8, 0));
      expect(history.takenTime, DateTime.utc(2025, 1, 15, 8, 15));
      expect(history.status, 'taken');
      expect(history.period, 'morning');
    });

    test('fromJson xử lý takenTime null khi chưa uống', () {
      final json = {
        'id': 'hist-002',
        'medicineId': 'med-001',
        'medicineName': 'Amoxicillin',
        'dosage': '500mg',
        'scheduledTime': '2025-01-15T20:00:00.000Z',
        'takenTime': null,
        'status': 'missed',
        'period': null,
      };

      final history = MedicineHistory.fromJson(json);

      expect(history.takenTime, isNull);
      expect(history.status, 'missed');
      expect(history.period, isNull);
    });

    test('fromJson xử lý các trạng thái khác nhau', () {
      final statuses = ['taken', 'skipped', 'snoozed', 'missed'];

      for (final status in statuses) {
        final json = {
          'id': 'hist-test',
          'medicineId': 'med-001',
          'medicineName': 'Test',
          'dosage': '1 viên',
          'scheduledTime': '2025-01-15T08:00:00.000Z',
          'status': status,
        };
        final history = MedicineHistory.fromJson(json);
        expect(history.status, status);
      }
    });

    test('toJson trả về Map đúng định dạng', () {
      final history = MedicineHistory.fromJson(sampleJson);
      final json = history.toJson();

      expect(json['medicineId'], 'med-001');
      expect(json['medicineName'], 'Paracetamol');
      expect(json['dosage'], '1 viên');
      expect(json['scheduledTime'], isNotNull);
      expect(json['takenTime'], isNotNull);
      expect(json['status'], 'taken');
      expect(json['period'], 'morning');
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson xử lý takenTime null', () {
      final json = {
        'id': 'hist-003',
        'medicineId': 'med-001',
        'medicineName': 'Test',
        'dosage': '1 viên',
        'scheduledTime': '2025-01-15T08:00:00.000Z',
        'status': 'skipped',
      };

      final history = MedicineHistory.fromJson(json);
      final output = history.toJson();

      expect(output['takenTime'], isNull);
    });

    test('fromJson phân biệt buổi sáng và buổi tối', () {
      final morningJson = Map<String, dynamic>.from(sampleJson);
      morningJson['period'] = 'morning';
      final morningHistory = MedicineHistory.fromJson(morningJson);
      expect(morningHistory.period, 'morning');

      final eveningJson = Map<String, dynamic>.from(sampleJson);
      eveningJson['period'] = 'evening';
      final eveningHistory = MedicineHistory.fromJson(eveningJson);
      expect(eveningHistory.period, 'evening');
    });
  });
}
