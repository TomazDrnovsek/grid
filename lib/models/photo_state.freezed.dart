// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PhotoState {
  /// List of full-resolution image files
  List<File> get images => throw _privateConstructorUsedError;

  /// List of thumbnail files corresponding to images
  List<File> get thumbnails => throw _privateConstructorUsedError;

  /// Set of selected image indexes
  Set<int> get selectedIndexes => throw _privateConstructorUsedError;

  /// Loading state for image operations
  bool get isLoading => throw _privateConstructorUsedError;

  /// Delete confirmation modal state
  bool get showDeleteConfirm => throw _privateConstructorUsedError;

  /// Image preview modal state
  bool get showImagePreview => throw _privateConstructorUsedError;

  /// Index of currently previewed image (-1 if none)
  int get previewImageIndex => throw _privateConstructorUsedError;

  /// Scroll position state (true if at top)
  bool get isAtTop => throw _privateConstructorUsedError;

  /// Header username editing state
  bool get editingHeaderUsername => throw _privateConstructorUsedError;

  /// Current header username value
  String get headerUsername => throw _privateConstructorUsedError;

  /// Total count of images for convenience
  int get imageCount => throw _privateConstructorUsedError;

  /// Whether arrays are in sync (safety check)
  bool get arraysInSync => throw _privateConstructorUsedError;

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoStateCopyWith<PhotoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoStateCopyWith<$Res> {
  factory $PhotoStateCopyWith(
    PhotoState value,
    $Res Function(PhotoState) then,
  ) = _$PhotoStateCopyWithImpl<$Res, PhotoState>;
  @useResult
  $Res call({
    List<File> images,
    List<File> thumbnails,
    Set<int> selectedIndexes,
    bool isLoading,
    bool showDeleteConfirm,
    bool showImagePreview,
    int previewImageIndex,
    bool isAtTop,
    bool editingHeaderUsername,
    String headerUsername,
    int imageCount,
    bool arraysInSync,
  });
}

/// @nodoc
class _$PhotoStateCopyWithImpl<$Res, $Val extends PhotoState>
    implements $PhotoStateCopyWith<$Res> {
  _$PhotoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? thumbnails = null,
    Object? selectedIndexes = null,
    Object? isLoading = null,
    Object? showDeleteConfirm = null,
    Object? showImagePreview = null,
    Object? previewImageIndex = null,
    Object? isAtTop = null,
    Object? editingHeaderUsername = null,
    Object? headerUsername = null,
    Object? imageCount = null,
    Object? arraysInSync = null,
  }) {
    return _then(
      _value.copyWith(
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<File>,
            thumbnails: null == thumbnails
                ? _value.thumbnails
                : thumbnails // ignore: cast_nullable_to_non_nullable
                      as List<File>,
            selectedIndexes: null == selectedIndexes
                ? _value.selectedIndexes
                : selectedIndexes // ignore: cast_nullable_to_non_nullable
                      as Set<int>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            showDeleteConfirm: null == showDeleteConfirm
                ? _value.showDeleteConfirm
                : showDeleteConfirm // ignore: cast_nullable_to_non_nullable
                      as bool,
            showImagePreview: null == showImagePreview
                ? _value.showImagePreview
                : showImagePreview // ignore: cast_nullable_to_non_nullable
                      as bool,
            previewImageIndex: null == previewImageIndex
                ? _value.previewImageIndex
                : previewImageIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isAtTop: null == isAtTop
                ? _value.isAtTop
                : isAtTop // ignore: cast_nullable_to_non_nullable
                      as bool,
            editingHeaderUsername: null == editingHeaderUsername
                ? _value.editingHeaderUsername
                : editingHeaderUsername // ignore: cast_nullable_to_non_nullable
                      as bool,
            headerUsername: null == headerUsername
                ? _value.headerUsername
                : headerUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            imageCount: null == imageCount
                ? _value.imageCount
                : imageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            arraysInSync: null == arraysInSync
                ? _value.arraysInSync
                : arraysInSync // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoStateImplCopyWith<$Res>
    implements $PhotoStateCopyWith<$Res> {
  factory _$$PhotoStateImplCopyWith(
    _$PhotoStateImpl value,
    $Res Function(_$PhotoStateImpl) then,
  ) = __$$PhotoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<File> images,
    List<File> thumbnails,
    Set<int> selectedIndexes,
    bool isLoading,
    bool showDeleteConfirm,
    bool showImagePreview,
    int previewImageIndex,
    bool isAtTop,
    bool editingHeaderUsername,
    String headerUsername,
    int imageCount,
    bool arraysInSync,
  });
}

/// @nodoc
class __$$PhotoStateImplCopyWithImpl<$Res>
    extends _$PhotoStateCopyWithImpl<$Res, _$PhotoStateImpl>
    implements _$$PhotoStateImplCopyWith<$Res> {
  __$$PhotoStateImplCopyWithImpl(
    _$PhotoStateImpl _value,
    $Res Function(_$PhotoStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? thumbnails = null,
    Object? selectedIndexes = null,
    Object? isLoading = null,
    Object? showDeleteConfirm = null,
    Object? showImagePreview = null,
    Object? previewImageIndex = null,
    Object? isAtTop = null,
    Object? editingHeaderUsername = null,
    Object? headerUsername = null,
    Object? imageCount = null,
    Object? arraysInSync = null,
  }) {
    return _then(
      _$PhotoStateImpl(
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<File>,
        thumbnails: null == thumbnails
            ? _value._thumbnails
            : thumbnails // ignore: cast_nullable_to_non_nullable
                  as List<File>,
        selectedIndexes: null == selectedIndexes
            ? _value._selectedIndexes
            : selectedIndexes // ignore: cast_nullable_to_non_nullable
                  as Set<int>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        showDeleteConfirm: null == showDeleteConfirm
            ? _value.showDeleteConfirm
            : showDeleteConfirm // ignore: cast_nullable_to_non_nullable
                  as bool,
        showImagePreview: null == showImagePreview
            ? _value.showImagePreview
            : showImagePreview // ignore: cast_nullable_to_non_nullable
                  as bool,
        previewImageIndex: null == previewImageIndex
            ? _value.previewImageIndex
            : previewImageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isAtTop: null == isAtTop
            ? _value.isAtTop
            : isAtTop // ignore: cast_nullable_to_non_nullable
                  as bool,
        editingHeaderUsername: null == editingHeaderUsername
            ? _value.editingHeaderUsername
            : editingHeaderUsername // ignore: cast_nullable_to_non_nullable
                  as bool,
        headerUsername: null == headerUsername
            ? _value.headerUsername
            : headerUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        imageCount: null == imageCount
            ? _value.imageCount
            : imageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        arraysInSync: null == arraysInSync
            ? _value.arraysInSync
            : arraysInSync // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PhotoStateImpl extends _PhotoState {
  const _$PhotoStateImpl({
    final List<File> images = const [],
    final List<File> thumbnails = const [],
    final Set<int> selectedIndexes = const {},
    this.isLoading = false,
    this.showDeleteConfirm = false,
    this.showImagePreview = false,
    this.previewImageIndex = -1,
    this.isAtTop = true,
    this.editingHeaderUsername = false,
    this.headerUsername = 'tomazdrnovsek',
    this.imageCount = 0,
    this.arraysInSync = true,
  }) : _images = images,
       _thumbnails = thumbnails,
       _selectedIndexes = selectedIndexes,
       super._();

  /// List of full-resolution image files
  final List<File> _images;

  /// List of full-resolution image files
  @override
  @JsonKey()
  List<File> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  /// List of thumbnail files corresponding to images
  final List<File> _thumbnails;

  /// List of thumbnail files corresponding to images
  @override
  @JsonKey()
  List<File> get thumbnails {
    if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thumbnails);
  }

  /// Set of selected image indexes
  final Set<int> _selectedIndexes;

  /// Set of selected image indexes
  @override
  @JsonKey()
  Set<int> get selectedIndexes {
    if (_selectedIndexes is EqualUnmodifiableSetView) return _selectedIndexes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedIndexes);
  }

  /// Loading state for image operations
  @override
  @JsonKey()
  final bool isLoading;

  /// Delete confirmation modal state
  @override
  @JsonKey()
  final bool showDeleteConfirm;

  /// Image preview modal state
  @override
  @JsonKey()
  final bool showImagePreview;

  /// Index of currently previewed image (-1 if none)
  @override
  @JsonKey()
  final int previewImageIndex;

  /// Scroll position state (true if at top)
  @override
  @JsonKey()
  final bool isAtTop;

  /// Header username editing state
  @override
  @JsonKey()
  final bool editingHeaderUsername;

  /// Current header username value
  @override
  @JsonKey()
  final String headerUsername;

  /// Total count of images for convenience
  @override
  @JsonKey()
  final int imageCount;

  /// Whether arrays are in sync (safety check)
  @override
  @JsonKey()
  final bool arraysInSync;

  @override
  String toString() {
    return 'PhotoState(images: $images, thumbnails: $thumbnails, selectedIndexes: $selectedIndexes, isLoading: $isLoading, showDeleteConfirm: $showDeleteConfirm, showImagePreview: $showImagePreview, previewImageIndex: $previewImageIndex, isAtTop: $isAtTop, editingHeaderUsername: $editingHeaderUsername, headerUsername: $headerUsername, imageCount: $imageCount, arraysInSync: $arraysInSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoStateImpl &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(
              other._thumbnails,
              _thumbnails,
            ) &&
            const DeepCollectionEquality().equals(
              other._selectedIndexes,
              _selectedIndexes,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.showDeleteConfirm, showDeleteConfirm) ||
                other.showDeleteConfirm == showDeleteConfirm) &&
            (identical(other.showImagePreview, showImagePreview) ||
                other.showImagePreview == showImagePreview) &&
            (identical(other.previewImageIndex, previewImageIndex) ||
                other.previewImageIndex == previewImageIndex) &&
            (identical(other.isAtTop, isAtTop) || other.isAtTop == isAtTop) &&
            (identical(other.editingHeaderUsername, editingHeaderUsername) ||
                other.editingHeaderUsername == editingHeaderUsername) &&
            (identical(other.headerUsername, headerUsername) ||
                other.headerUsername == headerUsername) &&
            (identical(other.imageCount, imageCount) ||
                other.imageCount == imageCount) &&
            (identical(other.arraysInSync, arraysInSync) ||
                other.arraysInSync == arraysInSync));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_thumbnails),
    const DeepCollectionEquality().hash(_selectedIndexes),
    isLoading,
    showDeleteConfirm,
    showImagePreview,
    previewImageIndex,
    isAtTop,
    editingHeaderUsername,
    headerUsername,
    imageCount,
    arraysInSync,
  );

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoStateImplCopyWith<_$PhotoStateImpl> get copyWith =>
      __$$PhotoStateImplCopyWithImpl<_$PhotoStateImpl>(this, _$identity);
}

abstract class _PhotoState extends PhotoState {
  const factory _PhotoState({
    final List<File> images,
    final List<File> thumbnails,
    final Set<int> selectedIndexes,
    final bool isLoading,
    final bool showDeleteConfirm,
    final bool showImagePreview,
    final int previewImageIndex,
    final bool isAtTop,
    final bool editingHeaderUsername,
    final String headerUsername,
    final int imageCount,
    final bool arraysInSync,
  }) = _$PhotoStateImpl;
  const _PhotoState._() : super._();

  /// List of full-resolution image files
  @override
  List<File> get images;

  /// List of thumbnail files corresponding to images
  @override
  List<File> get thumbnails;

  /// Set of selected image indexes
  @override
  Set<int> get selectedIndexes;

  /// Loading state for image operations
  @override
  bool get isLoading;

  /// Delete confirmation modal state
  @override
  bool get showDeleteConfirm;

  /// Image preview modal state
  @override
  bool get showImagePreview;

  /// Index of currently previewed image (-1 if none)
  @override
  int get previewImageIndex;

  /// Scroll position state (true if at top)
  @override
  bool get isAtTop;

  /// Header username editing state
  @override
  bool get editingHeaderUsername;

  /// Current header username value
  @override
  String get headerUsername;

  /// Total count of images for convenience
  @override
  int get imageCount;

  /// Whether arrays are in sync (safety check)
  @override
  bool get arraysInSync;

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoStateImplCopyWith<_$PhotoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProcessedImage {
  File get image => throw _privateConstructorUsedError;
  File get thumbnail => throw _privateConstructorUsedError;

  /// Create a copy of ProcessedImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessedImageCopyWith<ProcessedImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessedImageCopyWith<$Res> {
  factory $ProcessedImageCopyWith(
    ProcessedImage value,
    $Res Function(ProcessedImage) then,
  ) = _$ProcessedImageCopyWithImpl<$Res, ProcessedImage>;
  @useResult
  $Res call({File image, File thumbnail});
}

/// @nodoc
class _$ProcessedImageCopyWithImpl<$Res, $Val extends ProcessedImage>
    implements $ProcessedImageCopyWith<$Res> {
  _$ProcessedImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessedImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? image = null, Object? thumbnail = null}) {
    return _then(
      _value.copyWith(
            image: null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as File,
            thumbnail: null == thumbnail
                ? _value.thumbnail
                : thumbnail // ignore: cast_nullable_to_non_nullable
                      as File,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProcessedImageImplCopyWith<$Res>
    implements $ProcessedImageCopyWith<$Res> {
  factory _$$ProcessedImageImplCopyWith(
    _$ProcessedImageImpl value,
    $Res Function(_$ProcessedImageImpl) then,
  ) = __$$ProcessedImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({File image, File thumbnail});
}

/// @nodoc
class __$$ProcessedImageImplCopyWithImpl<$Res>
    extends _$ProcessedImageCopyWithImpl<$Res, _$ProcessedImageImpl>
    implements _$$ProcessedImageImplCopyWith<$Res> {
  __$$ProcessedImageImplCopyWithImpl(
    _$ProcessedImageImpl _value,
    $Res Function(_$ProcessedImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProcessedImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? image = null, Object? thumbnail = null}) {
    return _then(
      _$ProcessedImageImpl(
        image: null == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as File,
        thumbnail: null == thumbnail
            ? _value.thumbnail
            : thumbnail // ignore: cast_nullable_to_non_nullable
                  as File,
      ),
    );
  }
}

/// @nodoc

class _$ProcessedImageImpl implements _ProcessedImage {
  const _$ProcessedImageImpl({required this.image, required this.thumbnail});

  @override
  final File image;
  @override
  final File thumbnail;

  @override
  String toString() {
    return 'ProcessedImage(image: $image, thumbnail: $thumbnail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessedImageImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, image, thumbnail);

  /// Create a copy of ProcessedImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessedImageImplCopyWith<_$ProcessedImageImpl> get copyWith =>
      __$$ProcessedImageImplCopyWithImpl<_$ProcessedImageImpl>(
        this,
        _$identity,
      );
}

abstract class _ProcessedImage implements ProcessedImage {
  const factory _ProcessedImage({
    required final File image,
    required final File thumbnail,
  }) = _$ProcessedImageImpl;

  @override
  File get image;
  @override
  File get thumbnail;

  /// Create a copy of ProcessedImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessedImageImplCopyWith<_$ProcessedImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchImageResult {
  List<ProcessedImage> get processedImages =>
      throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Create a copy of BatchImageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchImageResultCopyWith<BatchImageResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchImageResultCopyWith<$Res> {
  factory $BatchImageResultCopyWith(
    BatchImageResult value,
    $Res Function(BatchImageResult) then,
  ) = _$BatchImageResultCopyWithImpl<$Res, BatchImageResult>;
  @useResult
  $Res call({
    List<ProcessedImage> processedImages,
    int successCount,
    int failureCount,
    List<String> errors,
  });
}

/// @nodoc
class _$BatchImageResultCopyWithImpl<$Res, $Val extends BatchImageResult>
    implements $BatchImageResultCopyWith<$Res> {
  _$BatchImageResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchImageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processedImages = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? errors = null,
  }) {
    return _then(
      _value.copyWith(
            processedImages: null == processedImages
                ? _value.processedImages
                : processedImages // ignore: cast_nullable_to_non_nullable
                      as List<ProcessedImage>,
            successCount: null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failureCount: null == failureCount
                ? _value.failureCount
                : failureCount // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchImageResultImplCopyWith<$Res>
    implements $BatchImageResultCopyWith<$Res> {
  factory _$$BatchImageResultImplCopyWith(
    _$BatchImageResultImpl value,
    $Res Function(_$BatchImageResultImpl) then,
  ) = __$$BatchImageResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ProcessedImage> processedImages,
    int successCount,
    int failureCount,
    List<String> errors,
  });
}

/// @nodoc
class __$$BatchImageResultImplCopyWithImpl<$Res>
    extends _$BatchImageResultCopyWithImpl<$Res, _$BatchImageResultImpl>
    implements _$$BatchImageResultImplCopyWith<$Res> {
  __$$BatchImageResultImplCopyWithImpl(
    _$BatchImageResultImpl _value,
    $Res Function(_$BatchImageResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchImageResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processedImages = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? errors = null,
  }) {
    return _then(
      _$BatchImageResultImpl(
        processedImages: null == processedImages
            ? _value._processedImages
            : processedImages // ignore: cast_nullable_to_non_nullable
                  as List<ProcessedImage>,
        successCount: null == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failureCount: null == failureCount
            ? _value.failureCount
            : failureCount // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$BatchImageResultImpl implements _BatchImageResult {
  const _$BatchImageResultImpl({
    required final List<ProcessedImage> processedImages,
    required this.successCount,
    required this.failureCount,
    final List<String> errors = const [],
  }) : _processedImages = processedImages,
       _errors = errors;

  final List<ProcessedImage> _processedImages;
  @override
  List<ProcessedImage> get processedImages {
    if (_processedImages is EqualUnmodifiableListView) return _processedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_processedImages);
  }

  @override
  final int successCount;
  @override
  final int failureCount;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'BatchImageResult(processedImages: $processedImages, successCount: $successCount, failureCount: $failureCount, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchImageResultImpl &&
            const DeepCollectionEquality().equals(
              other._processedImages,
              _processedImages,
            ) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_processedImages),
    successCount,
    failureCount,
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of BatchImageResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchImageResultImplCopyWith<_$BatchImageResultImpl> get copyWith =>
      __$$BatchImageResultImplCopyWithImpl<_$BatchImageResultImpl>(
        this,
        _$identity,
      );
}

abstract class _BatchImageResult implements BatchImageResult {
  const factory _BatchImageResult({
    required final List<ProcessedImage> processedImages,
    required final int successCount,
    required final int failureCount,
    final List<String> errors,
  }) = _$BatchImageResultImpl;

  @override
  List<ProcessedImage> get processedImages;
  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  List<String> get errors;

  /// Create a copy of BatchImageResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchImageResultImplCopyWith<_$BatchImageResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PhotoOperationEvent {
  PhotoOperation get operation => throw _privateConstructorUsedError;
  List<int> get indexes => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of PhotoOperationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoOperationEventCopyWith<PhotoOperationEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoOperationEventCopyWith<$Res> {
  factory $PhotoOperationEventCopyWith(
    PhotoOperationEvent value,
    $Res Function(PhotoOperationEvent) then,
  ) = _$PhotoOperationEventCopyWithImpl<$Res, PhotoOperationEvent>;
  @useResult
  $Res call({
    PhotoOperation operation,
    List<int> indexes,
    String message,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$PhotoOperationEventCopyWithImpl<$Res, $Val extends PhotoOperationEvent>
    implements $PhotoOperationEventCopyWith<$Res> {
  _$PhotoOperationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoOperationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operation = null,
    Object? indexes = null,
    Object? message = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            operation: null == operation
                ? _value.operation
                : operation // ignore: cast_nullable_to_non_nullable
                      as PhotoOperation,
            indexes: null == indexes
                ? _value.indexes
                : indexes // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoOperationEventImplCopyWith<$Res>
    implements $PhotoOperationEventCopyWith<$Res> {
  factory _$$PhotoOperationEventImplCopyWith(
    _$PhotoOperationEventImpl value,
    $Res Function(_$PhotoOperationEventImpl) then,
  ) = __$$PhotoOperationEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PhotoOperation operation,
    List<int> indexes,
    String message,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$PhotoOperationEventImplCopyWithImpl<$Res>
    extends _$PhotoOperationEventCopyWithImpl<$Res, _$PhotoOperationEventImpl>
    implements _$$PhotoOperationEventImplCopyWith<$Res> {
  __$$PhotoOperationEventImplCopyWithImpl(
    _$PhotoOperationEventImpl _value,
    $Res Function(_$PhotoOperationEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoOperationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? operation = null,
    Object? indexes = null,
    Object? message = null,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$PhotoOperationEventImpl(
        operation: null == operation
            ? _value.operation
            : operation // ignore: cast_nullable_to_non_nullable
                  as PhotoOperation,
        indexes: null == indexes
            ? _value._indexes
            : indexes // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$PhotoOperationEventImpl implements _PhotoOperationEvent {
  const _$PhotoOperationEventImpl({
    required this.operation,
    final List<int> indexes = const [],
    this.message = '',
    this.timestamp,
  }) : _indexes = indexes;

  @override
  final PhotoOperation operation;
  final List<int> _indexes;
  @override
  @JsonKey()
  List<int> get indexes {
    if (_indexes is EqualUnmodifiableListView) return _indexes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_indexes);
  }

  @override
  @JsonKey()
  final String message;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'PhotoOperationEvent(operation: $operation, indexes: $indexes, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoOperationEventImpl &&
            (identical(other.operation, operation) ||
                other.operation == operation) &&
            const DeepCollectionEquality().equals(other._indexes, _indexes) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    operation,
    const DeepCollectionEquality().hash(_indexes),
    message,
    timestamp,
  );

  /// Create a copy of PhotoOperationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoOperationEventImplCopyWith<_$PhotoOperationEventImpl> get copyWith =>
      __$$PhotoOperationEventImplCopyWithImpl<_$PhotoOperationEventImpl>(
        this,
        _$identity,
      );
}

abstract class _PhotoOperationEvent implements PhotoOperationEvent {
  const factory _PhotoOperationEvent({
    required final PhotoOperation operation,
    final List<int> indexes,
    final String message,
    final DateTime? timestamp,
  }) = _$PhotoOperationEventImpl;

  @override
  PhotoOperation get operation;
  @override
  List<int> get indexes;
  @override
  String get message;
  @override
  DateTime? get timestamp;

  /// Create a copy of PhotoOperationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoOperationEventImplCopyWith<_$PhotoOperationEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
