import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/medicine.dart';

void main() {
  group('Medicine Model', () {
    final sampleJson = {
      'id': 'med-001',
      'name': 'Paracetamol',
      'type': 'Viên nén',
      'dosage': '500mg',
      'imagePath': '/images/paracetamol.png',
      'totalQuantity': 30,
      'remainingQuantity': 10,
      'note': 'Uống sau ăn',
    };

    test('fromJson tạo đối tượng Medicine chính xác', () {
      final medicine = Medicine.fromJson(sampleJson);

      expect(medicine.id, 'med-001');
      expect(medicine.name, 'Paracetamol');
      expect(medicine.type, 'Viên nén');
      expect(medicine.dosage, '500mg');
      expect(medicine.imagePath, '/images/paracetamol.png');
      expect(medicine.totalQuantity, 30);
      expect(medicine.remainingQuantity, 10);
      expect(medicine.note, 'Uống sau ăn');
    });

    test('fromJson xử lý trường nullable khi null', () {
      final json = {
        'id': 'med-002',
        'name': 'Amoxicillin',
        'type': 'Viên nang',
        'dosage': '250mg',
        'imagePath': null,
        'totalQuantity': 20,
        'remainingQuantity': 15,
        'note': null,
      };

      final medicine = Medicine.fromJson(json);

      expect(medicine.imagePath, isNull);
      expect(medicine.note, isNull);
    });

    test('toJson trả về Map đúng định dạng', () {
      final medicine = Medicine.fromJson(sampleJson);
      final json = medicine.toJson();

      expect(json['name'], 'Paracetamol');
      expect(json['type'], 'Viên nén');
      expect(json['dosage'], '500mg');
      expect(json['totalQuantity'], 30);
      expect(json['remainingQuantity'], 10);
      expect(json['note'], 'Uống sau ăn');
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });

    test('isLowStock trả về true khi remainingQuantity <= 5', () {
      final medicine = Medicine(
        id: '1',
        name: 'Test',
        type: 'Viên',
        dosage: '1 viên',
        totalQuantity: 30,
        remainingQuantity: 5,
      );
      expect(medicine.isLowStock, isTrue);

      final medicine2 = Medicine(
        id: '2',
        name: 'Test2',
        type: 'Viên',
        dosage: '1 viên',
        totalQuantity: 30,
        remainingQuantity: 3,
      );
      expect(medicine2.isLowStock, isTrue);
    });

    test('isLowStock trả về false khi remainingQuantity > 5', () {
      final medicine = Medicine(
        id: '1',
        name: 'Test',
        type: 'Viên',
        dosage: '1 viên',
        totalQuantity: 30,
        remainingQuantity: 6,
      );
      expect(medicine.isLowStock, isFalse);
    });

    test('copyWith tạo bản sao với các trường được thay đổi', () {
      final original = Medicine.fromJson(sampleJson);
      final copy = original.copyWith(
        name: 'Aspirin',
        remainingQuantity: 3,
      );

      expect(copy.name, 'Aspirin');
      expect(copy.remainingQuantity, 3);
      // Các trường khác giữ nguyên
      expect(copy.id, original.id);
      expect(copy.type, original.type);
      expect(copy.dosage, original.dosage);
      expect(copy.totalQuantity, original.totalQuantity);
    });

    test('copyWith giữ nguyên tất cả trường khi không truyền tham số', () {
      final original = Medicine.fromJson(sampleJson);
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.type, original.type);
      expect(copy.dosage, original.dosage);
      expect(copy.imagePath, original.imagePath);
      expect(copy.totalQuantity, original.totalQuantity);
      expect(copy.remainingQuantity, original.remainingQuantity);
      expect(copy.note, original.note);
    });
  });
}
