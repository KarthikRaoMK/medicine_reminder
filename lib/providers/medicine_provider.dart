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
      category: MedicineCategory.painkiller,
      refillThreshold: 10,
    ),
    Medicine(
      id: 2,
      name: 'Vitamin D3',
      dosage: '1000 IU',
      frequency: 'Once a day',
      time: '09:00 AM',
      stockCount: 30,
      category: MedicineCategory.vitamin,
      refillThreshold: 20,
    ),
    Medicine(
      id: 3,
      name: 'Metformin',
      dosage: '850mg',
      frequency: 'Three times a day',
      time: '01:00 PM',
      stockCount: 5,
      category: MedicineCategory.diabetes,
      refillThreshold: 15,
    ),
    Medicine(
      id: 4,
      name: 'Omega 3',
      dosage: '1000mg',
      frequency: 'Once a day',
      time: '08:00 PM',
      stockCount: 20,
      category: MedicineCategory.supplement,
      refillThreshold: 10,
    ),
  ];

  // History list
  final List<MedicineHistory> _history = [];

  // Search and filter
  String _searchQuery = '';
  MedicineCategory? _selectedCategory;
  String? _selectedFrequency;

  // ── Getters ────────────────────────────────────────────
  List<Medicine> get medicines        => _medicines;
  List<MedicineHistory> get history   => List.unmodifiable(_history);

  List<Medicine> get takenMedicines   =>
      _medicines.where((m) => m.isTaken).toList();

  List<Medicine> get pendingMedicines =>
      _medicines.where((m) => !m.isTaken).toList();

  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.needsRefill).toList();

  // Get filtered medicines
  List<Medicine> get filteredMedicines {
    var filtered = _medicines.where((medicine) {
      bool matchesSearch = _searchQuery.isEmpty ||
          medicine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          medicine.dosage.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = _selectedCategory == null ||
          medicine.category == _selectedCategory;
      
      bool matchesFrequency = _selectedFrequency == null ||
          medicine.frequency.toLowerCase() ==
              _selectedFrequency!.toLowerCase();
      
      return matchesSearch && matchesCategory && matchesFrequency;
    }).toList();
    
    return filtered;
  }

  // Get all unique frequencies for filter options
  List<String> get frequencies {
    return _medicines
        .map((m) => m.frequency)
        .toSet()
        .toList();
  }

  // ── Actions ────────────────────────────────────────────

  // Search
  void searchMedicines(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(MedicineCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filter by frequency
  void filterByFrequency(String? frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedFrequency = null;
    notifyListeners();
  }

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
        category:     medicine.category.label,
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

  // Snooze medicine
  void snoozeMedicine(int id, Duration duration) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.snoozedUntil = DateTime.now().add(duration);

    // Record in history
    _history.add(
      MedicineHistory(
        medicineName: medicine.name,
        dosage:       medicine.dosage,
        frequency:    medicine.frequency,
        time:         medicine.time,
        status:       'snoozed',
        takenAt:      DateTime.now(),
        category:     medicine.category.label,
        notes:        'Snoozed for ${duration.inMinutes} minutes',
      ),
    );

    NotificationService().showNotification(
      id: id,
      title: '⏰ Reminder Snoozed',
      body: '${medicine.name} reminder snoozed for ${duration.inMinutes} minutes',
    );

    notifyListeners();
  }

  // Reschedule medicine
  void rescheduleMedicine(int id, String newTime) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    final oldTime = medicine.time;
    medicine.time = newTime;
    medicine.snoozedUntil = null;

    _history.add(
      MedicineHistory(
        medicineName: medicine.name,
        dosage:       medicine.dosage,
        frequency:    medicine.frequency,
        time:         newTime,
        status:       'rescheduled',
        takenAt:      DateTime.now(),
        category:     medicine.category.label,
        notes:        'Rescheduled from $oldTime to $newTime',
      ),
    );

    NotificationService().showNotification(
      id: id,
      title: '🔔 Medicine Rescheduled',
      body: '${medicine.name} rescheduled to $newTime',
    );

    notifyListeners();
  }

  // Add new medicine
  void addMedicine(Medicine medicine) {
    _medicines.add(medicine);
    
    int notificationId = medicine.id ?? _medicines.length;
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

  // Update medicine stock
  void updateMedicineStock(int id, int newCount) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.stockCount;  // This will fail - need to handle this differently
    // Since stockCount is final, we'd need to create a new instance
    notifyListeners();
  }

  // Clear all history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}