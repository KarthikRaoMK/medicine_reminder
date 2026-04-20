class MedicineHistory {
  final String   medicineName;
  final String   dosage;
  final String   frequency;
  final String   time;
  final String   status;      // 'taken' or 'missed'
  final DateTime takenAt;

  MedicineHistory({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.status,
    required this.takenAt,
  });

  // Formatted date shown in the history card e.g. "20 Apr 2026"
  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${takenAt.day} ${months[takenAt.month - 1]} ${takenAt.year}';
  }
}
