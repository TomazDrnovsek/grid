// File: lib/ui/grid_home.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_config.dart';
import '../providers/photo_provider.dart';
import '../services/scroll_optimization_service.dart';
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
  bool _isAtTop = true;

  // FIXED: Scroll listener throttling to prevent excessive calls
  DateTime _lastScrollListenerCall = DateTime.now();
  static const _scrollListenerThrottleMs = 50; // Max 20 FPS for UI updates

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

  /// FIXED: Lightweight scroll optimizations that eliminate 6+ second operations
  void _setupOptimizedScrollHandling() {
    // Initialize the scroll optimization service
    _scrollOptimizer.initialize();

    // FIXED: Throttled scroll listener to prevent excessive UI updates
    _scrollController.addListener(_onScrollThrottled);
  }

  /// FIXED: Throttled scroll listener that prevents performance bottlenecks
  void _onScrollThrottled() {
    try {
      final now = DateTime.now();
      final timeSinceLastCall = now.difference(_lastScrollListenerCall).inMilliseconds;

      // FIXED: Skip if called too frequently (max 20 FPS for UI updates)
      if (timeSinceLastCall < _scrollListenerThrottleMs) return;

      _lastScrollListenerCall = now;

      // FIXED: Lightweight scroll position updates
      final offset = _scrollController.offset;
      final buffer = AppConfig().scrollBuffer;

      // FIXED: Only update state if there's an actual change
      final isCurrentlyAtTop = offset <= buffer;
      if (isCurrentlyAtTop != _isAtTop) {
        setState(() => _isAtTop = isCurrentlyAtTop);

        // FIXED: Minimal provider update (removed to prevent excessive state changes)
        // ref.read(photoNotifierProvider.notifier).updateScrollPosition(isCurrentlyAtTop);
      }

      // FIXED: Pass scroll updates to optimization service (now lightweight)
      _scrollOptimizer.onScrollUpdate(offset);

    } catch (e) {
      // Silent error handling to prevent scroll interruption
    }
  }

  void _setupHeaderUsernameListener() {
    _headerUsernameFocus.addListener(() {
      final photoState = ref.read(photoNotifierProvider);
      if (!_headerUsernameFocus.hasFocus && photoState.editingHeaderUsername) {
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
    final currentUsername = ref.read(photoNotifierProvider).headerUsername;

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

    // Watch the photo state from Riverpod
    final photoState = ref.watch(photoNotifierProvider);
    final photoNotifier = ref.read(photoNotifierProvider.notifier);

    return AnimatedBuilder(
      animation: widget.themeNotifier,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (photoState.editingHeaderUsername) {
              _headerUsernameFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.scaffoldBackground(isDark),
                bottomNavigationBar: Container(
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
                    child: photoState.hasSelection
                        ? Row(
                      mainAxisAlignment: photoState.hasSingleSelection
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
                            if (photoState.hasMultipleSelection) ...[
                              const SizedBox(width: 16),
                              Text(
                                '${photoState.selectedCount}',
                                style: AppTheme.bodyMedium(isDark).copyWith(
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (photoState.hasSingleSelection)
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
                          onTap: _scrollToTop,
                          child: SvgPicture.asset(
                            _isAtTop ? 'assets/home_icon-fill.svg' : 'assets/home_icon-outline.svg',
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
                ),
                body: CustomScrollView(
                  controller: _scrollController,
                  physics: const HighRefreshScrollPhysics(), // Use our optimized physics
                  cacheExtent: AppConfig().optimalCacheExtent, // Use cached optimal cache extent
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: photoState.editingHeaderUsername
                                    ? TextField(
                                  controller: _headerUsernameController,
                                  focusNode: _headerUsernameFocus,
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
                                  onTap: _startEditingHeaderUsername,
                                  child: Text(
                                    photoState.headerUsername,
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
                                  onTap: photoState.isLoading ? null : photoNotifier.addPhotos,
                                  child: Opacity(
                                    opacity: photoState.isLoading ? 0.5 : 1.0,
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
                                  onTap: _onMenuPressed,
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
                    ),
                    const SliverToBoxAdapter(
                      child: ProfileBlock(),
                    ),
                    if (photoState.isLoading && photoState.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    if (photoState.isNotEmpty)
                      PhotoSliverGrid(
                        images: photoState.images,
                        thumbnails: photoState.thumbnails.length == photoState.images.length
                            ? photoState.thumbnails
                            : List.from(photoState.images), // Fallback if thumbnails out of sync
                        selectedIndexes: photoState.selectedIndexes,
                        onTap: photoNotifier.toggleSelection,
                        onDoubleTap: photoNotifier.showImagePreview,
                        onLongPress: (_) {},
                        onReorder: photoNotifier.reorderImages,
                        scrollController: _scrollController, // Pass scroll controller for optimization
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),

              // Modal overlays with optimized animations
              AnimatedOpacity(
                opacity: photoState.showDeleteConfirm ? 1.0 : 0.0,
                duration: AppConfig().fastAnimationDuration, // Use cached fast animation duration
                curve: Curves.easeInOutCubic,
                child: photoState.showDeleteConfirm
                    ? DeleteConfirmModal(
                  onCancel: photoNotifier.cancelDelete,
                  onDelete: photoNotifier.confirmDelete,
                  isDark: isDark,
                )
                    : const SizedBox.shrink(),
              ),

              if (photoState.showImagePreview &&
                  photoState.previewImageIndex >= 0 &&
                  photoState.previewImageIndex < photoState.images.length)
                ImagePreviewModal(
                  image: photoState.images[photoState.previewImageIndex],
                  onClose: photoNotifier.closeImagePreview,
                ),
            ],
          ),
        );
      },
    );
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