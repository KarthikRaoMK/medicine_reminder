import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/history.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {

  // Dummy data — will be replaced with API calls later
  final List<Medicine> _medicines = [
    Medicine(
      id: 1,
      name: 'Paracetamol',
      dosage: '500mg',
      frequency: 'Twice a day',
      time: '08:00 AM',
      stockCount: 14,
    ),
    Medicine(
      id: 2,
      name: 'Vitamin D3',
      dosage: '1000 IU',
      frequency: 'Once a day',
      time: '09:00 AM',
      stockCount: 30,
    ),
    Medicine(
      id: 3,
      name: 'Metformin',
      dosage: '850mg',
      frequency: 'Three times a day',
      time: '01:00 PM',
      stockCount: 5,
    ),
    Medicine(
      id: 4,
      name: 'Omega 3',
      dosage: '1000mg',
      frequency: 'Once a day',
      time: '08:00 PM',
      stockCount: 20,
    ),
  ];

  // History list
  final List<MedicineHistory> _history = [];

  // ── Getters ────────────────────────────────────────────
  List<Medicine> get medicines        => _medicines;
  List<MedicineHistory> get history   => List.unmodifiable(_history);

  List<Medicine> get takenMedicines   =>
      _medicines.where((m) => m.isTaken).toList();

  List<Medicine> get pendingMedicines =>
      _medicines.where((m) => !m.isTaken).toList();

  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.stockCount < 7).toList();

  // ── Actions ────────────────────────────────────────────

  // Toggle taken / not taken — also records a history entry
  void toggleTaken(int id) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.isTaken = !medicine.isTaken;

    // Record history entry whenever a medicine is marked taken or missed
    _history.add(
      MedicineHistory(
        
        medicineName: medicine.name,
        dosage:       medicine.dosage,
        frequency:    medicine.frequency,
        time:         medicine.time,
        status:       medicine.isTaken ? 'taken' : 'missed',
        takenAt:      DateTime.now(),
      ),
    );

    // Send notification
    if (medicine.isTaken) {
      NotificationService().showNotification(
        id: id,
        title: '✓ Medicine Taken',
        body: '${medicine.name} (${medicine.dosage}) marked as taken',
      );
    } else {
      NotificationService().showNotification(
        id: id,
        title: '⚠ Medicine Missed',
        body: '${medicine.name} (${medicine.dosage}) marked as missed',
      );
    }

    notifyListeners();
  }

  // Add new medicine
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    
    // Send notification with a valid ID (32-bit integer)
    int notificationId = medicine.id ?? _medicines.length;
    // Ensure ID fits in 32-bit range
    notificationId = (notificationId % 2147483647).abs();
    
    NotificationService().showNotification(
      id: notificationId,
      title: '+ New Medicine Added',
      body: '${medicine.name} (${medicine.dosage}) - ${medicine.frequency}',
    );
    
    notifyListeners();
  }

  // Delete medicine by id
  void deleteMedicine(int id) {
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // Clear all history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}