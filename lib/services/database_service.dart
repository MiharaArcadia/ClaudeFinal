import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_pkg;

import 'package:clocky/models/project.dart';
import 'package:clocky/models/entry.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path_pkg.join(dbPath, 'clocky.db');

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: _onCreate,
      onForeignKeys: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        client_name TEXT,
        client_address TEXT,
        client_email TEXT,
        hourly_rate REAL DEFAULT 0,
        color TEXT DEFAULT '#FF6B35',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER REFERENCES projects(id),
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        pause_minutes INTEGER DEFAULT 0,
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // ── Projects ────────────────────────────────────────────────────────────────

  Future<List<Project>> getProjects() async {
    final db = await database;
    final maps = await db.query('projects', orderBy: 'name ASC');
    return maps.map(Project.fromMap).toList();
  }

  Future<int> insertProject(Project p) async {
    final db = await database;
    return db.insert('projects', p.toMap());
  }

  Future<void> updateProject(Project p) async {
    final db = await database;
    await db.update(
      'projects',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // ── Entries ─────────────────────────────────────────────────────────────────

  /// Returns entries for a given month (format: 'YYYY-MM'). If null, returns all.
  Future<List<Entry>> getEntries({String? month}) async {
    final db = await database;
    if (month != null) {
      final maps = await db.query(
        'entries',
        where: "date LIKE ?",
        whereArgs: ['$month%'],
        orderBy: 'date DESC, start_time DESC',
      );
      return maps.map(Entry.fromMap).toList();
    }
    final maps = await db.query('entries', orderBy: 'date DESC, start_time DESC');
    return maps.map(Entry.fromMap).toList();
  }

  Future<List<Entry>> getEntriesInRange(DateTime from, DateTime to) async {
    final db = await database;
    final fromStr = _dateStr(from);
    final toStr = _dateStr(to);
    final maps = await db.query(
      'entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [fromStr, toStr],
      orderBy: 'date ASC, start_time ASC',
    );
    return maps.map(Entry.fromMap).toList();
  }

  Future<int> insertEntry(Entry e) async {
    final db = await database;
    return db.insert('entries', e.toMap());
  }

  Future<void> updateEntry(Entry e) async {
    final db = await database;
    await db.update(
      'entries',
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final maps = await db.query('settings');
    return {
      for (final row in maps)
        row['key'] as String: row['value'] as String? ?? '',
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _dateStr(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
