import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_colors.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {

  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController  = TextEditingController();

  String           _selectedFrequency = 'Once a day';
  TimeOfDay        _selectedTime      = TimeOfDay.now();
  MedicineCategory _selectedCategory  = MedicineCategory.other;
  bool             _isLoading         = false;

  final List<String> _frequencies = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'Every 6 hours',
    'Every 8 hours',
    'As needed',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour   = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final medicine = Medicine(
      id:              DateTime.now().millisecondsSinceEpoch,
      name:            _nameController.text.trim(),
      dosage:          _dosageController.text.trim(),
      frequency:       _selectedFrequency,
      time:            _formatTime(_selectedTime),
      stockCount:      int.parse(_stockController.text.trim()),
      category:        _selectedCategory,
      refillThreshold: 7,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.read<MedicineProvider>().addMedicine(medicine);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} added successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(
      String label, String hint, IconData icon) {
    return InputDecoration(
      labelText:  label,
      hintText:   hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled:     true,
      fillColor:  AppColors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Add Medicine',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              _SectionTitle(title: '💊 Medicine Info'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                    'Medicine Name', 'e.g. Paracetamol',
                    Icons.medication_rounded),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter medicine name'
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _dosageController,
                decoration: _inputDecoration(
                    'Dosage', 'e.g. 500mg', Icons.scale_rounded),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter dosage' : null,
              ),

              const SizedBox(height: 16),

              // Category dropdown
              _buildDropdownContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MedicineCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    items: MedicineCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            const Icon(Icons.category,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _SectionTitle(title: '🕐 Schedule'),
              const SizedBox(height: 12),

              // Frequency dropdown
              _buildDropdownContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFrequency,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    items: _frequencies.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Row(
                          children: [
                            const Icon(Icons.repeat,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(f),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedFrequency = v);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Time picker
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder Time',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textGrey)),
                          Text(
                            _formatTime(_selectedTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          // ✅ Fixed: withValues instead of withOpacity
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _SectionTitle(title: ' Stock'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                    'Stock Count', 'e.g. 30', Icons.inventory_2_outlined),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter stock count';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  if (int.parse(v) <= 0) return 'Stock must be greater than 0';
                  return null;
                },
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '  Low stock alert when less than 7 pills remain',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Save Medicine',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark),
    );
  }
}