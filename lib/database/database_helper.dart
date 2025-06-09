import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item_model.dart';

class DatabaseHelper {
  // Pola Singleton untuk memastikan hanya ada satu instance DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Instance tunggal dari database
  static Database? _database;

  // Getter untuk database, akan menginisialisasi jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inisialisasi database (membuat atau membuka database yang ada)
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'items.db');

    // Comment out or remove database deletion to preserve data
    // if (await File(path).exists()) {
    //   print('Deleting existing database');
    //   await deleteDatabase(path);
    // }

    print('Creating or opening database');
    return await openDatabase(
      path,
      version: 5, // Increase version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Metode ini hanya berjalan SEKALI saat database pertama kali dibuat
  Future<void> _onCreate(Database db, int version) async {
    print('Creating new tables');
    // Buat tabel users dengan kolom gender
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        birthDate TEXT,
        gender TEXT
      )
    ''');

    // Buat tabel items
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL DEFAULT 0.0,
        imageUrl TEXT,
        stock INTEGER NOT NULL DEFAULT 0,
        category TEXT
      )
    ''');
    // Create likes table
    await db.execute('''
      CREATE TABLE likes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, item_id)
      )
    ''');
    // Add saves table
    await db.execute('''
      CREATE TABLE saves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, item_id)
      )
    ''');
    print('Tables created successfully');
  }

  // Metode ini berjalan jika Anda menaikkan nomor `version` di `openDatabase`
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from $oldVersion to $newVersion');

    if (oldVersion < 5) {
      // Only create tables if they don't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS likes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          item_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(user_id, item_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS saves(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          item_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          UNIQUE(user_id, item_id)
        )
      ''');
    }
  }

  // --- Metode untuk Item ---
  Future<int> insertItem(Item item) async {
    final db = await database;
    Map<String, dynamic> itemMap = item.toMap();
    itemMap.remove('id');
    return await db.insert('items', itemMap);
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Update item method dengan error handling
  Future<int> updateItem(Item item) async {
    final db = await database;
    try {
      final result = await db.update(
        'items',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Item updated successfully: ${item.id}');
      return result;
    } catch (e) {
      print('Error updating item: $e');
      rethrow;
    }
  }

  // Delete item method dengan error handling
  Future<int> deleteItem(int id) async {
    final db = await database;
    try {
      final result = await db.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Item deleted successfully: $id');
      return result;
    } catch (e) {
      print('Error deleting item: $e');
      rethrow;
    }
  }

  // --- Metode untuk User ---
  // Update insert user method dengan penanganan error yang lebih baik
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      print('Inserting user: $user');
      final result = await db.insert(
        'users',
        user,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      print('User inserted successfully with id: $result');
      return result;
    } catch (e) {
      print('Error inserting user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Like/Unlike methods
  Future<bool> isItemLiked(int userId, int itemId) async {
    final db = await database;
    final result = await db.query(
      'likes',
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleLike(int userId, int itemId) async {
    final db = await database;
    final isLiked = await isItemLiked(userId, itemId);

    if (isLiked) {
      await db.delete(
        'likes',
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      );
    } else {
      await db.insert('likes', {
        'user_id': userId,
        'item_id': itemId,
      });
    }
  }

  Future<List<Item>> getLikedItems(int userId) async {
    final db = await database;
    final likes = await db.rawQuery('''
      SELECT items.* FROM items
      INNER JOIN likes ON items.id = likes.item_id
      WHERE likes.user_id = ?
      ORDER BY likes.created_at DESC
    ''', [userId]);

    return likes.map((map) => Item.fromMap(map)).toList();
  }

  // Save/Unsave methods
  Future<bool> isItemSaved(int userId, int itemId) async {
    final db = await database;
    final result = await db.query(
      'saves',
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
    return result.isNotEmpty;
  }

  Future<void> toggleSave(int userId, int itemId) async {
    final db = await database;
    final isSaved = await isItemSaved(userId, itemId);

    if (isSaved) {
      await db.delete(
        'saves',
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      );
    } else {
      await db.insert('saves', {
        'user_id': userId,
        'item_id': itemId,
      });
    }
  }

  Future<List<Item>> getSavedItems(int userId) async {
    final db = await database;
    final saves = await db.rawQuery('''
      SELECT items.* FROM items
      INNER JOIN saves ON items.id = saves.item_id
      WHERE saves.user_id = ?
      ORDER BY saves.created_at DESC
    ''', [userId]);

    return saves.map((map) => Item.fromMap(map)).toList();
  }

  // Metode untuk menutup koneksi database (opsional)
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null; // Set null agar bisa diinisialisasi ulang
  }
}
