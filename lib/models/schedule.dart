import 'medicine.dart';

class MedicineSchedule {
  final String id;
  final Medicine? medicine;
  final String medicineName;
  final String? dosage;
  final List<String> times; // ["08:00", "12:00", "20:00"]
  final String frequency; // "daily", "alternate", "weekly"
  final List<int>? weekDays; // [1, 3, 5] for Mon, Wed, Fri
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  MedicineSchedule({
    required this.id,
    this.medicine,
    required this.medicineName,
    this.dosage,
    required this.times,
    required this.frequency,
    this.weekDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String?,
      times: (json['times'] as List?)?.map((e) => e.toString()).toList() ??
          (json['times'] is String
              ? (json['times'] as String).split(',')
              : []),
      frequency: json['frequency'] as String? ?? 'daily',
      weekDays: (json['weekDays'] as List?)?.map((e) => e as int).toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'dosage': dosage,
        'times': times,
        'frequency': frequency,
        'weekDays': weekDays,
        'startDate': startDate.toIso8601String().substring(0, 10),
        'endDate': endDate?.toIso8601String().substring(0, 10),
      };
}
