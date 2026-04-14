import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/emergency_contact.dart';

void main() {
  group('EmergencyContact Model', () {
    final sampleJson = {
      'id': 'ec-001',
      'name': 'BS. Nguyễn Văn A',
      'phone': '0901234567',
      'relationship': 'Bác sĩ',
    };

    test('fromJson tạo đối tượng EmergencyContact chính xác', () {
      final contact = EmergencyContact.fromJson(sampleJson);

      expect(contact.id, 'ec-001');
      expect(contact.name, 'BS. Nguyễn Văn A');
      expect(contact.phone, '0901234567');
      expect(contact.relationship, 'Bác sĩ');
    });

    test('fromJson xử lý các mối quan hệ khác nhau', () {
      final relationships = ['Bác sĩ', 'Người thân', 'Bạn bè', 'Dược sĩ'];

      for (final rel in relationships) {
        final json = {
          'id': 'ec-test',
          'name': 'Test',
          'phone': '0123456789',
          'relationship': rel,
        };
        final contact = EmergencyContact.fromJson(json);
        expect(contact.relationship, rel);
      }
    });

    test('toJson trả về Map đúng định dạng', () {
      final contact = EmergencyContact.fromJson(sampleJson);
      final json = contact.toJson();

      expect(json['name'], 'BS. Nguyễn Văn A');
      expect(json['phone'], '0901234567');
      expect(json['relationship'], 'Bác sĩ');
      // toJson không bao gồm id
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson chỉ chứa 3 trường cần thiết', () {
      final contact = EmergencyContact.fromJson(sampleJson);
      final json = contact.toJson();

      expect(json.length, 3);
      expect(json.keys.toSet(), {'name', 'phone', 'relationship'});
    });

    test('fromJson và toJson đảm bảo tính nhất quán dữ liệu', () {
      final contact = EmergencyContact.fromJson(sampleJson);
      final json = contact.toJson();

      // Thêm id để tạo lại đối tượng
      json['id'] = 'ec-new';
      final recreated = EmergencyContact.fromJson(json);

      expect(recreated.name, contact.name);
      expect(recreated.phone, contact.phone);
      expect(recreated.relationship, contact.relationship);
    });
  });
}
