class Medicine {
  final String id;
  final String name;
  final String type; // viên nén, siro, tiêm, nhỏ mắt...
  final String dosage; // 1 viên, 10ml...
  final String? imagePath;
  final int totalQuantity;
  final int remainingQuantity;
  final String? note;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.dosage,
    this.imagePath,
    required this.totalQuantity,
    required this.remainingQuantity,
    this.note,
  });

  bool get isLowStock => remainingQuantity <= 5;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      dosage: json['dosage'] as String,
      imagePath: json['imagePath'] as String?,
      totalQuantity: json['totalQuantity'] as int,
      remainingQuantity: json['remainingQuantity'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'dosage': dosage,
        'imagePath': imagePath,
        'totalQuantity': totalQuantity,
        'remainingQuantity': remainingQuantity,
        'note': note,
      };

  Medicine copyWith({
    String? id,
    String? name,
    String? type,
    String? dosage,
    String? imagePath,
    int? totalQuantity,
    int? remainingQuantity,
    String? note,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      imagePath: imagePath ?? this.imagePath,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      note: note ?? this.note,
    );
  }
}
