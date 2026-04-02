import 'package:flutter/material.dart';

/// Đơn thuốc (Prescription)
class Prescription {
  final String id;
  final String diseaseName;
  final String doctorName;
  final DateTime startDate;
  final int treatmentDays;
  final String morningTime;
  final String eveningTime;
  final List<PrescriptionMedicine> medicines;

  Prescription({
    required this.id,
    required this.diseaseName,
    required this.doctorName,
    required this.startDate,
    required this.treatmentDays,
    required this.morningTime,
    required this.eveningTime,
    required this.medicines,
  });

  DateTime get endDate => startDate.add(Duration(days: treatmentDays - 1));
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
}
