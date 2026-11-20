import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/blocking_platform_channel.dart';

class BlockedAppItem {
  final String packageName;
  final String displayName;
  final bool isBlocked;

  const BlockedAppItem({
    required this.packageName,
    required this.displayName,
    this.isBlocked = true,
  });

  BlockedAppItem copyWith({bool? isBlocked}) {
    return BlockedAppItem(
      packageName: packageName,
      displayName: displayName,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

class BlockingState {
  final List<BlockedAppItem> apps;
  final bool isShieldActive;
  final bool hasUsagePermission;
  final bool isStrictMode;

  const BlockingState({
    this.apps = const [],
    this.isShieldActive = false,
    this.hasUsagePermission = false,
    this.isStrictMode = false,
  });

  BlockingState copyWith({
    List<BlockedAppItem>? apps,
    bool? isShieldActive,
    bool? hasUsagePermission,
    bool? isStrictMode,
  }) {
    return BlockingState(
      apps: apps ?? this.apps,
      isShieldActive: isShieldActive ?? this.isShieldActive,
      hasUsagePermission: hasUsagePermission ?? this.hasUsagePermission,
      isStrictMode: isStrictMode ?? this.isStrictMode,
    );
  }
}

class BlockingController extends StateNotifier<BlockingState> {
  BlockingController()
      : super(
          const BlockingState(
            apps: [
              BlockedAppItem(packageName: 'com.instagram.android', displayName: 'Instagram'),
              BlockedAppItem(packageName: 'com.zhiliaoapp.musically', displayName: 'TikTok'),
              BlockedAppItem(packageName: 'com.twitter.android', displayName: 'X / Twitter'),
              BlockedAppItem(packageName: 'com.google.android.youtube', displayName: 'YouTube'),
              BlockedAppItem(packageName: 'com.reddit.frontpage', displayName: 'Reddit'),
              BlockedAppItem(packageName: 'com.facebook.katana', displayName: 'Facebook'),
            ],
          ),
        ) {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final hasPerm = await BlockingPlatformChannel.hasUsagePermission();
    state = state.copyWith(hasUsagePermission: hasPerm);
  }

  Future<void> requestPermission() async {
    await BlockingPlatformChannel.requestUsagePermission();
    await checkPermissions();
  }

  void toggleAppBlock(String packageName, bool isBlocked) {
    final updated = state.apps.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isBlocked: isBlocked);
      }
      return app;
    }).toList();
    state = state.copyWith(apps: updated);
  }

  void toggleStrictMode(bool enabled) {
    state = state.copyWith(isStrictMode: enabled);
  }

  Future<void> startShield() async {
    final blockedPackages = state.apps
        .where((a) => a.isBlocked)
        .map((a) => a.packageName)
        .toList();

    await BlockingPlatformChannel.startBlockingService(blockedPackages);
    state = state.copyWith(isShieldActive: true);
  }

  Future<void> stopShield() async {
    await BlockingPlatformChannel.stopBlockingService();
    state = state.copyWith(isShieldActive: false);
  }
}

final blockingControllerProvider =
    StateNotifierProvider<BlockingController, BlockingState>((ref) {
  return BlockingController();
});
