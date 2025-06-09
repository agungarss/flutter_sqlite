import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'items.db');
    return await openDatabase(
      path,
      version: 2, // Increase version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        description TEXT DEFAULT '',
        price REAL NOT NULL DEFAULT 0.0,
        imageUrl TEXT DEFAULT '',
        stock INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        birthDate TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute(
          'ALTER TABLE items ADD COLUMN price REAL NOT NULL DEFAULT 0.0');
      await db.execute('ALTER TABLE items ADD COLUMN imageUrl TEXT DEFAULT ""');
      await db.execute(
          'ALTER TABLE items ADD COLUMN stock INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE items ADD COLUMN category TEXT NOT NULL DEFAULT ""');
    }
  }

  // Create
  Future<int> insertItem(Item item) async {
    final db = await database;
    // id akan di-generate secara otomatis oleh SQLite, jadi kita kirim map tanpa id
    // atau jika id sudah ada (misal dari objek yang sudah ada tapi ingin disalin),
    // SQLite akan tetap meng-override jika kolom id adalah PRIMARY KEY AUTOINCREMENT.
    // Lebih baik untuk operasi insert murni, id tidak disertakan atau null.
    Map<String, dynamic> itemMap = item.toMap();
    if (itemMap['id'] == null) {
      itemMap.remove('id'); // Hapus id jika null agar AUTOINCREMENT bekerja
    }
    return await db.insert('items', itemMap);
  }

  // Read all items
  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Read a single item by id
  Future<Item?> getItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  // Update
  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User authentication methods
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Close database (opsional, biasanya tidak perlu dipanggil secara manual)
  Future<void> close() async {
    final db = await database;
    db.close();
    _database =
        null; // Set _database menjadi null agar bisa diinisialisasi ulang
  }
}
