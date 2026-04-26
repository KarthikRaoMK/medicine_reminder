import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/history.dart';
import '../models/statistics.dart';

class ExportService {
  // Export history as CSV
  static Future<void> exportHistoryAsCSV(List<MedicineHistory> history) async {
    if (history.isEmpty) {
      throw Exception('No history to export');
    }

    // Prepare data
    List<List<dynamic>> rows = [
      [
        'Medicine Name',
        'Dosage',
        'Frequency',
        'Time',
        'Status',
        'Category',
        'Date',
        'Time Taken',
        'Notes'
      ],
    ];

    for (var record in history) {
      rows.add([
        record.medicineName,
        record.dosage,
        record.frequency,
        record.time,
        record.status,
        record.category ?? 'N/A',
        record.formattedDate,
        record.formattedTime,
        record.notes ?? '',
      ]);
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'medicine_history_$timestamp.csv';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(csv);

    // Share file
    await Share.shareXFiles([XFile(file.path)],
        text: 'Medicine History Report');
  }

  // Export statistics as CSV
  static Future<void> exportStatisticsAsCSV(
      OverallStatistics stats) async {
    List<List<dynamic>> rows = [
      ['Medication Adherence Report'],
      ['Generated on', DateTime.now().toString()],
      [''],
      ['Overall Statistics'],
      ['Total Medicines', stats.totalMedicines],
      ['Total Doses', stats.totalDoses],
      ['Taken', stats.takenDoses],
      ['Missed', stats.missedDoses],
      ['Snoozed', stats.snoozedDoses],
      ['Overall Adherence Rate (%)', stats.overallAdherence.toStringAsFixed(2)],
      ['Consecutive Compliant Days', stats.consecutiveDaysCompliant],
      [''],
      ['Medicine-wise Statistics'],
      [
        'Medicine Name',
        'Total Doses',
        'Taken',
        'Missed',
        'Snoozed',
        'Adherence Rate (%)'
      ],
    ];

    for (var med in stats.medicineStats) {
      rows.add([
        med.medicineName,
        med.totalDoses,
        med.takenDoses,
        med.missedDoses,
        med.snoozedDoses,
        med.adherenceRate.toStringAsFixed(2),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'medication_statistics_$timestamp.csv';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Medication Adherence Statistics');
  }

  // Export as JSON for backup
  static Future<void> exportHistoryAsJSON(
      List<MedicineHistory> history) async {
    if (history.isEmpty) {
      throw Exception('No history to export');
    }

    List<Map<String, dynamic>> jsonData =
        history.map((h) => h.toJson()).toList();

    String json = jsonData.toString();

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'medicine_history_$timestamp.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(json);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Medicine History Backup');
  }
}
