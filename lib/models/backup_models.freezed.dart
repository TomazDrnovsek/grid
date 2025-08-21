// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupManifest _$BackupManifestFromJson(Map<String, dynamic> json) {
  return _BackupManifest.fromJson(json);
}

/// @nodoc
mixin _$BackupManifest {
  int get version => throw _privateConstructorUsedError;
  DateTime get exportedAt => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  String get appVersion => throw _privateConstructorUsedError;
  List<BackupItem> get items => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this BackupManifest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupManifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupManifestCopyWith<BackupManifest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupManifestCopyWith<$Res> {
  factory $BackupManifestCopyWith(
    BackupManifest value,
    $Res Function(BackupManifest) then,
  ) = _$BackupManifestCopyWithImpl<$Res, BackupManifest>;
  @useResult
  $Res call({
    int version,
    DateTime exportedAt,
    String deviceId,
    String appVersion,
    List<BackupItem> items,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$BackupManifestCopyWithImpl<$Res, $Val extends BackupManifest>
    implements $BackupManifestCopyWith<$Res> {
  _$BackupManifestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupManifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? exportedAt = null,
    Object? deviceId = null,
    Object? appVersion = null,
    Object? items = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            exportedAt: null == exportedAt
                ? _value.exportedAt
                : exportedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            appVersion: null == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<BackupItem>,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupManifestImplCopyWith<$Res>
    implements $BackupManifestCopyWith<$Res> {
  factory _$$BackupManifestImplCopyWith(
    _$BackupManifestImpl value,
    $Res Function(_$BackupManifestImpl) then,
  ) = __$$BackupManifestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int version,
    DateTime exportedAt,
    String deviceId,
    String appVersion,
    List<BackupItem> items,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$BackupManifestImplCopyWithImpl<$Res>
    extends _$BackupManifestCopyWithImpl<$Res, _$BackupManifestImpl>
    implements _$$BackupManifestImplCopyWith<$Res> {
  __$$BackupManifestImplCopyWithImpl(
    _$BackupManifestImpl _value,
    $Res Function(_$BackupManifestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupManifest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? exportedAt = null,
    Object? deviceId = null,
    Object? appVersion = null,
    Object? items = null,
    Object? metadata = null,
  }) {
    return _then(
      _$BackupManifestImpl(
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        exportedAt: null == exportedAt
            ? _value.exportedAt
            : exportedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        appVersion: null == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<BackupItem>,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupManifestImpl implements _BackupManifest {
  const _$BackupManifestImpl({
    this.version = 1,
    required this.exportedAt,
    required this.deviceId,
    required this.appVersion,
    required final List<BackupItem> items,
    final Map<String, dynamic> metadata = const {},
  }) : _items = items,
       _metadata = metadata;

  factory _$BackupManifestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupManifestImplFromJson(json);

  @override
  @JsonKey()
  final int version;
  @override
  final DateTime exportedAt;
  @override
  final String deviceId;
  @override
  final String appVersion;
  final List<BackupItem> _items;
  @override
  List<BackupItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'BackupManifest(version: $version, exportedAt: $exportedAt, deviceId: $deviceId, appVersion: $appVersion, items: $items, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupManifestImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.exportedAt, exportedAt) ||
                other.exportedAt == exportedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    exportedAt,
    deviceId,
    appVersion,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupManifest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupManifestImplCopyWith<_$BackupManifestImpl> get copyWith =>
      __$$BackupManifestImplCopyWithImpl<_$BackupManifestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupManifestImplToJson(this);
  }
}

abstract class _BackupManifest implements BackupManifest {
  const factory _BackupManifest({
    final int version,
    required final DateTime exportedAt,
    required final String deviceId,
    required final String appVersion,
    required final List<BackupItem> items,
    final Map<String, dynamic> metadata,
  }) = _$BackupManifestImpl;

  factory _BackupManifest.fromJson(Map<String, dynamic> json) =
      _$BackupManifestImpl.fromJson;

  @override
  int get version;
  @override
  DateTime get exportedAt;
  @override
  String get deviceId;
  @override
  String get appVersion;
  @override
  List<BackupItem> get items;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of BackupManifest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupManifestImplCopyWith<_$BackupManifestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupItem _$BackupItemFromJson(Map<String, dynamic> json) {
  return _BackupItem.fromJson(json);
}

/// @nodoc
mixin _$BackupItem {
  String get id => throw _privateConstructorUsedError;
  String get relativePath => throw _privateConstructorUsedError;
  String get thumbPath => throw _privateConstructorUsedError;
  String get checksumSha256 => throw _privateConstructorUsedError;
  int get byteSize => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  DateTime? get exifTs => throw _privateConstructorUsedError;
  int get sortIndex => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this BackupItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupItemCopyWith<BackupItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupItemCopyWith<$Res> {
  factory $BackupItemCopyWith(
    BackupItem value,
    $Res Function(BackupItem) then,
  ) = _$BackupItemCopyWithImpl<$Res, BackupItem>;
  @useResult
  $Res call({
    String id,
    String relativePath,
    String thumbPath,
    String checksumSha256,
    int byteSize,
    DateTime createdAt,
    int width,
    int height,
    DateTime? exifTs,
    int sortIndex,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$BackupItemCopyWithImpl<$Res, $Val extends BackupItem>
    implements $BackupItemCopyWith<$Res> {
  _$BackupItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? relativePath = null,
    Object? thumbPath = null,
    Object? checksumSha256 = null,
    Object? byteSize = null,
    Object? createdAt = null,
    Object? width = null,
    Object? height = null,
    Object? exifTs = freezed,
    Object? sortIndex = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            relativePath: null == relativePath
                ? _value.relativePath
                : relativePath // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbPath: null == thumbPath
                ? _value.thumbPath
                : thumbPath // ignore: cast_nullable_to_non_nullable
                      as String,
            checksumSha256: null == checksumSha256
                ? _value.checksumSha256
                : checksumSha256 // ignore: cast_nullable_to_non_nullable
                      as String,
            byteSize: null == byteSize
                ? _value.byteSize
                : byteSize // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int,
            exifTs: freezed == exifTs
                ? _value.exifTs
                : exifTs // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sortIndex: null == sortIndex
                ? _value.sortIndex
                : sortIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupItemImplCopyWith<$Res>
    implements $BackupItemCopyWith<$Res> {
  factory _$$BackupItemImplCopyWith(
    _$BackupItemImpl value,
    $Res Function(_$BackupItemImpl) then,
  ) = __$$BackupItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String relativePath,
    String thumbPath,
    String checksumSha256,
    int byteSize,
    DateTime createdAt,
    int width,
    int height,
    DateTime? exifTs,
    int sortIndex,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$BackupItemImplCopyWithImpl<$Res>
    extends _$BackupItemCopyWithImpl<$Res, _$BackupItemImpl>
    implements _$$BackupItemImplCopyWith<$Res> {
  __$$BackupItemImplCopyWithImpl(
    _$BackupItemImpl _value,
    $Res Function(_$BackupItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? relativePath = null,
    Object? thumbPath = null,
    Object? checksumSha256 = null,
    Object? byteSize = null,
    Object? createdAt = null,
    Object? width = null,
    Object? height = null,
    Object? exifTs = freezed,
    Object? sortIndex = null,
    Object? metadata = null,
  }) {
    return _then(
      _$BackupItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        relativePath: null == relativePath
            ? _value.relativePath
            : relativePath // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbPath: null == thumbPath
            ? _value.thumbPath
            : thumbPath // ignore: cast_nullable_to_non_nullable
                  as String,
        checksumSha256: null == checksumSha256
            ? _value.checksumSha256
            : checksumSha256 // ignore: cast_nullable_to_non_nullable
                  as String,
        byteSize: null == byteSize
            ? _value.byteSize
            : byteSize // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int,
        exifTs: freezed == exifTs
            ? _value.exifTs
            : exifTs // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sortIndex: null == sortIndex
            ? _value.sortIndex
            : sortIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupItemImpl implements _BackupItem {
  const _$BackupItemImpl({
    required this.id,
    required this.relativePath,
    required this.thumbPath,
    required this.checksumSha256,
    required this.byteSize,
    required this.createdAt,
    required this.width,
    required this.height,
    this.exifTs,
    required this.sortIndex,
    final Map<String, dynamic> metadata = const {},
  }) : _metadata = metadata;

  factory _$BackupItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupItemImplFromJson(json);

  @override
  final String id;
  @override
  final String relativePath;
  @override
  final String thumbPath;
  @override
  final String checksumSha256;
  @override
  final int byteSize;
  @override
  final DateTime createdAt;
  @override
  final int width;
  @override
  final int height;
  @override
  final DateTime? exifTs;
  @override
  final int sortIndex;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'BackupItem(id: $id, relativePath: $relativePath, thumbPath: $thumbPath, checksumSha256: $checksumSha256, byteSize: $byteSize, createdAt: $createdAt, width: $width, height: $height, exifTs: $exifTs, sortIndex: $sortIndex, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.relativePath, relativePath) ||
                other.relativePath == relativePath) &&
            (identical(other.thumbPath, thumbPath) ||
                other.thumbPath == thumbPath) &&
            (identical(other.checksumSha256, checksumSha256) ||
                other.checksumSha256 == checksumSha256) &&
            (identical(other.byteSize, byteSize) ||
                other.byteSize == byteSize) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.exifTs, exifTs) || other.exifTs == exifTs) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    relativePath,
    thumbPath,
    checksumSha256,
    byteSize,
    createdAt,
    width,
    height,
    exifTs,
    sortIndex,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupItemImplCopyWith<_$BackupItemImpl> get copyWith =>
      __$$BackupItemImplCopyWithImpl<_$BackupItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupItemImplToJson(this);
  }
}

abstract class _BackupItem implements BackupItem {
  const factory _BackupItem({
    required final String id,
    required final String relativePath,
    required final String thumbPath,
    required final String checksumSha256,
    required final int byteSize,
    required final DateTime createdAt,
    required final int width,
    required final int height,
    final DateTime? exifTs,
    required final int sortIndex,
    final Map<String, dynamic> metadata,
  }) = _$BackupItemImpl;

  factory _BackupItem.fromJson(Map<String, dynamic> json) =
      _$BackupItemImpl.fromJson;

  @override
  String get id;
  @override
  String get relativePath;
  @override
  String get thumbPath;
  @override
  String get checksumSha256;
  @override
  int get byteSize;
  @override
  DateTime get createdAt;
  @override
  int get width;
  @override
  int get height;
  @override
  DateTime? get exifTs;
  @override
  int get sortIndex;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of BackupItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupItemImplCopyWith<_$BackupItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BackupState {
  BackupStatus get status => throw _privateConstructorUsedError;
  BackupPhase? get phase => throw _privateConstructorUsedError;
  int get current => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get bytesProcessed => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  BackupResult? get lastResult => throw _privateConstructorUsedError;
  String? get currentFile => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get cloudFolderUri => throw _privateConstructorUsedError;
  String? get cloudFolderName => throw _privateConstructorUsedError;
  DateTime? get lastBackupDate => throw _privateConstructorUsedError;
  bool get isCancelled => throw _privateConstructorUsedError;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupStateCopyWith<BackupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupStateCopyWith<$Res> {
  factory $BackupStateCopyWith(
    BackupState value,
    $Res Function(BackupState) then,
  ) = _$BackupStateCopyWithImpl<$Res, BackupState>;
  @useResult
  $Res call({
    BackupStatus status,
    BackupPhase? phase,
    int current,
    int total,
    int bytesProcessed,
    int totalBytes,
    BackupResult? lastResult,
    String? currentFile,
    String? error,
    String? cloudFolderUri,
    String? cloudFolderName,
    DateTime? lastBackupDate,
    bool isCancelled,
  });

  $BackupResultCopyWith<$Res>? get lastResult;
}

/// @nodoc
class _$BackupStateCopyWithImpl<$Res, $Val extends BackupState>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? phase = freezed,
    Object? current = null,
    Object? total = null,
    Object? bytesProcessed = null,
    Object? totalBytes = null,
    Object? lastResult = freezed,
    Object? currentFile = freezed,
    Object? error = freezed,
    Object? cloudFolderUri = freezed,
    Object? cloudFolderName = freezed,
    Object? lastBackupDate = freezed,
    Object? isCancelled = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BackupStatus,
            phase: freezed == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as BackupPhase?,
            current: null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            bytesProcessed: null == bytesProcessed
                ? _value.bytesProcessed
                : bytesProcessed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            lastResult: freezed == lastResult
                ? _value.lastResult
                : lastResult // ignore: cast_nullable_to_non_nullable
                      as BackupResult?,
            currentFile: freezed == currentFile
                ? _value.currentFile
                : currentFile // ignore: cast_nullable_to_non_nullable
                      as String?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            cloudFolderUri: freezed == cloudFolderUri
                ? _value.cloudFolderUri
                : cloudFolderUri // ignore: cast_nullable_to_non_nullable
                      as String?,
            cloudFolderName: freezed == cloudFolderName
                ? _value.cloudFolderName
                : cloudFolderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastBackupDate: freezed == lastBackupDate
                ? _value.lastBackupDate
                : lastBackupDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCancelled: null == isCancelled
                ? _value.isCancelled
                : isCancelled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackupResultCopyWith<$Res>? get lastResult {
    if (_value.lastResult == null) {
      return null;
    }

    return $BackupResultCopyWith<$Res>(_value.lastResult!, (value) {
      return _then(_value.copyWith(lastResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BackupStateImplCopyWith<$Res>
    implements $BackupStateCopyWith<$Res> {
  factory _$$BackupStateImplCopyWith(
    _$BackupStateImpl value,
    $Res Function(_$BackupStateImpl) then,
  ) = __$$BackupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BackupStatus status,
    BackupPhase? phase,
    int current,
    int total,
    int bytesProcessed,
    int totalBytes,
    BackupResult? lastResult,
    String? currentFile,
    String? error,
    String? cloudFolderUri,
    String? cloudFolderName,
    DateTime? lastBackupDate,
    bool isCancelled,
  });

  @override
  $BackupResultCopyWith<$Res>? get lastResult;
}

/// @nodoc
class __$$BackupStateImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$BackupStateImpl>
    implements _$$BackupStateImplCopyWith<$Res> {
  __$$BackupStateImplCopyWithImpl(
    _$BackupStateImpl _value,
    $Res Function(_$BackupStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? phase = freezed,
    Object? current = null,
    Object? total = null,
    Object? bytesProcessed = null,
    Object? totalBytes = null,
    Object? lastResult = freezed,
    Object? currentFile = freezed,
    Object? error = freezed,
    Object? cloudFolderUri = freezed,
    Object? cloudFolderName = freezed,
    Object? lastBackupDate = freezed,
    Object? isCancelled = null,
  }) {
    return _then(
      _$BackupStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BackupStatus,
        phase: freezed == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as BackupPhase?,
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        bytesProcessed: null == bytesProcessed
            ? _value.bytesProcessed
            : bytesProcessed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        lastResult: freezed == lastResult
            ? _value.lastResult
            : lastResult // ignore: cast_nullable_to_non_nullable
                  as BackupResult?,
        currentFile: freezed == currentFile
            ? _value.currentFile
            : currentFile // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        cloudFolderUri: freezed == cloudFolderUri
            ? _value.cloudFolderUri
            : cloudFolderUri // ignore: cast_nullable_to_non_nullable
                  as String?,
        cloudFolderName: freezed == cloudFolderName
            ? _value.cloudFolderName
            : cloudFolderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastBackupDate: freezed == lastBackupDate
            ? _value.lastBackupDate
            : lastBackupDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCancelled: null == isCancelled
            ? _value.isCancelled
            : isCancelled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$BackupStateImpl extends _BackupState {
  const _$BackupStateImpl({
    this.status = BackupStatus.idle,
    this.phase,
    this.current = 0,
    this.total = 0,
    this.bytesProcessed = 0,
    this.totalBytes = 0,
    this.lastResult,
    this.currentFile,
    this.error,
    this.cloudFolderUri,
    this.cloudFolderName,
    this.lastBackupDate,
    this.isCancelled = false,
  }) : super._();

  @override
  @JsonKey()
  final BackupStatus status;
  @override
  final BackupPhase? phase;
  @override
  @JsonKey()
  final int current;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int bytesProcessed;
  @override
  @JsonKey()
  final int totalBytes;
  @override
  final BackupResult? lastResult;
  @override
  final String? currentFile;
  @override
  final String? error;
  @override
  final String? cloudFolderUri;
  @override
  final String? cloudFolderName;
  @override
  final DateTime? lastBackupDate;
  @override
  @JsonKey()
  final bool isCancelled;

  @override
  String toString() {
    return 'BackupState(status: $status, phase: $phase, current: $current, total: $total, bytesProcessed: $bytesProcessed, totalBytes: $totalBytes, lastResult: $lastResult, currentFile: $currentFile, error: $error, cloudFolderUri: $cloudFolderUri, cloudFolderName: $cloudFolderName, lastBackupDate: $lastBackupDate, isCancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.bytesProcessed, bytesProcessed) ||
                other.bytesProcessed == bytesProcessed) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult) &&
            (identical(other.currentFile, currentFile) ||
                other.currentFile == currentFile) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.cloudFolderUri, cloudFolderUri) ||
                other.cloudFolderUri == cloudFolderUri) &&
            (identical(other.cloudFolderName, cloudFolderName) ||
                other.cloudFolderName == cloudFolderName) &&
            (identical(other.lastBackupDate, lastBackupDate) ||
                other.lastBackupDate == lastBackupDate) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    phase,
    current,
    total,
    bytesProcessed,
    totalBytes,
    lastResult,
    currentFile,
    error,
    cloudFolderUri,
    cloudFolderName,
    lastBackupDate,
    isCancelled,
  );

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupStateImplCopyWith<_$BackupStateImpl> get copyWith =>
      __$$BackupStateImplCopyWithImpl<_$BackupStateImpl>(this, _$identity);
}

abstract class _BackupState extends BackupState {
  const factory _BackupState({
    final BackupStatus status,
    final BackupPhase? phase,
    final int current,
    final int total,
    final int bytesProcessed,
    final int totalBytes,
    final BackupResult? lastResult,
    final String? currentFile,
    final String? error,
    final String? cloudFolderUri,
    final String? cloudFolderName,
    final DateTime? lastBackupDate,
    final bool isCancelled,
  }) = _$BackupStateImpl;
  const _BackupState._() : super._();

  @override
  BackupStatus get status;
  @override
  BackupPhase? get phase;
  @override
  int get current;
  @override
  int get total;
  @override
  int get bytesProcessed;
  @override
  int get totalBytes;
  @override
  BackupResult? get lastResult;
  @override
  String? get currentFile;
  @override
  String? get error;
  @override
  String? get cloudFolderUri;
  @override
  String? get cloudFolderName;
  @override
  DateTime? get lastBackupDate;
  @override
  bool get isCancelled;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupStateImplCopyWith<_$BackupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BackupResult {
  int get operationsProcessed => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  Duration get processingTime => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of BackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupResultCopyWith<BackupResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupResultCopyWith<$Res> {
  factory $BackupResultCopyWith(
    BackupResult value,
    $Res Function(BackupResult) then,
  ) = _$BackupResultCopyWithImpl<$Res, BackupResult>;
  @useResult
  $Res call({
    int operationsProcessed,
    int successCount,
    int failureCount,
    Duration processingTime,
    List<String> errors,
    List<String> warnings,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$BackupResultCopyWithImpl<$Res, $Val extends BackupResult>
    implements $BackupResultCopyWith<$Res> {
  _$BackupResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationsProcessed = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? processingTime = null,
    Object? errors = null,
    Object? warnings = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            operationsProcessed: null == operationsProcessed
                ? _value.operationsProcessed
                : operationsProcessed // ignore: cast_nullable_to_non_nullable
                      as int,
            successCount: null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failureCount: null == failureCount
                ? _value.failureCount
                : failureCount // ignore: cast_nullable_to_non_nullable
                      as int,
            processingTime: null == processingTime
                ? _value.processingTime
                : processingTime // ignore: cast_nullable_to_non_nullable
                      as Duration,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            warnings: null == warnings
                ? _value.warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupResultImplCopyWith<$Res>
    implements $BackupResultCopyWith<$Res> {
  factory _$$BackupResultImplCopyWith(
    _$BackupResultImpl value,
    $Res Function(_$BackupResultImpl) then,
  ) = __$$BackupResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int operationsProcessed,
    int successCount,
    int failureCount,
    Duration processingTime,
    List<String> errors,
    List<String> warnings,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$BackupResultImplCopyWithImpl<$Res>
    extends _$BackupResultCopyWithImpl<$Res, _$BackupResultImpl>
    implements _$$BackupResultImplCopyWith<$Res> {
  __$$BackupResultImplCopyWithImpl(
    _$BackupResultImpl _value,
    $Res Function(_$BackupResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationsProcessed = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? processingTime = null,
    Object? errors = null,
    Object? warnings = null,
    Object? metadata = null,
  }) {
    return _then(
      _$BackupResultImpl(
        operationsProcessed: null == operationsProcessed
            ? _value.operationsProcessed
            : operationsProcessed // ignore: cast_nullable_to_non_nullable
                  as int,
        successCount: null == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failureCount: null == failureCount
            ? _value.failureCount
            : failureCount // ignore: cast_nullable_to_non_nullable
                  as int,
        processingTime: null == processingTime
            ? _value.processingTime
            : processingTime // ignore: cast_nullable_to_non_nullable
                  as Duration,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        warnings: null == warnings
            ? _value._warnings
            : warnings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$BackupResultImpl extends _BackupResult {
  const _$BackupResultImpl({
    required this.operationsProcessed,
    required this.successCount,
    required this.failureCount,
    required this.processingTime,
    final List<String> errors = const [],
    final List<String> warnings = const [],
    final Map<String, dynamic> metadata = const {},
  }) : _errors = errors,
       _warnings = warnings,
       _metadata = metadata,
       super._();

  @override
  final int operationsProcessed;
  @override
  final int successCount;
  @override
  final int failureCount;
  @override
  final Duration processingTime;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'BackupResult(operationsProcessed: $operationsProcessed, successCount: $successCount, failureCount: $failureCount, processingTime: $processingTime, errors: $errors, warnings: $warnings, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupResultImpl &&
            (identical(other.operationsProcessed, operationsProcessed) ||
                other.operationsProcessed == operationsProcessed) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            (identical(other.processingTime, processingTime) ||
                other.processingTime == processingTime) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    operationsProcessed,
    successCount,
    failureCount,
    processingTime,
    const DeepCollectionEquality().hash(_errors),
    const DeepCollectionEquality().hash(_warnings),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupResultImplCopyWith<_$BackupResultImpl> get copyWith =>
      __$$BackupResultImplCopyWithImpl<_$BackupResultImpl>(this, _$identity);
}

abstract class _BackupResult extends BackupResult {
  const factory _BackupResult({
    required final int operationsProcessed,
    required final int successCount,
    required final int failureCount,
    required final Duration processingTime,
    final List<String> errors,
    final List<String> warnings,
    final Map<String, dynamic> metadata,
  }) = _$BackupResultImpl;
  const _BackupResult._() : super._();

  @override
  int get operationsProcessed;
  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  Duration get processingTime;
  @override
  List<String> get errors;
  @override
  List<String> get warnings;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of BackupResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupResultImplCopyWith<_$BackupResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SafEntry _$SafEntryFromJson(Map<String, dynamic> json) {
  return _SafEntry.fromJson(json);
}

/// @nodoc
mixin _$SafEntry {
  String get name => throw _privateConstructorUsedError;
  SafEntryType get type => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  DateTime get lastModified => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;

  /// Serializes this SafEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SafEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SafEntryCopyWith<SafEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SafEntryCopyWith<$Res> {
  factory $SafEntryCopyWith(SafEntry value, $Res Function(SafEntry) then) =
      _$SafEntryCopyWithImpl<$Res, SafEntry>;
  @useResult
  $Res call({
    String name,
    SafEntryType type,
    int size,
    DateTime lastModified,
    String? mimeType,
  });
}

/// @nodoc
class _$SafEntryCopyWithImpl<$Res, $Val extends SafEntry>
    implements $SafEntryCopyWith<$Res> {
  _$SafEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SafEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? size = null,
    Object? lastModified = null,
    Object? mimeType = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SafEntryType,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            lastModified: null == lastModified
                ? _value.lastModified
                : lastModified // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SafEntryImplCopyWith<$Res>
    implements $SafEntryCopyWith<$Res> {
  factory _$$SafEntryImplCopyWith(
    _$SafEntryImpl value,
    $Res Function(_$SafEntryImpl) then,
  ) = __$$SafEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    SafEntryType type,
    int size,
    DateTime lastModified,
    String? mimeType,
  });
}

/// @nodoc
class __$$SafEntryImplCopyWithImpl<$Res>
    extends _$SafEntryCopyWithImpl<$Res, _$SafEntryImpl>
    implements _$$SafEntryImplCopyWith<$Res> {
  __$$SafEntryImplCopyWithImpl(
    _$SafEntryImpl _value,
    $Res Function(_$SafEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SafEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? size = null,
    Object? lastModified = null,
    Object? mimeType = freezed,
  }) {
    return _then(
      _$SafEntryImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SafEntryType,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        lastModified: null == lastModified
            ? _value.lastModified
            : lastModified // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SafEntryImpl implements _SafEntry {
  const _$SafEntryImpl({
    required this.name,
    required this.type,
    required this.size,
    required this.lastModified,
    this.mimeType,
  });

  factory _$SafEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SafEntryImplFromJson(json);

  @override
  final String name;
  @override
  final SafEntryType type;
  @override
  final int size;
  @override
  final DateTime lastModified;
  @override
  final String? mimeType;

  @override
  String toString() {
    return 'SafEntry(name: $name, type: $type, size: $size, lastModified: $lastModified, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SafEntryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, type, size, lastModified, mimeType);

  /// Create a copy of SafEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SafEntryImplCopyWith<_$SafEntryImpl> get copyWith =>
      __$$SafEntryImplCopyWithImpl<_$SafEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SafEntryImplToJson(this);
  }
}

abstract class _SafEntry implements SafEntry {
  const factory _SafEntry({
    required final String name,
    required final SafEntryType type,
    required final int size,
    required final DateTime lastModified,
    final String? mimeType,
  }) = _$SafEntryImpl;

  factory _SafEntry.fromJson(Map<String, dynamic> json) =
      _$SafEntryImpl.fromJson;

  @override
  String get name;
  @override
  SafEntryType get type;
  @override
  int get size;
  @override
  DateTime get lastModified;
  @override
  String? get mimeType;

  /// Create a copy of SafEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SafEntryImplCopyWith<_$SafEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ManifestValidation {
  bool get isValid => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  int get itemCount => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  List<String> get missingFiles => throw _privateConstructorUsedError;
  DateTime? get exportedAt => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;

  /// Create a copy of ManifestValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManifestValidationCopyWith<ManifestValidation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManifestValidationCopyWith<$Res> {
  factory $ManifestValidationCopyWith(
    ManifestValidation value,
    $Res Function(ManifestValidation) then,
  ) = _$ManifestValidationCopyWithImpl<$Res, ManifestValidation>;
  @useResult
  $Res call({
    bool isValid,
    int version,
    int itemCount,
    List<String> errors,
    List<String> warnings,
    List<String> missingFiles,
    DateTime? exportedAt,
    String? deviceId,
  });
}

/// @nodoc
class _$ManifestValidationCopyWithImpl<$Res, $Val extends ManifestValidation>
    implements $ManifestValidationCopyWith<$Res> {
  _$ManifestValidationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManifestValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? version = null,
    Object? itemCount = null,
    Object? errors = null,
    Object? warnings = null,
    Object? missingFiles = null,
    Object? exportedAt = freezed,
    Object? deviceId = freezed,
  }) {
    return _then(
      _value.copyWith(
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            itemCount: null == itemCount
                ? _value.itemCount
                : itemCount // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            warnings: null == warnings
                ? _value.warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            missingFiles: null == missingFiles
                ? _value.missingFiles
                : missingFiles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            exportedAt: freezed == exportedAt
                ? _value.exportedAt
                : exportedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deviceId: freezed == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ManifestValidationImplCopyWith<$Res>
    implements $ManifestValidationCopyWith<$Res> {
  factory _$$ManifestValidationImplCopyWith(
    _$ManifestValidationImpl value,
    $Res Function(_$ManifestValidationImpl) then,
  ) = __$$ManifestValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isValid,
    int version,
    int itemCount,
    List<String> errors,
    List<String> warnings,
    List<String> missingFiles,
    DateTime? exportedAt,
    String? deviceId,
  });
}

/// @nodoc
class __$$ManifestValidationImplCopyWithImpl<$Res>
    extends _$ManifestValidationCopyWithImpl<$Res, _$ManifestValidationImpl>
    implements _$$ManifestValidationImplCopyWith<$Res> {
  __$$ManifestValidationImplCopyWithImpl(
    _$ManifestValidationImpl _value,
    $Res Function(_$ManifestValidationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ManifestValidation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? version = null,
    Object? itemCount = null,
    Object? errors = null,
    Object? warnings = null,
    Object? missingFiles = null,
    Object? exportedAt = freezed,
    Object? deviceId = freezed,
  }) {
    return _then(
      _$ManifestValidationImpl(
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        itemCount: null == itemCount
            ? _value.itemCount
            : itemCount // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        warnings: null == warnings
            ? _value._warnings
            : warnings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        missingFiles: null == missingFiles
            ? _value._missingFiles
            : missingFiles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        exportedAt: freezed == exportedAt
            ? _value.exportedAt
            : exportedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deviceId: freezed == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ManifestValidationImpl extends _ManifestValidation {
  const _$ManifestValidationImpl({
    required this.isValid,
    required this.version,
    required this.itemCount,
    final List<String> errors = const [],
    final List<String> warnings = const [],
    final List<String> missingFiles = const [],
    this.exportedAt,
    this.deviceId,
  }) : _errors = errors,
       _warnings = warnings,
       _missingFiles = missingFiles,
       super._();

  @override
  final bool isValid;
  @override
  final int version;
  @override
  final int itemCount;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  final List<String> _missingFiles;
  @override
  @JsonKey()
  List<String> get missingFiles {
    if (_missingFiles is EqualUnmodifiableListView) return _missingFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_missingFiles);
  }

  @override
  final DateTime? exportedAt;
  @override
  final String? deviceId;

  @override
  String toString() {
    return 'ManifestValidation(isValid: $isValid, version: $version, itemCount: $itemCount, errors: $errors, warnings: $warnings, missingFiles: $missingFiles, exportedAt: $exportedAt, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManifestValidationImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            const DeepCollectionEquality().equals(
              other._missingFiles,
              _missingFiles,
            ) &&
            (identical(other.exportedAt, exportedAt) ||
                other.exportedAt == exportedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isValid,
    version,
    itemCount,
    const DeepCollectionEquality().hash(_errors),
    const DeepCollectionEquality().hash(_warnings),
    const DeepCollectionEquality().hash(_missingFiles),
    exportedAt,
    deviceId,
  );

  /// Create a copy of ManifestValidation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManifestValidationImplCopyWith<_$ManifestValidationImpl> get copyWith =>
      __$$ManifestValidationImplCopyWithImpl<_$ManifestValidationImpl>(
        this,
        _$identity,
      );
}

abstract class _ManifestValidation extends ManifestValidation {
  const factory _ManifestValidation({
    required final bool isValid,
    required final int version,
    required final int itemCount,
    final List<String> errors,
    final List<String> warnings,
    final List<String> missingFiles,
    final DateTime? exportedAt,
    final String? deviceId,
  }) = _$ManifestValidationImpl;
  const _ManifestValidation._() : super._();

  @override
  bool get isValid;
  @override
  int get version;
  @override
  int get itemCount;
  @override
  List<String> get errors;
  @override
  List<String> get warnings;
  @override
  List<String> get missingFiles;
  @override
  DateTime? get exportedAt;
  @override
  String? get deviceId;

  /// Create a copy of ManifestValidation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManifestValidationImplCopyWith<_$ManifestValidationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$StreamProgress {
  String get fileName => throw _privateConstructorUsedError;
  int get bytesTransferred => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// Create a copy of StreamProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamProgressCopyWith<StreamProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamProgressCopyWith<$Res> {
  factory $StreamProgressCopyWith(
    StreamProgress value,
    $Res Function(StreamProgress) then,
  ) = _$StreamProgressCopyWithImpl<$Res, StreamProgress>;
  @useResult
  $Res call({
    String fileName,
    int bytesTransferred,
    int totalBytes,
    DateTime startTime,
    DateTime? endTime,
  });
}

/// @nodoc
class _$StreamProgressCopyWithImpl<$Res, $Val extends StreamProgress>
    implements $StreamProgressCopyWith<$Res> {
  _$StreamProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? startTime = null,
    Object? endTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            bytesTransferred: null == bytesTransferred
                ? _value.bytesTransferred
                : bytesTransferred // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StreamProgressImplCopyWith<$Res>
    implements $StreamProgressCopyWith<$Res> {
  factory _$$StreamProgressImplCopyWith(
    _$StreamProgressImpl value,
    $Res Function(_$StreamProgressImpl) then,
  ) = __$$StreamProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fileName,
    int bytesTransferred,
    int totalBytes,
    DateTime startTime,
    DateTime? endTime,
  });
}

/// @nodoc
class __$$StreamProgressImplCopyWithImpl<$Res>
    extends _$StreamProgressCopyWithImpl<$Res, _$StreamProgressImpl>
    implements _$$StreamProgressImplCopyWith<$Res> {
  __$$StreamProgressImplCopyWithImpl(
    _$StreamProgressImpl _value,
    $Res Function(_$StreamProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StreamProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? bytesTransferred = null,
    Object? totalBytes = null,
    Object? startTime = null,
    Object? endTime = freezed,
  }) {
    return _then(
      _$StreamProgressImpl(
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        bytesTransferred: null == bytesTransferred
            ? _value.bytesTransferred
            : bytesTransferred // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$StreamProgressImpl extends _StreamProgress {
  const _$StreamProgressImpl({
    required this.fileName,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.startTime,
    this.endTime,
  }) : super._();

  @override
  final String fileName;
  @override
  final int bytesTransferred;
  @override
  final int totalBytes;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;

  @override
  String toString() {
    return 'StreamProgress(fileName: $fileName, bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamProgressImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.bytesTransferred, bytesTransferred) ||
                other.bytesTransferred == bytesTransferred) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fileName,
    bytesTransferred,
    totalBytes,
    startTime,
    endTime,
  );

  /// Create a copy of StreamProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamProgressImplCopyWith<_$StreamProgressImpl> get copyWith =>
      __$$StreamProgressImplCopyWithImpl<_$StreamProgressImpl>(
        this,
        _$identity,
      );
}

abstract class _StreamProgress extends StreamProgress {
  const factory _StreamProgress({
    required final String fileName,
    required final int bytesTransferred,
    required final int totalBytes,
    required final DateTime startTime,
    final DateTime? endTime,
  }) = _$StreamProgressImpl;
  const _StreamProgress._() : super._();

  @override
  String get fileName;
  @override
  int get bytesTransferred;
  @override
  int get totalBytes;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;

  /// Create a copy of StreamProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamProgressImplCopyWith<_$StreamProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupConfig _$BackupConfigFromJson(Map<String, dynamic> json) {
  return _BackupConfig.fromJson(json);
}

/// @nodoc
mixin _$BackupConfig {
  int get chunkSize =>
      throw _privateConstructorUsedError; // 64KB chunks for streaming
  int get maxConcurrency =>
      throw _privateConstructorUsedError; // Max concurrent file operations
  bool get includeOriginals => throw _privateConstructorUsedError;
  bool get includeThumbnails => throw _privateConstructorUsedError;
  bool get validateChecksums => throw _privateConstructorUsedError;
  bool get skipExisting =>
      throw _privateConstructorUsedError; // Skip files that already exist
  bool get verboseLogging => throw _privateConstructorUsedError;
  String get cloudFolderName => throw _privateConstructorUsedError;

  /// Serializes this BackupConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupConfigCopyWith<BackupConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupConfigCopyWith<$Res> {
  factory $BackupConfigCopyWith(
    BackupConfig value,
    $Res Function(BackupConfig) then,
  ) = _$BackupConfigCopyWithImpl<$Res, BackupConfig>;
  @useResult
  $Res call({
    int chunkSize,
    int maxConcurrency,
    bool includeOriginals,
    bool includeThumbnails,
    bool validateChecksums,
    bool skipExisting,
    bool verboseLogging,
    String cloudFolderName,
  });
}

/// @nodoc
class _$BackupConfigCopyWithImpl<$Res, $Val extends BackupConfig>
    implements $BackupConfigCopyWith<$Res> {
  _$BackupConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkSize = null,
    Object? maxConcurrency = null,
    Object? includeOriginals = null,
    Object? includeThumbnails = null,
    Object? validateChecksums = null,
    Object? skipExisting = null,
    Object? verboseLogging = null,
    Object? cloudFolderName = null,
  }) {
    return _then(
      _value.copyWith(
            chunkSize: null == chunkSize
                ? _value.chunkSize
                : chunkSize // ignore: cast_nullable_to_non_nullable
                      as int,
            maxConcurrency: null == maxConcurrency
                ? _value.maxConcurrency
                : maxConcurrency // ignore: cast_nullable_to_non_nullable
                      as int,
            includeOriginals: null == includeOriginals
                ? _value.includeOriginals
                : includeOriginals // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeThumbnails: null == includeThumbnails
                ? _value.includeThumbnails
                : includeThumbnails // ignore: cast_nullable_to_non_nullable
                      as bool,
            validateChecksums: null == validateChecksums
                ? _value.validateChecksums
                : validateChecksums // ignore: cast_nullable_to_non_nullable
                      as bool,
            skipExisting: null == skipExisting
                ? _value.skipExisting
                : skipExisting // ignore: cast_nullable_to_non_nullable
                      as bool,
            verboseLogging: null == verboseLogging
                ? _value.verboseLogging
                : verboseLogging // ignore: cast_nullable_to_non_nullable
                      as bool,
            cloudFolderName: null == cloudFolderName
                ? _value.cloudFolderName
                : cloudFolderName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupConfigImplCopyWith<$Res>
    implements $BackupConfigCopyWith<$Res> {
  factory _$$BackupConfigImplCopyWith(
    _$BackupConfigImpl value,
    $Res Function(_$BackupConfigImpl) then,
  ) = __$$BackupConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int chunkSize,
    int maxConcurrency,
    bool includeOriginals,
    bool includeThumbnails,
    bool validateChecksums,
    bool skipExisting,
    bool verboseLogging,
    String cloudFolderName,
  });
}

/// @nodoc
class __$$BackupConfigImplCopyWithImpl<$Res>
    extends _$BackupConfigCopyWithImpl<$Res, _$BackupConfigImpl>
    implements _$$BackupConfigImplCopyWith<$Res> {
  __$$BackupConfigImplCopyWithImpl(
    _$BackupConfigImpl _value,
    $Res Function(_$BackupConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkSize = null,
    Object? maxConcurrency = null,
    Object? includeOriginals = null,
    Object? includeThumbnails = null,
    Object? validateChecksums = null,
    Object? skipExisting = null,
    Object? verboseLogging = null,
    Object? cloudFolderName = null,
  }) {
    return _then(
      _$BackupConfigImpl(
        chunkSize: null == chunkSize
            ? _value.chunkSize
            : chunkSize // ignore: cast_nullable_to_non_nullable
                  as int,
        maxConcurrency: null == maxConcurrency
            ? _value.maxConcurrency
            : maxConcurrency // ignore: cast_nullable_to_non_nullable
                  as int,
        includeOriginals: null == includeOriginals
            ? _value.includeOriginals
            : includeOriginals // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeThumbnails: null == includeThumbnails
            ? _value.includeThumbnails
            : includeThumbnails // ignore: cast_nullable_to_non_nullable
                  as bool,
        validateChecksums: null == validateChecksums
            ? _value.validateChecksums
            : validateChecksums // ignore: cast_nullable_to_non_nullable
                  as bool,
        skipExisting: null == skipExisting
            ? _value.skipExisting
            : skipExisting // ignore: cast_nullable_to_non_nullable
                  as bool,
        verboseLogging: null == verboseLogging
            ? _value.verboseLogging
            : verboseLogging // ignore: cast_nullable_to_non_nullable
                  as bool,
        cloudFolderName: null == cloudFolderName
            ? _value.cloudFolderName
            : cloudFolderName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupConfigImpl implements _BackupConfig {
  const _$BackupConfigImpl({
    this.chunkSize = 64 * 1024,
    this.maxConcurrency = 2,
    this.includeOriginals = true,
    this.includeThumbnails = true,
    this.validateChecksums = true,
    this.skipExisting = false,
    this.verboseLogging = false,
    this.cloudFolderName = 'Grid',
  });

  factory _$BackupConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupConfigImplFromJson(json);

  @override
  @JsonKey()
  final int chunkSize;
  // 64KB chunks for streaming
  @override
  @JsonKey()
  final int maxConcurrency;
  // Max concurrent file operations
  @override
  @JsonKey()
  final bool includeOriginals;
  @override
  @JsonKey()
  final bool includeThumbnails;
  @override
  @JsonKey()
  final bool validateChecksums;
  @override
  @JsonKey()
  final bool skipExisting;
  // Skip files that already exist
  @override
  @JsonKey()
  final bool verboseLogging;
  @override
  @JsonKey()
  final String cloudFolderName;

  @override
  String toString() {
    return 'BackupConfig(chunkSize: $chunkSize, maxConcurrency: $maxConcurrency, includeOriginals: $includeOriginals, includeThumbnails: $includeThumbnails, validateChecksums: $validateChecksums, skipExisting: $skipExisting, verboseLogging: $verboseLogging, cloudFolderName: $cloudFolderName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupConfigImpl &&
            (identical(other.chunkSize, chunkSize) ||
                other.chunkSize == chunkSize) &&
            (identical(other.maxConcurrency, maxConcurrency) ||
                other.maxConcurrency == maxConcurrency) &&
            (identical(other.includeOriginals, includeOriginals) ||
                other.includeOriginals == includeOriginals) &&
            (identical(other.includeThumbnails, includeThumbnails) ||
                other.includeThumbnails == includeThumbnails) &&
            (identical(other.validateChecksums, validateChecksums) ||
                other.validateChecksums == validateChecksums) &&
            (identical(other.skipExisting, skipExisting) ||
                other.skipExisting == skipExisting) &&
            (identical(other.verboseLogging, verboseLogging) ||
                other.verboseLogging == verboseLogging) &&
            (identical(other.cloudFolderName, cloudFolderName) ||
                other.cloudFolderName == cloudFolderName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chunkSize,
    maxConcurrency,
    includeOriginals,
    includeThumbnails,
    validateChecksums,
    skipExisting,
    verboseLogging,
    cloudFolderName,
  );

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      __$$BackupConfigImplCopyWithImpl<_$BackupConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupConfigImplToJson(this);
  }
}

abstract class _BackupConfig implements BackupConfig {
  const factory _BackupConfig({
    final int chunkSize,
    final int maxConcurrency,
    final bool includeOriginals,
    final bool includeThumbnails,
    final bool validateChecksums,
    final bool skipExisting,
    final bool verboseLogging,
    final String cloudFolderName,
  }) = _$BackupConfigImpl;

  factory _BackupConfig.fromJson(Map<String, dynamic> json) =
      _$BackupConfigImpl.fromJson;

  @override
  int get chunkSize; // 64KB chunks for streaming
  @override
  int get maxConcurrency; // Max concurrent file operations
  @override
  bool get includeOriginals;
  @override
  bool get includeThumbnails;
  @override
  bool get validateChecksums;
  @override
  bool get skipExisting; // Skip files that already exist
  @override
  bool get verboseLogging;
  @override
  String get cloudFolderName;

  /// Create a copy of BackupConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupConfigImplCopyWith<_$BackupConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BackupCheckpoint _$BackupCheckpointFromJson(Map<String, dynamic> json) {
  return _BackupCheckpoint.fromJson(json);
}

/// @nodoc
mixin _$BackupCheckpoint {
  String get operationId => throw _privateConstructorUsedError;
  BackupPhase get phase => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;
  int get lastProcessedIndex => throw _privateConstructorUsedError;
  List<String> get processedIds => throw _privateConstructorUsedError;
  List<String> get failedIds => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this BackupCheckpoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupCheckpointCopyWith<BackupCheckpoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupCheckpointCopyWith<$Res> {
  factory $BackupCheckpointCopyWith(
    BackupCheckpoint value,
    $Res Function(BackupCheckpoint) then,
  ) = _$BackupCheckpointCopyWithImpl<$Res, BackupCheckpoint>;
  @useResult
  $Res call({
    String operationId,
    BackupPhase phase,
    DateTime startedAt,
    DateTime? lastUpdatedAt,
    int lastProcessedIndex,
    List<String> processedIds,
    List<String> failedIds,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$BackupCheckpointCopyWithImpl<$Res, $Val extends BackupCheckpoint>
    implements $BackupCheckpointCopyWith<$Res> {
  _$BackupCheckpointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationId = null,
    Object? phase = null,
    Object? startedAt = null,
    Object? lastUpdatedAt = freezed,
    Object? lastProcessedIndex = null,
    Object? processedIds = null,
    Object? failedIds = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            operationId: null == operationId
                ? _value.operationId
                : operationId // ignore: cast_nullable_to_non_nullable
                      as String,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as BackupPhase,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastUpdatedAt: freezed == lastUpdatedAt
                ? _value.lastUpdatedAt
                : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastProcessedIndex: null == lastProcessedIndex
                ? _value.lastProcessedIndex
                : lastProcessedIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            processedIds: null == processedIds
                ? _value.processedIds
                : processedIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            failedIds: null == failedIds
                ? _value.failedIds
                : failedIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupCheckpointImplCopyWith<$Res>
    implements $BackupCheckpointCopyWith<$Res> {
  factory _$$BackupCheckpointImplCopyWith(
    _$BackupCheckpointImpl value,
    $Res Function(_$BackupCheckpointImpl) then,
  ) = __$$BackupCheckpointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String operationId,
    BackupPhase phase,
    DateTime startedAt,
    DateTime? lastUpdatedAt,
    int lastProcessedIndex,
    List<String> processedIds,
    List<String> failedIds,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$BackupCheckpointImplCopyWithImpl<$Res>
    extends _$BackupCheckpointCopyWithImpl<$Res, _$BackupCheckpointImpl>
    implements _$$BackupCheckpointImplCopyWith<$Res> {
  __$$BackupCheckpointImplCopyWithImpl(
    _$BackupCheckpointImpl _value,
    $Res Function(_$BackupCheckpointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operationId = null,
    Object? phase = null,
    Object? startedAt = null,
    Object? lastUpdatedAt = freezed,
    Object? lastProcessedIndex = null,
    Object? processedIds = null,
    Object? failedIds = null,
    Object? metadata = null,
  }) {
    return _then(
      _$BackupCheckpointImpl(
        operationId: null == operationId
            ? _value.operationId
            : operationId // ignore: cast_nullable_to_non_nullable
                  as String,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as BackupPhase,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastUpdatedAt: freezed == lastUpdatedAt
            ? _value.lastUpdatedAt
            : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastProcessedIndex: null == lastProcessedIndex
            ? _value.lastProcessedIndex
            : lastProcessedIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        processedIds: null == processedIds
            ? _value._processedIds
            : processedIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        failedIds: null == failedIds
            ? _value._failedIds
            : failedIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupCheckpointImpl extends _BackupCheckpoint {
  const _$BackupCheckpointImpl({
    required this.operationId,
    required this.phase,
    required this.startedAt,
    this.lastUpdatedAt,
    required this.lastProcessedIndex,
    required final List<String> processedIds,
    required final List<String> failedIds,
    final Map<String, dynamic> metadata = const {},
  }) : _processedIds = processedIds,
       _failedIds = failedIds,
       _metadata = metadata,
       super._();

  factory _$BackupCheckpointImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupCheckpointImplFromJson(json);

  @override
  final String operationId;
  @override
  final BackupPhase phase;
  @override
  final DateTime startedAt;
  @override
  final DateTime? lastUpdatedAt;
  @override
  final int lastProcessedIndex;
  final List<String> _processedIds;
  @override
  List<String> get processedIds {
    if (_processedIds is EqualUnmodifiableListView) return _processedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_processedIds);
  }

  final List<String> _failedIds;
  @override
  List<String> get failedIds {
    if (_failedIds is EqualUnmodifiableListView) return _failedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failedIds);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'BackupCheckpoint(operationId: $operationId, phase: $phase, startedAt: $startedAt, lastUpdatedAt: $lastUpdatedAt, lastProcessedIndex: $lastProcessedIndex, processedIds: $processedIds, failedIds: $failedIds, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupCheckpointImpl &&
            (identical(other.operationId, operationId) ||
                other.operationId == operationId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt) &&
            (identical(other.lastProcessedIndex, lastProcessedIndex) ||
                other.lastProcessedIndex == lastProcessedIndex) &&
            const DeepCollectionEquality().equals(
              other._processedIds,
              _processedIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._failedIds,
              _failedIds,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    operationId,
    phase,
    startedAt,
    lastUpdatedAt,
    lastProcessedIndex,
    const DeepCollectionEquality().hash(_processedIds),
    const DeepCollectionEquality().hash(_failedIds),
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BackupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupCheckpointImplCopyWith<_$BackupCheckpointImpl> get copyWith =>
      __$$BackupCheckpointImplCopyWithImpl<_$BackupCheckpointImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupCheckpointImplToJson(this);
  }
}

abstract class _BackupCheckpoint extends BackupCheckpoint {
  const factory _BackupCheckpoint({
    required final String operationId,
    required final BackupPhase phase,
    required final DateTime startedAt,
    final DateTime? lastUpdatedAt,
    required final int lastProcessedIndex,
    required final List<String> processedIds,
    required final List<String> failedIds,
    final Map<String, dynamic> metadata,
  }) = _$BackupCheckpointImpl;
  const _BackupCheckpoint._() : super._();

  factory _BackupCheckpoint.fromJson(Map<String, dynamic> json) =
      _$BackupCheckpointImpl.fromJson;

  @override
  String get operationId;
  @override
  BackupPhase get phase;
  @override
  DateTime get startedAt;
  @override
  DateTime? get lastUpdatedAt;
  @override
  int get lastProcessedIndex;
  @override
  List<String> get processedIds;
  @override
  List<String> get failedIds;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of BackupCheckpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupCheckpointImplCopyWith<_$BackupCheckpointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  String get deviceId => throw _privateConstructorUsedError;
  String get manufacturer => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  String get androidVersion => throw _privateConstructorUsedError;
  int get sdkInt => throw _privateConstructorUsedError;
  String get appVersion => throw _privateConstructorUsedError;
  String get buildNumber => throw _privateConstructorUsedError;

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
    DeviceInfo value,
    $Res Function(DeviceInfo) then,
  ) = _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call({
    String deviceId,
    String manufacturer,
    String model,
    String androidVersion,
    int sdkInt,
    String appVersion,
    String buildNumber,
  });
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? manufacturer = null,
    Object? model = null,
    Object? androidVersion = null,
    Object? sdkInt = null,
    Object? appVersion = null,
    Object? buildNumber = null,
  }) {
    return _then(
      _value.copyWith(
            deviceId: null == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            manufacturer: null == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            androidVersion: null == androidVersion
                ? _value.androidVersion
                : androidVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            sdkInt: null == sdkInt
                ? _value.sdkInt
                : sdkInt // ignore: cast_nullable_to_non_nullable
                      as int,
            appVersion: null == appVersion
                ? _value.appVersion
                : appVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            buildNumber: null == buildNumber
                ? _value.buildNumber
                : buildNumber // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
    _$DeviceInfoImpl value,
    $Res Function(_$DeviceInfoImpl) then,
  ) = __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String deviceId,
    String manufacturer,
    String model,
    String androidVersion,
    int sdkInt,
    String appVersion,
    String buildNumber,
  });
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
    _$DeviceInfoImpl _value,
    $Res Function(_$DeviceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? manufacturer = null,
    Object? model = null,
    Object? androidVersion = null,
    Object? sdkInt = null,
    Object? appVersion = null,
    Object? buildNumber = null,
  }) {
    return _then(
      _$DeviceInfoImpl(
        deviceId: null == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        manufacturer: null == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        androidVersion: null == androidVersion
            ? _value.androidVersion
            : androidVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        sdkInt: null == sdkInt
            ? _value.sdkInt
            : sdkInt // ignore: cast_nullable_to_non_nullable
                  as int,
        appVersion: null == appVersion
            ? _value.appVersion
            : appVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        buildNumber: null == buildNumber
            ? _value.buildNumber
            : buildNumber // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  const _$DeviceInfoImpl({
    required this.deviceId,
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    required this.sdkInt,
    required this.appVersion,
    required this.buildNumber,
  });

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  @override
  final String deviceId;
  @override
  final String manufacturer;
  @override
  final String model;
  @override
  final String androidVersion;
  @override
  final int sdkInt;
  @override
  final String appVersion;
  @override
  final String buildNumber;

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, manufacturer: $manufacturer, model: $model, androidVersion: $androidVersion, sdkInt: $sdkInt, appVersion: $appVersion, buildNumber: $buildNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.androidVersion, androidVersion) ||
                other.androidVersion == androidVersion) &&
            (identical(other.sdkInt, sdkInt) || other.sdkInt == sdkInt) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.buildNumber, buildNumber) ||
                other.buildNumber == buildNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deviceId,
    manufacturer,
    model,
    androidVersion,
    sdkInt,
    appVersion,
    buildNumber,
  );

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(this);
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  const factory _DeviceInfo({
    required final String deviceId,
    required final String manufacturer,
    required final String model,
    required final String androidVersion,
    required final int sdkInt,
    required final String appVersion,
    required final String buildNumber,
  }) = _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  @override
  String get deviceId;
  @override
  String get manufacturer;
  @override
  String get model;
  @override
  String get androidVersion;
  @override
  int get sdkInt;
  @override
  String get appVersion;
  @override
  String get buildNumber;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
