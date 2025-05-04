import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:quickcopy/models/clipboard_item.dart';
import 'package:quickcopy/models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  
  DatabaseService._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quickcopy.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    // Clipboard items tablosunu oluştur
    await db.execute('''
      CREATE TABLE clipboard_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        color INTEGER,
        isFavorite INTEGER NOT NULL,
        usageCount INTEGER NOT NULL
      )
    ''');
    
    // Kategoriler tablosunu oluştur
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        iconFontFamily TEXT,
        iconFontPackage TEXT,
        itemCount INTEGER NOT NULL
      )
    ''');
    
    // Varsayılan kategorileri ekle
    await _addDefaultCategories(db);
  }
  
  Future<void> _addDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'name': 'Genel',
        'color': Colors.blue.value,
        'icon': Icons.category.codePoint,
        'iconFontFamily': Icons.category.fontFamily,
        'iconFontPackage': Icons.category.fontPackage,
        'itemCount': 0
      },
      {
        'name': 'Kişisel',
        'color': Colors.green.value,
        'icon': Icons.person.codePoint,
        'iconFontFamily': Icons.person.fontFamily,
        'iconFontPackage': Icons.person.fontPackage,
        'itemCount': 0
      },
      {
        'name': 'İş',
        'color': Colors.orange.value,
        'icon': Icons.work.codePoint,
        'iconFontFamily': Icons.work.fontFamily,
        'iconFontPackage': Icons.work.fontPackage,
        'itemCount': 0
      },
      {
        'name': 'Banka',
        'color': Colors.purple.value,
        'icon': Icons.account_balance.codePoint,
        'iconFontFamily': Icons.account_balance.fontFamily,
        'iconFontPackage': Icons.account_balance.fontPackage,
        'itemCount': 0
      },
    ];
    
    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }
  
  // Clipboard Items CRUD İşlemleri
  
  Future<int> insertClipboardItem(ClipboardItem item) async {
    final db = await database;
    final id = await db.insert('clipboard_items', item.toMap());
    await _updateCategoryItemCount(item.categoryName);
    return id;
  }
  
  Future<int> updateClipboardItem(ClipboardItem item) async {
    final db = await database;
    return await db.update(
      'clipboard_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
  
  Future<int> incrementUsageCount(int id) async {
    final db = await database;
    final item = await getClipboardItem(id);
    if (item != null) {
      final updatedItem = item.copyWith(
        usageCount: item.usageCount + 1,
        updatedAt: DateTime.now(),
      );
      return await updateClipboardItem(updatedItem);
    }
    return 0;
  }
  
  Future<int> deleteClipboardItem(int id) async {
    final db = await database;
    final item = await getClipboardItem(id);
    if (item != null) {
      final result = await db.delete(
        'clipboard_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      await _updateCategoryItemCount(item.categoryName);
      return result;
    }
    return 0;
  }
  
  Future<ClipboardItem?> getClipboardItem(int id) async {
    final db = await database;
    final maps = await db.query(
      'clipboard_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ClipboardItem.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<ClipboardItem>> getAllClipboardItems() async {
    final db = await database;
    final maps = await db.query('clipboard_items', orderBy: 'updatedAt DESC');
    
    return List.generate(maps.length, (i) {
      return ClipboardItem.fromMap(maps[i]);
    });
  }
  
  Future<List<ClipboardItem>> getClipboardItemsByCategory(String categoryName) async {
    final db = await database;
    final maps = await db.query(
      'clipboard_items',
      where: 'categoryName = ?',
      whereArgs: [categoryName],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ClipboardItem.fromMap(maps[i]);
    });
  }
  
  Future<List<ClipboardItem>> getFavoriteClipboardItems() async {
    final db = await database;
    final maps = await db.query(
      'clipboard_items',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ClipboardItem.fromMap(maps[i]);
    });
  }
  
  Future<List<ClipboardItem>> searchClipboardItems(String query) async {
    final db = await database;
    final maps = await db.query(
      'clipboard_items',
      where: 'title LIKE ? OR content LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return ClipboardItem.fromMap(maps[i]);
    });
  }
  
  // Categories CRUD İşlemleri
  
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }
  
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
  
  Future<int> deleteCategory(int id) async {
    final db = await database;
    final category = await getCategory(id);
    if (category != null && category.name != 'Genel') {
      // Kategoriye ait öğeleri Genel kategorisine taşı
      await db.update(
        'clipboard_items',
        {'categoryName': 'Genel'},
        where: 'categoryName = ?',
        whereArgs: [category.name],
      );
      
      // Kategoriyi sil
      final result = await db.delete(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Genel kategorisinin öğe sayısını güncelle
      await _updateCategoryItemCount('Genel');
      
      return result;
    }
    return 0; // Genel kategori silinemez
  }
  
  Future<Category?> getCategory(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }
  
  Future<Category?> getCategoryByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }
  
  Future<void> _updateCategoryItemCount(String categoryName) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM clipboard_items WHERE categoryName = ?',
      [categoryName],
    )) ?? 0;
    
    await db.update(
      'categories',
      {'itemCount': count},
      where: 'name = ?',
      whereArgs: [categoryName],
    );
  }
}