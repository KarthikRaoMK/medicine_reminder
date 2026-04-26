import 'package:flutter/material.dart';
import '../models/statistics.dart';
import '../models/history.dart';
import '../models/medicine.dart';

class StatisticsProvider extends ChangeNotifier {
  final List<MedicineHistory> _history;
  final List<Medicine> _medicines;

  StatisticsProvider({
    required List<MedicineHistory> history,
    required List<Medicine> medicines,
  })  : _history = history,
        _medicines = medicines;

  // Calculate overall statistics
  OverallStatistics getOverallStatistics() {
    if (_history.isEmpty) {
      return OverallStatistics(
        totalMedicines: _medicines.length,
        totalDoses: 0,
        takenDoses: 0,
        missedDoses: 0,
        snoozedDoses: 0,
        overallAdherence: 0,
        medicineStats: [],
        consecutiveDaysCompliant: 0,
      );
    }

    int takenCount = _history.where((h) => h.status == 'taken').length;
    int missedCount = _history.where((h) => h.status == 'missed').length;
    int snoozedCount = _history.where((h) => h.status == 'snoozed').length;
    int totalCount = _history.length;

    double adherence = totalCount > 0
        ? (takenCount / (totalCount - snoozedCount)) * 100
        : 0;
    adherence = adherence.clamp(0, 100);

    // Get medicine-specific statistics
    Map<String, List<MedicineHistory>> historyByMedicine = {};
    for (var record in _history) {
      historyByMedicine
          .putIfAbsent(record.medicineName, () => [])
          .add(record);
    }

    List<MedicineStatistics> medicineStats = [];
    historyByMedicine.forEach((medicineName, records) {
      int taken = records.where((r) => r.status == 'taken').length;
      int missed = records.where((r) => r.status == 'missed').length;
      int snoozed = records.where((r) => r.status == 'snoozed').length;
      int total = records.length;

      double rate = total > 0 ? (taken / (total - snoozed)) * 100 : 0;
      rate = rate.clamp(0, 100);

      medicineStats.add(MedicineStatistics(
        medicineName: medicineName,
        totalDoses: total,
        takenDoses: taken,
        missedDoses: missed,
        snoozedDoses: snoozed,
        adherenceRate: rate,
      ));
    });

    return OverallStatistics(
      totalMedicines: _medicines.length,
      totalDoses: totalCount,
      takenDoses: takenCount,
      missedDoses: missedCount,
      snoozedDoses: snoozedCount,
      overallAdherence: adherence,
      medicineStats: medicineStats,
      consecutiveDaysCompliant: _calculateConsecutiveDays(),
    );
  }

  // Calculate consecutive days of compliance
  int _calculateConsecutiveDays() {
    if (_history.isEmpty) return 0;

    // Group history by date
    Map<String, List<MedicineHistory>> historyByDate = {};
    for (var record in _history) {
      String dateKey =
          '${record.takenAt.year}-${record.takenAt.month}-${record.takenAt.day}';
      historyByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // Sort dates
    List<DateTime> dates = historyByDate.keys
        .map((key) {
          List<String> parts = key.split('-');
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        })
        .toList();
    dates.sort();

    // Count consecutive compliant days
    int consecutive = 0;
    for (int i = dates.length - 1; i >= 0; i--) {
      String dateKey =
          '${dates[i].year}-${dates[i].month}-${dates[i].day}';
      List<MedicineHistory> dayRecords = historyByDate[dateKey] ?? [];

      if (dayRecords.isEmpty) break;

      int taken = dayRecords.where((r) => r.status == 'taken').length;
      int total = dayRecords
          .where((r) => r.status == 'taken' || r.status == 'missed')
          .length;

      if (total > 0 && taken == total) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  // Get daily adherence for last N days
  List<DailyAdherence> getDailyAdherence({int days = 30}) {
    List<DailyAdherence> dailyStats = [];

    // Group history by date
    Map<String, List<MedicineHistory>> historyByDate = {};
    for (var record in _history) {
      String dateKey =
          '${record.takenAt.year}-${record.takenAt.month}-${record.takenAt.day}';
      historyByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // Generate daily stats for the last N days
    DateTime now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dateKey = '${date.year}-${date.month}-${date.day}';

      List<MedicineHistory> dayRecords = historyByDate[dateKey] ?? [];

      int takenCount = dayRecords.where((r) => r.status == 'taken').length;
      int totalCount = dayRecords
          .where((r) => r.status == 'taken' || r.status == 'missed')
          .length;

      double adherence = totalCount > 0 ? (takenCount / totalCount) * 100 : 0;

      dailyStats.add(DailyAdherence(
        date: date,
        takenCount: takenCount,
        totalCount: totalCount,
        adherenceRate: adherence,
      ));
    }

    return dailyStats;
  }

  // Get adherence by category
  Map<String, double> getAdherenceByCategory() {
    Map<String, List<MedicineHistory>> historyByCategory = {};

    for (var record in _history) {
      historyByCategory
          .putIfAbsent(record.category ?? 'Other', () => [])
          .add(record);
    }

    Map<String, double> categoryAdherence = {};
    historyByCategory.forEach((category, records) {
      int taken = records.where((r) => r.status == 'taken').length;
      int total =
          records.where((r) => r.status == 'taken' || r.status == 'missed').length;

      double rate = total > 0 ? (taken / total) * 100 : 0;
      categoryAdherence[category] = rate.clamp(0, 100);
    });

    return categoryAdherence;
  }

  // Get most taken medicines
  List<MedicineStatistics> getMostTakenMedicines({int limit = 5}) {
    final stats = getOverallStatistics();
    final sorted = [...stats.medicineStats];
    sorted.sort((a, b) => b.takenDoses.compareTo(a.takenDoses));
    return sorted.take(limit).toList();
  }

  // Get least compliant medicines
  List<MedicineStatistics> getLeastCompliantMedicines({int limit = 5}) {
    final stats = getOverallStatistics();
    final sorted = [...stats.medicineStats];
    sorted.sort((a, b) => a.adherenceRate.compareTo(b.adherenceRate));
    return sorted.take(limit).toList();
  }
}
