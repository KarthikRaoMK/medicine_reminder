class MedicineHistory {
  final String   medicineName;
  final String   dosage;
  final String   frequency;
  final String   time;
  final String   status;      // 'taken', 'missed', 'snoozed'
  final DateTime takenAt;
  final String?  category;
  final String?  notes;

  MedicineHistory({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.status,
    required this.takenAt,
    this.category,
    this.notes,
  });

  // Formatted date shown in the history card e.g. "20 Apr 2026"
  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${takenAt.day} ${months[takenAt.month - 1]} ${takenAt.year}';
  }

  String get formattedTime {
    return '${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}';
  }

  // Convert to JSON for export
  Map<String, dynamic> toJson() => {
    'medicineName': medicineName,
    'dosage': dosage,
    'frequency': frequency,
    'time': time,
    'status': status,
    'takenAt': takenAt.toIso8601String(),
    'category': category,
    'notes': notes,
  };
}