import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_db.g.dart';

/// The main local database for the app.
/// Drift generates _$AppDb (in app_db.g.dart) based on the tables we register here.
/// uses dart run build_runner build --delete-conflicting-outputs to generate the code.
///
/// Tables included right now:
/// - Projects: connected Cospend projects (server + token + name)
/// - Members: cached members per project (id + name)
@DriftDatabase(tables: [Projects, Members])
class AppDb extends _$AppDb {
  /// Create the DB using our LazyDatabase connection.
  /// LazyDatabase = only opens the DB file when it's actually needed.
  AppDb() : super(_openConnection());

  /// Schema version for migrations.
  /// Whenever we change tables (add columns/tables), we bump this number.
  @override
  int get schemaVersion => 2;

  /// Migration rules when upgrading from an older schemaVersion.
  ///
  /// Example:
  /// - version 1: only Projects table existed
  /// - version 2: Members table was added
  ///
  /// So if the user had v1 installed, upgrading to v2 needs to create Members.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(members);
          }
        },
      );

  // ---------------------------------------------------------------------------
  // Projects
  // ---------------------------------------------------------------------------

  /// Stream all projects, live.
  /// Any insert/update/delete automatically updates listeners in the UI.
  Stream<List<Project>> watchProjects() => select(projects).watch();

  /// Read one project by local id (Project.id).
  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Insert or update a project in one call.
  /// If the id already exists, Drift updates that row.
  Future<void> upsertProject(ProjectsCompanion project) async {
    await into(projects).insertOnConflictUpdate(project);
  }

  /// Delete a project by local id.
  Future<int> deleteProject(String id) =>
      (delete(projects)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  /// Stream members for a given project (by local project id).
  Stream<List<Member>> watchMembersForProject(String projectLocalId) {
    return (select(members)
          ..where((t) => t.projectLocalId.equals(projectLocalId)))
        .watch();
  }

  /// Replace the full members list for one project.
  /// We do this when we re-fetch project info from Cospend:
  /// - delete all members for that project
  /// - insert the fresh ones
  Future<void> replaceMembersForProject({
    required String projectLocalId,
    required List<MembersCompanion> newMembers,
  }) async {
    await transaction(() async {
      // Clear existing members for this project
      await (delete(members)
            ..where((t) => t.projectLocalId.equals(projectLocalId)))
          .go();

      // Insert new list in a batch (faster than individual inserts)
      await batch((b) {
        b.insertAll(members, newMembers);
      });
    });
  }
}

/// Aliases that make the rest of the code readable.
/// Drift generates row classes named after tables, singular:
/// Projects -> Project, Members -> Member
typedef ProjectRow = Project;
typedef MemberRow = Member;

/// Opens the SQLite database file.
/// Using NativeDatabase (SQLite) for iOS/Android.
/// createInBackground runs DB open work off the UI thread.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'settleup.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}