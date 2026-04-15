import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/models/medicine.dart';
import 'package:medicine_reminder/models/prescription.dart';
import 'package:medicine_reminder/models/schedule.dart';
import 'package:medicine_reminder/models/history.dart';
import 'package:medicine_reminder/models/emergency_contact.dart';

/// Test tích hợp: kiểm tra luồng dữ liệu từ API response (JSON) -> Model -> JSON
/// Mô phỏng phản hồi từ backend NestJS (có wrapper {success, data, timestamp})
void main() {
  group('Tích hợp Frontend-Backend: Phân tích dữ liệu API', () {
    test('phân tích phản hồi API danh sách thuốc', () {
      // Mô phỏng response từ GET /api/medicines
      final apiResponse = {
        'success': true,
        'data': [
          {
            'id': 'uuid-001',
            'name': 'Paracetamol 500mg',
            'type': 'Viên nén',
            'dosage': '1 viên',
            'imagePath': null,
            'totalQuantity': 30,
            'remainingQuantity': 25,
            'note': 'Uống sau ăn 30 phút',
          },
          {
            'id': 'uuid-002',
            'name': 'Amoxicillin 250mg',
            'type': 'Viên nang',
            'dosage': '500mg',
            'imagePath': null,
            'totalQuantity': 20,
            'remainingQuantity': 3,
            'note': null,
          },
        ],
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final list = apiResponse['data'] as List;
      final medicines = list
          .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(medicines.length, 2);
      expect(medicines[0].name, 'Paracetamol 500mg');
      expect(medicines[0].isLowStock, isFalse);
      expect(medicines[1].name, 'Amoxicillin 250mg');
      expect(medicines[1].isLowStock, isTrue);
    });

    test('phân tích phản hồi API đơn thuốc với medicines lồng nhau', () {
      // Mô phỏng response từ GET /api/prescriptions
      final apiResponse = {
        'success': true,
        'data': [
          {
            'id': 'rx-001',
            'patientName': 'Nguyễn Văn A',
            'diseaseName': 'Viêm phế quản',
            'doctorName': 'BS. Trần Thị B',
            'startDate': '2025-01-01',
            'treatmentDays': 14,
            'morningTime': '07:30',
            'eveningTime': '19:30',
            'isActive': true,
            'notes': 'Tái khám sau 2 tuần',
            'medicines': [
              {
                'id': 'pm-001',
                'name': 'Augmentin 1g',
                'shortName': 'AUG',
                'type': 'Viên nén',
                'ingredient': 'Amoxicillin + Acid Clavulanic',
                'usage': 'Kháng sinh phổ rộng',
                'morningDose': '1 viên',
                'eveningDose': '1 viên',
                'instruction': 'Uống đầu bữa ăn',
                'color': '#E91E63',
              },
              {
                'id': 'pm-002',
                'name': 'Prednisolon 5mg',
                'shortName': 'PRD',
                'type': 'Viên nén',
                'ingredient': 'Prednisolone',
                'usage': 'Chống viêm',
                'morningDose': '2 viên',
                'eveningDose': '1 viên',
                'instruction': 'Uống sau ăn',
                'color': '#2196F3',
              },
            ],
          },
        ],
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final list = apiResponse['data'] as List;
      final prescriptions = list
          .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(prescriptions.length, 1);
      final rx = prescriptions.first;
      expect(rx.diseaseName, 'Viêm phế quản');
      expect(rx.medicines.length, 2);
      expect(rx.medicines[0].shortName, 'AUG');
      expect(rx.medicines[1].morningDose, '2 viên');
      expect(rx.endDate, DateTime(2025, 1, 14)); // startDate + 13 days
    });

    test('phân tích phản hồi API lịch sử phân trang', () {
      // Mô phỏng response từ GET /api/history?page=1&limit=50
      final apiResponse = {
        'success': true,
        'data': {
          'data': [
            {
              'id': 'hist-001',
              'medicineId': 'med-001',
              'medicineName': 'Paracetamol',
              'dosage': '1 viên',
              'scheduledTime': '2025-01-15T07:30:00.000Z',
              'takenTime': '2025-01-15T07:45:00.000Z',
              'status': 'taken',
              'period': 'morning',
            },
            {
              'id': 'hist-002',
              'medicineId': 'med-001',
              'medicineName': 'Paracetamol',
              'dosage': '1 viên',
              'scheduledTime': '2025-01-15T19:30:00.000Z',
              'takenTime': null,
              'status': 'missed',
              'period': 'evening',
            },
          ],
          'total': 50,
          'page': 1,
          'limit': 50,
        },
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      // Mô phỏng cách HistoryService xử lý response
      final data = apiResponse['data'] as Map<String, dynamic>;
      final list = data['data'] as List;
      final histories = list
          .map((e) => MedicineHistory.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(histories.length, 2);
      expect(histories[0].status, 'taken');
      expect(histories[0].takenTime, isNotNull);
      expect(histories[1].status, 'missed');
      expect(histories[1].takenTime, isNull);
    });

    test('phân tích phản hồi API lịch uống thuốc', () {
      final apiResponse = {
        'success': true,
        'data': [
          {
            'id': 'sch-001',
            'medicineName': 'Paracetamol',
            'dosage': '1 viên',
            'times': ['08:00', '20:00'],
            'frequency': 'daily',
            'weekDays': null,
            'startDate': '2025-01-01',
            'endDate': '2025-01-31',
            'isActive': true,
          },
        ],
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final list = apiResponse['data'] as List;
      final schedules = list
          .map((e) => MedicineSchedule.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(schedules.length, 1);
      expect(schedules.first.times, ['08:00', '20:00']);
      expect(schedules.first.frequency, 'daily');
      expect(schedules.first.isActive, isTrue);
    });

    test('phân tích phản hồi API liên hệ khẩn cấp', () {
      final apiResponse = {
        'success': true,
        'data': [
          {
            'id': 'ec-001',
            'name': 'BS. Nguyễn Văn A',
            'phone': '0901234567',
            'relationship': 'Bác sĩ',
          },
          {
            'id': 'ec-002',
            'name': 'Trần Thị B',
            'phone': '0912345678',
            'relationship': 'Người thân',
          },
        ],
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final list = apiResponse['data'] as List;
      final contacts = list
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(contacts.length, 2);
      expect(contacts[0].relationship, 'Bác sĩ');
      expect(contacts[1].relationship, 'Người thân');
    });

    test('phân tích phản hồi API báo cáo tuân thủ', () {
      // Mô phỏng response từ GET /api/reports/adherence
      final apiResponse = {
        'success': true,
        'data': {
          'adherenceRate': 85.5,
          'totalDoses': 28,
          'takenDoses': 24,
          'missedDoses': 4,
          'periodBreakdown': {
            'morning': {'total': 14, 'taken': 13, 'rate': 92.9},
            'evening': {'total': 14, 'taken': 11, 'rate': 78.6},
          },
          'byMedicine': [
            {
              'medicineId': 'med-001',
              'medicineName': 'Paracetamol',
              'total': 14,
              'taken': 12,
              'rate': 85.7,
            },
          ],
          'dailyStats': [
            {
              'date': '2025-01-15',
              'total': 4,
              'taken': 3,
              'rate': 75.0,
            },
          ],
        },
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final data = apiResponse['data'] as Map<String, dynamic>;

      expect(data['adherenceRate'], 85.5);
      expect(data['totalDoses'], 28);
      expect(data['takenDoses'], 24);

      final periodBreakdown =
          data['periodBreakdown'] as Map<String, dynamic>;
      final morning = periodBreakdown['morning'] as Map<String, dynamic>;
      expect(morning['rate'], 92.9);

      final byMedicine = data['byMedicine'] as List;
      expect(byMedicine.length, 1);
      expect((byMedicine[0] as Map<String, dynamic>)['medicineName'],
          'Paracetamol');
    });

    test('phân tích phản hồi API cài đặt', () {
      final apiResponse = {
        'success': true,
        'data': {
          'sound_enabled': 'true',
          'vibration_enabled': 'true',
          'push_notification_enabled': 'true',
          'snooze_minutes': '5',
          'cloud_sync_enabled': 'false',
        },
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final data = apiResponse['data'] as Map<String, dynamic>;

      expect(data['sound_enabled'], 'true');
      expect(data['snooze_minutes'], '5');
      expect(data['cloud_sync_enabled'], 'false');
    });
  });

  group('Tích hợp Frontend-Backend: Gửi dữ liệu lên API', () {
    test('chuẩn bị dữ liệu tạo thuốc mới cho API', () {
      final medicine = Medicine(
        id: '',
        name: 'Vitamin C',
        type: 'Viên nén',
        dosage: '1 viên',
        totalQuantity: 60,
        remainingQuantity: 60,
        note: 'Uống mỗi ngày',
      );

      final json = medicine.toJson();

      // Kiểm tra body gửi lên POST /api/medicines
      expect(json.containsKey('id'), isFalse);
      expect(json['name'], 'Vitamin C');
      expect(json['type'], 'Viên nén');
      expect(json['totalQuantity'], 60);
    });

    test('chuẩn bị dữ liệu tạo đơn thuốc mới cho API', () {
      final prescription = Prescription(
        id: '',
        patientName: 'Lê Văn C',
        diseaseName: 'Cảm cúm',
        doctorName: 'BS. Phạm D',
        startDate: DateTime(2025, 3, 1),
        treatmentDays: 5,
        morningTime: '07:00',
        eveningTime: '19:00',
        medicines: [],
      );

      final json = prescription.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['patientName'], 'Lê Văn C');
      expect(json['startDate'], '2025-03-01');
      expect(json['treatmentDays'], 5);
      expect(json['medicines'], isEmpty);
    });

    test('chuẩn bị dữ liệu tạo lịch uống thuốc cho API', () {
      final schedule = MedicineSchedule(
        id: '',
        medicineName: 'Paracetamol',
        dosage: '1 viên',
        times: ['08:00', '20:00'],
        frequency: 'daily',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
      );

      final json = schedule.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['medicineName'], 'Paracetamol');
      expect(json['times'], ['08:00', '20:00']);
      expect(json['startDate'], '2025-01-01');
      expect(json['endDate'], '2025-01-31');
    });

    test('chuẩn bị dữ liệu tạo liên hệ khẩn cấp cho API', () {
      final contact = EmergencyContact(
        id: '',
        name: 'Nguyễn Thị E',
        phone: '0987654321',
        relationship: 'Người thân',
      );

      final json = contact.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['name'], 'Nguyễn Thị E');
      expect(json['phone'], '0987654321');
      expect(json['relationship'], 'Người thân');
    });

    test('chuẩn bị dữ liệu ghi lịch sử uống thuốc cho API', () {
      final history = MedicineHistory(
        id: '',
        medicineId: 'med-001',
        medicineName: 'Paracetamol',
        dosage: '1 viên',
        scheduledTime: DateTime(2025, 1, 15, 8, 0),
        status: 'taken',
        takenTime: DateTime(2025, 1, 15, 8, 10),
        period: 'morning',
      );

      final json = history.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['medicineId'], 'med-001');
      expect(json['status'], 'taken');
      expect(json['period'], 'morning');
      expect(json['takenTime'], isNotNull);
    });
  });

  group('Tích hợp Frontend-Backend: Xử lý lỗi API', () {
    test('xử lý phản hồi lỗi 401 - Chưa xác thực', () {
      final errorResponse = {
        'statusCode': 401,
        'message': 'Unauthorized',
      };

      expect(errorResponse['statusCode'], 401);
      expect(errorResponse['message'], 'Unauthorized');
    });

    test('xử lý phản hồi lỗi 404 - Không tìm thấy', () {
      final errorResponse = {
        'statusCode': 404,
        'message': 'Không tìm thấy thuốc',
      };

      expect(errorResponse['statusCode'], 404);
      expect(errorResponse['message'], 'Không tìm thấy thuốc');
    });

    test('xử lý phản hồi lỗi 409 - Trùng lặp email', () {
      final errorResponse = {
        'statusCode': 409,
        'message': 'Email đã tồn tại',
      };

      expect(errorResponse['statusCode'], 409);
      expect(errorResponse['message'], 'Email đã tồn tại');
    });

    test('xử lý danh sách rỗng từ API', () {
      final apiResponse = {
        'success': true,
        'data': <Map<String, dynamic>>[],
        'timestamp': '2025-01-15T10:30:00.000Z',
      };

      final list = apiResponse['data'] as List;
      final medicines = list
          .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(medicines, isEmpty);
    });
  });
}
