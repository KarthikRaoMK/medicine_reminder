import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';

class SearchAndFilterBar extends StatefulWidget {
  final VoidCallback onClose;

  const SearchAndFilterBar({
    super.key,
    required this.onClose,
  });

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search medicines...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  medicineProvider.searchMedicines('');
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        medicineProvider.searchMedicines(value);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withAlpha(25),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category filter
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          selected: medicineProvider._selectedCategory == null,
                          onSelected: (_) {
                            medicineProvider.filterByCategory(null);
                            setState(() {});
                          },
                        ),
                        ...MedicineCategory.values.map((category) {
                          return _buildFilterChip(
                            label: category.label,
                            selected:
                                medicineProvider._selectedCategory == category,
                            onSelected: (_) {
                              medicineProvider.filterByCategory(category);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Frequency filter
                    const Text(
                      'Frequency',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          selected: medicineProvider._selectedFrequency == null,
                          onSelected: (_) {
                            medicineProvider.filterByFrequency(null);
                            setState(() {});
                          },
                        ),
                        ...medicineProvider.frequencies.map((frequency) {
                          return _buildFilterChip(
                            label: frequency,
                            selected:
                                medicineProvider._selectedFrequency == frequency,
                            onSelected: (_) {
                              medicineProvider.filterByFrequency(frequency);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Clear filters button
                    if (medicineProvider._searchQuery.isNotEmpty ||
                        medicineProvider._selectedCategory != null ||
                        medicineProvider._selectedFrequency != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            medicineProvider.clearFilters();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300],
                          ),
                          child: const Text('Clear Filters'),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary.withAlpha(100),
    );
  }
}
