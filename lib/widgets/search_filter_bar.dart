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
      builder: (context, provider, _) {
        // ✅ Using PUBLIC getters instead of private fields
        final selectedCategory  = provider.selectedCategory;
        final selectedFrequency = provider.selectedFrequency;
        final searchQuery       = provider.searchQuery;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Search bar ──────────────────────────────
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
                                  provider.searchMedicines('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        provider.searchMedicines(value);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                    color: AppColors.textGrey,
                  ),
                ],
              ),
            ),

            // ── Filters ─────────────────────────────────
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
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            provider.filterByCategory(null);
                            setState(() {});
                          },
                        ),
                        ...MedicineCategory.values.map((category) {
                          return _buildFilterChip(
                            label: category.label,
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              provider.filterByCategory(category);
                              setState(() {});
                            },
                          );
                        }),
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
                          selected: selectedFrequency == null,
                          onSelected: (_) {
                            provider.filterByFrequency(null);
                            setState(() {});
                          },
                        ),
                        ...provider.frequencies.map((frequency) {
                          return _buildFilterChip(
                            label: frequency,
                            selected: selectedFrequency == frequency,
                            onSelected: (_) {
                              provider.filterByFrequency(frequency);
                              setState(() {});
                            },
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Clear filters
                    if (searchQuery.isNotEmpty ||
                        selectedCategory != null ||
                        selectedFrequency != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.clearFilters();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
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
      selectedColor: AppColors.primary.withValues(alpha: 0.4),
    );
  }
}