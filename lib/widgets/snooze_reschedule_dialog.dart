import 'package:flutter/material.dart';

// ── Snooze Options Dialog ─────────────────────────────────
class SnoozeOptionsDialog extends StatelessWidget {
  // ✅ Fixed: Function(Duration) instead of VoidCallback Function(Duration)
  final Function(Duration) onSnooze;

  const SnoozeOptionsDialog({
    super.key,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ('5 minutes',  const Duration(minutes: 5)),
      ('15 minutes', const Duration(minutes: 15)),
      ('30 minutes', const Duration(minutes: 30)),
      ('1 hour',     const Duration(hours: 1)),
      ('2 hours',    const Duration(hours: 2)),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Snooze Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...options.map((option) {
            return ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: Text(option.$1),
              onTap: () {
                onSnooze(option.$2);
                Navigator.pop(context);
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text('Custom'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => CustomSnoozeDialog(onSnooze: onSnooze),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Custom Snooze Dialog ──────────────────────────────────
class CustomSnoozeDialog extends StatefulWidget {
  final Function(Duration) onSnooze;

  const CustomSnoozeDialog({super.key, required this.onSnooze});

  @override
  State<CustomSnoozeDialog> createState() => _CustomSnoozeDialogState();
}

class _CustomSnoozeDialogState extends State<CustomSnoozeDialog> {
  int _hours   = 0;
  int _minutes = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Custom Snooze Time'),
      content: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Hours'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    hintText: '0',
                  ),
                  onChanged: (v) =>
                      setState(() => _hours = int.tryParse(v) ?? 0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Minutes'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    hintText: '0',
                  ),
                  onChanged: (v) =>
                      setState(() => _minutes = int.tryParse(v) ?? 0),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = Duration(hours: _hours, minutes: _minutes);
            if (duration.inSeconds > 0) {
              widget.onSnooze(duration);
              Navigator.pop(context);
            }
          },
          child: const Text('Snooze'),
        ),
      ],
    );
  }
}

// ── Reschedule Dialog ─────────────────────────────────────
class RescheduleDialog extends StatefulWidget {
  final String currentTime;
  // ✅ Fixed: Function(String) instead of VoidCallback Function(String)
  final Function(String) onReschedule;

  const RescheduleDialog({
    super.key,
    required this.currentTime,
    required this.onReschedule,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // ✅ Fixed: safe time parsing that handles "08:00 AM" format too
    _selectedTime = _parseTime(widget.currentTime);
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      // Handle "HH:MM AM/PM" format
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        final parts  = timeStr.split(':');
        int hour     = int.parse(parts[0].trim());
        final rest   = parts[1].split(' ');
        final minute = int.parse(rest[0]);
        final isPM   = rest.length > 1 && rest[1] == 'PM';
        if (isPM && hour != 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
      // Handle "HH:MM" 24h format
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour:   int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Reschedule Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select new time:'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayTime,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onReschedule(displayTime);
            Navigator.pop(context);
          },
          child: const Text('Reschedule'),
        ),
      ],
    );
  }
}