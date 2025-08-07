// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photoNotifierHash() => r'395d206c4a52e9fdb8bd0668ef4eb8b1c1324d78';

/// Riverpod provider for photo state management with ENHANCED batch processing
/// Reduces cascading rebuilds from multiple operations (5 photos = 1 state update)
///
/// Copied from [PhotoNotifier].
@ProviderFor(PhotoNotifier)
final photoNotifierProvider =
    AutoDisposeNotifierProvider<PhotoNotifier, PhotoState>.internal(
      PhotoNotifier.new,
      name: r'photoNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$photoNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PhotoNotifier = AutoDisposeNotifier<PhotoState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
