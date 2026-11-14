import '../models/admin_agenda.dart';

/// Supplies the admin's agenda. Screens depend on this interface so the
/// mock below can later be swapped for real Firestore counts (FR-05, FR-08)
/// without changing any widget.
abstract class AdminAgendaService {
  /// Emits today's agenda, and again whenever the counts change.
  Stream<AdminAgenda> watchToday();
}

/// Sample agenda shown until attendance registers are stored in Firestore.
class MockAdminAgendaService implements AdminAgendaService {
  const MockAdminAgendaService();

  static const sample = AdminAgenda([
    AgendaItem(kind: AgendaItemKind.awaitingProcessing, count: 3),
    AgendaItem(kind: AgendaItemKind.notSubmitted, count: 2),
  ]);

  @override
  Stream<AdminAgenda> watchToday() => Stream.value(sample);
}
