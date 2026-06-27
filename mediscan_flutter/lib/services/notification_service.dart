// Feature: MEDICINE REMINDERS — Push notifications for medicine timing
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap on notification
      },
    );

    // Request permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ── Schedule daily medicine reminder ─────────────────────────────────────
  Future<List<int>> scheduleMedicineReminder({
    required String medicineName,
    required String dosage,
    required List<String> times, // ["08:00", "14:00", "21:00"]
  }) async {
    await initialize();
    final ids = <int>[];

    for (final timeStr in times) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      final id = Random().nextInt(999999);

      final androidDetails = AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Daily medicine timing reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF0052CC),
        playSound: true,
        enableVibration: true,
      );

      await _plugin.periodicallyShowWithDuration(
        id,
        '💊 Medicine Reminder',
        '$medicineName — $dosage at $timeStr',
        const Duration(hours: 24),
        NotificationDetails(android: androidDetails),
      );

      ids.add(id);
    }

    return ids;
  }

  // ── Cancel specific reminder ──────────────────────────────────────────────
  Future<void> cancelReminder(List<int> notifIds) async {
    for (final id in notifIds) {
      await _plugin.cancel(id);
    }
  }

  // ── Show immediate test notification ────────────────────────────────────
  Future<void> showTestNotification(String medicineName) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily medicine timing reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF0052CC),
    );
    await _plugin.show(
      0,
      '💊 MediScan AI Reminder',
      'Time to take: $medicineName',
      const NotificationDetails(android: androidDetails),
    );
  }

  // ── Show emergency alert notification ───────────────────────────────────
  Future<void> showEmergencyAlert() async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'emergency',
      'Emergency Alerts',
      channelDescription: 'SOS emergency alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFEF4444),
    );
    await _plugin.show(
      999,
      '🚨 SOS Alert Sent',
      'Emergency contacts and location shared. Help is on the way.',
      const NotificationDetails(android: androidDetails),
    );
  }
}
