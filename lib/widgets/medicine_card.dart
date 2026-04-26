import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../providers/medicine_provider.dart';
import 'snooze_reschedule_dialog.dart';

class MedicineCard extends StatelessWidget {
  final Medicine     medicine;
  final VoidCallback onTaken;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTaken,
  });

  @override
  Widget build(BuildContext context) {
    final isSnoozed = medicine.isSnoozed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSnoozed
              ? Colors.orange.shade200
              : medicine.isTaken
                  ? Colors.green.shade200
                  : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ✅ Fixed: withValues instead of withOpacity
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Medicine icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSnoozed
                      ? Colors.orange.shade50
                      : medicine.isTaken
                          ? Colors.green.shade50
                          : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: isSnoozed
                      ? Colors.orange
                      : medicine.isTaken
                          ? Colors.green
                          : AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Name, dosage, time, stock
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Badges row
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
                        if (medicine.needsRefill) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Refill',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (isSnoozed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Snoozed',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade600,
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
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey),
                    ),

                    const SizedBox(height: 4),

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
                              fontSize: 13, color: AppColors.textGrey),
                        ),
                      ],
                    ),

                    if (isSnoozed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Snoozed for ${_formatSnoozeRemaining(medicine.snoozedUntil!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  medicine.category.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons (only when not taken)
          if (!medicine.isTaken) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 32,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => SnoozeOptionsDialog(
                          onSnooze: (duration) {
                            context
                                .read<MedicineProvider>()
                                .snoozeMedicine(medicine.id!, duration);
                            return () {};
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Snooze'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => RescheduleDialog(
                          currentTime: medicine.time,
                          onReschedule: (newTime) {
                            context
                                .read<MedicineProvider>()
                                .rescheduleMedicine(medicine.id!, newTime);
                            return () {};
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('Reschedule'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onTaken,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.check),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onTaken,
                    child: const Text('Mark as not taken'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatSnoozeRemaining(DateTime until) {
    final diff = until.difference(DateTime.now());
    if (diff.inMinutes < 1)  return 'soon';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }
}