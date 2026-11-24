import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/notion_page_entity.dart';
import '../../domain/repositories/notion_repository.dart';
import '../datasources/notion_remote_datasource.dart';
import '../repositories/notion_repository_impl.dart';

final notionRepositoryProvider = Provider<NotionRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NotionRepositoryImpl(NotionRemoteDataSourceImpl(supabase));
});

class NotionState {
  final bool isConnected;
  final List<NotionPageEntity> pages;
  final bool isLoading;
  final String? errorMessage;

  const NotionState({
    this.isConnected = false,
    this.pages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotionState copyWith({
    bool? isConnected,
    List<NotionPageEntity>? pages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotionState(
      isConnected: isConnected ?? this.isConnected,
      pages: pages ?? this.pages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotionController extends StateNotifier<NotionState> {
  final NotionRepository _repository;
  final String _userId;

  NotionController(this._repository, this._userId) : super(const NotionState()) {
    checkConnectionAndLoad();
  }

  Future<void> checkConnectionAndLoad() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final connected = await _repository.isConnected(_userId);
      if (connected) {
        final pages = await _repository.getAuthorizedPages(_userId);
        state = state.copyWith(isConnected: true, pages: pages, isLoading: false);
      } else {
        // Show demo pages for review
        final pages = await _repository.getAuthorizedPages(_userId);
        state = state.copyWith(isConnected: false, pages: pages, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> connect(String token, String workspace) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.connectNotion(
        userId: _userId,
        accessToken: token,
        workspaceName: workspace,
        workspaceId: 'ws_${DateTime.now().millisecondsSinceEpoch}',
      );
      final pages = await _repository.getAuthorizedPages(_userId);
      state = state.copyWith(isConnected: true, pages: pages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> disconnect() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.disconnectNotion(_userId);
      state = state.copyWith(isConnected: false, pages: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> exportSessionNote({
    required String parentPageId,
    required String title,
    required String markdown,
    required String subjectName,
    required int durationSeconds,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final note = await _repository.createStudyNote(
        userId: _userId,
        parentPageId: parentPageId,
        title: title,
        contentMarkdown: markdown,
        subjectName: subjectName,
        durationSeconds: durationSeconds,
      );
      state = state.copyWith(
        pages: [note, ...state.pages],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final notionControllerProvider =
    StateNotifierProvider<NotionController, NotionState>((ref) {
  final repo = ref.watch(notionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final userId = user?.id ?? 'guest_user';
  return NotionController(repo, userId);
});
