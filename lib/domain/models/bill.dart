/// A bill/transaction inside a project.
///
/// This is the “app-friendly” shape we use in the domain layer:
/// - not tied to the API JSON
/// - not tied to the database schema
///
/// The whole point is: we can store it offline, queue changes,
/// and sync later without rewriting the UI.
class Bill {
  const Bill({
    required this.localId,
    required this.projectLocalId,
    this.remoteId,
    required this.what,
    required this.amount,
    required this.date,
    required this.payerMemberId,
    required this.payedForMemberIds,
    this.comment,
    required this.syncState,
    required this.updatedAt,
  });

  /// Local ID used inside the app. Exists even when offline.
  final String localId;

  /// The local project this bill belongs to (Project.id).
  final String projectLocalId;

  /// Remote Cospend bill id. Null until the bill exists on the server.
  final int? remoteId;

  /// Short description shown in the list (Cospend uses "what").
  final String what;

  /// Amount of the bill.
  final double amount;

  /// Date in YYYY-MM-DD (keeps things simple and matches the API).
  final String date;

  /// Member id (Cospend) of who paid.
  final int payerMemberId;

  /// Member ids (Cospend) that this bill was paid for (owers).
  final List<int> payedForMemberIds;

  /// Optional notes.
  final String? comment;

  /// Where this bill stands in the sync pipeline.
  final SyncState syncState;

  /// Last time we changed it locally (used for sync/conflicts).
  final DateTime updatedAt;

  Bill copyWith({
    String? localId,
    String? projectLocalId,
    int? remoteId,
    String? what,
    double? amount,
    String? date,
    int? payerMemberId,
    List<int>? payedForMemberIds,
    String? comment,
    SyncState? syncState,
    DateTime? updatedAt,
  }) {
    return Bill(
      localId: localId ?? this.localId,
      projectLocalId: projectLocalId ?? this.projectLocalId,
      remoteId: remoteId ?? this.remoteId,
      what: what ?? this.what,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      payedForMemberIds: payedForMemberIds ?? this.payedForMemberIds,
      comment: comment ?? this.comment,
      syncState: syncState ?? this.syncState,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum SyncState {
  /// Local == remote.
  synced,

  /// Created offline, must POST on next sync.
  pendingCreate,

  /// Edited offline, must PUT on next sync.
  pendingUpdate,

  /// Deleted offline, must DELETE on next sync.
  pendingDelete,

  /// Needs manual resolution (remote changed too).
  conflict,
}