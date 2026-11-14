/// What an agenda item counts. Each kind maps to a real Firestore query
/// later: registers awaiting processing (FR-08) and classes that have not
/// submitted today's attendance (FR-05).
enum AgendaItemKind { awaitingProcessing, notSubmitted }

/// One line of the admin's "Today's agenda".
class AgendaItem {
  const AgendaItem({required this.kind, required this.count});

  final AgendaItemKind kind;
  final int count;

  /// e.g. "3 registers awaiting processing".
  String get text => switch (kind) {
    AgendaItemKind.awaitingProcessing =>
      '$count ${count == 1 ? 'register' : 'registers'} awaiting processing',
    AgendaItemKind.notSubmitted =>
      '$count ${count == 1 ? 'class' : 'classes'} not yet submitted today',
  };
}

/// The admin's agenda for today.
class AdminAgenda {
  const AdminAgenda(this.items);

  final List<AgendaItem> items;

  /// Items that need attention; a count of zero is not shown.
  List<AgendaItem> get pending =>
      items.where((item) => item.count > 0).toList();
}
