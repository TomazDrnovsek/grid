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
                    // Screen title
                    Text(
                      'Cloud Backup',
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

                      // Cloud folder status
                      _buildCloudFolderSection(backupState, backupNotifier, isDark),

                      const SizedBox(height: 24),

                      // Actions
                      _buildActionButtonsSection(backupState, backupNotifier, isDark),

                      const SizedBox(height: 24),

                      // Backup status
                      _buildBackupStatusSection(backupState, isDark),

                      const SizedBox(height: 16),

                      // Dynamic status sections
                      if (backupState.status == BackupStatus.running) ...[
                        _buildProgressSection(backupState, backupNotifier, isDark),
                        const SizedBox(height: 16),
                      ] else if (backupState.status == BackupStatus.error) ...[
                        _buildErrorSection(backupState, isDark),
                        const SizedBox(height: 16),
                      ] else if (backupState.status == BackupStatus.success) ...[
                        _buildSuccessSection(backupState, isDark),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudFolderSection(BackupState backupState, BackupNotifier backupNotifier, bool isDark) {
    final hasCloudFolder = backupState.cloudFolderName != null;

    return Card(
      elevation: 0,
      color: AppColors.modalContentBackground(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cloud Storage', style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  hasCloudFolder ? Icons.folder : Icons.folder_outlined,
                  color: hasCloudFolder ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasCloudFolder ? backupState.cloudFolderName! : 'No folder selected',
                    style: AppTheme.body(isDark).copyWith(
                      color: hasCloudFolder ? AppColors.textPrimary(isDark) : AppColors.textSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isOperationInProgress ? null : () => _selectCloudFolder(backupNotifier),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary(isDark),
                  side: BorderSide(color: AppColors.textSecondary(isDark)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  hasCloudFolder ? 'Change Folder' : 'Select Folder',
                  style: AppTheme.body(isDark).copyWith(fontSize: 14),
                ),
              ),
            ),
            if (hasCloudFolder) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isOperationInProgress ? null : () => _forgetCloudFolder(backupNotifier),
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsSection(BackupState backupState, BackupNotifier backupNotifier, bool isDark) {
    final hasCloudFolder = backupState.cloudFolderName != null;
    final isOperationInProgress = backupState.status == BackupStatus.running || _isOperationInProgress;

    return Card(
      elevation: 0,
      color: AppColors.modalContentBackground(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isOperationInProgress || !hasCloudFolder) ? null : () => _performBackup(backupNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary(isDark),
                  foregroundColor: AppColors.scaffoldBackground(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                label: Text('Backup Now', style: AppTheme.body(!isDark).copyWith(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (isOperationInProgress || !hasCloudFolder) ? null : () => _performRestore(backupNotifier),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary(isDark),
                  side: BorderSide(color: AppColors.textSecondary(isDark)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.cloud_download_outlined, size: 20),
                label: Text('Restore from Backup', style: AppTheme.body(isDark).copyWith(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupStatusSection(BackupState backupState, bool isDark) {
    final lastBackupDate = backupState.lastBackupDate;

    return Card(
      elevation: 0,
      color: AppColors.modalContentBackground(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last Backup', style: AppTheme.body(isDark).copyWith(fontSize: 14, color: AppColors.textSecondary(isDark))),
                Text(
                  lastBackupDate != null ? _formatDate(lastBackupDate) : 'Never',
                  style: AppTheme.body(isDark).copyWith(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BackupState backupState, BackupNotifier backupNotifier, bool isDark) {
    final progress = backupState.current;
    final total = backupState.total;
    final progressPercentage = total > 0 ? (progress / total * 100).round() : 0;
    final isBackup = backupState.phase == BackupPhase.backingUp;

    return Card(
      elevation: 0,
      color: AppColors.modalContentBackground(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBackup ? 'Backing up...' : 'Restoring...',
                  style: AppTheme.body(isDark).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$progressPercentage%',
                  style: AppTheme.body(isDark).copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total > 0 ? progress / total : 0,
              backgroundColor: AppColors.textSecondary(isDark).withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary(isDark)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progress of $total photos',
                  style: AppTheme.body(isDark).copyWith(fontSize: 12, color: AppColors.textSecondary(isDark)),
                ),
                TextButton(
                  onPressed: () => backupNotifier.cancelOperation(),
                  child: Text(
                    'Cancel',
                    style: AppTheme.body(isDark).copyWith(fontSize: 14, color: AppColors.deleteButtonText(isDark)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(BackupState backupState, bool isDark) {
    return Card(
      elevation: 0,
      color: AppColors.deleteButtonText(isDark).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.deleteButtonText(isDark), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Operation Failed',
                  style: AppTheme.body(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.deleteButtonText(isDark),
                  ),
                ),
              ],
            ),
            if (backupState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                backupState.error!,
                style: AppTheme.body(isDark).copyWith(
                  fontSize: 14,
                  color: AppColors.deleteButtonText(isDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessSection(BackupState backupState, bool isDark) {
    final isBackup = backupState.phase == BackupPhase.backingUp;
    final itemCount = backupState.total;

    return Card(
      elevation: 0,
      color: Colors.green.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  isBackup ? 'Backup Complete' : 'Restore Complete',
                  style: AppTheme.body(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isBackup
                  ? 'Successfully backed up $itemCount photos to cloud storage.'
                  : 'Successfully restored $itemCount photos from backup.',
              style: AppTheme.body(isDark).copyWith(fontSize: 14, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCloudFolder(BackupNotifier backupNotifier) async {
    setState(() {
      _isOperationInProgress = true;
    });

    try {
      final safProvider = SafStorageProvider();
      final result = await safProvider.pickDirectory();

      if (result != null && mounted) {
        final uri = result['uri'];
        final name = result['name'];

        if (uri != null && name != null) {
          // Save the cloud folder configuration
          final success = await safProvider.setCloudFolder(uri, name);
          if (success) {
            // Update the backup provider state
            await backupNotifier.setCloudFolder(uri, name);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cloud folder selected: $name'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to set cloud folder'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error selecting cloud folder: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
      'Forget Cloud Folder',
      'This will remove the cloud folder configuration. Your backed up photos will remain in the cloud.',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isOperationInProgress = true;
    });

    try {
      await backupNotifier.removeCloudFolder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud folder configuration removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error forgetting cloud folder: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOperationInProgress = false;
        });
      }
    }
  }

  Future<void> _performBackup(BackupNotifier backupNotifier) async {
    setState(() {
      _isOperationInProgress = true;
    });

    try {
      await backupNotifier.performBackup();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error performing backup: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
    if (!confirmed || !mounted) return;

    setState(() {
      _isOperationInProgress = true;
    });

    try {
      await backupNotifier.performRestore();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error performing restore: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOperationInProgress = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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

  Future<bool> _showRestoreConfirmationDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.modalContentBackground(isDark),
          title: Text('Restore from Backup?', style: AppTheme.headlineSm(isDark)),
          content: Text(
            'This will replace all current photos with the backed up photos. This action cannot be undone.',
            style: AppTheme.body(isDark).copyWith(
              fontSize: 14,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary(isDark)),
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
                'Restore',
                style: AppTheme.body(isDark).copyWith(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }
}