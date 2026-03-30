import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        decoration: medicine.isTaken
                            ? TextDecoration.lineThrough
                            : null,
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
                Text(
                  '${medicine.dosage} • ${medicine.frequency}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      medicine.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.inventory_2_outlined,
                        size: 13, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${medicine.stockCount} left',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onTaken,
            child: Container(
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
                color: medicine.isTaken ? AppColors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}