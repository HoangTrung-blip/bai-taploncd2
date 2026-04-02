import 'medicine.dart';

class MedicineSchedule {
  final String id;
  final Medicine medicine;
  final List<String> times; // ["08:00", "12:00", "20:00"]
  final String frequency; // "daily", "alternate", "weekly"
  final List<int>? weekDays; // [1, 3, 5] for Mon, Wed, Fri
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  MedicineSchedule({
    required this.id,
    required this.medicine,
    required this.times,
    required this.frequency,
    this.weekDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });
}
