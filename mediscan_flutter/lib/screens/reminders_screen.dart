// Feature: MEDICINE REMINDERS — manage and schedule medicine notifications
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final LocalDbService _db = LocalDbService();
  final NotificationService _notifService = NotificationService();
  List<MedicineReminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    _reminders = await _db.getAllReminders();
    setState(() => _loading = false);
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(
        onSave: (reminder) async {
          // Schedule notifications
          final ids = await _notifService.scheduleMedicineReminder(
            medicineName: reminder.medicineName,
            dosage: reminder.dosage,
            times: reminder.times,
          );
          final withIds = reminder.copyWith(notifIds: ids);
          await _db.saveReminder(withIds);
          await _loadReminders();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '✅ Reminder set for ${reminder.medicineName}'),
            backgroundColor: AppTheme.green,
          ));
        },
      ),
    );
  }

  Future<void> _deleteReminder(MedicineReminder reminder) async {
    await _notifService.cancelReminder(reminder.notifIds);
    await _db.deleteReminder(reminder.id);
    await _loadReminders();
  }

  Future<void> _toggleReminder(MedicineReminder reminder) async {
    if (reminder.enabled) {
      await _notifService.cancelReminder(reminder.notifIds);
      await _db.toggleReminder(reminder.id, false);
    } else {
      final ids = await _notifService.scheduleMedicineReminder(
        medicineName: reminder.medicineName,
        dosage: reminder.dosage,
        times: reminder.times,
      );
      await _db.saveReminder(reminder.copyWith(enabled: true, notifIds: ids));
    }
    await _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          IconButton(
            onPressed: () async {
              await _notifService.showTestNotification('Test Medicine');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Test notification sent!'),
                ));
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Test notification',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderSheet,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Reminder',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _EmptyState(onAdd: _showAddReminderSheet)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _reminders.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReminderCard(
                      reminder: _reminders[i],
                      onDelete: () => _deleteReminder(_reminders[i]),
                      onToggle: () => _toggleReminder(_reminders[i]),
                    ),
                  ),
                ),
    );
  }
}

// ── Reminder Card ──────────────────────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ReminderCard({
    required this.reminder,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.enabled
              ? AppTheme.primaryBlue.withValues(alpha: 0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: reminder.enabled
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: reminder.enabled
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: reminder.enabled
                            ? null
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      reminder.dosage,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.enabled,
                onChanged: (_) => onToggle(),
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time chips
          Wrap(
            spacing: 8,
            children: reminder.times.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: reminder.enabled
                      ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: reminder.enabled
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: reminder.enabled
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.red,
                    padding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Reminder Bottom Sheet ──────────────────────────────────────────────────
class _AddReminderSheet extends StatefulWidget {
  final void Function(MedicineReminder) onSave;
  const _AddReminderSheet({required this.onSave});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final List<String> _times = ['08:00'];
  final _uuid = const Uuid();

  Future<void> _pickTime(int index) async {
    final parts = _times[index].split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        _times[index] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }
    final reminder = MedicineReminder(
      id: _uuid.v4(),
      medicineName: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim().isEmpty
          ? '1 tablet'
          : _dosageCtrl.text.trim(),
      times: List.from(_times),
    );
    Navigator.pop(context);
    widget.onSave(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add Medicine Reminder',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Medicine Name',
              hintText: 'e.g. Vitamin D3, Metformin',
              prefixIcon: Icon(Icons.medication_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosageCtrl,
            decoration: const InputDecoration(
              labelText: 'Dosage',
              hintText: 'e.g. 1 tablet, 5ml syrup',
              prefixIcon: Icon(Icons.format_list_numbered),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reminder Times',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () {
                  if (_times.length < 4) {
                    setState(() => _times.add('12:00'));
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Time'),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue),
              ),
            ],
          ),
          ..._times.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: AppTheme.primaryBlue, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_times.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() => _times.removeAt(e.key));
                      },
                      icon: Icon(Icons.remove_circle_outline,
                          color: AppTheme.red, size: 20),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Reminder',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication_outlined,
                  color: AppTheme.primaryBlue, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('No Reminders Yet',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Add your daily medicines to get timely push notifications.',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_alarm),
              label: const Text('Add First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
