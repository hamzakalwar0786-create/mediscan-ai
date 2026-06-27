// Feature: OFFLINE MODE — SQLite local storage with sync queue
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/medical_report.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'mediscan.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reports (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            createdAt INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            createdAt INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reminders (
            id TEXT PRIMARY KEY,
            medicineName TEXT NOT NULL,
            dosage TEXT NOT NULL,
            times TEXT NOT NULL,
            enabled INTEGER NOT NULL DEFAULT 1,
            notifIds TEXT NOT NULL DEFAULT '[]',
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Reports ───────────────────────────────────────────────────────────────
  Future<void> saveReportLocally(MedicalReport report) async {
    final db = await database;
    await db.insert(
      'reports',
      {
        'id': report.id,
        'data': jsonEncode(report.toMap()),
        'synced': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markReportSynced(String id) async {
    final db = await database;
    await db.update(
      'reports',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MedicalReport>> getUnsyncedReports() async {
    final db = await database;
    final rows =
        await db.query('reports', where: 'synced = 0', orderBy: 'createdAt DESC');
    return rows.map((row) {
      final map = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return MedicalReport.fromMap(map, row['id'] as String);
    }).toList();
  }

  Future<List<MedicalReport>> getAllLocalReports() async {
    final db = await database;
    final rows =
        await db.query('reports', orderBy: 'createdAt DESC');
    return rows.map((row) {
      final map = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return MedicalReport.fromMap(map, row['id'] as String);
    }).toList();
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Medicine Reminders ────────────────────────────────────────────────────
  Future<void> saveReminder(MedicineReminder reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      {
        'id': reminder.id,
        'medicineName': reminder.medicineName,
        'dosage': reminder.dosage,
        'times': jsonEncode(reminder.times),
        'enabled': reminder.enabled ? 1 : 0,
        'notifIds': jsonEncode(reminder.notifIds),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicineReminder>> getAllReminders() async {
    final db = await database;
    final rows = await db.query('reminders', orderBy: 'createdAt ASC');
    return rows.map((row) => MedicineReminder.fromMap(row)).toList();
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final db = await database;
    await db.update(
      'reminders',
      {'enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ─── Medicine Reminder Model ───────────────────────────────────────────────────
class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosage;
  final List<String> times; // "08:00", "14:00", "21:00"
  final bool enabled;
  final List<int> notifIds;

  const MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.times,
    this.enabled = true,
    this.notifIds = const [],
  });

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as String,
      medicineName: map['medicineName'] as String,
      dosage: map['dosage'] as String,
      times: List<String>.from(
          jsonDecode(map['times'] as String) as List),
      enabled: (map['enabled'] as int) == 1,
      notifIds: List<int>.from(
          jsonDecode(map['notifIds'] as String) as List),
    );
  }

  MedicineReminder copyWith({
    bool? enabled,
    List<int>? notifIds,
  }) {
    return MedicineReminder(
      id: id,
      medicineName: medicineName,
      dosage: dosage,
      times: times,
      enabled: enabled ?? this.enabled,
      notifIds: notifIds ?? this.notifIds,
    );
  }
}
