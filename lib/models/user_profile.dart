class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String bloodType;
  final String allergies;
  final String emergencyContact;
  final String emergencyPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.bloodType,
    required this.allergies,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'bloodType': bloodType,
    'allergies': allergies,
    'emergencyContact': emergencyContact,
    'emergencyPhone': emergencyPhone,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Convert from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dateOfBirth: json['dateOfBirth'] ?? '',
    bloodType: json['bloodType'] ?? 'O+',
    allergies: json['allergies'] ?? 'None',
    emergencyContact: json['emergencyContact'] ?? '',
    emergencyPhone: json['emergencyPhone'] ?? '',
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
  );

  // Copy with modifications
  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? bloodType,
    String? allergies,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        bloodType: bloodType ?? this.bloodType,
        allergies: allergies ?? this.allergies,
        emergencyContact: emergencyContact ?? this.emergencyContact,
        emergencyPhone: emergencyPhone ?? this.emergencyPhone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
