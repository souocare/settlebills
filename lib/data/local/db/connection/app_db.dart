import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Projects, Members])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(members);
          }
        },
      );

  // --- Projects ---
  Stream<List<Project>> watchProjects() => select(projects).watch();

  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertProject(ProjectsCompanion project) async {
    await into(projects).insertOnConflictUpdate(project);
  }

  Future<int> deleteProject(String id) => (delete(projects)..where((t) => t.id.equals(id))).go();

  // --- Members ---
  Stream<List<Member>> watchMembersForProject(String projectLocalId) {
    return (select(members)..where((t) => t.projectLocalId.equals(projectLocalId)))
        .watch();
  }

  Future<void> replaceMembersForProject({
    required String projectLocalId,
    required List<MembersCompanion> newMembers,
  }) async {
    await transaction(() async {
      await (delete(members)
            ..where((t) => t.projectLocalId.equals(projectLocalId)))
          .go();

      await batch((b) {
        b.insertAll(members, newMembers);
      });
    });
  }
}

typedef ProjectRow = Project;
typedef MemberRow = Member;

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'settlebills.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}