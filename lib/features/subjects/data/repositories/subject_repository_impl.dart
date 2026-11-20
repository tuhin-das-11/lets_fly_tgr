import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_datasource.dart';
import '../datasources/subject_remote_datasource.dart';
import '../models/subject_model.dart';

/// Offline-first implementation combining local SQLite cache and Supabase backend.
class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource _localDataSource;
  final SubjectRemoteDataSource _remoteDataSource;
  final _uuid = const Uuid();

  // In-memory reactive stream for immediate updates
  final _subjectsStreamController = StreamController<List<SubjectEntity>>.broadcast();
  List<SubjectEntity> _cachedSubjects = [];

  SubjectRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Stream<List<SubjectEntity>> watchSubjects(String userId) {
    // Kick off initial fetch
    getSubjects(userId);
    return _subjectsStreamController.stream;
  }

  @override
  Future<List<SubjectEntity>> getSubjects(String userId) async {
    try {
      // 1. Try local cache
      final local = await _localDataSource.getLocalSubjects(userId);
      if (local.isNotEmpty) {
        _cachedSubjects = local;
        _subjectsStreamController.add(_cachedSubjects);
      }

      // 2. Fetch fresh from remote
      final remote = await _remoteDataSource.getRemoteSubjects(userId);
      _cachedSubjects = remote;
      _subjectsStreamController.add(_cachedSubjects);

      // 3. Cache remotely fetched items locally
      await _localDataSource.saveSubjects(remote);
      return _cachedSubjects;
    } catch (e) {
      // Return cached subjects on network error
      if (_cachedSubjects.isNotEmpty) return _cachedSubjects;
      
      // Default fallback mock subjects so user can start studying offline immediately
      if (_cachedSubjects.isEmpty) {
        _cachedSubjects = [
          SubjectEntity(
            id: 'default_cs',
            userId: userId,
            name: 'Computer Science',
            colorHex: '#4F46E5',
            iconName: 'code',
            category: 'Engineering',
            targetMinutesDaily: 120,
            sortOrder: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SubjectEntity(
            id: 'default_math',
            userId: userId,
            name: 'Mathematics',
            colorHex: '#10B981',
            iconName: 'calculate',
            category: 'Science',
            targetMinutesDaily: 90,
            sortOrder: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SubjectEntity(
            id: 'default_physics',
            userId: userId,
            name: 'Physics',
            colorHex: '#F59E0B',
            iconName: 'science',
            category: 'Science',
            targetMinutesDaily: 60,
            sortOrder: 2,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        _subjectsStreamController.add(_cachedSubjects);
      }
      return _cachedSubjects;
    }
  }

  @override
  Future<SubjectEntity> createSubject({
    required String userId,
    required String name,
    required String colorHex,
    required String iconName,
    required String category,
    required int targetMinutesDaily,
  }) async {
    final now = DateTime.now();
    final newSubject = SubjectModel(
      id: _uuid.v4(),
      userId: userId,
      name: name,
      colorHex: colorHex,
      iconName: iconName,
      category: category,
      targetMinutesDaily: targetMinutesDaily,
      sortOrder: _cachedSubjects.length,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );

    // Optimistic UI update
    _cachedSubjects.add(newSubject);
    _subjectsStreamController.add(List.from(_cachedSubjects));
    await _localDataSource.upsertSubject(newSubject);

    // Remote sync
    try {
      final remoteCreated = await _remoteDataSource.createSubject(newSubject);
      return remoteCreated;
    } catch (_) {
      // Queued for sync
      return newSubject;
    }
  }

  @override
  Future<SubjectEntity> updateSubject(SubjectEntity subject) async {
    final model = SubjectModel.fromEntity(subject.copyWith(updatedAt: DateTime.now()));

    final idx = _cachedSubjects.indexWhere((s) => s.id == subject.id);
    if (idx != -1) {
      _cachedSubjects[idx] = model;
      _subjectsStreamController.add(List.from(_cachedSubjects));
    }

    await _localDataSource.upsertSubject(model);

    try {
      return await _remoteDataSource.updateSubject(model);
    } catch (_) {
      return model;
    }
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    _cachedSubjects.removeWhere((s) => s.id == subjectId);
    _subjectsStreamController.add(List.from(_cachedSubjects));

    await _localDataSource.deleteSubject(subjectId);
    try {
      await _remoteDataSource.deleteSubject(subjectId);
    } catch (_) {}
  }

  @override
  Future<void> reorderSubjects(List<String> subjectIdsInOrder) async {
    final reordered = <SubjectEntity>[];
    for (int i = 0; i < subjectIdsInOrder.length; i++) {
      final item = _cachedSubjects.firstWhere((s) => s.id == subjectIdsInOrder[i]);
      reordered.add(item.copyWith(sortOrder: i));
    }
    _cachedSubjects = reordered;
    _subjectsStreamController.add(List.from(_cachedSubjects));

    try {
      await _remoteDataSource.reorderSubjects(subjectIdsInOrder);
    } catch (_) {}
  }

  @override
  Future<void> toggleArchive(String subjectId, bool isArchived) async {
    final idx = _cachedSubjects.indexWhere((s) => s.id == subjectId);
    if (idx != -1) {
      final updated = _cachedSubjects[idx].copyWith(isArchived: isArchived);
      await updateSubject(updated);
    }
  }
}
