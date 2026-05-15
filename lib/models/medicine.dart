enum MedicineCategory {
  painkiller('Painkillers'),
  vitamin('Vitamins'),
  antibiotic('Antibiotics'),
  supplement('Supplements'),
  diabetes('Diabetes'),
  blood_pressure('Blood Pressure'),
  allergy('Allergy'),
  other('Other');

  final String label;
  const MedicineCategory(this.label);
}

class Medicine {
  String?      id;
  final String name;
  final String dosage;
  final String frequency;
  String       time;  // Made mutable for snooze
  int          stockCount;
  bool         isTaken;
  final MedicineCategory category;
  final DateTime? refillDate;
  final int? refillThreshold;
  DateTime?    snoozedUntil;  // Track snooze time
  final String? notes;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.stockCount,
    this.isTaken = false,
    this.category = MedicineCategory.other,
    this.refillDate,
    this.refillThreshold = 7,
    this.snoozedUntil,
    this.notes,
  });

  // Check if needs refill
  bool get needsRefill => stockCount < (refillThreshold ?? 7);

  // Check if snoozed
  bool get isSnoozed =>
      snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  // Get snooze remaining time
  Duration? get snoozeRemaining {
    if (snoozedUntil == null) return null;
    final remaining = snoozedUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  // Dart object → JSON map  (used when sending to API)
  Map<String, dynamic> toJson() => {
    'id':             id,
    'name':           name,
    'dosage':         dosage,
    'frequency':      frequency,
    'time':           time,
    'stockCount':     stockCount,
    'isTaken':        isTaken,
    'category':       category.name,
    'refillDate':     refillDate?.toIso8601String(),
    'refillThreshold': refillThreshold,
    'snoozedUntil':   snoozedUntil?.toIso8601String(),
    'notes':          notes,
  };

  // JSON map → Dart object  (used when receiving from API)
  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id:              json['id']?.toString(),
    name:            json['name'],
    dosage:          json['dosage'],
    frequency:       json['frequency'],
    time:            json['time'],
    stockCount:      json['stockCount'],
    isTaken:         json['isTaken'] ?? false,
    category:        MedicineCategory.values.firstWhere(
      (c) => c.name == (json['category'] ?? 'other'),
      orElse: () => MedicineCategory.other,
    ),
    refillDate:      json['refillDate'] != null
        ? DateTime.parse(json['refillDate'])
        : null,
    refillThreshold: json['refillThreshold'] ?? 7,
    snoozedUntil:    json['snoozedUntil'] != null
        ? DateTime.parse(json['snoozedUntil'])
        : null,
    notes:           json['notes'],
  );
}