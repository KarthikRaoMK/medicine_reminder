class MedicineStatistics {
  final String medicineName;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int snoozedDoses;
  final double adherenceRate; // percentage 0-100

  MedicineStatistics({
    required this.medicineName,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.snoozedDoses,
    required this.adherenceRate,
  });

  // Get adherence status
  String get status {
    if (adherenceRate >= 90) return 'Excellent';
    if (adherenceRate >= 75) return 'Good';
    if (adherenceRate >= 60) return 'Fair';
    return 'Poor';
  }
}

class OverallStatistics {
  final int totalMedicines;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int snoozedDoses;
  final double overallAdherence; // percentage 0-100
  final List<MedicineStatistics> medicineStats;
  final int consecutiveDaysCompliant;

  OverallStatistics({
    required this.totalMedicines,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.snoozedDoses,
    required this.overallAdherence,
    required this.medicineStats,
    required this.consecutiveDaysCompliant,
  });

  // Get week statistics
  Map<String, int> getWeeklyData() {
    return {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
  }
}

class DailyAdherence {
  final DateTime date;
  final int takenCount;
  final int totalCount;
  final double adherenceRate;

  DailyAdherence({
    required this.date,
    required this.takenCount,
    required this.totalCount,
    required this.adherenceRate,
  });

  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
