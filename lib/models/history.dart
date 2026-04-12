class MedicineHistory {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status; // "taken", "skipped", "snoozed", "missed"
  final String? period; // "morning", "evening"

  MedicineHistory({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.period,
  });

  factory MedicineHistory.fromJson(Map<String, dynamic> json) {
    return MedicineHistory(
      id: json['id'] as String,
      medicineId: json['medicineId'] as String,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      status: json['status'] as String,
      period: json['period'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
        'takenTime': takenTime?.toIso8601String(),
        'status': status,
        'period': period,
      };
}
