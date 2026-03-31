import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';

class MedicineCard extends StatelessWidget {
  final Medicine    medicine;
  final VoidCallback onTaken;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: medicine.isTaken
              ? Colors.green.shade200
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          // ── Medicine icon ──────────────────────────────
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: medicine.isTaken
                  ? Colors.green.shade50
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: medicine.isTaken ? Colors.green : AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // ── Name, dosage, time, stock ──────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Name + Low Stock badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        medicine.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          decoration: medicine.isTaken
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (medicine.stockCount < 7) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Low Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // Dosage & frequency
                Text(
                  '${medicine.dosage} • ${medicine.frequency}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 4),

                // Time & stock count
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      medicine.time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.inventory_2_outlined,
                        size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${medicine.stockCount} left',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Check button ───────────────────────────────
          GestureDetector(
            onTap: onTaken,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: medicine.isTaken
                    ? Colors.green
                    : AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: medicine.isTaken
                    ? AppColors.white
                    : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}