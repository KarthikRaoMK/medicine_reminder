import 'package:flutter/material.dart';
import '../models/medicine.dart';

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
      stockCount: 5,   // low stock — will trigger warning
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

  // ── Getters ────────────────────────────────────────────
  List<Medicine> get medicines       => _medicines;

  List<Medicine> get takenMedicines  =>
      _medicines.where((m) => m.isTaken).toList();

  List<Medicine> get pendingMedicines =>
      _medicines.where((m) => !m.isTaken).toList();

  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.stockCount < 7).toList();

  // ── Actions ────────────────────────────────────────────

  // Toggle taken / not taken
  void toggleTaken(int id) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.isTaken = !medicine.isTaken;
    notifyListeners(); // rebuild all listening widgets
  }

  // Add new medicine
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    notifyListeners();
  }

  // Delete medicine by id
  void deleteMedicine(int id) {
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}