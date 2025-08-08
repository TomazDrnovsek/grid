// File: lib/ui/grid_home.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_config.dart';
import '../providers/photo_provider.dart';
import '../services/scroll_optimization_service.dart';
import '../models/photo_state.dart';
import 'profile_block.dart';
import 'photo_sliver_grid.dart';
import 'menu_screen.dart';
import '../app_theme.dart';

/// High refresh rate optimized scroll physics that adapts to device capabilities
/// Provides buttery smooth scrolling on 120Hz+ displays while maintaining
/// excellent performance on standard 60Hz screens
class HighRefreshScrollPhysics extends BouncingScrollPhysics {
  const HighRefreshScrollPhysics({super.parent});

  @override
  HighRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return HighRefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring {
    // Use cached performance configuration
    return AppConfig().optimizedSpringDescription;
  }

  @override
  double get minFlingVelocity {
    // Use cached configuration
    return AppConfig().minFlingVelocity;
  }

  @override
  double get maxFlingVelocity {
    // Use cached configuration
    return AppConfig().maxFlingVelocity;
  }
}

class GridHomePage extends ConsumerStatefulWidget {
  final ThemeNotifier themeNotifier;

  const GridHomePage({super.key, required this.themeNotifier});

  @override
  ConsumerState<GridHomePage> createState() => _GridHomePageState();
}

class _GridHomePageState extends ConsumerState<GridHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  // FIXED: Lightweight scroll controller with optimized listener
  final ScrollController _scrollController = ScrollController();
  final ScrollOptimizationService _scrollOptimizer = ScrollOptimizationService();

  // FIXED: Scroll listener throttling synced to high refresh rate display
  DateTime _lastScrollListenerCall = DateTime.now();
  static const _scrollListenerThrottleMs = 16; // FIXED: 60 FPS (16ms) synced to 120Hz display

  // Header username editing
  final TextEditingController _headerUsernameController = TextEditingController();
  final FocusNode _headerUsernameFocus = FocusNode();

  // Keep the state alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupOptimizedScrollHandling();
    _setupHeaderUsernameListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerUsernameController.dispose();
    _headerUsernameFocus.dispose();
    _scrollOptimizer.dispose();
    super.dispose();
  }

  /// FIXED: Ultra-lightweight scroll handling that eliminates stutters
  void _setupOptimizedScrollHandling() {
    // Initialize the scroll optimization service
    _scrollOptimizer.initialize();

    // FIXED: Ultra-lightweight scroll listener
    _scrollController.addListener(_onScrollUltraLightweight);
  }

  /// FIXED: Responsive scroll listener synced to 120Hz display
  void _onScrollUltraLightweight() {
    try {
      final now = DateTime.now();
      final timeSinceLastCall = now.difference(_lastScrollListenerCall).inMilliseconds;

      // FIXED: 60 FPS updates (16ms) - much more responsive for 120Hz display
      if (timeSinceLastCall < _scrollListenerThrottleMs) return;

      _lastScrollListenerCall = now;

      final offset = _scrollController.offset;
      final buffer = AppConfig().scrollBuffer;

      // FIXED: Use Riverpod to update scroll position (no setState!)
      final photoNotifier = ref.read(photoNotifierProvider.notifier);
      final isCurrentlyAtTop = offset <= buffer;
      photoNotifier.updateScrollPosition(isCurrentlyAtTop);

      // FIXED: Pass scroll updates to optimization service (lightweight)
      _scrollOptimizer.onScrollUpdate(offset);

    } catch (e) {
      // Silent error handling to prevent scroll interruption
    }
  }

  void _setupHeaderUsernameListener() {
    _headerUsernameFocus.addListener(() {
      final editingHeaderUsername = ref.read(photoNotifierProvider.select((state) => state.editingHeaderUsername));
      if (!_headerUsernameFocus.hasFocus && editingHeaderUsername) {
        final notifier = ref.read(photoNotifierProvider.notifier);
        notifier.saveHeaderUsername(_headerUsernameController.text);
      }
    });
  }

  /// FIXED: Optimized scroll to top with lightweight animation
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: AppConfig().fastAnimationDuration,
        curve: Curves.easeOutCubic, // Smooth curve optimized for high refresh rate
      );
    }
  }

  /// Start editing header username
  void _startEditingHeaderUsername() {
    final notifier = ref.read(photoNotifierProvider.notifier);
    final currentUsername = ref.read(photoNotifierProvider.select((state) => state.headerUsername));

    notifier.startEditingHeaderUsername();
    _headerUsernameController.text = currentUsername;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerUsernameFocus.requestFocus();
    });
  }

  void _onMenuPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(themeNotifier: widget.themeNotifier),
        transitionDuration: AppConfig().animationDuration,
        reverseTransitionDuration: AppConfig().animationDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic, // Smooth curve optimized for high refresh rate
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // OPTIMIZATION: Granular state selectors to prevent 79-image grid cascade rebuilds
    final photoNotifier = ref.read(photoNotifierProvider.notifier);

    return AnimatedBuilder(
      animation: widget.themeNotifier,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            final editingHeaderUsername = ref.read(photoNotifierProvider.select((state) => state.editingHeaderUsername));
            if (editingHeaderUsername) {
              _headerUsernameFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.scaffoldBackground(isDark),
                bottomNavigationBar: _OptimizedBottomNavigationBar(
                  isDark: isDark,
                  onScrollToTop: _scrollToTop,
                  photoNotifier: photoNotifier,
                ),
                body: CustomScrollView(
                  controller: _scrollController,
                  physics: const HighRefreshScrollPhysics(), // Use our optimized physics
                  cacheExtent: AppConfig().optimalCacheExtent, // Use cached optimal cache extent
                  slivers: [
                    _OptimizedHeaderSliver(
                      isDark: isDark,
                      onMenuPressed: _onMenuPressed,
                      onStartEditingUsername: _startEditingHeaderUsername,
                      headerUsernameController: _headerUsernameController,
                      headerUsernameFocus: _headerUsernameFocus,
                      photoNotifier: photoNotifier,
                    ),
                    const SliverToBoxAdapter(
                      child: ProfileBlock(),
                    ),
                    _OptimizedLoadingSliver(),
                    _OptimizedPhotoGridSliver(
                      scrollController: _scrollController,
                      photoNotifier: photoNotifier,
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),

              // Modal overlays with optimized animations
              _OptimizedDeleteModal(
                isDark: isDark,
                photoNotifier: photoNotifier,
              ),

              // PHASE 1: Loading modal with progress
              _OptimizedLoadingModal(
                isDark: isDark,
                photoNotifier: photoNotifier,
              ),

              _OptimizedImagePreviewModal(
                onClose: photoNotifier.closeImagePreview,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// FIXED: Bottom navigation bar with Riverpod scroll state (responsive at 60 FPS)
class _OptimizedBottomNavigationBar extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onScrollToTop;
  final dynamic photoNotifier;

  const _OptimizedBottomNavigationBar({
    required this.isDark,
    required this.onScrollToTop,
    required this.photoNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch selection-related state
    final selectedIndexes = ref.watch(photoNotifierProvider.select((state) => state.selectedIndexes));
    // FIXED: Watch scroll position from Riverpod - now updates at 60 FPS for smooth UI
    final isAtTop = ref.watch(photoNotifierProvider.select((state) => state.isAtTop));

    final hasSelection = selectedIndexes.isNotEmpty;
    final hasSingleSelection = selectedIndexes.length == 1;
    final hasMultipleSelection = selectedIndexes.length > 1;
    final selectedCount = selectedIndexes.length;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.bottomBarBackground(isDark),
        border: Border(
          top: BorderSide(
            color: AppColors.sheetDivider(isDark),
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: hasSelection
            ? Row(
          mainAxisAlignment: hasSingleSelection
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: photoNotifier.showDeleteConfirmation,
                  child: SvgPicture.asset(
                    'assets/delete_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      AppColors.textPrimary(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                if (hasMultipleSelection) ...[
                  const SizedBox(width: 16),
                  Text(
                    '$selectedCount',
                    style: AppTheme.bodyMedium(isDark).copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ],
            ),
            if (hasSingleSelection)
              GestureDetector(
                onTap: photoNotifier.shareSelectedImage,
                child: SvgPicture.asset(
                  'assets/share_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.textPrimary(isDark),
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onScrollToTop,
              child: SvgPicture.asset(
                // FIXED: Icon changes now update at 60 FPS - smooth and responsive
                isAtTop ? 'assets/home_icon-fill.svg' : 'assets/home_icon-outline.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary(isDark),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OPTIMIZATION: Header that only rebuilds when header-related state changes
class _OptimizedHeaderSliver extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onMenuPressed;
  final VoidCallback onStartEditingUsername;
  final TextEditingController headerUsernameController;
  final FocusNode headerUsernameFocus;
  final dynamic photoNotifier;

  const _OptimizedHeaderSliver({
    required this.isDark,
    required this.onMenuPressed,
    required this.onStartEditingUsername,
    required this.headerUsernameController,
    required this.headerUsernameFocus,
    required this.photoNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch header and loading state
    final editingHeaderUsername = ref.watch(photoNotifierProvider.select((state) => state.editingHeaderUsername));
    final headerUsername = ref.watch(photoNotifierProvider.select((state) => state.headerUsername));
    final isLoading = ref.watch(photoNotifierProvider.select((state) => state.isLoading));

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: editingHeaderUsername
                    ? TextField(
                  controller: headerUsernameController,
                  focusNode: headerUsernameFocus,
                  style: AppTheme.headlineSm(isDark),
                  maxLines: 1,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
                    : GestureDetector(
                  onTap: onStartEditingUsername,
                  child: Text(
                    headerUsername,
                    style: AppTheme.headlineSm(isDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isLoading ? null : photoNotifier.addPhotos,
                  child: Opacity(
                    opacity: isLoading ? 0.5 : 1.0,
                    child: SvgPicture.asset(
                      'assets/add_button.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppColors.textPrimary(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onMenuPressed,
                  child: SvgPicture.asset(
                    'assets/menu_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      AppColors.textPrimary(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// OPTIMIZATION: Loading indicator that only rebuilds when loading state changes
class _OptimizedLoadingSliver extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch loading and image state
    final isLoading = ref.watch(photoNotifierProvider.select((state) => state.isLoading));
    final isEmpty = ref.watch(photoNotifierProvider.select((state) => state.images.isEmpty));

    if (isLoading && isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

/// OPTIMIZATION: Photo grid that only rebuilds when image/selection state changes
class _OptimizedPhotoGridSliver extends ConsumerWidget {
  final ScrollController scrollController;
  final dynamic photoNotifier;

  const _OptimizedPhotoGridSliver({
    required this.scrollController,
    required this.photoNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch image and selection state
    final images = ref.watch(photoNotifierProvider.select((state) => state.images));
    final thumbnails = ref.watch(photoNotifierProvider.select((state) => state.thumbnails));
    final selectedIndexes = ref.watch(photoNotifierProvider.select((state) => state.selectedIndexes));
    final isNotEmpty = images.isNotEmpty;

    if (isNotEmpty) {
      return PhotoSliverGrid(
        images: images,
        thumbnails: thumbnails.length == images.length
            ? thumbnails
            : List.from(images), // Fallback if thumbnails out of sync
        selectedIndexes: selectedIndexes,
        onTap: photoNotifier.toggleSelection,
        onDoubleTap: photoNotifier.showImagePreview,
        onLongPress: (_) {},
        onReorder: photoNotifier.reorderImages,
        scrollController: scrollController, // Pass scroll controller for optimization
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

/// OPTIMIZATION: Delete modal that only rebuilds when delete modal state changes
class _OptimizedDeleteModal extends ConsumerWidget {
  final bool isDark;
  final dynamic photoNotifier;

  const _OptimizedDeleteModal({
    required this.isDark,
    required this.photoNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch delete modal state
    final showDeleteConfirm = ref.watch(photoNotifierProvider.select((state) => state.showDeleteConfirm));

    return AnimatedOpacity(
      opacity: showDeleteConfirm ? 1.0 : 0.0,
      duration: AppConfig().fastAnimationDuration, // Use cached fast animation duration
      curve: Curves.easeInOutCubic,
      child: showDeleteConfirm
          ? DeleteConfirmModal(
        onCancel: photoNotifier.cancelDelete,
        onDelete: photoNotifier.confirmDelete,
        isDark: isDark,
      )
          : const SizedBox.shrink(),
    );
  }
}

/// PHASE 1: Loading modal that only rebuilds when loading modal state changes
class _OptimizedLoadingModal extends ConsumerWidget {
  final bool isDark;
  final dynamic photoNotifier;

  const _OptimizedLoadingModal({
    required this.isDark,
    required this.photoNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch loading modal state
    final showLoadingModal = ref.watch(photoNotifierProvider.select((state) => state.showLoadingModal));
    final currentBatchOperation = ref.watch(photoNotifierProvider.select((state) => state.currentBatchOperation));

    return AnimatedOpacity(
      opacity: showLoadingModal ? 1.0 : 0.0,
      duration: AppConfig().fastAnimationDuration,
      curve: Curves.easeInOutCubic,
      child: showLoadingModal && currentBatchOperation != null
          ? LoadingModal(
        batchOperation: currentBatchOperation,
        isDark: isDark,
      )
          : const SizedBox.shrink(),
    );
  }
}

/// OPTIMIZATION: Image preview modal that only rebuilds when preview state changes
class _OptimizedImagePreviewModal extends ConsumerWidget {
  final VoidCallback onClose;

  const _OptimizedImagePreviewModal({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OPTIMIZATION: Only watch image preview state
    final showImagePreview = ref.watch(photoNotifierProvider.select((state) => state.showImagePreview));
    final previewImageIndex = ref.watch(photoNotifierProvider.select((state) => state.previewImageIndex));
    final images = ref.watch(photoNotifierProvider.select((state) => state.images));

    if (showImagePreview &&
        previewImageIndex >= 0 &&
        previewImageIndex < images.length) {
      return ImagePreviewModal(
        image: images[previewImageIndex],
        onClose: onClose,
      );
    }

    return const SizedBox.shrink();
  }
}

// Optimized image preview modal
class ImagePreviewModal extends StatelessWidget {
  final File image;
  final VoidCallback onClose;

  const ImagePreviewModal({
    super.key,
    required this.image,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.imagePreviewOverlay,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Hero(
              tag: 'image_${image.path}',
              child: Image.file(
                image,
                fit: BoxFit.contain,
                gaplessPlayback: true, // Prevent blinking on high refresh rate
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.imagePreviewErrorIcon,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: AppTheme.imagePreviewError,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized delete confirm modal
class DeleteConfirmModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool isDark;

  const DeleteConfirmModal({
    super.key,
    required this.onCancel,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              color: AppColors.modalOverlayBackground(isDark),
            ),
          ),
        ),
        Center(
          child: Semantics(
            label: 'Delete confirmation dialog',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.modalContentBackground(isDark),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure?',
                    textAlign: TextAlign.center,
                    style: AppTheme.dialogTitle(isDark),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                AppColors.cancelButtonBackground(isDark)),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.textPrimary(isDark).withAlpha(18),
                            ),
                          ),
                          onPressed: onCancel,
                          child: Text(
                            'Cancel',
                            style: AppTheme.dialogActionPrimary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        height: 44,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                AppColors.deleteButtonBackground(isDark)),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            overlayColor: WidgetStateProperty.all(
                              AppColors.deleteButtonOverlay(isDark),
                            ),
                          ),
                          onPressed: onDelete,
                          child: Text(
                            'Delete',
                            style: AppTheme.dialogActionDanger(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// PHASE 1: Loading modal with progress display
class LoadingModal extends StatelessWidget {
  final BatchOperationStatus batchOperation;
  final bool isDark;

  const LoadingModal({
    super.key,
    required this.batchOperation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = batchOperation.progress;
    final progressPercentage = (progress * 100).round();

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: AppColors.modalOverlayBackground(isDark),
          ),
        ),
        Center(
          child: Semantics(
            label: 'Loading progress dialog',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.modalContentBackground(isDark),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress circle with percentage
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: AppColors.textSecondary(isDark).withAlpha(51),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary(isDark),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              '$progressPercentage%',
                              style: AppTheme.bodyMedium(isDark).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Operation status
                  Text(
                    batchOperation.status,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium(isDark),
                  ),
                  const SizedBox(height: 8),
                  // Progress text
                  Text(
                    '${batchOperation.completedOperations} of ${batchOperation.operationCount}',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(isDark).copyWith(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}