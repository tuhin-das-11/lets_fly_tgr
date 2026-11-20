import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/active_session_entity.dart';
import '../../domain/repositories/study_timer_repository.dart';
import '../datasources/study_timer_remote_datasource.dart';
import '../repositories/study_timer_repository_impl.dart';

final studyTimerRepositoryProvider = Provider<StudyTimerRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StudyTimerRepositoryImpl(
    StudyTimerRemoteDataSourceImpl(supabase),
  );
});

/// Comprehensive UI timer state with active session data, local ticking,
/// cross-device conflict status, and today's accumulated duration.
class StudyTimerState {
  final ActiveSessionEntity? activeSession;
  final Duration elapsed;
  final Duration todayTotal;
  final bool isRunning;
  final bool isPaused;
  final bool isCrossDeviceConflict;
  final String? conflictDevicePlatform;
  final String currentSubjectId;
  final bool isLoading;

  const StudyTimerState({
    this.activeSession,
    this.elapsed = Duration.zero,
    this.todayTotal = Duration.zero,
    this.isRunning = false,
    this.isPaused = false,
    this.isCrossDeviceConflict = false,
    this.conflictDevicePlatform,
    this.currentSubjectId = '',
    this.isLoading = false,
  });

  StudyTimerState copyWith({
    ActiveSessionEntity? activeSession,
    bool clearActiveSession = false,
    Duration? elapsed,
    Duration? todayTotal,
    bool? isRunning,
    bool? isPaused,
    bool? isCrossDeviceConflict,
    String? conflictDevicePlatform,
    String? currentSubjectId,
    bool? isLoading,
  }) {
    return StudyTimerState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      elapsed: elapsed ?? this.elapsed,
      todayTotal: todayTotal ?? this.todayTotal,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCrossDeviceConflict: isCrossDeviceConflict ?? this.isCrossDeviceConflict,
      conflictDevicePlatform: conflictDevicePlatform ?? this.conflictDevicePlatform,
      currentSubjectId: currentSubjectId ?? this.currentSubjectId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Riverpod StateNotifier managing the live timer engine, cross-device sync, and heartbeats.
class StudyTimerController extends StateNotifier<StudyTimerState> {
  final StudyTimerRepository _repository;
  final String _userId;
  final String _currentDeviceId = 'device_${Platform.operatingSystem}_1';
  final String _currentPlatform = Platform.isAndroid ? 'android' : (Platform.isWindows ? 'windows' : 'other');

  Timer? _localTicker;
  Timer? _heartbeatTimer;
  StreamSubscription<ActiveSessionEntity?>? _cloudSyncSubscription;

  StudyTimerController(this._repository, this._userId) : super(const StudyTimerState()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Fetch today total hours
    final total = await _repository.getTodayTotalDuration(_userId);
    state = state.copyWith(todayTotal: total);

    // 2. Check if a server-authoritative session is already running
    final active = await _repository.getActiveSession(_userId);
    if (active != null) {
      _applyActiveSession(active);
    }

    // 3. Subscribe to Realtime cloud sync updates (Cross-device events)
    _cloudSyncSubscription = _repository.watchActiveSession(_userId).listen((remoteSession) {
      if (remoteSession == null) {
        _stopLocalTicker();
        state = state.copyWith(
          clearActiveSession: true,
          isRunning: false,
          isPaused: false,
          elapsed: Duration.zero,
        );
      } else {
        _applyActiveSession(remoteSession);
      }
    });
  }

  void _applyActiveSession(ActiveSessionEntity session) {
    final isOurDevice = session.deviceId == _currentDeviceId;
    final isConflict = !isOurDevice && session.isRunning;

    state = state.copyWith(
      activeSession: session,
      currentSubjectId: session.subjectId,
      isRunning: session.isRunning,
      isPaused: session.isPaused,
      isCrossDeviceConflict: isConflict,
      conflictDevicePlatform: session.platform,
      elapsed: session.calculateCurrentDuration(),
    );

    if (session.isRunning && !isConflict) {
      _startLocalTicker();
      _startHeartbeat();
    } else {
      _stopLocalTicker();
      _stopHeartbeat();
    }
  }

  void _startLocalTicker() {
    _localTicker?.cancel();
    _localTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.activeSession != null && state.isRunning) {
        state = state.copyWith(
          elapsed: state.activeSession!.calculateCurrentDuration(),
        );
      }
    });
  }

  void _stopLocalTicker() {
    _localTicker?.cancel();
    _localTicker = null;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _repository.sendHeartbeat(_userId);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void selectSubject(String subjectId) {
    state = state.copyWith(currentSubjectId: subjectId);
  }

  Future<void> startTimer({String? subjectId}) async {
    final subId = subjectId ?? state.currentSubjectId;
    if (subId.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final session = await _repository.startSession(
        userId: _userId,
        subjectId: subId,
        deviceId: _currentDeviceId,
        platform: _currentPlatform,
      );
      _applyActiveSession(session);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> pauseTimer() async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repository.pauseSession(_userId);
      _applyActiveSession(session);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resumeTimer() async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repository.resumeSession(_userId);
      _applyActiveSession(session);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> stopAndCommitSession({String notes = ''}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.stopAndCommitSession(userId: _userId, notes: notes);
      _stopLocalTicker();
      _stopHeartbeat();

      final updatedTotal = await _repository.getTodayTotalDuration(_userId);
      state = state.copyWith(
        clearActiveSession: true,
        isRunning: false,
        isPaused: false,
        elapsed: Duration.zero,
        todayTotal: updatedTotal,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> discardSession() async {
    await _repository.discardActiveSession(_userId);
    _stopLocalTicker();
    _stopHeartbeat();
    state = state.copyWith(
      clearActiveSession: true,
      isRunning: false,
      isPaused: false,
      elapsed: Duration.zero,
    );
  }

  Future<void> takeOverSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repository.takeOverSession(
        userId: _userId,
        newDeviceId: _currentDeviceId,
        newPlatform: _currentPlatform,
      );
      _applyActiveSession(session);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _localTicker?.cancel();
    _heartbeatTimer?.cancel();
    _cloudSyncSubscription?.cancel();
    super.dispose();
  }
}

final studyTimerControllerProvider =
    StateNotifierProvider<StudyTimerController, StudyTimerState>((ref) {
  final repo = ref.watch(studyTimerRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return StudyTimerController(repo, userId);
});
