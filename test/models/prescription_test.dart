import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/prescription.dart';

void main() {
  group('Prescription Model', () {
    final sampleJson = {
      'id': 'rx-001',
      'patientName': 'Nguyễn Văn A',
      'diseaseName': 'Viêm họng cấp',
      'doctorName': 'BS. Trần Thị B',
      'startDate': '2025-01-01',
      'treatmentDays': 7,
      'morningTime': '07:00',
      'eveningTime': '19:00',
      'notes': 'Uống thuốc đúng giờ',
      'isActive': true,
      'medicines': [
        {
          'id': 'pm-001',
          'name': 'Amoxicillin 500mg',
          'shortName': 'AMX',
          'type': 'Viên nang',
          'ingredient': 'Amoxicillin trihydrate',
          'usage': 'Kháng sinh',
          'morningDose': '1 viên',
          'eveningDose': '1 viên',
          'instruction': 'Uống sau ăn 30 phút',
          'color': '#4CAF50',
        },
      ],
    };

    test('fromJson tạo đối tượng Prescription chính xác', () {
      final prescription = Prescription.fromJson(sampleJson);

      expect(prescription.id, 'rx-001');
      expect(prescription.patientName, 'Nguyễn Văn A');
      expect(prescription.diseaseName, 'Viêm họng cấp');
      expect(prescription.doctorName, 'BS. Trần Thị B');
      expect(prescription.startDate, DateTime(2025, 1, 1));
      expect(prescription.treatmentDays, 7);
      expect(prescription.morningTime, '07:00');
      expect(prescription.eveningTime, '19:00');
      expect(prescription.notes, 'Uống thuốc đúng giờ');
      expect(prescription.isActive, isTrue);
      expect(prescription.medicines.length, 1);
    });

    test('fromJson xử lý mặc định khi thiếu trường', () {
      final minimalJson = {
        'id': 'rx-002',
        'diseaseName': 'Cảm cúm',
        'doctorName': 'BS. Lê C',
        'startDate': '2025-03-01',
        'treatmentDays': 5,
        'morningTime': '08:00',
        'eveningTime': '20:00',
      };

      final prescription = Prescription.fromJson(minimalJson);

      expect(prescription.patientName, '');
      expect(prescription.notes, isNull);
      expect(prescription.isActive, isTrue);
      expect(prescription.medicines, isEmpty);
    });

    test('endDate tính đúng từ startDate và treatmentDays', () {
      final prescription = Prescription.fromJson(sampleJson);

      // startDate = 2025-01-01, treatmentDays = 7
      // endDate = startDate + (7-1) days = 2025-01-07
      expect(prescription.endDate, DateTime(2025, 1, 7));
    });

    test('toJson trả về Map đúng định dạng', () {
      final prescription = Prescription.fromJson(sampleJson);
      final json = prescription.toJson();

      expect(json['patientName'], 'Nguyễn Văn A');
      expect(json['diseaseName'], 'Viêm họng cấp');
      expect(json['doctorName'], 'BS. Trần Thị B');
      expect(json['startDate'], '2025-01-01');
      expect(json['treatmentDays'], 7);
      expect(json['morningTime'], '07:00');
      expect(json['eveningTime'], '19:00');
      expect(json['notes'], 'Uống thuốc đúng giờ');
      expect(json['medicines'], isList);
      expect((json['medicines'] as List).length, 1);
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });
  });

  group('PrescriptionMedicine Model', () {
    final sampleJson = {
      'id': 'pm-001',
      'name': 'Paracetamol 500mg',
      'shortName': 'PCM',
      'type': 'Viên nén',
      'ingredient': 'Paracetamol',
      'usage': 'Hạ sốt, giảm đau',
      'morningDose': '2 viên',
      'eveningDose': '1 viên',
      'instruction': 'Uống sau ăn',
      'color': '#FF5722',
    };

    test('fromJson tạo đối tượng PrescriptionMedicine chính xác', () {
      final medicine = PrescriptionMedicine.fromJson(sampleJson);

      expect(medicine.id, 'pm-001');
      expect(medicine.name, 'Paracetamol 500mg');
      expect(medicine.shortName, 'PCM');
      expect(medicine.type, 'Viên nén');
      expect(medicine.ingredient, 'Paracetamol');
      expect(medicine.usage, 'Hạ sốt, giảm đau');
      expect(medicine.morningDose, '2 viên');
      expect(medicine.eveningDose, '1 viên');
      expect(medicine.instruction, 'Uống sau ăn');
    });

    test('fromJson chuyển đổi màu sắc chính xác từ hex string', () {
      final medicine = PrescriptionMedicine.fromJson(sampleJson);

      // #FF5722 -> 0xFFFF5722
      expect(medicine.color, const Color(0xFFFF5722));
    });

    test('fromJson dùng màu mặc định khi không có color', () {
      final jsonNoColor = Map<String, dynamic>.from(sampleJson);
      jsonNoColor.remove('color');

      final medicine = PrescriptionMedicine.fromJson(jsonNoColor);

      // Mặc định là #4CAF50
      expect(medicine.color, const Color(0xFF4CAF50));
    });

    test('toJson chuyển đổi color thành hex string', () {
      final medicine = PrescriptionMedicine.fromJson(sampleJson);
      final json = medicine.toJson();

      expect(json['color'], '#FF5722');
      expect(json['name'], 'Paracetamol 500mg');
      expect(json['shortName'], 'PCM');
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });
  });
}
