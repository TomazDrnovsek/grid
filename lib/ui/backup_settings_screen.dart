// File: lib/ui/backup_settings_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_theme.dart';
import '../models/backup_models.dart';
import '../providers/backup_provider.dart';
import '../providers/photo_provider.dart';
import '../repositories/saf_storage_provider.dart';
import '../widgets/error_boundary.dart';

class BackupSettingsScreen extends ConsumerStatefulWidget {
  final ThemeNotifier themeNotifier;

  const BackupSettingsScreen({super.key, required this.themeNotifier});

  @override
  ConsumerState<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _isOperationInProgress = false;

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Theme listener
    widget.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backupState = ref.watch(backupProvider);
    final backupNotifier = ref.read(backupProvider.notifier);

    // Listen for restore success - this is the proper place for ref.listen in ConsumerStatefulWidget
    ref.listen<BackupState>(backupProvider, (prev, next) async {
      if (prev != null && mounted) {
        final restoreJustSucceeded = next.status == BackupStatus.success &&
            next.phase == BackupPhase.restoring;
        if (restoreJustSucceeded) {
          await ref.read(photoNotifierProvider.notifier).refreshImages();
        }
      }
    });

    return ErrorBoundary(
      errorContext: 'BackupSettingsScreen',
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground(isDark),
        body: SafeArea(
          child: Column(
            children: [
              // Top navigation bar
              Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back arrow
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/arrow_left.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          AppColors.textPrimary(isDark),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // ✅ UPDATED: Screen title changed to "Local Backup"
                    Text(
                      'Local Backup',
                      style: AppTheme.headlineSm(isDark),
                    ),
                    // Spacer to balance layout
                    const SizedBox(width: 24),
                  ],
                ),
              ),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ✅ UPDATED: Local folder section
                      _buildLocalFolderSection(backupState, backupNotifier, isDark),

                      const SizedBox(height: 24),

                      // ✅ UPDATED: Actions section with state-aware button labels (Step B3)
                      _buildActionButtonsSection(backupState, backupNotifier, isDark),

                      const SizedBox(height: 24),

                      // ✅ REMOVED: Status, Progress, Error, and Success sections per Step B3
                      // All state information now shown inline in button labels

                      // Version text spacer
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Version number at bottom (matching menu screen)
              Container(
                padding: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
                child: Text(
                  'Version 1.0',
                  style: AppTheme.body(isDark),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ UPDATED: Renamed and updated for Local Storage
  Widget _buildLocalFolderSection(BackupState backupState, BackupNotifier backupNotifier, bool isDark) {
    final hasCloudFolder = backupState.cloudFolderName != null;
    // ✅ ADDED: Check for active operations to disable Change Folder button
    final isOperationInProgress = backupState.status == BackupStatus.running || _isOperationInProgress;

    return Card(
      elevation: 0,
      color: Colors.transparent, // ✅ Removed black background in dark mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ UPDATED: Section heading changed to "Local Storage"
            Text('Local Storage', style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                // ✅ UPDATED: SVG folder icon instead of material icon
                SvgPicture.asset(
                  'assets/folder_icon.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    hasCloudFolder ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // ✅ UPDATED: Folder name placeholder updated
                    hasCloudFolder ? backupState.cloudFolderName! : 'Folder name',
                    style: AppTheme.body(isDark).copyWith(
                      color: hasCloudFolder ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ✅ UPDATED: Now disabled during operations
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOperationInProgress ? null : () => _selectCloudFolder(backupNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deleteButtonBackground(isDark), // Primary/black background
                  foregroundColor: AppColors.deleteButtonText(isDark), // White/black text
                  disabledBackgroundColor: AppColors.cancelButtonBackground(isDark), // ✅ Disabled fill
                  disabledForegroundColor: AppColors.textSecondary(isDark), // ✅ Disabled text
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Same as Delete dialog
                  ),
                ),
                child: Text(
                  hasCloudFolder ? 'Change Folder' : 'Select Folder',
                  style: AppTheme.body(isDark).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600, // ✅ Added to match action buttons
                    color: isOperationInProgress
                        ? AppColors.textSecondary(isDark) // ✅ Disabled color
                        : AppColors.deleteButtonText(isDark), // ✅ Enabled color
                  ),
                ),
              ),
            ),
            // ✅ FIXED: Maintain consistent spacing - always reserve space for "Forget Folder"
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44, // ✅ Reserve consistent height for button area
              child: hasCloudFolder && !isOperationInProgress
                  ? TextButton(
                onPressed: () => _forgetCloudFolder(backupNotifier),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deleteButtonText(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Forget Folder',
                  style: AppTheme.body(isDark).copyWith(
                    fontSize: 14,
                    color: AppColors.deleteButtonText(isDark),
                  ),
                ),
              )
                  : const SizedBox(), // ✅ Empty space when button is hidden
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ UPDATED: Actions section with state-aware button labels (Step B3)
  Widget _buildActionButtonsSection(BackupState backupState, BackupNotifier backupNotifier, bool isDark) {
    final hasCloudFolder = backupState.cloudFolderName != null;

    // ✅ Step B3: Map state to button labels and enablement
    String backupButtonText;
    bool backupButtonEnabled;
    String restoreButtonText;
    bool restoreButtonEnabled;

    switch (backupState.status) {
      case BackupStatus.running:
        if (backupState.phase == BackupPhase.backingUp) {
          // Backing up (i/n)
          final current = backupState.current;
          final total = backupState.total;
          backupButtonText = 'Backing up $current of $total photos...';
          backupButtonEnabled = false;
          restoreButtonText = 'Restore from Backup';
          restoreButtonEnabled = false;
        } else if (backupState.phase == BackupPhase.restoring) {
          // Restoring (i/n)
          final current = backupState.current;
          final total = backupState.total;
          backupButtonText = 'Backup Now';
          backupButtonEnabled = false;
          restoreButtonText = 'Restoring $current of $total photos...';
          restoreButtonEnabled = false;
        } else {
          // Default running state
          backupButtonText = 'Backup Now';
          backupButtonEnabled = false;
          restoreButtonText = 'Restore from Backup';
          restoreButtonEnabled = false;
        }
        break;

      case BackupStatus.success:
        if (backupState.phase == BackupPhase.backingUp) {
          // Backup complete
          backupButtonText = 'Backup Complete!';
          backupButtonEnabled = false;
          restoreButtonText = 'Restore from Backup';
          restoreButtonEnabled = hasCloudFolder;
        } else if (backupState.phase == BackupPhase.restoring) {
          // Restore complete
          backupButtonText = 'Backup Now';
          backupButtonEnabled = hasCloudFolder;
          restoreButtonText = 'Restore Complete!';
          restoreButtonEnabled = false;
        } else {
          // Default success state
          backupButtonText = 'Backup Now';
          backupButtonEnabled = hasCloudFolder;
          restoreButtonText = 'Restore from Backup';
          restoreButtonEnabled = hasCloudFolder;
        }
        break;

      case BackupStatus.idle:
      case BackupStatus.error:
      // Idle (can restore if has backup) or Error state
        final hasBackup = backupState.lastBackupDate != null;
        backupButtonText = 'Backup Now';
        backupButtonEnabled = hasCloudFolder && !_isOperationInProgress;
        restoreButtonText = 'Restore from Backup';
        restoreButtonEnabled = hasCloudFolder && hasBackup && !_isOperationInProgress;
        break;
    }

    return Card(
      elevation: 0,
      color: Colors.transparent, // ✅ Removed black background in dark mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            // ✅ UPDATED: Backup button with state-aware text
            SizedBox(
              width: double.infinity,
              height: 52, // ✅ Height ≈ 52dp as specified
              child: ElevatedButton(
                onPressed: backupButtonEnabled ? () => _performBackup(backupNotifier) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deleteButtonBackground(isDark), // ✅ Primary/black fill
                  foregroundColor: AppColors.deleteButtonText(isDark), // ✅ White/black text
                  disabledBackgroundColor: AppColors.cancelButtonBackground(isDark), // ✅ Disabled fill
                  disabledForegroundColor: AppColors.textSecondary(isDark), // ✅ Disabled text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ✅ Same as Delete dialog
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ SVG icon with proper color filtering
                    SvgPicture.asset(
                      'assets/folder-up_icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        backupButtonEnabled
                            ? AppColors.deleteButtonText(isDark)
                            : AppColors.textSecondary(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12), // ✅ Icon-to-label spacing = 12dp
                    Flexible(
                      child: Text(
                        backupButtonText,
                        style: AppTheme.body(isDark).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: backupButtonEnabled
                              ? AppColors.deleteButtonText(isDark)
                              : AppColors.textSecondary(isDark),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ UPDATED: Restore button with state-aware text
            SizedBox(
              width: double.infinity,
              height: 52, // ✅ Height ≈ 52dp as specified
              child: ElevatedButton(
                onPressed: restoreButtonEnabled ? () => _performRestore(backupNotifier) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deleteButtonBackground(isDark), // ✅ Primary/black fill
                  foregroundColor: AppColors.deleteButtonText(isDark), // ✅ White/black text
                  disabledBackgroundColor: AppColors.cancelButtonBackground(isDark), // ✅ Disabled fill
                  disabledForegroundColor: AppColors.textSecondary(isDark), // ✅ Disabled text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ✅ Same as Delete dialog
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ SVG icon with proper color filtering
                    SvgPicture.asset(
                      'assets/folder-down_icon.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        restoreButtonEnabled
                            ? AppColors.deleteButtonText(isDark)
                            : AppColors.textSecondary(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12), // ✅ Icon-to-label spacing = 12dp
                    Flexible(
                      child: Text(
                        restoreButtonText,
                        style: AppTheme.body(isDark).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: restoreButtonEnabled
                              ? AppColors.deleteButtonText(isDark)
                              : AppColors.textSecondary(isDark),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCloudFolder(BackupNotifier backupNotifier) async {
    try {
      setState(() {
        _isOperationInProgress = true;
      });

      final safProvider = SafStorageProvider();
      final result = await safProvider.pickDirectory();

      if (result != null && mounted) {
        final uri = result['uri'];
        final name = result['name'];

        if (uri != null && name != null) {
          await backupNotifier.setCloudFolder(uri, name);
        }
      }
    } catch (e) {
      if (mounted && kDebugMode) {
        debugPrint('Error selecting cloud folder: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOperationInProgress = false;
        });
      }
    }
  }

  Future<void> _forgetCloudFolder(BackupNotifier backupNotifier) async {
    final confirmed = await _showConfirmationDialog(
      'Forget Folder?',
      'This will remove the cloud folder configuration. You can always select it again later.',
    );

    if (confirmed && mounted) {
      await backupNotifier.removeCloudFolder();
    }
  }

  Future<void> _performBackup(BackupNotifier backupNotifier) async {
    try {
      setState(() {
        _isOperationInProgress = true;
      });

      await backupNotifier.performBackup();
    } catch (e) {
      if (mounted && kDebugMode) {
        debugPrint('Error performing backup: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOperationInProgress = false;
        });
      }
    }
  }

  Future<void> _performRestore(BackupNotifier backupNotifier) async {
    final confirmed = await _showRestoreConfirmationDialog();

    if (confirmed && mounted) {
      try {
        setState(() {
          _isOperationInProgress = true;
        });

        await backupNotifier.performRestore();
      } catch (e) {
        if (mounted && kDebugMode) {
          debugPrint('Error performing restore: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isOperationInProgress = false;
          });
        }
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.modalContentBackground(isDark),
          title: Text(title, style: AppTheme.headlineSm(isDark)),
          content: Text(message, style: AppTheme.body(isDark).copyWith(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTheme.body(isDark).copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deleteButtonText(isDark),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Confirm',
                style: AppTheme.body(isDark).copyWith(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// ✅ UPDATED: Restore confirmation dialog matching Delete dialog shape (Step B4)
  Future<bool> _showRestoreConfirmationDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  color: AppColors.modalOverlayBackground(isDark),
                ),
              ),
            ),
            Center(
              child: Semantics(
                label: 'Restore confirmation dialog',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.modalContentBackground(isDark),
                    borderRadius: BorderRadius.circular(20), // ✅ Same as Delete dialog
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Title only: "Are you sure?"
                      Text(
                        'Are you sure?',
                        textAlign: TextAlign.center,
                        style: AppTheme.dialogTitle(isDark),
                      ),
                      const SizedBox(height: 24),
                      // ✅ Buttons side-by-side matching Delete dialog
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ Cancel button - secondary/grey style (same as Delete dialog Cancel)
                          SizedBox(
                            width: 80, // ✅ Same width as Delete dialog
                            height: 44, // ✅ Same height as Delete dialog
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    AppColors.cancelButtonBackground(isDark)),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // ✅ Same as Delete dialog
                                  ),
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  AppColors.textPrimary(isDark).withAlpha(18),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: AppTheme.dialogActionPrimary(isDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16), // ✅ Same spacing as Delete dialog
                          // ✅ Restore button - primary/black style (same as Delete dialog Delete button)
                          SizedBox(
                            width: 80, // ✅ Same width as Delete dialog
                            height: 44, // ✅ Same height as Delete dialog
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    AppColors.deleteButtonBackground(isDark)),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // ✅ Same as Delete dialog
                                  ),
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  AppColors.deleteButtonOverlay(isDark),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Restore',
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
      },
    ) ?? false;
  }
}