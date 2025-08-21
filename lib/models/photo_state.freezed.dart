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

  /// PHASE 2: List of photo UUIDs corresponding to images (for backup/restore order preservation)
  List<String> get imageUuids => throw _privateConstructorUsedError;

  /// Set of selected image indexes
  Set<int> get selectedIndexes => throw _privateConstructorUsedError;

  /// Loading state for image operations
  bool get isLoading => throw _privateConstructorUsedError;

  /// Delete confirmation modal state
  bool get showDeleteConfirm => throw _privateConstructorUsedError;

  /// PHASE 1: Loading modal with progress state
  bool get showLoadingModal => throw _privateConstructorUsedError;

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

  /// PHASE 2: Hue map overlay toggle state
  bool get showHueMap =>
      throw _privateConstructorUsedError; // ========================================================================
  // PHASE 2: ENHANCED BATCH OPERATION TRACKING
  // ========================================================================
  /// Current batch operation in progress (null if none)
  BatchOperationStatus? get currentBatchOperation =>
      throw _privateConstructorUsedError;

  /// History of recent batch operations for debugging
  List<BatchOperationRecord> get batchHistory =>
      throw _privateConstructorUsedError;

  /// Total number of batch operations completed in this session
  int get totalBatchOperations => throw _privateConstructorUsedError;

  /// Number of operations currently queued for batch processing
  int get queuedOperations => throw _privateConstructorUsedError;

  /// Whether batch processing is currently active
  bool get isBatchProcessing => throw _privateConstructorUsedError;

  /// Last batch operation result for UI feedback
  BatchResult? get lastBatchResult => throw _privateConstructorUsedError;

  /// Batch processing metrics for performance monitoring
  BatchMetrics get batchMetrics => throw _privateConstructorUsedError;

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
    List<String> imageUuids,
    Set<int> selectedIndexes,
    bool isLoading,
    bool showDeleteConfirm,
    bool showLoadingModal,
    bool showImagePreview,
    int previewImageIndex,
    bool isAtTop,
    bool editingHeaderUsername,
    String headerUsername,
    int imageCount,
    bool arraysInSync,
    bool showHueMap,
    BatchOperationStatus? currentBatchOperation,
    List<BatchOperationRecord> batchHistory,
    int totalBatchOperations,
    int queuedOperations,
    bool isBatchProcessing,
    BatchResult? lastBatchResult,
    BatchMetrics batchMetrics,
  });

  $BatchOperationStatusCopyWith<$Res>? get currentBatchOperation;
  $BatchResultCopyWith<$Res>? get lastBatchResult;
  $BatchMetricsCopyWith<$Res> get batchMetrics;
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
    Object? imageUuids = null,
    Object? selectedIndexes = null,
    Object? isLoading = null,
    Object? showDeleteConfirm = null,
    Object? showLoadingModal = null,
    Object? showImagePreview = null,
    Object? previewImageIndex = null,
    Object? isAtTop = null,
    Object? editingHeaderUsername = null,
    Object? headerUsername = null,
    Object? imageCount = null,
    Object? arraysInSync = null,
    Object? showHueMap = null,
    Object? currentBatchOperation = freezed,
    Object? batchHistory = null,
    Object? totalBatchOperations = null,
    Object? queuedOperations = null,
    Object? isBatchProcessing = null,
    Object? lastBatchResult = freezed,
    Object? batchMetrics = null,
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
            imageUuids: null == imageUuids
                ? _value.imageUuids
                : imageUuids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
            showLoadingModal: null == showLoadingModal
                ? _value.showLoadingModal
                : showLoadingModal // ignore: cast_nullable_to_non_nullable
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
            showHueMap: null == showHueMap
                ? _value.showHueMap
                : showHueMap // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentBatchOperation: freezed == currentBatchOperation
                ? _value.currentBatchOperation
                : currentBatchOperation // ignore: cast_nullable_to_non_nullable
                      as BatchOperationStatus?,
            batchHistory: null == batchHistory
                ? _value.batchHistory
                : batchHistory // ignore: cast_nullable_to_non_nullable
                      as List<BatchOperationRecord>,
            totalBatchOperations: null == totalBatchOperations
                ? _value.totalBatchOperations
                : totalBatchOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            queuedOperations: null == queuedOperations
                ? _value.queuedOperations
                : queuedOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            isBatchProcessing: null == isBatchProcessing
                ? _value.isBatchProcessing
                : isBatchProcessing // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastBatchResult: freezed == lastBatchResult
                ? _value.lastBatchResult
                : lastBatchResult // ignore: cast_nullable_to_non_nullable
                      as BatchResult?,
            batchMetrics: null == batchMetrics
                ? _value.batchMetrics
                : batchMetrics // ignore: cast_nullable_to_non_nullable
                      as BatchMetrics,
          )
          as $Val,
    );
  }

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchOperationStatusCopyWith<$Res>? get currentBatchOperation {
    if (_value.currentBatchOperation == null) {
      return null;
    }

    return $BatchOperationStatusCopyWith<$Res>(_value.currentBatchOperation!, (
      value,
    ) {
      return _then(_value.copyWith(currentBatchOperation: value) as $Val);
    });
  }

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchResultCopyWith<$Res>? get lastBatchResult {
    if (_value.lastBatchResult == null) {
      return null;
    }

    return $BatchResultCopyWith<$Res>(_value.lastBatchResult!, (value) {
      return _then(_value.copyWith(lastBatchResult: value) as $Val);
    });
  }

  /// Create a copy of PhotoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchMetricsCopyWith<$Res> get batchMetrics {
    return $BatchMetricsCopyWith<$Res>(_value.batchMetrics, (value) {
      return _then(_value.copyWith(batchMetrics: value) as $Val);
    });
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
    List<String> imageUuids,
    Set<int> selectedIndexes,
    bool isLoading,
    bool showDeleteConfirm,
    bool showLoadingModal,
    bool showImagePreview,
    int previewImageIndex,
    bool isAtTop,
    bool editingHeaderUsername,
    String headerUsername,
    int imageCount,
    bool arraysInSync,
    bool showHueMap,
    BatchOperationStatus? currentBatchOperation,
    List<BatchOperationRecord> batchHistory,
    int totalBatchOperations,
    int queuedOperations,
    bool isBatchProcessing,
    BatchResult? lastBatchResult,
    BatchMetrics batchMetrics,
  });

  @override
  $BatchOperationStatusCopyWith<$Res>? get currentBatchOperation;
  @override
  $BatchResultCopyWith<$Res>? get lastBatchResult;
  @override
  $BatchMetricsCopyWith<$Res> get batchMetrics;
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
    Object? imageUuids = null,
    Object? selectedIndexes = null,
    Object? isLoading = null,
    Object? showDeleteConfirm = null,
    Object? showLoadingModal = null,
    Object? showImagePreview = null,
    Object? previewImageIndex = null,
    Object? isAtTop = null,
    Object? editingHeaderUsername = null,
    Object? headerUsername = null,
    Object? imageCount = null,
    Object? arraysInSync = null,
    Object? showHueMap = null,
    Object? currentBatchOperation = freezed,
    Object? batchHistory = null,
    Object? totalBatchOperations = null,
    Object? queuedOperations = null,
    Object? isBatchProcessing = null,
    Object? lastBatchResult = freezed,
    Object? batchMetrics = null,
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
        imageUuids: null == imageUuids
            ? _value._imageUuids
            : imageUuids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
        showLoadingModal: null == showLoadingModal
            ? _value.showLoadingModal
            : showLoadingModal // ignore: cast_nullable_to_non_nullable
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
        showHueMap: null == showHueMap
            ? _value.showHueMap
            : showHueMap // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentBatchOperation: freezed == currentBatchOperation
            ? _value.currentBatchOperation
            : currentBatchOperation // ignore: cast_nullable_to_non_nullable
                  as BatchOperationStatus?,
        batchHistory: null == batchHistory
            ? _value._batchHistory
            : batchHistory // ignore: cast_nullable_to_non_nullable
                  as List<BatchOperationRecord>,
        totalBatchOperations: null == totalBatchOperations
            ? _value.totalBatchOperations
            : totalBatchOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        queuedOperations: null == queuedOperations
            ? _value.queuedOperations
            : queuedOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        isBatchProcessing: null == isBatchProcessing
            ? _value.isBatchProcessing
            : isBatchProcessing // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastBatchResult: freezed == lastBatchResult
            ? _value.lastBatchResult
            : lastBatchResult // ignore: cast_nullable_to_non_nullable
                  as BatchResult?,
        batchMetrics: null == batchMetrics
            ? _value.batchMetrics
            : batchMetrics // ignore: cast_nullable_to_non_nullable
                  as BatchMetrics,
      ),
    );
  }
}

/// @nodoc

class _$PhotoStateImpl extends _PhotoState {
  const _$PhotoStateImpl({
    final List<File> images = const [],
    final List<File> thumbnails = const [],
    final List<String> imageUuids = const <String>[],
    final Set<int> selectedIndexes = const {},
    this.isLoading = false,
    this.showDeleteConfirm = false,
    this.showLoadingModal = false,
    this.showImagePreview = false,
    this.previewImageIndex = -1,
    this.isAtTop = true,
    this.editingHeaderUsername = false,
    this.headerUsername = 'tomazdrnovsek',
    this.imageCount = 0,
    this.arraysInSync = true,
    this.showHueMap = false,
    this.currentBatchOperation,
    final List<BatchOperationRecord> batchHistory = const [],
    this.totalBatchOperations = 0,
    this.queuedOperations = 0,
    this.isBatchProcessing = false,
    this.lastBatchResult,
    this.batchMetrics = const BatchMetrics(),
  }) : _images = images,
       _thumbnails = thumbnails,
       _imageUuids = imageUuids,
       _selectedIndexes = selectedIndexes,
       _batchHistory = batchHistory,
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

  /// PHASE 2: List of photo UUIDs corresponding to images (for backup/restore order preservation)
  final List<String> _imageUuids;

  /// PHASE 2: List of photo UUIDs corresponding to images (for backup/restore order preservation)
  @override
  @JsonKey()
  List<String> get imageUuids {
    if (_imageUuids is EqualUnmodifiableListView) return _imageUuids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUuids);
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

  /// PHASE 1: Loading modal with progress state
  @override
  @JsonKey()
  final bool showLoadingModal;

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

  /// PHASE 2: Hue map overlay toggle state
  @override
  @JsonKey()
  final bool showHueMap;
  // ========================================================================
  // PHASE 2: ENHANCED BATCH OPERATION TRACKING
  // ========================================================================
  /// Current batch operation in progress (null if none)
  @override
  final BatchOperationStatus? currentBatchOperation;

  /// History of recent batch operations for debugging
  final List<BatchOperationRecord> _batchHistory;

  /// History of recent batch operations for debugging
  @override
  @JsonKey()
  List<BatchOperationRecord> get batchHistory {
    if (_batchHistory is EqualUnmodifiableListView) return _batchHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_batchHistory);
  }

  /// Total number of batch operations completed in this session
  @override
  @JsonKey()
  final int totalBatchOperations;

  /// Number of operations currently queued for batch processing
  @override
  @JsonKey()
  final int queuedOperations;

  /// Whether batch processing is currently active
  @override
  @JsonKey()
  final bool isBatchProcessing;

  /// Last batch operation result for UI feedback
  @override
  final BatchResult? lastBatchResult;

  /// Batch processing metrics for performance monitoring
  @override
  @JsonKey()
  final BatchMetrics batchMetrics;

  @override
  String toString() {
    return 'PhotoState(images: $images, thumbnails: $thumbnails, imageUuids: $imageUuids, selectedIndexes: $selectedIndexes, isLoading: $isLoading, showDeleteConfirm: $showDeleteConfirm, showLoadingModal: $showLoadingModal, showImagePreview: $showImagePreview, previewImageIndex: $previewImageIndex, isAtTop: $isAtTop, editingHeaderUsername: $editingHeaderUsername, headerUsername: $headerUsername, imageCount: $imageCount, arraysInSync: $arraysInSync, showHueMap: $showHueMap, currentBatchOperation: $currentBatchOperation, batchHistory: $batchHistory, totalBatchOperations: $totalBatchOperations, queuedOperations: $queuedOperations, isBatchProcessing: $isBatchProcessing, lastBatchResult: $lastBatchResult, batchMetrics: $batchMetrics)';
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
              other._imageUuids,
              _imageUuids,
            ) &&
            const DeepCollectionEquality().equals(
              other._selectedIndexes,
              _selectedIndexes,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.showDeleteConfirm, showDeleteConfirm) ||
                other.showDeleteConfirm == showDeleteConfirm) &&
            (identical(other.showLoadingModal, showLoadingModal) ||
                other.showLoadingModal == showLoadingModal) &&
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
                other.arraysInSync == arraysInSync) &&
            (identical(other.showHueMap, showHueMap) ||
                other.showHueMap == showHueMap) &&
            (identical(other.currentBatchOperation, currentBatchOperation) ||
                other.currentBatchOperation == currentBatchOperation) &&
            const DeepCollectionEquality().equals(
              other._batchHistory,
              _batchHistory,
            ) &&
            (identical(other.totalBatchOperations, totalBatchOperations) ||
                other.totalBatchOperations == totalBatchOperations) &&
            (identical(other.queuedOperations, queuedOperations) ||
                other.queuedOperations == queuedOperations) &&
            (identical(other.isBatchProcessing, isBatchProcessing) ||
                other.isBatchProcessing == isBatchProcessing) &&
            (identical(other.lastBatchResult, lastBatchResult) ||
                other.lastBatchResult == lastBatchResult) &&
            (identical(other.batchMetrics, batchMetrics) ||
                other.batchMetrics == batchMetrics));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_thumbnails),
    const DeepCollectionEquality().hash(_imageUuids),
    const DeepCollectionEquality().hash(_selectedIndexes),
    isLoading,
    showDeleteConfirm,
    showLoadingModal,
    showImagePreview,
    previewImageIndex,
    isAtTop,
    editingHeaderUsername,
    headerUsername,
    imageCount,
    arraysInSync,
    showHueMap,
    currentBatchOperation,
    const DeepCollectionEquality().hash(_batchHistory),
    totalBatchOperations,
    queuedOperations,
    isBatchProcessing,
    lastBatchResult,
    batchMetrics,
  ]);

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
    final List<String> imageUuids,
    final Set<int> selectedIndexes,
    final bool isLoading,
    final bool showDeleteConfirm,
    final bool showLoadingModal,
    final bool showImagePreview,
    final int previewImageIndex,
    final bool isAtTop,
    final bool editingHeaderUsername,
    final String headerUsername,
    final int imageCount,
    final bool arraysInSync,
    final bool showHueMap,
    final BatchOperationStatus? currentBatchOperation,
    final List<BatchOperationRecord> batchHistory,
    final int totalBatchOperations,
    final int queuedOperations,
    final bool isBatchProcessing,
    final BatchResult? lastBatchResult,
    final BatchMetrics batchMetrics,
  }) = _$PhotoStateImpl;
  const _PhotoState._() : super._();

  /// List of full-resolution image files
  @override
  List<File> get images;

  /// List of thumbnail files corresponding to images
  @override
  List<File> get thumbnails;

  /// PHASE 2: List of photo UUIDs corresponding to images (for backup/restore order preservation)
  @override
  List<String> get imageUuids;

  /// Set of selected image indexes
  @override
  Set<int> get selectedIndexes;

  /// Loading state for image operations
  @override
  bool get isLoading;

  /// Delete confirmation modal state
  @override
  bool get showDeleteConfirm;

  /// PHASE 1: Loading modal with progress state
  @override
  bool get showLoadingModal;

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

  /// PHASE 2: Hue map overlay toggle state
  @override
  bool get showHueMap; // ========================================================================
  // PHASE 2: ENHANCED BATCH OPERATION TRACKING
  // ========================================================================
  /// Current batch operation in progress (null if none)
  @override
  BatchOperationStatus? get currentBatchOperation;

  /// History of recent batch operations for debugging
  @override
  List<BatchOperationRecord> get batchHistory;

  /// Total number of batch operations completed in this session
  @override
  int get totalBatchOperations;

  /// Number of operations currently queued for batch processing
  @override
  int get queuedOperations;

  /// Whether batch processing is currently active
  @override
  bool get isBatchProcessing;

  /// Last batch operation result for UI feedback
  @override
  BatchResult? get lastBatchResult;

  /// Batch processing metrics for performance monitoring
  @override
  BatchMetrics get batchMetrics;

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

/// @nodoc
mixin _$BatchOperationStatus {
  BatchOperationType get type => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  int get operationCount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get completedOperations => throw _privateConstructorUsedError;
  List<String> get currentMessages => throw _privateConstructorUsedError;

  /// Create a copy of BatchOperationStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchOperationStatusCopyWith<BatchOperationStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchOperationStatusCopyWith<$Res> {
  factory $BatchOperationStatusCopyWith(
    BatchOperationStatus value,
    $Res Function(BatchOperationStatus) then,
  ) = _$BatchOperationStatusCopyWithImpl<$Res, BatchOperationStatus>;
  @useResult
  $Res call({
    BatchOperationType type,
    DateTime startTime,
    int operationCount,
    String status,
    int completedOperations,
    List<String> currentMessages,
  });
}

/// @nodoc
class _$BatchOperationStatusCopyWithImpl<
  $Res,
  $Val extends BatchOperationStatus
>
    implements $BatchOperationStatusCopyWith<$Res> {
  _$BatchOperationStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchOperationStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? startTime = null,
    Object? operationCount = null,
    Object? status = null,
    Object? completedOperations = null,
    Object? currentMessages = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BatchOperationType,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            operationCount: null == operationCount
                ? _value.operationCount
                : operationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            completedOperations: null == completedOperations
                ? _value.completedOperations
                : completedOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            currentMessages: null == currentMessages
                ? _value.currentMessages
                : currentMessages // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchOperationStatusImplCopyWith<$Res>
    implements $BatchOperationStatusCopyWith<$Res> {
  factory _$$BatchOperationStatusImplCopyWith(
    _$BatchOperationStatusImpl value,
    $Res Function(_$BatchOperationStatusImpl) then,
  ) = __$$BatchOperationStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BatchOperationType type,
    DateTime startTime,
    int operationCount,
    String status,
    int completedOperations,
    List<String> currentMessages,
  });
}

/// @nodoc
class __$$BatchOperationStatusImplCopyWithImpl<$Res>
    extends _$BatchOperationStatusCopyWithImpl<$Res, _$BatchOperationStatusImpl>
    implements _$$BatchOperationStatusImplCopyWith<$Res> {
  __$$BatchOperationStatusImplCopyWithImpl(
    _$BatchOperationStatusImpl _value,
    $Res Function(_$BatchOperationStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchOperationStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? startTime = null,
    Object? operationCount = null,
    Object? status = null,
    Object? completedOperations = null,
    Object? currentMessages = null,
  }) {
    return _then(
      _$BatchOperationStatusImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BatchOperationType,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        operationCount: null == operationCount
            ? _value.operationCount
            : operationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        completedOperations: null == completedOperations
            ? _value.completedOperations
            : completedOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        currentMessages: null == currentMessages
            ? _value._currentMessages
            : currentMessages // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$BatchOperationStatusImpl extends _BatchOperationStatus {
  const _$BatchOperationStatusImpl({
    required this.type,
    required this.startTime,
    required this.operationCount,
    this.status = 'Processing...',
    this.completedOperations = 0,
    final List<String> currentMessages = const [],
  }) : _currentMessages = currentMessages,
       super._();

  @override
  final BatchOperationType type;
  @override
  final DateTime startTime;
  @override
  final int operationCount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final int completedOperations;
  final List<String> _currentMessages;
  @override
  @JsonKey()
  List<String> get currentMessages {
    if (_currentMessages is EqualUnmodifiableListView) return _currentMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentMessages);
  }

  @override
  String toString() {
    return 'BatchOperationStatus(type: $type, startTime: $startTime, operationCount: $operationCount, status: $status, completedOperations: $completedOperations, currentMessages: $currentMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchOperationStatusImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.operationCount, operationCount) ||
                other.operationCount == operationCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedOperations, completedOperations) ||
                other.completedOperations == completedOperations) &&
            const DeepCollectionEquality().equals(
              other._currentMessages,
              _currentMessages,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    startTime,
    operationCount,
    status,
    completedOperations,
    const DeepCollectionEquality().hash(_currentMessages),
  );

  /// Create a copy of BatchOperationStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchOperationStatusImplCopyWith<_$BatchOperationStatusImpl>
  get copyWith =>
      __$$BatchOperationStatusImplCopyWithImpl<_$BatchOperationStatusImpl>(
        this,
        _$identity,
      );
}

abstract class _BatchOperationStatus extends BatchOperationStatus {
  const factory _BatchOperationStatus({
    required final BatchOperationType type,
    required final DateTime startTime,
    required final int operationCount,
    final String status,
    final int completedOperations,
    final List<String> currentMessages,
  }) = _$BatchOperationStatusImpl;
  const _BatchOperationStatus._() : super._();

  @override
  BatchOperationType get type;
  @override
  DateTime get startTime;
  @override
  int get operationCount;
  @override
  String get status;
  @override
  int get completedOperations;
  @override
  List<String> get currentMessages;

  /// Create a copy of BatchOperationStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchOperationStatusImplCopyWith<_$BatchOperationStatusImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchOperationRecord {
  BatchOperationType get type => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  int get operationCount => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  bool get wasOptimized => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Create a copy of BatchOperationRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchOperationRecordCopyWith<BatchOperationRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchOperationRecordCopyWith<$Res> {
  factory $BatchOperationRecordCopyWith(
    BatchOperationRecord value,
    $Res Function(BatchOperationRecord) then,
  ) = _$BatchOperationRecordCopyWithImpl<$Res, BatchOperationRecord>;
  @useResult
  $Res call({
    BatchOperationType type,
    DateTime startTime,
    DateTime endTime,
    int operationCount,
    int successCount,
    int failureCount,
    List<String> errors,
    List<String> warnings,
    bool wasOptimized,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$BatchOperationRecordCopyWithImpl<
  $Res,
  $Val extends BatchOperationRecord
>
    implements $BatchOperationRecordCopyWith<$Res> {
  _$BatchOperationRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchOperationRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? operationCount = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? errors = null,
    Object? warnings = null,
    Object? wasOptimized = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BatchOperationType,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            operationCount: null == operationCount
                ? _value.operationCount
                : operationCount // ignore: cast_nullable_to_non_nullable
                      as int,
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
            warnings: null == warnings
                ? _value.warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            wasOptimized: null == wasOptimized
                ? _value.wasOptimized
                : wasOptimized // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$BatchOperationRecordImplCopyWith<$Res>
    implements $BatchOperationRecordCopyWith<$Res> {
  factory _$$BatchOperationRecordImplCopyWith(
    _$BatchOperationRecordImpl value,
    $Res Function(_$BatchOperationRecordImpl) then,
  ) = __$$BatchOperationRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BatchOperationType type,
    DateTime startTime,
    DateTime endTime,
    int operationCount,
    int successCount,
    int failureCount,
    List<String> errors,
    List<String> warnings,
    bool wasOptimized,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$BatchOperationRecordImplCopyWithImpl<$Res>
    extends _$BatchOperationRecordCopyWithImpl<$Res, _$BatchOperationRecordImpl>
    implements _$$BatchOperationRecordImplCopyWith<$Res> {
  __$$BatchOperationRecordImplCopyWithImpl(
    _$BatchOperationRecordImpl _value,
    $Res Function(_$BatchOperationRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchOperationRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? operationCount = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? errors = null,
    Object? warnings = null,
    Object? wasOptimized = null,
    Object? metadata = null,
  }) {
    return _then(
      _$BatchOperationRecordImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BatchOperationType,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        operationCount: null == operationCount
            ? _value.operationCount
            : operationCount // ignore: cast_nullable_to_non_nullable
                  as int,
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
        warnings: null == warnings
            ? _value._warnings
            : warnings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        wasOptimized: null == wasOptimized
            ? _value.wasOptimized
            : wasOptimized // ignore: cast_nullable_to_non_nullable
                  as bool,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$BatchOperationRecordImpl extends _BatchOperationRecord {
  const _$BatchOperationRecordImpl({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.operationCount,
    required this.successCount,
    required this.failureCount,
    final List<String> errors = const [],
    final List<String> warnings = const [],
    required this.wasOptimized,
    final Map<String, dynamic> metadata = const {},
  }) : _errors = errors,
       _warnings = warnings,
       _metadata = metadata,
       super._();

  @override
  final BatchOperationType type;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final int operationCount;
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

  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  final bool wasOptimized;
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
    return 'BatchOperationRecord(type: $type, startTime: $startTime, endTime: $endTime, operationCount: $operationCount, successCount: $successCount, failureCount: $failureCount, errors: $errors, warnings: $warnings, wasOptimized: $wasOptimized, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchOperationRecordImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.operationCount, operationCount) ||
                other.operationCount == operationCount) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.wasOptimized, wasOptimized) ||
                other.wasOptimized == wasOptimized) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    startTime,
    endTime,
    operationCount,
    successCount,
    failureCount,
    const DeepCollectionEquality().hash(_errors),
    const DeepCollectionEquality().hash(_warnings),
    wasOptimized,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of BatchOperationRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchOperationRecordImplCopyWith<_$BatchOperationRecordImpl>
  get copyWith =>
      __$$BatchOperationRecordImplCopyWithImpl<_$BatchOperationRecordImpl>(
        this,
        _$identity,
      );
}

abstract class _BatchOperationRecord extends BatchOperationRecord {
  const factory _BatchOperationRecord({
    required final BatchOperationType type,
    required final DateTime startTime,
    required final DateTime endTime,
    required final int operationCount,
    required final int successCount,
    required final int failureCount,
    final List<String> errors,
    final List<String> warnings,
    required final bool wasOptimized,
    final Map<String, dynamic> metadata,
  }) = _$BatchOperationRecordImpl;
  const _BatchOperationRecord._() : super._();

  @override
  BatchOperationType get type;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  int get operationCount;
  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  List<String> get errors;
  @override
  List<String> get warnings;
  @override
  bool get wasOptimized;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of BatchOperationRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchOperationRecordImplCopyWith<_$BatchOperationRecordImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchResult {
  int get operationsProcessed => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  Duration get processingTime => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  bool get wasOptimized => throw _privateConstructorUsedError;
  BatchOperationType get primaryOperationType =>
      throw _privateConstructorUsedError;
  Map<String, int> get operationBreakdown => throw _privateConstructorUsedError;
  Map<String, dynamic> get performanceMetrics =>
      throw _privateConstructorUsedError;

  /// Create a copy of BatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchResultCopyWith<BatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchResultCopyWith<$Res> {
  factory $BatchResultCopyWith(
    BatchResult value,
    $Res Function(BatchResult) then,
  ) = _$BatchResultCopyWithImpl<$Res, BatchResult>;
  @useResult
  $Res call({
    int operationsProcessed,
    int successCount,
    int failureCount,
    Duration processingTime,
    List<String> errors,
    List<String> warnings,
    bool wasOptimized,
    BatchOperationType primaryOperationType,
    Map<String, int> operationBreakdown,
    Map<String, dynamic> performanceMetrics,
  });
}

/// @nodoc
class _$BatchResultCopyWithImpl<$Res, $Val extends BatchResult>
    implements $BatchResultCopyWith<$Res> {
  _$BatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchResult
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
    Object? wasOptimized = null,
    Object? primaryOperationType = null,
    Object? operationBreakdown = null,
    Object? performanceMetrics = null,
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
            wasOptimized: null == wasOptimized
                ? _value.wasOptimized
                : wasOptimized // ignore: cast_nullable_to_non_nullable
                      as bool,
            primaryOperationType: null == primaryOperationType
                ? _value.primaryOperationType
                : primaryOperationType // ignore: cast_nullable_to_non_nullable
                      as BatchOperationType,
            operationBreakdown: null == operationBreakdown
                ? _value.operationBreakdown
                : operationBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            performanceMetrics: null == performanceMetrics
                ? _value.performanceMetrics
                : performanceMetrics // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchResultImplCopyWith<$Res>
    implements $BatchResultCopyWith<$Res> {
  factory _$$BatchResultImplCopyWith(
    _$BatchResultImpl value,
    $Res Function(_$BatchResultImpl) then,
  ) = __$$BatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int operationsProcessed,
    int successCount,
    int failureCount,
    Duration processingTime,
    List<String> errors,
    List<String> warnings,
    bool wasOptimized,
    BatchOperationType primaryOperationType,
    Map<String, int> operationBreakdown,
    Map<String, dynamic> performanceMetrics,
  });
}

/// @nodoc
class __$$BatchResultImplCopyWithImpl<$Res>
    extends _$BatchResultCopyWithImpl<$Res, _$BatchResultImpl>
    implements _$$BatchResultImplCopyWith<$Res> {
  __$$BatchResultImplCopyWithImpl(
    _$BatchResultImpl _value,
    $Res Function(_$BatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchResult
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
    Object? wasOptimized = null,
    Object? primaryOperationType = null,
    Object? operationBreakdown = null,
    Object? performanceMetrics = null,
  }) {
    return _then(
      _$BatchResultImpl(
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
        wasOptimized: null == wasOptimized
            ? _value.wasOptimized
            : wasOptimized // ignore: cast_nullable_to_non_nullable
                  as bool,
        primaryOperationType: null == primaryOperationType
            ? _value.primaryOperationType
            : primaryOperationType // ignore: cast_nullable_to_non_nullable
                  as BatchOperationType,
        operationBreakdown: null == operationBreakdown
            ? _value._operationBreakdown
            : operationBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        performanceMetrics: null == performanceMetrics
            ? _value._performanceMetrics
            : performanceMetrics // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc

class _$BatchResultImpl extends _BatchResult {
  const _$BatchResultImpl({
    required this.operationsProcessed,
    required this.successCount,
    required this.failureCount,
    required this.processingTime,
    final List<String> errors = const [],
    final List<String> warnings = const [],
    required this.wasOptimized,
    required this.primaryOperationType,
    final Map<String, int> operationBreakdown = const {},
    final Map<String, dynamic> performanceMetrics = const {},
  }) : _errors = errors,
       _warnings = warnings,
       _operationBreakdown = operationBreakdown,
       _performanceMetrics = performanceMetrics,
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

  @override
  final bool wasOptimized;
  @override
  final BatchOperationType primaryOperationType;
  final Map<String, int> _operationBreakdown;
  @override
  @JsonKey()
  Map<String, int> get operationBreakdown {
    if (_operationBreakdown is EqualUnmodifiableMapView)
      return _operationBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_operationBreakdown);
  }

  final Map<String, dynamic> _performanceMetrics;
  @override
  @JsonKey()
  Map<String, dynamic> get performanceMetrics {
    if (_performanceMetrics is EqualUnmodifiableMapView)
      return _performanceMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_performanceMetrics);
  }

  @override
  String toString() {
    return 'BatchResult(operationsProcessed: $operationsProcessed, successCount: $successCount, failureCount: $failureCount, processingTime: $processingTime, errors: $errors, warnings: $warnings, wasOptimized: $wasOptimized, primaryOperationType: $primaryOperationType, operationBreakdown: $operationBreakdown, performanceMetrics: $performanceMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchResultImpl &&
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
            (identical(other.wasOptimized, wasOptimized) ||
                other.wasOptimized == wasOptimized) &&
            (identical(other.primaryOperationType, primaryOperationType) ||
                other.primaryOperationType == primaryOperationType) &&
            const DeepCollectionEquality().equals(
              other._operationBreakdown,
              _operationBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._performanceMetrics,
              _performanceMetrics,
            ));
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
    wasOptimized,
    primaryOperationType,
    const DeepCollectionEquality().hash(_operationBreakdown),
    const DeepCollectionEquality().hash(_performanceMetrics),
  );

  /// Create a copy of BatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchResultImplCopyWith<_$BatchResultImpl> get copyWith =>
      __$$BatchResultImplCopyWithImpl<_$BatchResultImpl>(this, _$identity);
}

abstract class _BatchResult extends BatchResult {
  const factory _BatchResult({
    required final int operationsProcessed,
    required final int successCount,
    required final int failureCount,
    required final Duration processingTime,
    final List<String> errors,
    final List<String> warnings,
    required final bool wasOptimized,
    required final BatchOperationType primaryOperationType,
    final Map<String, int> operationBreakdown,
    final Map<String, dynamic> performanceMetrics,
  }) = _$BatchResultImpl;
  const _BatchResult._() : super._();

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
  bool get wasOptimized;
  @override
  BatchOperationType get primaryOperationType;
  @override
  Map<String, int> get operationBreakdown;
  @override
  Map<String, dynamic> get performanceMetrics;

  /// Create a copy of BatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchResultImplCopyWith<_$BatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchValidationResult {
  bool get isValid => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  BatchOperationType get operationType => throw _privateConstructorUsedError;

  /// Create a copy of BatchValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchValidationResultCopyWith<BatchValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchValidationResultCopyWith<$Res> {
  factory $BatchValidationResultCopyWith(
    BatchValidationResult value,
    $Res Function(BatchValidationResult) then,
  ) = _$BatchValidationResultCopyWithImpl<$Res, BatchValidationResult>;
  @useResult
  $Res call({
    bool isValid,
    List<String> errors,
    List<String> warnings,
    BatchOperationType operationType,
  });
}

/// @nodoc
class _$BatchValidationResultCopyWithImpl<
  $Res,
  $Val extends BatchValidationResult
>
    implements $BatchValidationResultCopyWith<$Res> {
  _$BatchValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? errors = null,
    Object? warnings = null,
    Object? operationType = null,
  }) {
    return _then(
      _value.copyWith(
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            warnings: null == warnings
                ? _value.warnings
                : warnings // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            operationType: null == operationType
                ? _value.operationType
                : operationType // ignore: cast_nullable_to_non_nullable
                      as BatchOperationType,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchValidationResultImplCopyWith<$Res>
    implements $BatchValidationResultCopyWith<$Res> {
  factory _$$BatchValidationResultImplCopyWith(
    _$BatchValidationResultImpl value,
    $Res Function(_$BatchValidationResultImpl) then,
  ) = __$$BatchValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isValid,
    List<String> errors,
    List<String> warnings,
    BatchOperationType operationType,
  });
}

/// @nodoc
class __$$BatchValidationResultImplCopyWithImpl<$Res>
    extends
        _$BatchValidationResultCopyWithImpl<$Res, _$BatchValidationResultImpl>
    implements _$$BatchValidationResultImplCopyWith<$Res> {
  __$$BatchValidationResultImplCopyWithImpl(
    _$BatchValidationResultImpl _value,
    $Res Function(_$BatchValidationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? errors = null,
    Object? warnings = null,
    Object? operationType = null,
  }) {
    return _then(
      _$BatchValidationResultImpl(
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        warnings: null == warnings
            ? _value._warnings
            : warnings // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        operationType: null == operationType
            ? _value.operationType
            : operationType // ignore: cast_nullable_to_non_nullable
                  as BatchOperationType,
      ),
    );
  }
}

/// @nodoc

class _$BatchValidationResultImpl extends _BatchValidationResult {
  const _$BatchValidationResultImpl({
    required this.isValid,
    required final List<String> errors,
    required final List<String> warnings,
    required this.operationType,
  }) : _errors = errors,
       _warnings = warnings,
       super._();

  @override
  final bool isValid;
  final List<String> _errors;
  @override
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  final List<String> _warnings;
  @override
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  final BatchOperationType operationType;

  @override
  String toString() {
    return 'BatchValidationResult(isValid: $isValid, errors: $errors, warnings: $warnings, operationType: $operationType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.operationType, operationType) ||
                other.operationType == operationType));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isValid,
    const DeepCollectionEquality().hash(_errors),
    const DeepCollectionEquality().hash(_warnings),
    operationType,
  );

  /// Create a copy of BatchValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchValidationResultImplCopyWith<_$BatchValidationResultImpl>
  get copyWith =>
      __$$BatchValidationResultImplCopyWithImpl<_$BatchValidationResultImpl>(
        this,
        _$identity,
      );
}

abstract class _BatchValidationResult extends BatchValidationResult {
  const factory _BatchValidationResult({
    required final bool isValid,
    required final List<String> errors,
    required final List<String> warnings,
    required final BatchOperationType operationType,
  }) = _$BatchValidationResultImpl;
  const _BatchValidationResult._() : super._();

  @override
  bool get isValid;
  @override
  List<String> get errors;
  @override
  List<String> get warnings;
  @override
  BatchOperationType get operationType;

  /// Create a copy of BatchValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchValidationResultImplCopyWith<_$BatchValidationResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchDebugInfo {
  BatchOperationStatus? get currentOperation =>
      throw _privateConstructorUsedError;
  int get queuedOperations => throw _privateConstructorUsedError;
  bool get isBatchProcessing => throw _privateConstructorUsedError;
  int get totalOperations => throw _privateConstructorUsedError;
  List<BatchOperationRecord> get recentHistory =>
      throw _privateConstructorUsedError;
  BatchMetrics get metrics => throw _privateConstructorUsedError;
  BatchResult? get lastResult => throw _privateConstructorUsedError;
  bool get arraysInSync => throw _privateConstructorUsedError;
  int get imagesCount => throw _privateConstructorUsedError;
  int get thumbnailsCount => throw _privateConstructorUsedError;
  int get selectedCount => throw _privateConstructorUsedError;

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchDebugInfoCopyWith<BatchDebugInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchDebugInfoCopyWith<$Res> {
  factory $BatchDebugInfoCopyWith(
    BatchDebugInfo value,
    $Res Function(BatchDebugInfo) then,
  ) = _$BatchDebugInfoCopyWithImpl<$Res, BatchDebugInfo>;
  @useResult
  $Res call({
    BatchOperationStatus? currentOperation,
    int queuedOperations,
    bool isBatchProcessing,
    int totalOperations,
    List<BatchOperationRecord> recentHistory,
    BatchMetrics metrics,
    BatchResult? lastResult,
    bool arraysInSync,
    int imagesCount,
    int thumbnailsCount,
    int selectedCount,
  });

  $BatchOperationStatusCopyWith<$Res>? get currentOperation;
  $BatchMetricsCopyWith<$Res> get metrics;
  $BatchResultCopyWith<$Res>? get lastResult;
}

/// @nodoc
class _$BatchDebugInfoCopyWithImpl<$Res, $Val extends BatchDebugInfo>
    implements $BatchDebugInfoCopyWith<$Res> {
  _$BatchDebugInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentOperation = freezed,
    Object? queuedOperations = null,
    Object? isBatchProcessing = null,
    Object? totalOperations = null,
    Object? recentHistory = null,
    Object? metrics = null,
    Object? lastResult = freezed,
    Object? arraysInSync = null,
    Object? imagesCount = null,
    Object? thumbnailsCount = null,
    Object? selectedCount = null,
  }) {
    return _then(
      _value.copyWith(
            currentOperation: freezed == currentOperation
                ? _value.currentOperation
                : currentOperation // ignore: cast_nullable_to_non_nullable
                      as BatchOperationStatus?,
            queuedOperations: null == queuedOperations
                ? _value.queuedOperations
                : queuedOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            isBatchProcessing: null == isBatchProcessing
                ? _value.isBatchProcessing
                : isBatchProcessing // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalOperations: null == totalOperations
                ? _value.totalOperations
                : totalOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            recentHistory: null == recentHistory
                ? _value.recentHistory
                : recentHistory // ignore: cast_nullable_to_non_nullable
                      as List<BatchOperationRecord>,
            metrics: null == metrics
                ? _value.metrics
                : metrics // ignore: cast_nullable_to_non_nullable
                      as BatchMetrics,
            lastResult: freezed == lastResult
                ? _value.lastResult
                : lastResult // ignore: cast_nullable_to_non_nullable
                      as BatchResult?,
            arraysInSync: null == arraysInSync
                ? _value.arraysInSync
                : arraysInSync // ignore: cast_nullable_to_non_nullable
                      as bool,
            imagesCount: null == imagesCount
                ? _value.imagesCount
                : imagesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            thumbnailsCount: null == thumbnailsCount
                ? _value.thumbnailsCount
                : thumbnailsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedCount: null == selectedCount
                ? _value.selectedCount
                : selectedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchOperationStatusCopyWith<$Res>? get currentOperation {
    if (_value.currentOperation == null) {
      return null;
    }

    return $BatchOperationStatusCopyWith<$Res>(_value.currentOperation!, (
      value,
    ) {
      return _then(_value.copyWith(currentOperation: value) as $Val);
    });
  }

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchMetricsCopyWith<$Res> get metrics {
    return $BatchMetricsCopyWith<$Res>(_value.metrics, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchResultCopyWith<$Res>? get lastResult {
    if (_value.lastResult == null) {
      return null;
    }

    return $BatchResultCopyWith<$Res>(_value.lastResult!, (value) {
      return _then(_value.copyWith(lastResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BatchDebugInfoImplCopyWith<$Res>
    implements $BatchDebugInfoCopyWith<$Res> {
  factory _$$BatchDebugInfoImplCopyWith(
    _$BatchDebugInfoImpl value,
    $Res Function(_$BatchDebugInfoImpl) then,
  ) = __$$BatchDebugInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BatchOperationStatus? currentOperation,
    int queuedOperations,
    bool isBatchProcessing,
    int totalOperations,
    List<BatchOperationRecord> recentHistory,
    BatchMetrics metrics,
    BatchResult? lastResult,
    bool arraysInSync,
    int imagesCount,
    int thumbnailsCount,
    int selectedCount,
  });

  @override
  $BatchOperationStatusCopyWith<$Res>? get currentOperation;
  @override
  $BatchMetricsCopyWith<$Res> get metrics;
  @override
  $BatchResultCopyWith<$Res>? get lastResult;
}

/// @nodoc
class __$$BatchDebugInfoImplCopyWithImpl<$Res>
    extends _$BatchDebugInfoCopyWithImpl<$Res, _$BatchDebugInfoImpl>
    implements _$$BatchDebugInfoImplCopyWith<$Res> {
  __$$BatchDebugInfoImplCopyWithImpl(
    _$BatchDebugInfoImpl _value,
    $Res Function(_$BatchDebugInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentOperation = freezed,
    Object? queuedOperations = null,
    Object? isBatchProcessing = null,
    Object? totalOperations = null,
    Object? recentHistory = null,
    Object? metrics = null,
    Object? lastResult = freezed,
    Object? arraysInSync = null,
    Object? imagesCount = null,
    Object? thumbnailsCount = null,
    Object? selectedCount = null,
  }) {
    return _then(
      _$BatchDebugInfoImpl(
        currentOperation: freezed == currentOperation
            ? _value.currentOperation
            : currentOperation // ignore: cast_nullable_to_non_nullable
                  as BatchOperationStatus?,
        queuedOperations: null == queuedOperations
            ? _value.queuedOperations
            : queuedOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        isBatchProcessing: null == isBatchProcessing
            ? _value.isBatchProcessing
            : isBatchProcessing // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalOperations: null == totalOperations
            ? _value.totalOperations
            : totalOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        recentHistory: null == recentHistory
            ? _value._recentHistory
            : recentHistory // ignore: cast_nullable_to_non_nullable
                  as List<BatchOperationRecord>,
        metrics: null == metrics
            ? _value.metrics
            : metrics // ignore: cast_nullable_to_non_nullable
                  as BatchMetrics,
        lastResult: freezed == lastResult
            ? _value.lastResult
            : lastResult // ignore: cast_nullable_to_non_nullable
                  as BatchResult?,
        arraysInSync: null == arraysInSync
            ? _value.arraysInSync
            : arraysInSync // ignore: cast_nullable_to_non_nullable
                  as bool,
        imagesCount: null == imagesCount
            ? _value.imagesCount
            : imagesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        thumbnailsCount: null == thumbnailsCount
            ? _value.thumbnailsCount
            : thumbnailsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedCount: null == selectedCount
            ? _value.selectedCount
            : selectedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$BatchDebugInfoImpl extends _BatchDebugInfo {
  const _$BatchDebugInfoImpl({
    this.currentOperation,
    required this.queuedOperations,
    required this.isBatchProcessing,
    required this.totalOperations,
    required final List<BatchOperationRecord> recentHistory,
    required this.metrics,
    this.lastResult,
    required this.arraysInSync,
    required this.imagesCount,
    required this.thumbnailsCount,
    required this.selectedCount,
  }) : _recentHistory = recentHistory,
       super._();

  @override
  final BatchOperationStatus? currentOperation;
  @override
  final int queuedOperations;
  @override
  final bool isBatchProcessing;
  @override
  final int totalOperations;
  final List<BatchOperationRecord> _recentHistory;
  @override
  List<BatchOperationRecord> get recentHistory {
    if (_recentHistory is EqualUnmodifiableListView) return _recentHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentHistory);
  }

  @override
  final BatchMetrics metrics;
  @override
  final BatchResult? lastResult;
  @override
  final bool arraysInSync;
  @override
  final int imagesCount;
  @override
  final int thumbnailsCount;
  @override
  final int selectedCount;

  @override
  String toString() {
    return 'BatchDebugInfo(currentOperation: $currentOperation, queuedOperations: $queuedOperations, isBatchProcessing: $isBatchProcessing, totalOperations: $totalOperations, recentHistory: $recentHistory, metrics: $metrics, lastResult: $lastResult, arraysInSync: $arraysInSync, imagesCount: $imagesCount, thumbnailsCount: $thumbnailsCount, selectedCount: $selectedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchDebugInfoImpl &&
            (identical(other.currentOperation, currentOperation) ||
                other.currentOperation == currentOperation) &&
            (identical(other.queuedOperations, queuedOperations) ||
                other.queuedOperations == queuedOperations) &&
            (identical(other.isBatchProcessing, isBatchProcessing) ||
                other.isBatchProcessing == isBatchProcessing) &&
            (identical(other.totalOperations, totalOperations) ||
                other.totalOperations == totalOperations) &&
            const DeepCollectionEquality().equals(
              other._recentHistory,
              _recentHistory,
            ) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult) &&
            (identical(other.arraysInSync, arraysInSync) ||
                other.arraysInSync == arraysInSync) &&
            (identical(other.imagesCount, imagesCount) ||
                other.imagesCount == imagesCount) &&
            (identical(other.thumbnailsCount, thumbnailsCount) ||
                other.thumbnailsCount == thumbnailsCount) &&
            (identical(other.selectedCount, selectedCount) ||
                other.selectedCount == selectedCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentOperation,
    queuedOperations,
    isBatchProcessing,
    totalOperations,
    const DeepCollectionEquality().hash(_recentHistory),
    metrics,
    lastResult,
    arraysInSync,
    imagesCount,
    thumbnailsCount,
    selectedCount,
  );

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchDebugInfoImplCopyWith<_$BatchDebugInfoImpl> get copyWith =>
      __$$BatchDebugInfoImplCopyWithImpl<_$BatchDebugInfoImpl>(
        this,
        _$identity,
      );
}

abstract class _BatchDebugInfo extends BatchDebugInfo {
  const factory _BatchDebugInfo({
    final BatchOperationStatus? currentOperation,
    required final int queuedOperations,
    required final bool isBatchProcessing,
    required final int totalOperations,
    required final List<BatchOperationRecord> recentHistory,
    required final BatchMetrics metrics,
    final BatchResult? lastResult,
    required final bool arraysInSync,
    required final int imagesCount,
    required final int thumbnailsCount,
    required final int selectedCount,
  }) = _$BatchDebugInfoImpl;
  const _BatchDebugInfo._() : super._();

  @override
  BatchOperationStatus? get currentOperation;
  @override
  int get queuedOperations;
  @override
  bool get isBatchProcessing;
  @override
  int get totalOperations;
  @override
  List<BatchOperationRecord> get recentHistory;
  @override
  BatchMetrics get metrics;
  @override
  BatchResult? get lastResult;
  @override
  bool get arraysInSync;
  @override
  int get imagesCount;
  @override
  int get thumbnailsCount;
  @override
  int get selectedCount;

  /// Create a copy of BatchDebugInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchDebugInfoImplCopyWith<_$BatchDebugInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BatchMetrics {
  Duration get totalProcessingTime => throw _privateConstructorUsedError;
  int get totalOperations => throw _privateConstructorUsedError;
  int get totalBatches => throw _privateConstructorUsedError;
  Duration get averageProcessingTime => throw _privateConstructorUsedError;
  Duration get averageBatchTime => throw _privateConstructorUsedError;
  int get totalOptimizations => throw _privateConstructorUsedError;
  int get totalFailures => throw _privateConstructorUsedError;
  Map<BatchOperationType, int> get operationTypeBreakdown =>
      throw _privateConstructorUsedError;
  DateTime? get lastResetTime => throw _privateConstructorUsedError;

  /// Create a copy of BatchMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchMetricsCopyWith<BatchMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchMetricsCopyWith<$Res> {
  factory $BatchMetricsCopyWith(
    BatchMetrics value,
    $Res Function(BatchMetrics) then,
  ) = _$BatchMetricsCopyWithImpl<$Res, BatchMetrics>;
  @useResult
  $Res call({
    Duration totalProcessingTime,
    int totalOperations,
    int totalBatches,
    Duration averageProcessingTime,
    Duration averageBatchTime,
    int totalOptimizations,
    int totalFailures,
    Map<BatchOperationType, int> operationTypeBreakdown,
    DateTime? lastResetTime,
  });
}

/// @nodoc
class _$BatchMetricsCopyWithImpl<$Res, $Val extends BatchMetrics>
    implements $BatchMetricsCopyWith<$Res> {
  _$BatchMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessingTime = null,
    Object? totalOperations = null,
    Object? totalBatches = null,
    Object? averageProcessingTime = null,
    Object? averageBatchTime = null,
    Object? totalOptimizations = null,
    Object? totalFailures = null,
    Object? operationTypeBreakdown = null,
    Object? lastResetTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalProcessingTime: null == totalProcessingTime
                ? _value.totalProcessingTime
                : totalProcessingTime // ignore: cast_nullable_to_non_nullable
                      as Duration,
            totalOperations: null == totalOperations
                ? _value.totalOperations
                : totalOperations // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBatches: null == totalBatches
                ? _value.totalBatches
                : totalBatches // ignore: cast_nullable_to_non_nullable
                      as int,
            averageProcessingTime: null == averageProcessingTime
                ? _value.averageProcessingTime
                : averageProcessingTime // ignore: cast_nullable_to_non_nullable
                      as Duration,
            averageBatchTime: null == averageBatchTime
                ? _value.averageBatchTime
                : averageBatchTime // ignore: cast_nullable_to_non_nullable
                      as Duration,
            totalOptimizations: null == totalOptimizations
                ? _value.totalOptimizations
                : totalOptimizations // ignore: cast_nullable_to_non_nullable
                      as int,
            totalFailures: null == totalFailures
                ? _value.totalFailures
                : totalFailures // ignore: cast_nullable_to_non_nullable
                      as int,
            operationTypeBreakdown: null == operationTypeBreakdown
                ? _value.operationTypeBreakdown
                : operationTypeBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<BatchOperationType, int>,
            lastResetTime: freezed == lastResetTime
                ? _value.lastResetTime
                : lastResetTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchMetricsImplCopyWith<$Res>
    implements $BatchMetricsCopyWith<$Res> {
  factory _$$BatchMetricsImplCopyWith(
    _$BatchMetricsImpl value,
    $Res Function(_$BatchMetricsImpl) then,
  ) = __$$BatchMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Duration totalProcessingTime,
    int totalOperations,
    int totalBatches,
    Duration averageProcessingTime,
    Duration averageBatchTime,
    int totalOptimizations,
    int totalFailures,
    Map<BatchOperationType, int> operationTypeBreakdown,
    DateTime? lastResetTime,
  });
}

/// @nodoc
class __$$BatchMetricsImplCopyWithImpl<$Res>
    extends _$BatchMetricsCopyWithImpl<$Res, _$BatchMetricsImpl>
    implements _$$BatchMetricsImplCopyWith<$Res> {
  __$$BatchMetricsImplCopyWithImpl(
    _$BatchMetricsImpl _value,
    $Res Function(_$BatchMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessingTime = null,
    Object? totalOperations = null,
    Object? totalBatches = null,
    Object? averageProcessingTime = null,
    Object? averageBatchTime = null,
    Object? totalOptimizations = null,
    Object? totalFailures = null,
    Object? operationTypeBreakdown = null,
    Object? lastResetTime = freezed,
  }) {
    return _then(
      _$BatchMetricsImpl(
        totalProcessingTime: null == totalProcessingTime
            ? _value.totalProcessingTime
            : totalProcessingTime // ignore: cast_nullable_to_non_nullable
                  as Duration,
        totalOperations: null == totalOperations
            ? _value.totalOperations
            : totalOperations // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBatches: null == totalBatches
            ? _value.totalBatches
            : totalBatches // ignore: cast_nullable_to_non_nullable
                  as int,
        averageProcessingTime: null == averageProcessingTime
            ? _value.averageProcessingTime
            : averageProcessingTime // ignore: cast_nullable_to_non_nullable
                  as Duration,
        averageBatchTime: null == averageBatchTime
            ? _value.averageBatchTime
            : averageBatchTime // ignore: cast_nullable_to_non_nullable
                  as Duration,
        totalOptimizations: null == totalOptimizations
            ? _value.totalOptimizations
            : totalOptimizations // ignore: cast_nullable_to_non_nullable
                  as int,
        totalFailures: null == totalFailures
            ? _value.totalFailures
            : totalFailures // ignore: cast_nullable_to_non_nullable
                  as int,
        operationTypeBreakdown: null == operationTypeBreakdown
            ? _value._operationTypeBreakdown
            : operationTypeBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<BatchOperationType, int>,
        lastResetTime: freezed == lastResetTime
            ? _value.lastResetTime
            : lastResetTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BatchMetricsImpl extends _BatchMetrics {
  const _$BatchMetricsImpl({
    this.totalProcessingTime = Duration.zero,
    this.totalOperations = 0,
    this.totalBatches = 0,
    this.averageProcessingTime = Duration.zero,
    this.averageBatchTime = Duration.zero,
    this.totalOptimizations = 0,
    this.totalFailures = 0,
    final Map<BatchOperationType, int> operationTypeBreakdown = const {},
    this.lastResetTime,
  }) : _operationTypeBreakdown = operationTypeBreakdown,
       super._();

  @override
  @JsonKey()
  final Duration totalProcessingTime;
  @override
  @JsonKey()
  final int totalOperations;
  @override
  @JsonKey()
  final int totalBatches;
  @override
  @JsonKey()
  final Duration averageProcessingTime;
  @override
  @JsonKey()
  final Duration averageBatchTime;
  @override
  @JsonKey()
  final int totalOptimizations;
  @override
  @JsonKey()
  final int totalFailures;
  final Map<BatchOperationType, int> _operationTypeBreakdown;
  @override
  @JsonKey()
  Map<BatchOperationType, int> get operationTypeBreakdown {
    if (_operationTypeBreakdown is EqualUnmodifiableMapView)
      return _operationTypeBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_operationTypeBreakdown);
  }

  @override
  final DateTime? lastResetTime;

  @override
  String toString() {
    return 'BatchMetrics(totalProcessingTime: $totalProcessingTime, totalOperations: $totalOperations, totalBatches: $totalBatches, averageProcessingTime: $averageProcessingTime, averageBatchTime: $averageBatchTime, totalOptimizations: $totalOptimizations, totalFailures: $totalFailures, operationTypeBreakdown: $operationTypeBreakdown, lastResetTime: $lastResetTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchMetricsImpl &&
            (identical(other.totalProcessingTime, totalProcessingTime) ||
                other.totalProcessingTime == totalProcessingTime) &&
            (identical(other.totalOperations, totalOperations) ||
                other.totalOperations == totalOperations) &&
            (identical(other.totalBatches, totalBatches) ||
                other.totalBatches == totalBatches) &&
            (identical(other.averageProcessingTime, averageProcessingTime) ||
                other.averageProcessingTime == averageProcessingTime) &&
            (identical(other.averageBatchTime, averageBatchTime) ||
                other.averageBatchTime == averageBatchTime) &&
            (identical(other.totalOptimizations, totalOptimizations) ||
                other.totalOptimizations == totalOptimizations) &&
            (identical(other.totalFailures, totalFailures) ||
                other.totalFailures == totalFailures) &&
            const DeepCollectionEquality().equals(
              other._operationTypeBreakdown,
              _operationTypeBreakdown,
            ) &&
            (identical(other.lastResetTime, lastResetTime) ||
                other.lastResetTime == lastResetTime));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalProcessingTime,
    totalOperations,
    totalBatches,
    averageProcessingTime,
    averageBatchTime,
    totalOptimizations,
    totalFailures,
    const DeepCollectionEquality().hash(_operationTypeBreakdown),
    lastResetTime,
  );

  /// Create a copy of BatchMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchMetricsImplCopyWith<_$BatchMetricsImpl> get copyWith =>
      __$$BatchMetricsImplCopyWithImpl<_$BatchMetricsImpl>(this, _$identity);
}

abstract class _BatchMetrics extends BatchMetrics {
  const factory _BatchMetrics({
    final Duration totalProcessingTime,
    final int totalOperations,
    final int totalBatches,
    final Duration averageProcessingTime,
    final Duration averageBatchTime,
    final int totalOptimizations,
    final int totalFailures,
    final Map<BatchOperationType, int> operationTypeBreakdown,
    final DateTime? lastResetTime,
  }) = _$BatchMetricsImpl;
  const _BatchMetrics._() : super._();

  @override
  Duration get totalProcessingTime;
  @override
  int get totalOperations;
  @override
  int get totalBatches;
  @override
  Duration get averageProcessingTime;
  @override
  Duration get averageBatchTime;
  @override
  int get totalOptimizations;
  @override
  int get totalFailures;
  @override
  Map<BatchOperationType, int> get operationTypeBreakdown;
  @override
  DateTime? get lastResetTime;

  /// Create a copy of BatchMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchMetricsImplCopyWith<_$BatchMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
