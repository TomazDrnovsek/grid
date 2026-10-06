// Carousels (G-016): the pure parts of how slides are grouped, ordered,
// stored and carried through a backup manifest.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid/models/backup_models.dart';
import 'package:grid/models/photo_state.dart';
import 'package:grid/repositories/cloud_manifest_repository.dart';
import 'package:grid/repositories/photo_repository.dart';
import 'package:grid/repositories/saf_storage_provider.dart';
import 'package:grid/services/photo_database.dart';

PhotoDatabaseEntry _photo(String name, int order, {String? carouselId, int? carouselIndex}) {
  return PhotoDatabaseEntry(
    uuid: 'uuid_$name',
    imagePath: '/photos/$name.jpg',
    dateAdded: DateTime.utc(2026, 10, 6),
    orderIndex: order,
    carouselId: carouselId,
    carouselIndex: carouselIndex,
  );
}

/// In-memory folder standing in for the Storage Access Framework
class _MemorySaf implements SafStorageProvider {
  final Map<String, Uint8List> files = {};

  @override
  Future<String?> getCloudFolderUri() async => 'content://test';

  @override
  Future<bool> exists(String uri, String relativePath) async => files.containsKey(relativePath);

  @override
  Future<Uint8List?> readFile(String uri, String relativePath) async => files[relativePath];

  @override
  Future<bool> writeFile(String uri, String relativePath, Uint8List bytes, {bool createDirs = true}) async {
    files[relativePath] = bytes;
    return true;
  }

  @override
  Future<bool> renameFile(String uri, String fromPath, String toPath) async {
    final bytes = files.remove(fromPath);
    if (bytes == null) return false;
    files[toPath] = bytes;
    return true;
  }

  @override
  Future<bool> deleteFile(String uri, String relativePath) async => files.remove(relativePath) != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

BackupItem _item(String id, int sortIndex, {String? carouselId, int? carouselIndex}) {
  return BackupItem(
    id: id,
    relativePath: 'originals/2026/10/$id.jpg',
    thumbPath: 'thumbs/2026/10/$id.webp',
    checksumSha256: 'a' * 64,
    byteSize: 1000,
    createdAt: DateTime.utc(2026, 10, 6),
    width: 0,
    height: 0,
    sortIndex: sortIndex,
    carouselId: carouselId,
    carouselIndex: carouselIndex,
  );
}

void main() {
  group('groupIntoTiles', () {
    test('photos outside a carousel are one tile each, in stored order', () {
      final tiles = PhotoRepository.groupIntoTiles([_photo('a', 0), _photo('b', 1)]);
      expect(tiles.map((t) => t.map((p) => p.uuid).toList()).toList(), [
        ['uuid_a'],
        ['uuid_b'],
      ]);
    });

    test('a carousel is one tile at its first photo, slides by position', () {
      final tiles = PhotoRepository.groupIntoTiles([
        _photo('single1', 0),
        _photo('c0', 1, carouselId: 'c', carouselIndex: 0),
        _photo('c2', 2, carouselId: 'c', carouselIndex: 2),
        _photo('c1', 3, carouselId: 'c', carouselIndex: 1),
        _photo('single2', 4),
      ]);
      expect(tiles.map((t) => t.map((p) => p.uuid).toList()).toList(), [
        ['uuid_single1'],
        ['uuid_c0', 'uuid_c1', 'uuid_c2'],
        ['uuid_single2'],
      ]);
    });

    test('two carousels stay apart', () {
      final tiles = PhotoRepository.groupIntoTiles([
        _photo('x0', 0, carouselId: 'x', carouselIndex: 0),
        _photo('x1', 1, carouselId: 'x', carouselIndex: 1),
        _photo('y0', 2, carouselId: 'y', carouselIndex: 0),
        _photo('y1', 3, carouselId: 'y', carouselIndex: 1),
      ]);
      expect(tiles.length, 2);
      expect(tiles[0].map((p) => p.uuid), ['uuid_x0', 'uuid_x1']);
      expect(tiles[1].map((p) => p.uuid), ['uuid_y0', 'uuid_y1']);
    });
  });

  group('PhotoState', () {
    final single = File('/photos/single.jpg');
    final cover = File('/photos/cover.jpg');
    final slide1 = File('/photos/slide1.jpg');
    final slide2 = File('/photos/slide2.jpg');
    final state = PhotoState(
      images: [single, cover],
      carousels: {
        cover.path: [cover, slide1, slide2],
      },
    );

    test('allImagePaths lists every photo, slides right after their cover', () {
      expect(state.allImagePaths, [single.path, cover.path, slide1.path, slide2.path]);
    });

    test('carouselAt gives the slides of a carousel tile only', () {
      expect(state.carouselAt(0), isNull);
      expect(state.carouselAt(1), [cover, slide1, slide2]);
      expect(state.carouselAt(2), isNull);
    });
  });

  group('PhotoDatabaseEntry', () {
    test('carousel columns survive toMap and fromMap', () {
      final entry = _photo('c1', 3, carouselId: 'carousel_1', carouselIndex: 1);
      final back = PhotoDatabaseEntry.fromMap(entry.toMap());
      expect(back.carouselId, 'carousel_1');
      expect(back.carouselIndex, 1);
    });

    test('a photo outside a carousel stores nulls', () {
      final map = _photo('a', 0).toMap();
      expect(map['carousel_id'], isNull);
      expect(map['carousel_index'], isNull);
      final back = PhotoDatabaseEntry.fromMap(map);
      expect(back.carouselId, isNull);
      expect(back.carouselIndex, isNull);
    });

    test('withCarousel can clear the membership', () {
      final entry = _photo('c1', 3, carouselId: 'carousel_1', carouselIndex: 1);
      final cleared = entry.withCarousel(null, null);
      expect(cleared.carouselId, isNull);
      expect(cleared.carouselIndex, isNull);
      expect(cleared.uuid, entry.uuid);
      expect(cleared.orderIndex, entry.orderIndex);
    });
  });

  group('backup manifest', () {
    BackupManifest manifest(List<BackupItem> items) => BackupManifest(
          exportedAt: DateTime.utc(2026, 10, 6),
          deviceId: 'device',
          appVersion: '1.0.4',
          items: items,
        );

    test('carousel fields survive a write and read, version stays 1', () async {
      final saf = _MemorySaf();
      final repo = CloudManifestRepository(saf);

      await repo.writeManifest(manifest([
        _item('single', 0),
        _item('c0', 1, carouselId: 'carousel_1', carouselIndex: 0),
        _item('c1', 2, carouselId: 'carousel_1', carouselIndex: 1),
      ]));
      final back = await repo.readManifest();

      expect(back, isNotNull);
      expect(back!.version, 1);
      expect(back.items.map((i) => i.carouselId), [null, 'carousel_1', 'carousel_1']);
      expect(back.items.map((i) => i.carouselIndex), [null, 0, 1]);
    });

    test('a photo outside a carousel writes no carousel keys', () async {
      final saf = _MemorySaf();
      await CloudManifestRepository(saf).writeManifest(manifest([_item('single', 0)]));

      final json = jsonDecode(utf8.decode(saf.files['manifest.json']!)) as Map<String, dynamic>;
      final item = (json['items'] as List).single as Map<String, dynamic>;
      expect(item.containsKey('carouselId'), isFalse);
      expect(item.containsKey('carouselIndex'), isFalse);
    });

    test('a backup made before carousels reads with no carousel', () async {
      final saf = _MemorySaf();
      final oldManifest = {
        'version': 1,
        'exportedAt': '2026-10-06T00:00:00.000Z',
        'deviceId': 'device',
        'appVersion': '1.0.4',
        'items': [
          {
            'id': 'old',
            'relativePath': 'originals/2026/10/old.jpg',
            'thumbPath': 'thumbs/2026/10/old.webp',
            'checksumSha256': 'b' * 64,
            'byteSize': 1000,
            'createdAt': '2026-10-06T00:00:00.000Z',
            'width': 0,
            'height': 0,
            'exifTs': null,
            'sortIndex': 0,
            'metadata': <String, dynamic>{},
          },
        ],
        'metadata': <String, dynamic>{},
      };
      saf.files['manifest.json'] = Uint8List.fromList(utf8.encode(jsonEncode(oldManifest)));

      final back = await CloudManifestRepository(saf).readManifest();
      expect(back!.items.single.carouselId, isNull);
      expect(back.items.single.carouselIndex, isNull);
    });
  });
}
