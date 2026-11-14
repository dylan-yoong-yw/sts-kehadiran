import 'dart:async';

import 'package:sts_kehadiran/models/admin_agenda.dart';
import 'package:sts_kehadiran/services/admin_agenda_service.dart';

/// [AdminAgendaService] controlled by the test: nothing is emitted until
/// [emit] or [fail] is called, so the loading state can be checked.
class FakeAdminAgendaService implements AdminAgendaService {
  final _controllers = <StreamController<AdminAgenda>>[];

  /// How many times the agenda has been requested.
  int get requests => _controllers.length;

  @override
  Stream<AdminAgenda> watchToday() {
    final controller = StreamController<AdminAgenda>();
    _controllers.add(controller);
    return controller.stream;
  }

  /// Sends [agenda] to the latest listener.
  void emit(AdminAgenda agenda) => _controllers.last.add(agenda);

  /// Fails the latest listener.
  void fail([Object error = 'unavailable']) =>
      _controllers.last.addError(error);
}
