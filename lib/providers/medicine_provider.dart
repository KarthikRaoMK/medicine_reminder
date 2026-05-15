import 'dart:async';
import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/history.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineProvider extends ChangeNotifier {

  List<Medicine> _medicines = [];
  final List<MedicineHistory> _history = [];
  StreamSubscription<QuerySnapshot>? _medicinesSubscription;

  MedicineProvider() {
    _initMedicinesStream();
  }

  void _initMedicinesStream() {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    _medicinesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .snapshots()
        .listen((snapshot) {
      
      _medicines = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Medicine.fromJson(data);
      }).toList();

      for (var medicine in _medicines) {
        _scheduleMedicineNotification(medicine);
      }
      
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _medicinesSubscription?.cancel();
    super.dispose();
  }

  // Search and filter — now public getters so widgets can read them
  String _searchQuery = '';
  MedicineCategory? _selectedCategory;
  String? _selectedFrequency;

  // ── Public getters ─────────────────────────────────────
  List<Medicine> get medicines         => _medicines;
  List<MedicineHistory> get history    => List.unmodifiable(_history);
  String get searchQuery               => _searchQuery;
  MedicineCategory? get selectedCategory   => _selectedCategory;
  String? get selectedFrequency        => _selectedFrequency;

  List<Medicine> get takenMedicines    =>
      _medicines.where((m) => m.isTaken).toList();

  List<Medicine> get pendingMedicines  =>
      _medicines.where((m) => !m.isTaken).toList();

  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.needsRefill).toList();

  List<Medicine> get filteredMedicines {
    return _medicines.where((medicine) {
      final matchesSearch = _searchQuery.isEmpty ||
          medicine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          medicine.dosage.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || medicine.category == _selectedCategory;

      final matchesFrequency = _selectedFrequency == null ||
          medicine.frequency.toLowerCase() ==
              _selectedFrequency!.toLowerCase();

      return matchesSearch && matchesCategory && matchesFrequency;
    }).toList();
  }

  List<String> get frequencies =>
      _medicines.map((m) => m.frequency).toSet().toList();

  // ── Actions ────────────────────────────────────────────

  void searchMedicines(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByCategory(MedicineCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void filterByFrequency(String? frequency) {
    _selectedFrequency = frequency;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedFrequency = null;
    notifyListeners();
  }

  void toggleTaken(String id) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.isTaken = !medicine.isTaken;

    final userId = AuthService().currentUserId;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(id)
          .update({'isTaken': medicine.isTaken});
    }

    _history.add(MedicineHistory(
      medicineName: medicine.name,
      dosage:       medicine.dosage,
      frequency:    medicine.frequency,
      time:         medicine.time,
      status:       medicine.isTaken ? 'taken' : 'missed',
      takenAt:      DateTime.now(),
      category:     medicine.category.label,
    ));

    if (medicine.isTaken) {
      NotificationService().showNotification(
        id: id.hashCode,
        title: 'Medicine Taken',
        body: '${medicine.name} (${medicine.dosage}) marked as taken',
      );
    }

    notifyListeners();
  }

  void snoozeMedicine(String id, Duration duration) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    medicine.snoozedUntil = DateTime.now().add(duration);

    final userId = AuthService().currentUserId;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(id)
          .update({'snoozedUntil': medicine.snoozedUntil?.toIso8601String()});
    }

    _history.add(MedicineHistory(
      medicineName: medicine.name,
      dosage:       medicine.dosage,
      frequency:    medicine.frequency,
      time:         medicine.time,
      status:       'snoozed',
      takenAt:      DateTime.now(),
      category:     medicine.category.label,
      notes:        'Snoozed for ${duration.inMinutes} minutes',
    ));

    NotificationService().showNotification(
      id: id.hashCode,
      title: 'Reminder Snoozed',
      body: '${medicine.name} snoozed for ${duration.inMinutes} minutes',
    );

    notifyListeners();
  }

  void rescheduleMedicine(String id, String newTime) {
    final medicine = _medicines.firstWhere((m) => m.id == id);
    final oldTime  = medicine.time;
    medicine.time  = newTime;
    medicine.snoozedUntil = null;

    final userId = AuthService().currentUserId;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(id)
          .update({
            'time': newTime,
            'snoozedUntil': null
          });
    }

    _history.add(MedicineHistory(
      medicineName: medicine.name,
      dosage:       medicine.dosage,
      frequency:    medicine.frequency,
      time:         newTime,
      status:       'rescheduled',
      takenAt:      DateTime.now(),
      category:     medicine.category.label,
      notes:        'Rescheduled from $oldTime to $newTime',
    ));

    final notifId = (medicine.id?.hashCode ?? medicine.hashCode).abs() % 2147483647;
    NotificationService().cancelNotification(notifId);
    _scheduleMedicineNotification(medicine);

    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;
  
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .add({
        'name': medicine.name,
        'dosage': medicine.dosage,
        'frequency': medicine.frequency,
        'time': medicine.time,
        'stockCount': medicine.stockCount,
        'category': medicine.category.name,
        'refillThreshold': medicine.refillThreshold,
        'createdAt': Timestamp.now(),
      });

      print("Medicine saved to Firebase ");
    } catch (e) {
      print("Error saving to Firebase : $e");
    }
  }

  void deleteMedicine(String id) {
    try {
      final medicine = _medicines.firstWhere((m) => m.id == id);
      final notifId = (medicine.id?.hashCode ?? medicine.hashCode).abs() % 2147483647;
      NotificationService().cancelNotification(notifId);
      
      final userId = AuthService().currentUserId;
      if (userId != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicines')
            .doc(id)
            .delete();
      }
    } catch (e) {
      // Medicine not found
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void _scheduleMedicineNotification(Medicine medicine) {
    final notifId = (medicine.id?.hashCode ?? medicine.hashCode).abs() % 2147483647;
    
    DateTime scheduledTime;
    try {
      final parts = medicine.time.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';
      
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
      
      final now = DateTime.now();
      scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    } catch (e) {
      // Fallback
      scheduledTime = DateTime.now().add(const Duration(minutes: 1));
    }

    NotificationService().scheduleNotification(
      id: notifId,
      title: 'Time for ${medicine.name}',
      body: 'Dosage: ${medicine.dosage} - ${medicine.frequency}',
      scheduledTime: scheduledTime,
    );
  }
}