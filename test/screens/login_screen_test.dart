import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget', () {
    Widget createWidget() {
      return const MaterialApp(
        home: LoginScreen(),
      );
    }

    testWidgets('hiển thị tiêu đề Đăng nhập', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Đăng nhập'), findsWidgets);
    });

    testWidgets('hiển thị phụ đề Nhắc uống thuốc',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Nhắc uống thuốc'), findsOneWidget);
    });

    testWidgets('hiển thị trường email với giá trị mặc định',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('demo@medicine.app'), findsOneWidget);
    });

    testWidgets('hiển thị trường mật khẩu', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Mật khẩu'), findsOneWidget);
    });

    testWidgets('hiển thị nút Đăng nhập', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(
        find.widgetWithText(ElevatedButton, 'Đăng nhập'),
        findsOneWidget,
      );
    });

    testWidgets('hiển thị liên kết chuyển sang Đăng ký',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
    });

    testWidgets('chuyển sang form Đăng ký khi nhấn liên kết',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhấn chuyển sang Đăng ký
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pumpAndSettle();

      // Kiểm tra giao diện chuyển sang Đăng ký
      expect(find.text('Đăng ký'), findsWidgets);
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Đã có tài khoản? Đăng nhập'), findsOneWidget);
    });

    testWidgets('chuyển lại form Đăng nhập khi nhấn liên kết',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Chuyển sang Đăng ký
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pumpAndSettle();

      // Chuyển lại Đăng nhập
      await tester.tap(find.text('Đã có tài khoản? Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
      // Trường Họ và tên không còn hiển thị
      expect(find.text('Họ và tên'), findsNothing);
    });

    testWidgets('hiển thị lỗi validation khi email trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Xóa email mặc định
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, '');

      // Nhấn Đăng nhập
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('hiển thị lỗi validation khi email không hợp lệ',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhập email không hợp lệ
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      // Nhấn Đăng nhập
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('hiển thị lỗi validation khi mật khẩu trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Xóa mật khẩu mặc định  
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');
      await tester.enterText(passwordField, '');

      // Nhấn Đăng nhập
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('hiển thị lỗi validation khi mật khẩu quá ngắn',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhập mật khẩu ngắn
      final passwordField = find.widgetWithText(TextFormField, 'Mật khẩu');
      await tester.enterText(passwordField, '123');

      // Nhấn Đăng nhập
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('chuyển đổi ẩn/hiện mật khẩu khi nhấn icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Mặc định mật khẩu bị ẩn (có icon visibility_off)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Nhấn để hiện mật khẩu
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Kiểm tra icon chuyển thành visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('hiển thị trường Họ và tên khi ở chế độ Đăng ký',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Đổi sang Đăng ký
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên'), findsOneWidget);
    });

    testWidgets('validation họ tên khi đăng ký bỏ trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Đổi sang Đăng ký
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
      await tester.pumpAndSettle();

      // Nhấn Đăng ký mà chưa nhập họ tên
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    });

    testWidgets('hiển thị icon thuốc ở đầu trang', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.medication), findsOneWidget);
    });
  });
}
