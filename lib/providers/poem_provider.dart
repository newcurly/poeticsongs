// lib/providers/poem_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/poem.dart';

class PoemProvider with ChangeNotifier {
  static const _dbName = 'poems.db';
  static const _table = 'poems';
  Database? _db;

  final List<Poem> _items = [];
  List<Poem> get items => List.unmodifiable(_items);

  PoemProvider() {
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    await _initDb();
    await fetchAll();
  }

  Future<void> _initDb() async {
    if (_db != null) return;
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            composer TEXT NOT NULL,
            lyricist TEXT NOT NULL,
            genre TEXT NOT NULL,
            year INTEGER NOT NULL,
            songKey TEXT NOT NULL,
            bpm INTEGER NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            lyrics TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> fetchAll({String? keyword, String? orderBy}) async {
    if (_db == null) return;
    final where = (keyword == null || keyword.trim().isEmpty)
        ? null
        : 'title LIKE ? OR composer LIKE ? OR lyricist LIKE ? OR lyrics LIKE ?';
    final args = (keyword == null || keyword.trim().isEmpty)
        ? null
        : List.filled(4, '%${keyword.trim()}%');

    final rows = await _db!.query(
      _table,
      where: where,
      whereArgs: args,
      orderBy: orderBy ?? 'id DESC',
    );
    _items
      ..clear()
      ..addAll(rows.map(Poem.fromMap));
    notifyListeners();
  }

  Future<int> add(Poem poem) async {
    await _initDb();
    final id = await _db!.insert(_table, poem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _items.insert(0, poem.copyWith(id: id));
    notifyListeners();
    return id;
  }

  Future<int> update(Poem poem) async {
    if (poem.id == null || _db == null) return 0;
    final rows = await _db!.update(_table, poem.toMap(),
        where: 'id = ?', whereArgs: [poem.id]);
    final idx = _items.indexWhere((e) => e.id == poem.id);
    if (idx != -1) _items[idx] = poem;
    notifyListeners();
    return rows;
  }

  Future<int> delete(int id) async {
    if (_db == null) return 0;
    final rows =
        await _db!.delete(_table, where: 'id = ?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    return rows;
  }

  Future<void> toggleFavorite(int id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final updated = _items[i].copyWith(isFavorite: !_items[i].isFavorite);
    await update(updated);
  }
}
