// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupManifestImpl _$$BackupManifestImplFromJson(Map<String, dynamic> json) =>
    _$BackupManifestImpl(
      version: (json['version'] as num?)?.toInt() ?? 1,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      deviceId: json['deviceId'] as String,
      appVersion: json['appVersion'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => BackupItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$BackupManifestImplToJson(
  _$BackupManifestImpl instance,
) => <String, dynamic>{
  'version': instance.version,
  'exportedAt': instance.exportedAt.toIso8601String(),
  'deviceId': instance.deviceId,
  'appVersion': instance.appVersion,
  'items': instance.items,
  'metadata': instance.metadata,
};

_$BackupItemImpl _$$BackupItemImplFromJson(Map<String, dynamic> json) =>
    _$BackupItemImpl(
      id: json['id'] as String,
      relativePath: json['relativePath'] as String,
      thumbPath: json['thumbPath'] as String,
      checksumSha256: json['checksumSha256'] as String,
      byteSize: (json['byteSize'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      exifTs: json['exifTs'] == null
          ? null
          : DateTime.parse(json['exifTs'] as String),
      sortIndex: (json['sortIndex'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      carouselId: json['carouselId'] as String?,
      carouselIndex: (json['carouselIndex'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BackupItemImplToJson(_$BackupItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'relativePath': instance.relativePath,
      'thumbPath': instance.thumbPath,
      'checksumSha256': instance.checksumSha256,
      'byteSize': instance.byteSize,
      'createdAt': instance.createdAt.toIso8601String(),
      'width': instance.width,
      'height': instance.height,
      'exifTs': instance.exifTs?.toIso8601String(),
      'sortIndex': instance.sortIndex,
      'metadata': instance.metadata,
      'carouselId': instance.carouselId,
      'carouselIndex': instance.carouselIndex,
    };

_$SafEntryImpl _$$SafEntryImplFromJson(Map<String, dynamic> json) =>
    _$SafEntryImpl(
      name: json['name'] as String,
      type: $enumDecode(_$SafEntryTypeEnumMap, json['type']),
      size: (json['size'] as num).toInt(),
      lastModified: DateTime.parse(json['lastModified'] as String),
      mimeType: json['mimeType'] as String?,
    );

Map<String, dynamic> _$$SafEntryImplToJson(_$SafEntryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$SafEntryTypeEnumMap[instance.type]!,
      'size': instance.size,
      'lastModified': instance.lastModified.toIso8601String(),
      'mimeType': instance.mimeType,
    };

const _$SafEntryTypeEnumMap = {
  SafEntryType.file: 'file',
  SafEntryType.directory: 'directory',
};

_$BackupConfigImpl _$$BackupConfigImplFromJson(Map<String, dynamic> json) =>
    _$BackupConfigImpl(
      chunkSize: (json['chunkSize'] as num?)?.toInt() ?? 64 * 1024,
      maxConcurrency: (json['maxConcurrency'] as num?)?.toInt() ?? 2,
      includeOriginals: json['includeOriginals'] as bool? ?? true,
      includeThumbnails: json['includeThumbnails'] as bool? ?? true,
      validateChecksums: json['validateChecksums'] as bool? ?? true,
      skipExisting: json['skipExisting'] as bool? ?? false,
      verboseLogging: json['verboseLogging'] as bool? ?? false,
      cloudFolderName: json['cloudFolderName'] as String? ?? 'Grid',
    );

Map<String, dynamic> _$$BackupConfigImplToJson(_$BackupConfigImpl instance) =>
    <String, dynamic>{
      'chunkSize': instance.chunkSize,
      'maxConcurrency': instance.maxConcurrency,
      'includeOriginals': instance.includeOriginals,
      'includeThumbnails': instance.includeThumbnails,
      'validateChecksums': instance.validateChecksums,
      'skipExisting': instance.skipExisting,
      'verboseLogging': instance.verboseLogging,
      'cloudFolderName': instance.cloudFolderName,
    };

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      deviceId: json['deviceId'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      androidVersion: json['androidVersion'] as String,
      sdkInt: (json['sdkInt'] as num).toInt(),
      appVersion: json['appVersion'] as String,
      buildNumber: json['buildNumber'] as String,
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'androidVersion': instance.androidVersion,
      'sdkInt': instance.sdkInt,
      'appVersion': instance.appVersion,
      'buildNumber': instance.buildNumber,
    };
