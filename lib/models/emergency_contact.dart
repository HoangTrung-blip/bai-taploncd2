class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship; // Bác sĩ, Người thân...

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };
}
