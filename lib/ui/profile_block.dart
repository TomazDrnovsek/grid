// File: lib/ui/profile_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:grid/app_theme.dart';
import '../file_utils.dart';

// Profile data model
class ProfileData {
  String username;
  String posts;
  String followers;
  String following;
  String bio;
  String? profileImagePath;

  ProfileData({
    this.username = 'tomazdrnovsek',
    this.posts = '327',
    this.followers = '3,333',
    this.following = '813',
    this.bio = 'From Ljubljana, Slovenia.',
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'posts': posts,
    'followers': followers,
    'following': following,
    'bio': bio,
    'profileImagePath': profileImagePath,
  };

  static ProfileData fromJson(Map<String, dynamic> json) {
    try {
      return ProfileData(
        username: json['username']?.toString() ?? 'tomazdrnovsek',
        posts: json['posts']?.toString() ?? '327',
        followers: json['followers']?.toString() ?? '3,333',
        following: json['following']?.toString() ?? '813',
        bio: json['bio']?.toString() ?? 'From Ljubljana, Slovenia.',
        profileImagePath: json['profileImagePath']?.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing ProfileData from JSON: $e');
      return ProfileData(); // Return default profile
    }
  }
}

// Profile data manager
class ProfileDataManager {
  static const String _key = 'profile_data';

  static Future<ProfileData> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          final profile = ProfileData.fromJson(json);

          // Validate profile image exists
          if (profile.profileImagePath != null) {
            final imageFile = File(profile.profileImagePath!);
            if (!await imageFile.exists()) {
              debugPrint('Profile image no longer exists, clearing path');
              profile.profileImagePath = null;
            }
          }

          return profile;
        } catch (e) {
          debugPrint('Error decoding profile JSON: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading profile from SharedPreferences: $e');
    }
    return ProfileData();
  }

  static Future<bool> saveProfile(ProfileData profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return false;
    }
  }
}

/// Editable profile block that allows tap-to-edit functionality
class ProfileBlock extends StatefulWidget {
  const ProfileBlock({super.key});

  @override
  State<ProfileBlock> createState() => _ProfileBlockState();
}

class _ProfileBlockState extends State<ProfileBlock>
    with AutomaticKeepAliveClientMixin {
  late ProfileData _profileData;
  bool _isLoading = true;
  bool _isSaving = false;

  // Editing state tracking
  bool _editingUsername = false;
  bool _editingPosts = false;
  bool _editingFollowers = false;
  bool _editingFollowing = false;
  bool _editingBio = false;

  // Text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postsController = TextEditingController();
  final TextEditingController _followersController = TextEditingController();
  final TextEditingController _followingController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Focus nodes
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _postsFocus = FocusNode();
  final FocusNode _followersFocus = FocusNode();
  final FocusNode _followingFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();

  // Keep the state alive to prevent rebuilds that cause image blinking
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _setupFocusListeners();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _postsController.dispose();
    _followersController.dispose();
    _followingController.dispose();
    _bioController.dispose();
    _usernameFocus.dispose();
    _postsFocus.dispose();
    _followersFocus.dispose();
    _followingFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  void _setupFocusListeners() {
    _usernameFocus.addListener(() {
      if (!_usernameFocus.hasFocus && _editingUsername) {
        _saveField('username', _usernameController.text);
        setState(() => _editingUsername = false);
      }
    });

    _postsFocus.addListener(() {
      if (!_postsFocus.hasFocus && _editingPosts) {
        _saveField('posts', _formatNumber(_postsController.text));
        setState(() => _editingPosts = false);
      }
    });

    _followersFocus.addListener(() {
      if (!_followersFocus.hasFocus && _editingFollowers) {
        _saveField('followers', _formatNumber(_followersController.text));
        setState(() => _editingFollowers = false);
      }
    });

    _followingFocus.addListener(() {
      if (!_followingFocus.hasFocus && _editingFollowing) {
        _saveField('following', _formatNumber(_followingController.text));
        setState(() => _editingFollowing = false);
      }
    });

    _bioFocus.addListener(() {
      if (!_bioFocus.hasFocus && _editingBio) {
        _saveField('bio', _bioController.text);
        setState(() => _editingBio = false);
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileDataManager.loadProfile();
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _profileData = ProfileData(); // Use default profile on error
          _isLoading = false;
        });
      }
    }
  }

  String _formatNumber(String input) {
    try {
      final cleaned = input.replaceAll(',', '').replaceAll(' ', '').trim();
      if (cleaned.isEmpty) return '0';

      final number = int.tryParse(cleaned);
      if (number == null) return input;

      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    } catch (e) {
      debugPrint('Error formatting number: $e');
      return input;
    }
  }

  String _unformatNumber(String formatted) {
    return formatted.replaceAll(',', '');
  }

  Future<void> _saveField(String field, String value) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Validate input
      final trimmedValue = value.trim();
      if (trimmedValue.isEmpty && field != 'bio') {
        // Don't allow empty values for username, posts, followers, following
        debugPrint('Rejecting empty value for field: $field');
        return;
      }

      switch (field) {
        case 'username':
          if (trimmedValue.length > 30) {
            debugPrint('Username too long, truncating');
            _profileData.username = trimmedValue.substring(0, 30);
          } else {
            _profileData.username = trimmedValue;
          }
          break;
        case 'posts':
          _profileData.posts = trimmedValue;
          break;
        case 'followers':
          _profileData.followers = trimmedValue;
          break;
        case 'following':
          _profileData.following = trimmedValue;
          break;
        case 'bio':
          if (trimmedValue.length > 100) {
            debugPrint('Bio too long, truncating');
            _profileData.bio = trimmedValue.substring(0, 100);
          } else {
            _profileData.bio = trimmedValue;
          }
          break;
      }

      final saved = await ProfileDataManager.saveProfile(_profileData);
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile changes'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving field $field: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while saving'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changeProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        try {
          final result = await FileUtils.processImageWithThumbnail(image);
          final profileImage = result['image']!;

          // Delete old profile image if it exists
          if (_profileData.profileImagePath != null) {
            try {
              final oldImage = File(_profileData.profileImagePath!);
              await FileUtils.deleteFileSafely(oldImage);
            } catch (e) {
              debugPrint('Failed to delete old profile image: $e');
            }
          }

          setState(() {
            _profileData.profileImagePath = profileImage.path;
          });

          final saved = await ProfileDataManager.saveProfile(_profileData);
          if (!saved && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to save profile image'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error processing profile image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to process profile image'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select profile image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _startEditing(String field) {
    if (_isSaving) return;

    setState(() {
      switch (field) {
        case 'username':
          _editingUsername = true;
          _usernameController.text = _profileData.username;
          break;
        case 'posts':
          _editingPosts = true;
          _postsController.text = _unformatNumber(_profileData.posts);
          break;
        case 'followers':
          _editingFollowers = true;
          _followersController.text = _unformatNumber(_profileData.followers);
          break;
        case 'following':
          _editingFollowing = true;
          _followingController.text = _unformatNumber(_profileData.following);
          break;
        case 'bio':
          _editingBio = true;
          _bioController.text = _profileData.bio;
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (field) {
        case 'username':
          _usernameFocus.requestFocus();
          break;
        case 'posts':
          _postsFocus.requestFocus();
          break;
        case 'followers':
          _followersFocus.requestFocus();
          break;
        case 'following':
          _followingFocus.requestFocus();
          break;
        case 'bio':
          _bioFocus.requestFocus();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _isSaving ? null : _changeProfileImage,
                    child: Opacity(
                      opacity: _isSaving ? 0.5 : 1.0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.avatarPlaceholder(isDark),
                        ),
                        child: ClipOval(
                          child: _HighRefreshProfileImage(
                            profileImagePath: _profileData.profileImagePath,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _editingUsername
                            ? TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          style: AppTheme.bodyMedium(isDark),
                          maxLines: 1,
                          maxLength: 30,
                          enabled: !_isSaving,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                            : GestureDetector(
                          onTap: _isSaving ? null : () => _startEditing('username'),
                          child: Text(_profileData.username, style: AppTheme.bodyMedium(isDark)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            EditableStat(
                              label: 'posts',
                              value: _profileData.posts,
                              isEditing: _editingPosts,
                              controller: _postsController,
                              focusNode: _postsFocus,
                              onTap: _isSaving ? () {} : () => _startEditing('posts'),
                              isDark: isDark,
                              isEnabled: !_isSaving,
                            ),
                            const SizedBox(width: 24),
                            EditableStat(
                              label: 'followers',
                              value: _profileData.followers,
                              isEditing: _editingFollowers,
                              controller: _followersController,
                              focusNode: _followersFocus,
                              onTap: _isSaving ? () {} : () => _startEditing('followers'),
                              isDark: isDark,
                              isEnabled: !_isSaving,
                            ),
                            const SizedBox(width: 24),
                            EditableStat(
                              label: 'following',
                              value: _profileData.following,
                              isEditing: _editingFollowing,
                              controller: _followingController,
                              focusNode: _followingFocus,
                              onTap: _isSaving ? () {} : () => _startEditing('following'),
                              isDark: isDark,
                              isEnabled: !_isSaving,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bio container - now dynamically sizes to content
              GestureDetector(
                onTap: () {
                  if (!_editingBio && !_isSaving) {
                    _startEditing('bio');
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: _editingBio
                      ? TextField(
                    controller: _bioController,
                    focusNode: _bioFocus,
                    style: AppTheme.body(isDark),
                    maxLines: null, // Allow multiple lines as needed
                    maxLength: 100,
                    enabled: !_isSaving,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                      : Text(
                    _profileData.bio,
                    style: AppTheme.body(isDark),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_editingBio || _editingUsername || _editingPosts || _editingFollowers || _editingFollowing)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_editingUsername) _usernameFocus.unfocus();
                if (_editingPosts) _postsFocus.unfocus();
                if (_editingFollowers) _followersFocus.unfocus();
                if (_editingFollowing) _followingFocus.unfocus();
                if (_editingBio) _bioFocus.unfocus();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }
}

/// Reusable editable stat widget
class EditableStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final bool isDark;
  final bool isEnabled;

  const EditableStat({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.isDark,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing
            ? SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTheme.statValue(isDark),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: isEnabled,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        )
            : GestureDetector(
          onTap: onTap,
          child: Text(value, style: AppTheme.statValue(isDark)),
        ),
        Text(label, style: AppTheme.statLabel(isDark)),
      ],
    );
  }
}

/// High refresh rate optimized profile image widget
class _HighRefreshProfileImage extends StatefulWidget {
  final String? profileImagePath;
  final bool isDark;

  const _HighRefreshProfileImage({
    required this.profileImagePath,
    required this.isDark,
  });

  @override
  State<_HighRefreshProfileImage> createState() => _HighRefreshProfileImageState();
}

class _HighRefreshProfileImageState extends State<_HighRefreshProfileImage>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _imageLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Detect refresh rate for optimized animation timing
    final refreshRate = SchedulerBinding.instance.platformDispatcher.displays.first.refreshRate;
    final frameDuration = refreshRate > 90
        ? const Duration(milliseconds: 8)  // ~1 frame at 120Hz
        : const Duration(milliseconds: 16); // ~1 frame at 60Hz

    _fadeController = AnimationController(
      duration: frameDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.avatarPlaceholder(widget.isDark),
      child: Icon(
        Icons.person,
        size: 40,
        color: AppColors.textSecondary(widget.isDark),
      ),
    );
  }

  Widget _buildImageWithOptimizedLoading({
    required ImageProvider imageProvider,
    required Widget errorWidget,
  }) {
    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      width: 80,
      height: 80,
      gaplessPlayback: true, // Critical for high refresh rate stability
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // Handle frame-perfect loading for high refresh rate displays
        if (wasSynchronouslyLoaded) {
          _imageLoaded = true;
          return child;
        }

        if (frame != null && !_imageLoaded) {
          _imageLoaded = true;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasError) {
              _fadeController.forward();
            }
          });
        }

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: frame == null ? 0.0 : _fadeAnimation.value,
              child: child,
            );
          },
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Profile image error: $error');
        if (!_hasError) {
          _hasError = true;
        }
        return errorWidget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorWidget = _buildErrorWidget();

    try {
      if (widget.profileImagePath != null) {
        final imageFile = File(widget.profileImagePath!);
        // Quick sync check to avoid async overhead for error state
        if (!imageFile.existsSync()) {
          return errorWidget;
        }

        return _buildImageWithOptimizedLoading(
          imageProvider: FileImage(imageFile),
          errorWidget: errorWidget,
        );
      } else {
        return _buildImageWithOptimizedLoading(
          imageProvider: const AssetImage('assets/images/profile.jpg'),
          errorWidget: errorWidget,
        );
      }
    } catch (e) {
      debugPrint('Error building profile image: $e');
      return errorWidget;
    }
  }
}