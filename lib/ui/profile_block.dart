// File: lib/ui/profile_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static ProfileData fromJson(Map<String, dynamic> json) => ProfileData(
    username: json['username'] ?? 'tomazdrnovsek',
    posts: json['posts'] ?? '327',
    followers: json['followers'] ?? '3,333',
    following: json['following'] ?? '813',
    bio: json['bio'] ?? 'From Ljubljana, Slovenia.',
    profileImagePath: json['profileImagePath'],
  );
}

// Profile data manager
class ProfileDataManager {
  static const String _key = 'profile_data';

  static Future<ProfileData> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return ProfileData.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
    return ProfileData();
  }

  static Future<void> saveProfile(ProfileData profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }
}

/// Editable profile block that allows tap-to-edit functionality
class ProfileBlock extends StatefulWidget {
  const ProfileBlock({super.key});

  @override
  State<ProfileBlock> createState() => _ProfileBlockState();
}

class _ProfileBlockState extends State<ProfileBlock> {
  late ProfileData _profileData;
  bool _isLoading = true;

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
    final profile = await ProfileDataManager.loadProfile();
    setState(() {
      _profileData = profile;
      _isLoading = false;
    });
  }

  String _formatNumber(String input) {
    final cleaned = input.replaceAll(',', '').replaceAll(' ', '');
    final number = int.tryParse(cleaned);
    if (number == null) return input;

    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String _unformatNumber(String formatted) {
    return formatted.replaceAll(',', '');
  }

  Future<void> _saveField(String field, String value) async {
    switch (field) {
      case 'username':
        _profileData.username = value;
        break;
      case 'posts':
        _profileData.posts = value;
        break;
      case 'followers':
        _profileData.followers = value;
        break;
      case 'following':
        _profileData.following = value;
        break;
      case 'bio':
        _profileData.bio = value;
        break;
    }
    await ProfileDataManager.saveProfile(_profileData);
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
        final result = await FileUtils.processImageWithThumbnail(image);
        final profileImage = result['image']!;

        setState(() {
          _profileData.profileImagePath = profileImage.path;
        });

        await ProfileDataManager.saveProfile(_profileData);
      }
    } catch (e) {
      debugPrint('Error changing profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile image'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _startEditing(String field) {
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
                    onTap: _changeProfileImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _profileData.profileImagePath != null
                          ? FileImage(File(_profileData.profileImagePath!))
                          : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                      backgroundColor: AppColors.avatarPlaceholder(isDark),
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                            : GestureDetector(
                          onTap: () => _startEditing('username'),
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
                              onTap: () => _startEditing('posts'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 24),
                            EditableStat(
                              label: 'followers',
                              value: _profileData.followers,
                              isEditing: _editingFollowers,
                              controller: _followersController,
                              focusNode: _followersFocus,
                              onTap: () => _startEditing('followers'),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 24),
                            EditableStat(
                              label: 'following',
                              value: _profileData.following,
                              isEditing: _editingFollowing,
                              controller: _followingController,
                              focusNode: _followingFocus,
                              onTap: () => _startEditing('following'),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (!_editingBio) {
                    _startEditing('bio');
                  }
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 40),
                  child: _editingBio
                      ? TextField(
                    controller: _bioController,
                    focusNode: _bioFocus,
                    style: AppTheme.body(isDark),
                    maxLines: 2,
                    maxLength: 100,
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

  const EditableStat({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.isDark,
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