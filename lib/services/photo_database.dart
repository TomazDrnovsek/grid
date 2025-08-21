// File: lib/services/photo_database.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database service for managing photo metadata and app settings
/// PHASE 2 IMPLEMENTATION: Added stable photo IDs for order preservation across devices
class PhotoDatabase {
  static const String _databaseName = 'photos.db';
  static const int _databaseVersion = 2; // UPDATED: Incremented for UUID migration

  // Table names (single source of truth)
  static const String photosTable = 'photos';
  static const String settingsTable = 'settings';

  Database? _database;

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database connection and create tables
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);

      debugPrint('Opening database at: $path');

      final database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
        onOpen: (db) => debugPrint('Database opened successfully'),
      );

      return database;

    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create database tables for fresh installation
  Future<void> _createTables(Database db, int version) async {
    try {
      debugPrint('Creating database tables...');

      // Create photos table with UUID support
      await db.execute('''
        CREATE TABLE $photosTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          image_path TEXT NOT NULL,
          thumbnail_path TEXT,
          original_name TEXT,
          file_size INTEGER,
          width INTEGER,
          height INTEGER,
          date_added INTEGER NOT NULL,
          date_modified INTEGER,
          order_index INTEGER NOT NULL DEFAULT 0,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          tags TEXT DEFAULT '',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Create settings table
      await db.execute('''
        CREATE TABLE $settingsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT NOT NULL UNIQUE,
          value TEXT NOT NULL,
          type TEXT NOT NULL DEFAULT 'string',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Create indexes for better performance
      await db.execute('CREATE INDEX idx_photos_order ON $photosTable(order_index)');
      await db.execute('CREATE INDEX idx_photos_date_added ON $photosTable(date_added DESC)');
      await db.execute('CREATE INDEX idx_photos_path ON $photosTable(image_path)');
      await db.execute('CREATE UNIQUE INDEX idx_photos_uuid ON $photosTable(uuid)'); // NEW: UUID index

      debugPrint('Database tables created successfully');

    } catch (e) {
      debugPrint('Error creating database tables: $e');
      rethrow;
    }
  }

  /// Handle database version upgrades
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');

    try {
      // PHASE 2: Add UUID column migration (v1 -> v2)
      if (oldVersion < 2 && newVersion >= 2) {
        debugPrint('Migrating to version 2: Adding UUID support');

        // Add uuid column to existing photos table
        await db.execute('ALTER TABLE $photosTable ADD COLUMN uuid TEXT');

        // Generate UUIDs for existing photos
        final existingPhotos = await db.query(photosTable, columns: ['id']);
        debugPrint('Backfilling UUIDs for ${existingPhotos.length} existing photos');

        for (final photo in existingPhotos) {
          final photoId = photo['id'] as int;
          final uuid = _generatePhotoId();
          await db.update(
            photosTable,
            {'uuid': uuid},
            where: 'id = ?',
            whereArgs: [photoId],
          );
        }

        // Now make uuid column NOT NULL and add unique constraint
        // SQLite doesn't support ALTER COLUMN, so we need to recreate the table
        await db.execute('BEGIN TRANSACTION');

        try {
          // Create new table with proper schema
          await db.execute('''
            CREATE TABLE ${photosTable}_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              uuid TEXT NOT NULL UNIQUE,
              image_path TEXT NOT NULL,
              thumbnail_path TEXT,
              original_name TEXT,
              file_size INTEGER,
              width INTEGER,
              height INTEGER,
              date_added INTEGER NOT NULL,
              date_modified INTEGER,
              order_index INTEGER NOT NULL DEFAULT 0,
              is_favorite INTEGER NOT NULL DEFAULT 0,
              tags TEXT DEFAULT '',
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');

          // Copy data from old table to new table
          await db.execute('''
            INSERT INTO ${photosTable}_new 
            SELECT * FROM $photosTable
          ''');

          // Drop old table and rename new table
          await db.execute('DROP TABLE $photosTable');
          await db.execute('ALTER TABLE ${photosTable}_new RENAME TO $photosTable');

          // Recreate indexes
          await db.execute('CREATE INDEX idx_photos_order ON $photosTable(order_index)');
          await db.execute('CREATE INDEX idx_photos_date_added ON $photosTable(date_added DESC)');
          await db.execute('CREATE INDEX idx_photos_path ON $photosTable(image_path)');
          await db.execute('CREATE UNIQUE INDEX idx_photos_uuid ON $photosTable(uuid)');

          await db.execute('COMMIT');
          debugPrint('UUID migration completed successfully');

        } catch (e) {
          await db.execute('ROLLBACK');
          debugPrint('UUID migration failed, rolling back: $e');
          rethrow;
        }
      }

      // Future version upgrades will be handled here

    } catch (e) {
      debugPrint('Error during database upgrade: $e');
      rethrow;
    }
  }

  /// Generate a unique photo ID using secure random
  String _generatePhotoId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List<int>.generate(8, (i) => random.nextInt(256));
    final randomHex = randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'photo_${timestamp}_$randomHex';
  }

  /// Insert a new photo entry
  Future<int> insertPhoto(PhotoDatabaseEntry photo) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Generate UUID if not provided
      final uuid = photo.uuid ?? _generatePhotoId();

      final result = await db.insert(
        photosTable,
        {
          ...photo.toMap(),
          'uuid': uuid,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Inserted photo with ID: $result, UUID: $uuid');
      return result;

    } catch (e) {
      debugPrint('Error inserting photo: $e');
      rethrow;
    }
  }

  /// Get all photos ordered by index
  Future<List<PhotoDatabaseEntry>> getAllPhotos() async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
        orderBy: 'order_index ASC',
      );

      return result.map((map) => PhotoDatabaseEntry.fromMap(map)).toList();

    } catch (e) {
      debugPrint('Error getting all photos: $e');
      return <PhotoDatabaseEntry>[];
    }
  }

  /// Get photo by UUID
  Future<PhotoDatabaseEntry?> getPhotoByUuid(String uuid) async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
        where: 'uuid = ?',
        whereArgs: [uuid],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return PhotoDatabaseEntry.fromMap(result.first);

    } catch (e) {
      debugPrint('Error getting photo by UUID: $e');
      return null;
    }
  }

  /// Get photo by path (legacy support)
  Future<PhotoDatabaseEntry?> getPhotoByPath(String imagePath) async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
        where: 'image_path = ?',
        whereArgs: [imagePath],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return PhotoDatabaseEntry.fromMap(result.first);

    } catch (e) {
      debugPrint('Error getting photo by path: $e');
      return null;
    }
  }

  /// Update photo entry
  Future<int> updatePhoto(PhotoDatabaseEntry photo) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final result = await db.update(
        photosTable,
        {
          ...photo.toMap(),
          'updated_at': now,
        },
        where: 'uuid = ?',
        whereArgs: [photo.uuid],
      );

      debugPrint('Updated photo: ${photo.uuid}');
      return result;

    } catch (e) {
      debugPrint('Error updating photo: $e');
      rethrow;
    }
  }

  /// Delete photo by UUID
  Future<int> deletePhotoByUuid(String uuid) async {
    try {
      final db = await database;
      final result = await db.delete(
        photosTable,
        where: 'uuid = ?',
        whereArgs: [uuid],
      );

      debugPrint('Deleted photo: $uuid');
      return result;

    } catch (e) {
      debugPrint('Error deleting photo: $e');
      rethrow;
    }
  }

  /// Delete photo by path (legacy support)
  Future<int> deletePhotoByPath(String imagePath) async {
    try {
      final db = await database;
      final result = await db.delete(
        photosTable,
        where: 'image_path = ?',
        whereArgs: [imagePath],
      );

      debugPrint('Deleted photo by path: $imagePath');
      return result;

    } catch (e) {
      debugPrint('Error deleting photo by path: $e');
      rethrow;
    }
  }

  /// Update multiple photo order indices efficiently
  Future<void> updatePhotoOrders(List<({String uuid, int orderIndex})> updates) async {
    try {
      final db = await database;
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final update in updates) {
        batch.update(
          photosTable,
          {
            'order_index': update.orderIndex,
            'updated_at': now,
          },
          where: 'uuid = ?',
          whereArgs: [update.uuid],
        );
      }

      await batch.commit(noResult: true);
      debugPrint('Updated order for ${updates.length} photos');

    } catch (e) {
      debugPrint('Error updating photo orders: $e');
      rethrow;
    }
  }

  /// ðŸ”§ NEW: Update order by image paths (authoritative 0..n; 0 = top/newest)
  /// This is used by the repository to persist the exact UI order
  /// when we only have paths (e.g., right after adding new images).
  Future<void> updatePhotoOrdersByPaths(List<String> orderedPaths) async {
    try {
      final db = await database;
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < orderedPaths.length; i++) {
        batch.update(
          photosTable,
          {
            'order_index': i,
            'updated_at': now,
          },
          where: 'image_path = ?',
          whereArgs: [orderedPaths[i]],
        );
      }

      await batch.commit(noResult: true);
      debugPrint('Updated order (by paths) for ${orderedPaths.length} photos');
    } catch (e) {
      debugPrint('Error updating photo orders by paths: $e');
      rethrow;
    }
  }

  /// Get total photo count
  Future<int> getPhotoCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM $photosTable');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting photo count: $e');
      return 0;
    }
  }

  /// Check if photo exists by UUID
  Future<bool> photoExistsByUuid(String uuid) async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
        where: 'uuid = ?',
        whereArgs: [uuid],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking photo existence by UUID: $e');
      return false;
    }
  }

  /// Check if photo exists by path (legacy support)
  Future<bool> photoExists(String imagePath) async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
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
        settingsTable,
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
        settingsTable,
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
        photosTable,
        columns: ['image_path'],
        orderBy: 'order_index ASC',
      );

      return result.map((row) => row['image_path'] as String).toList();

    } catch (e) {
      debugPrint('Error getting all photo paths: $e');
      return <String>[];
    }
  }

  /// Get all photo UUIDs in order
  Future<List<String>> getAllPhotoUuids() async {
    try {
      final db = await database;
      final result = await db.query(
        photosTable,
        columns: ['uuid'],
        orderBy: 'order_index ASC',
      );

      return result.map((row) => row['uuid'] as String).toList();

    } catch (e) {
      debugPrint('Error getting all photo UUIDs: $e');
      return <String>[];
    }
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(photosTable);
      await db.delete(settingsTable);
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
          await db.rawQuery('SELECT COUNT(*) FROM $settingsTable')
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
/// PHASE 2: Added UUID field for stable photo identification
class PhotoDatabaseEntry {
  final int? id;
  final String? uuid; // NEW: Stable photo identifier
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
    this.uuid,
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
      if (uuid != null) 'uuid': uuid,
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
      uuid: map['uuid'], // NEW: UUID field
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
          : <String>[],
    );
  }

  /// Create a copy with updated fields
  PhotoDatabaseEntry copyWith({
    int? id,
    String? uuid,
    String? imagePath,
    String? thumbnailPath,
    String? originalName,
    int? fileSize,
    int? width,
    int? height,
    DateTime? dateAdded,
    DateTime? dateModified,
    int? orderIndex,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return PhotoDatabaseEntry(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      originalName: originalName ?? this.originalName,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      orderIndex: orderIndex ?? this.orderIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() {
    return 'PhotoDatabaseEntry{id: $id, uuid: $uuid, imagePath: $imagePath, orderIndex: $orderIndex}';
  }
}

/// Database statistics model
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

  double get databaseSizeMB => databaseSizeBytes / (1024 * 1024);

  @override
  String toString() {
    return 'DatabaseStatistics{photos: $photoCount, settings: $settingsCount, size: ${databaseSizeMB.toStringAsFixed(2)}MB}';
  }
}