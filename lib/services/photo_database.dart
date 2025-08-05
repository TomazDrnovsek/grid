// File: lib/services/photo_database.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database service for photo metadata storage
/// Replaces SharedPreferences for scalable, structured data management
class PhotoDatabase {
  static final PhotoDatabase _instance = PhotoDatabase._internal();
  factory PhotoDatabase() => _instance;
  PhotoDatabase._internal();

  static const String _databaseName = 'grid_photos.db';
  static const int _databaseVersion = 1;

  // Table definitions
  static const String _photosTable = 'photos';
  static const String _settingsTable = 'settings';

  Database? _database;

  /// Get database instance, creating if necessary
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with tables
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);

      debugPrint('Initializing database at: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
        onOpen: (db) {
          debugPrint('Database opened successfully');
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    try {
      // Photos table for image metadata
      await db.execute('''
        CREATE TABLE $_photosTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          image_path TEXT NOT NULL UNIQUE,
          thumbnail_path TEXT,
          original_name TEXT,
          file_size INTEGER,
          width INTEGER,
          height INTEGER,
          date_added INTEGER NOT NULL,
          date_modified INTEGER,
          order_index INTEGER NOT NULL,
          is_favorite INTEGER DEFAULT 0,
          tags TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Settings table for app preferences
      await db.execute('''
        CREATE TABLE $_settingsTable (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          type TEXT NOT NULL DEFAULT 'string',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Create indexes for better performance
      await db.execute('CREATE INDEX idx_photos_order ON $_photosTable(order_index)');
      await db.execute('CREATE INDEX idx_photos_date_added ON $_photosTable(date_added DESC)');
      await db.execute('CREATE INDEX idx_photos_path ON $_photosTable(image_path)');

      debugPrint('Database tables created successfully');

    } catch (e) {
      debugPrint('Error creating database tables: $e');
      rethrow;
    }
  }

  /// Handle database version upgrades
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');

    // Future version upgrades will be handled here
    // For now, just recreate tables (data loss acceptable during development)
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $_photosTable');
      await db.execute('DROP TABLE IF EXISTS $_settingsTable');
      await _createTables(db, newVersion);
    }
  }

  /// Insert a new photo entry
  Future<int> insertPhoto(PhotoDatabaseEntry photo) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final result = await db.insert(
        _photosTable,
        {
          ...photo.toMap(),
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Inserted photo: ${photo.imagePath} with ID: $result');
      return result;

    } catch (e) {
      debugPrint('Error inserting photo: $e');
      rethrow;
    }
  }

  /// Insert multiple photos in a batch transaction
  Future<List<int>> insertPhotos(List<PhotoDatabaseEntry> photos) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final results = <int>[];

      await db.transaction((txn) async {
        for (final photo in photos) {
          final result = await txn.insert(
            _photosTable,
            {
              ...photo.toMap(),
              'created_at': now,
              'updated_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          results.add(result);
        }
      });

      debugPrint('Batch inserted ${photos.length} photos');
      return results;

    } catch (e) {
      debugPrint('Error batch inserting photos: $e');
      rethrow;
    }
  }

  /// Get all photos ordered by index
  Future<List<PhotoDatabaseEntry>> getAllPhotos() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _photosTable,
        orderBy: 'order_index ASC',
      );

      return maps.map((map) => PhotoDatabaseEntry.fromMap(map)).toList();

    } catch (e) {
      debugPrint('Error getting all photos: $e');
      return <PhotoDatabaseEntry>[];
    }
  }

  /// Get photos with pagination
  Future<List<PhotoDatabaseEntry>> getPhotos({int? limit, int? offset}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _photosTable,
        orderBy: 'order_index ASC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => PhotoDatabaseEntry.fromMap(map)).toList();

    } catch (e) {
      debugPrint('Error getting photos with pagination: $e');
      return <PhotoDatabaseEntry>[];
    }
  }

  /// Update photo order indexes (for reordering)
  Future<void> updatePhotoOrders(List<String> orderedPaths) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction((txn) async {
        for (int i = 0; i < orderedPaths.length; i++) {
          await txn.update(
            _photosTable,
            {
              'order_index': i,
              'updated_at': now,
            },
            where: 'image_path = ?',
            whereArgs: [orderedPaths[i]],
          );
        }
      });

      debugPrint('Updated order for ${orderedPaths.length} photos');

    } catch (e) {
      debugPrint('Error updating photo orders: $e');
      rethrow;
    }
  }

  /// Delete photos by paths
  Future<int> deletePhotosByPaths(List<String> imagePaths) async {
    try {
      final db = await database;
      int deletedCount = 0;

      await db.transaction((txn) async {
        for (final path in imagePaths) {
          final result = await txn.delete(
            _photosTable,
            where: 'image_path = ?',
            whereArgs: [path],
          );
          deletedCount += result;
        }
      });

      debugPrint('Deleted $deletedCount photos from database');
      return deletedCount;

    } catch (e) {
      debugPrint('Error deleting photos: $e');
      return 0;
    }
  }

  /// Get photo count
  Future<int> getPhotoCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_photosTable');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting photo count: $e');
      return 0;
    }
  }

  /// Check if photo exists by path
  Future<bool> photoExists(String imagePath) async {
    try {
      final db = await database;
      final result = await db.query(
        _photosTable,
        where: 'image_path = ?',
        whereArgs: [imagePath],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking photo existence: $e');
      return false;
    }
  }

  /// Store app setting
  Future<void> setSetting(String key, dynamic value) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      String valueStr;
      String type;

      if (value is String) {
        valueStr = value;
        type = 'string';
      } else if (value is int) {
        valueStr = value.toString();
        type = 'int';
      } else if (value is double) {
        valueStr = value.toString();
        type = 'double';
      } else if (value is bool) {
        valueStr = value.toString();
        type = 'bool';
      } else if (value is List<String>) {
        valueStr = value.join('|||'); // Use delimiter that won't appear in file paths
        type = 'string_list';
      } else {
        valueStr = value.toString();
        type = 'string';
      }

      await db.insert(
        _settingsTable,
        {
          'key': key,
          'value': valueStr,
          'type': type,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

    } catch (e) {
      debugPrint('Error setting value for key $key: $e');
      rethrow;
    }
  }

  /// Get app setting
  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    try {
      final db = await database;
      final result = await db.query(
        _settingsTable,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) return defaultValue;

      final map = result.first;
      final valueStr = map['value'] as String;
      final type = map['type'] as String;

      switch (type) {
        case 'string':
          return valueStr as T;
        case 'int':
          return int.parse(valueStr) as T;
        case 'double':
          return double.parse(valueStr) as T;
        case 'bool':
          return (valueStr.toLowerCase() == 'true') as T;
        case 'string_list':
          return valueStr.split('|||') as T;
        default:
          return valueStr as T;
      }

    } catch (e) {
      debugPrint('Error getting setting for key $key: $e');
      return defaultValue;
    }
  }

  /// Get all photo paths in order (for migration compatibility)
  Future<List<String>> getAllPhotoPaths() async {
    try {
      final db = await database;
      final result = await db.query(
        _photosTable,
        columns: ['image_path'],
        orderBy: 'order_index ASC',
      );

      return result.map((row) => row['image_path'] as String).toList();

    } catch (e) {
      debugPrint('Error getting all photo paths: $e');
      return <String>[];
    }
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(_photosTable);
      await db.delete(_settingsTable);
      debugPrint('Cleared all database data');
    } catch (e) {
      debugPrint('Error clearing database: $e');
      rethrow;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      debugPrint('Database connection closed');
    }
  }

  /// Get database statistics
  Future<DatabaseStatistics> getStatistics() async {
    try {
      final db = await database;

      final photoCount = await getPhotoCount();
      final settingsCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_settingsTable')
      ) ?? 0;

      // Get database file size
      final path = join(await getDatabasesPath(), _databaseName);
      final file = File(path);
      final fileSize = await file.exists() ? await file.length() : 0;

      return DatabaseStatistics(
        photoCount: photoCount,
        settingsCount: settingsCount,
        databaseSizeBytes: fileSize,
        databasePath: path,
      );

    } catch (e) {
      debugPrint('Error getting database statistics: $e');
      return const DatabaseStatistics(
        photoCount: -1,
        settingsCount: -1,
        databaseSizeBytes: -1,
        databasePath: 'Unknown',
      );
    }
  }
}

/// Data model for photo database entries
class PhotoDatabaseEntry {
  final int? id;
  final String imagePath;
  final String? thumbnailPath;
  final String? originalName;
  final int? fileSize;
  final int? width;
  final int? height;
  final DateTime dateAdded;
  final DateTime? dateModified;
  final int orderIndex;
  final bool isFavorite;
  final List<String> tags;

  PhotoDatabaseEntry({
    this.id,
    required this.imagePath,
    this.thumbnailPath,
    this.originalName,
    this.fileSize,
    this.width,
    this.height,
    required this.dateAdded,
    this.dateModified,
    required this.orderIndex,
    this.isFavorite = false,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'original_name': originalName,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'date_added': dateAdded.millisecondsSinceEpoch,
      'date_modified': dateModified?.millisecondsSinceEpoch,
      'order_index': orderIndex,
      'is_favorite': isFavorite ? 1 : 0,
      'tags': tags.join(','),
    };
  }

  factory PhotoDatabaseEntry.fromMap(Map<String, dynamic> map) {
    return PhotoDatabaseEntry(
      id: map['id']?.toInt(),
      imagePath: map['image_path'] ?? '',
      thumbnailPath: map['thumbnail_path'],
      originalName: map['original_name'],
      fileSize: map['file_size']?.toInt(),
      width: map['width']?.toInt(),
      height: map['height']?.toInt(),
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['date_added'] ?? 0),
      dateModified: map['date_modified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_modified'])
          : null,
      orderIndex: map['order_index']?.toInt() ?? 0,
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? map['tags'].toString().split(',')
          : [],
    );
  }
}

/// Database statistics
class DatabaseStatistics {
  final int photoCount;
  final int settingsCount;
  final int databaseSizeBytes;
  final String databasePath;

  const DatabaseStatistics({
    required this.photoCount,
    required this.settingsCount,
    required this.databaseSizeBytes,
    required this.databasePath,
  });

  String get formattedSize {
    if (databaseSizeBytes < 0) return 'Unknown';
    if (databaseSizeBytes < 1024) return '${databaseSizeBytes}B';
    if (databaseSizeBytes < 1024 * 1024) return '${(databaseSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(databaseSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}