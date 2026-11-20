import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Local SQLite schema for Subjects (Offline-First cache and local storage)
class LocalSubjects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#4F46E5'))();
  TextColumn get icon => text().withDefault(const Constant('book'))();
  TextColumn get category => text().withDefault(const Constant('General'))();
  IntColumn get targetMinutesDaily => integer().withDefault(const Constant(60))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for Completed Study Sessions
class LocalStudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get subjectId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  TextColumn get deviceId => text()();
  TextColumn get sessionType => text().withDefault(const Constant('stopwatch'))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for Current Active Session
class LocalActiveSessions extends Table {
  TextColumn get userId => text()();
  TextColumn get subjectId => text()();
  TextColumn get deviceId => text()();
  TextColumn get platform => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastHeartbeat => dateTime()();
  TextColumn get status => text().withDefault(const Constant('running'))(); // running, paused
  IntColumn get pausedSecondsTotal => integer().withDefault(const Constant(0))();
  TextColumn get sessionType => text().withDefault(const Constant('stopwatch'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Offline mutation queue for reliable offline-first synchronization
class LocalSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payload => text()(); // JSON serialized payload
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [LocalSubjects, LocalStudySessions, LocalActiveSessions, LocalSyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'lets_fly_tgr_local.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
