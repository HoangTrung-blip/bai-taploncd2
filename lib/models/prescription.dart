import 'package:flutter/material.dart';

/// Đơn thuốc (Prescription)
class Prescription {
  final String id;
  final String patientName;
  final String diseaseName;
  final String doctorName;
  final DateTime startDate;
  final int treatmentDays;
  final String morningTime;
  final String eveningTime;
  final List<PrescriptionMedicine> medicines;
  final String? notes;
  final bool isActive;

  Prescription({
    required this.id,
    required this.patientName,
    required this.diseaseName,
    required this.doctorName,
    required this.startDate,
    required this.treatmentDays,
    required this.morningTime,
    required this.eveningTime,
    required this.medicines,
    this.notes,
    this.isActive = true,
  });

  DateTime get endDate => startDate.add(Duration(days: treatmentDays - 1));

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      patientName: json['patientName'] as String? ?? '',
      diseaseName: json['diseaseName'] as String,
      doctorName: json['doctorName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      treatmentDays: json['treatmentDays'] as int,
      morningTime: json['morningTime'] as String,
      eveningTime: json['eveningTime'] as String,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      medicines: (json['medicines'] as List?)
              ?.map((e) =>
                  PrescriptionMedicine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'patientName': patientName,
        'diseaseName': diseaseName,
        'doctorName': doctorName,
        'startDate': startDate.toIso8601String().substring(0, 10),
        'treatmentDays': treatmentDays,
        'morningTime': morningTime,
        'eveningTime': eveningTime,
        'notes': notes,
        'medicines': medicines.map((m) => m.toJson()).toList(),
      };
}

/// Thuốc trong đơn thuốc
class PrescriptionMedicine {
  final String id;
  final String name;
  final String shortName;
  final String type;
  final String ingredient;
  final String usage;
  final String morningDose;
  final String eveningDose;
  final String instruction;
  final Color color;

  PrescriptionMedicine({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.ingredient,
    required this.usage,
    required this.morningDose,
    required this.eveningDose,
    required this.instruction,
    required this.color,
  });

  factory PrescriptionMedicine.fromJson(Map<String, dynamic> json) {
    final colorStr = json['color'] as String? ?? '#4CAF50';
    final colorValue =
        int.parse(colorStr.replaceFirst('#', ''), radix: 16) + 0xFF000000;
    return PrescriptionMedicine(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      type: json['type'] as String,
      ingredient: json['ingredient'] as String,
      usage: json['usage'] as String,
      morningDose: json['morningDose'] as String,
      eveningDose: json['eveningDose'] as String,
      instruction: json['instruction'] as String,
      color: Color(colorValue),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'shortName': shortName,
        'type': type,
        'ingredient': ingredient,
        'usage': usage,
        'morningDose': morningDose,
        'eveningDose': eveningDose,
        'instruction': instruction,
        'color':
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
      };
}
