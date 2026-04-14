import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/screens/add_medicine_screen.dart';

void main() {
  group('AddMedicineScreen Widget', () {
    Widget createWidget() {
      return const MaterialApp(
        home: AddMedicineScreen(),
      );
    }

    testWidgets('hiển thị tiêu đề Thêm thuốc mới',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Thêm thuốc mới'), findsOneWidget);
    });

    testWidgets('hiển thị các trường form cần thiết',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Tên thuốc *'), findsOneWidget);
      expect(find.text('Loại thuốc *'), findsOneWidget);
      expect(find.text('Liều lượng mỗi lần *'), findsOneWidget);
      expect(find.text('Số lượng hiện có *'), findsOneWidget);
      expect(find.text('Ghi chú'), findsOneWidget);
    });

    testWidgets('hiển thị nút Lưu thuốc', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Lưu thuốc'), findsOneWidget);
    });

    testWidgets('hiển thị loại thuốc mặc định là Viên nén',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Viên nén'), findsOneWidget);
    });

    testWidgets('validation tên thuốc khi bỏ trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Cuộn đến nút và nhấn Lưu thuốc khi chưa nhập
      await tester.ensureVisible(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập tên thuốc'), findsOneWidget);
    });

    testWidgets('validation liều lượng khi bỏ trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhập tên thuốc
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập tên thuốc'),
        'Paracetamol',
      );
      await tester.pumpAndSettle();

      // Cuộn xuống và nhấn Lưu thuốc
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập liều lượng'), findsOneWidget);
    });

    testWidgets('validation số lượng khi bỏ trống',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhập tên thuốc và liều lượng
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập tên thuốc'),
        'Paracetamol',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ví dụ: 1 viên, 10ml'),
        '1 viên',
      );

      // Cuộn đến nút và nhấn Lưu thuốc
      await tester.ensureVisible(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập số lượng'), findsOneWidget);
    });

    testWidgets('validation số lượng khi nhập không phải số',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Nhập tên và liều lượng hợp lệ
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập tên thuốc'),
        'Paracetamol',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ví dụ: 1 viên, 10ml'),
        '1 viên',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập số lượng thuốc hiện có'),
        'abc',
      );

      // Cuộn đến nút và nhấn Lưu thuốc
      await tester.ensureVisible(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu thuốc'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập số hợp lệ'), findsOneWidget);
    });

    testWidgets('hiển thị gợi ý nhập liệu', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Nhập tên thuốc'), findsOneWidget);
      expect(find.text('Ví dụ: 1 viên, 10ml'), findsOneWidget);
      expect(find.text('Nhập số lượng thuốc hiện có'), findsOneWidget);
      expect(find.text('Ghi chú thêm (không bắt buộc)'), findsOneWidget);
    });
  });
}
