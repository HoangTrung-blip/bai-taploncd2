import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_reminder/main.dart';

void main() {
  group('MainNavigation Widget', () {
    testWidgets('hiển thị 5 mục điều hướng trong thanh dưới',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const MainNavigation(),
        ),
      );
      // Đợi frame đầu tiên (loading state)
      await tester.pump();

      // Kiểm tra NavigationBar hiển thị
      expect(find.byType(NavigationBar), findsOneWidget);

      // Kiểm tra 5 mục điều hướng
      expect(find.text('Lịch uống'), findsOneWidget);
      expect(find.text('Thuốc'), findsOneWidget);
      expect(find.text('Lịch sử'), findsOneWidget);
      expect(find.text('Báo cáo'), findsOneWidget);
      expect(find.text('Liên hệ'), findsOneWidget);
    });

    testWidgets('hiển thị các icon điều hướng',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const MainNavigation(),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
      expect(find.byIcon(Icons.medication_outlined), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.contacts_outlined), findsOneWidget);
    });
  });

  group('MedicineReminderApp Widget', () {
    testWidgets('khởi tạo ứng dụng với MaterialApp',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MedicineReminderApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('hiển thị LoginScreen khi chưa đăng nhập',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MedicineReminderApp());

      // Khi chưa đăng nhập, hiển thị LoginScreen
      expect(find.text('Nhắc uống thuốc'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsWidgets);
    });

    testWidgets('không hiển thị debug banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MedicineReminderApp());

      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });
}
