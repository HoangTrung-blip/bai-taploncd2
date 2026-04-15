import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/services/api_service.dart';

void main() {
  group('ApiException', () {
    test('toString trả về chuỗi đúng định dạng', () {
      final exception = ApiException(statusCode: 401, message: 'Unauthorized');

      expect(exception.toString(), 'ApiException(401): Unauthorized');
    });

    test('lưu trữ statusCode chính xác', () {
      final exception = ApiException(statusCode: 404, message: 'Not found');

      expect(exception.statusCode, 404);
    });

    test('lưu trữ message chính xác', () {
      final exception =
          ApiException(statusCode: 500, message: 'Lỗi máy chủ nội bộ');

      expect(exception.message, 'Lỗi máy chủ nội bộ');
    });

    test('là một Exception', () {
      final exception =
          ApiException(statusCode: 400, message: 'Bad request');

      expect(exception, isA<Exception>());
    });

    test('xử lý các mã trạng thái HTTP khác nhau', () {
      final codes = {
        400: 'Yêu cầu không hợp lệ',
        401: 'Chưa xác thực',
        403: 'Không có quyền truy cập',
        404: 'Không tìm thấy',
        409: 'Dữ liệu trùng lặp',
        500: 'Lỗi máy chủ',
      };

      for (final entry in codes.entries) {
        final exception =
            ApiException(statusCode: entry.key, message: entry.value);
        expect(exception.statusCode, entry.key);
        expect(exception.message, entry.value);
        expect(exception.toString(),
            'ApiException(${entry.key}): ${entry.value}');
      }
    });
  });

  group('ApiService cấu hình', () {
    test('isLoggedIn trả về false khi chưa đăng nhập', () {
      // Khi chưa gọi init() hoặc setToken(), _token = null
      expect(ApiService.isLoggedIn, isFalse);
    });
  });
}
