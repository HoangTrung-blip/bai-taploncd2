import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/screens/add_schedule_screen.dart';

void main() {
  group('AddScheduleScreen Widget', () {
    Widget createWidget() {
      return const MaterialApp(
        home: AddScheduleScreen(),
      );
    }

    testWidgets('hiển thị tiêu đề Đặt lịch nhắc',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Đặt lịch nhắc'), findsOneWidget);
    });

    testWidgets('hiển thị trạng thái loading ban đầu',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Khi mới khởi tạo, hiển thị loading (API call sẽ fail trong test)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hiển thị các nhãn sau khi load xong',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      // Đợi loading hoàn tất (API sẽ fail -> isLoading = false)
      await tester.pumpAndSettle();

      expect(find.text('Chọn thuốc'), findsOneWidget);
      expect(find.text('Tần suất uống'), findsOneWidget);
    });
  });
}
