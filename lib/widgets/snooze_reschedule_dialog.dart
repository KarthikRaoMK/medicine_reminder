import 'package:flutter/material.dart';

class SnoozeOptionsDialog extends StatelessWidget {
  final VoidCallback Function(Duration) onSnooze;

  const SnoozeOptionsDialog({
    super.key,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ('5 minutes', Duration(minutes: 5)),
      ('15 minutes', Duration(minutes: 15)),
      ('30 minutes', Duration(minutes: 30)),
      ('1 hour', Duration(hours: 1)),
      ('2 hours', Duration(hours: 2)),
      ('Custom', null),
    ];

    return AlertDialog(
      title: const Text('Snooze Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            title: Text(option.$1),
            onTap: () {
              if (option.$2 != null) {
                onSnooze(option.$2!);
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                _showCustomSnoozeDialog(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCustomSnoozeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomSnoozeDialog(onSnooze: onSnooze),
    );
  }
}

class CustomSnoozeDialog extends StatefulWidget {
  final VoidCallback Function(Duration) onSnooze;

  const CustomSnoozeDialog({
    super.key,
    required this.onSnooze,
  });

  @override
  State<CustomSnoozeDialog> createState() => _CustomSnoozeDialogState();
}

class _CustomSnoozeDialogState extends State<CustomSnoozeDialog> {
  int hours = 0;
  int minutes = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Snooze Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Hours'),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          hours = int.tryParse(value) ?? 0;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text('Minutes'),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          minutes = int.tryParse(value) ?? 0;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            final duration = Duration(hours: hours, minutes: minutes);
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

class RescheduleDialog extends StatefulWidget {
  final String currentTime;
  final VoidCallback Function(String) onReschedule;

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
    final parts = widget.currentTime.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reschedule Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select new time:'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
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
            final newTime =
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
            widget.onReschedule(newTime);
            Navigator.pop(context);
          },
          child: const Text('Reschedule'),
        ),
      ],
    );
  }
}
