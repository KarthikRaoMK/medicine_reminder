class Medicine {
  final int? id;
  final String name;
  final String dosage;
  final String frequency;
  final String time;
  final int stockCount;
  bool isTaken;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.stockCount,
    this.isTaken = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'frequency': frequency,
    'time': time,
    'stockCount': stockCount,
    'isTaken': isTaken,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    dosage: json['dosage'],
    frequency: json['frequency'],
    time: json['time'],
    stockCount: json['stockCount'],
    isTaken: json['isTaken'] ?? false,
  );
}