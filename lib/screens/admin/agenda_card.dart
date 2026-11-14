import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/admin_agenda.dart';
import '../../services/admin_agenda_service.dart';
import '../../widgets/dashboard_widgets.dart';

/// "Today's agenda" on the admin home: what needs attention today (FR-05,
/// FR-08) and a button to the attendance submissions.
///
/// Reads the agenda from the [AdminAgendaService] provided above it. When
/// given extra height, the button stays at the bottom of the card.
class AgendaCard extends StatefulWidget {
  const AgendaCard({super.key, required this.onOpenSubmissions});

  final VoidCallback onOpenSubmissions;

  @override
  State<AgendaCard> createState() => _AgendaCardState();
}

class _AgendaCardState extends State<AgendaCard> {
  Stream<AdminAgenda>? _agenda;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _agenda ??= context.read<AdminAgendaService>().watchToday();
  }

  void _retry() =>
      setState(() => _agenda = context.read<AdminAgendaService>().watchToday());

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DashboardCard(
      color: AppColors.attendanceCard,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text('Today’s agenda', style: text.titleMedium),
              ),
              const SizedBox(height: 8),
              StreamBuilder<AdminAgenda>(
                // A new stream after a retry starts from a fresh snapshot,
                // instead of keeping the previous error.
                key: ObjectKey(_agenda),
                stream: _agenda,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Could not load agenda: ${snapshot.error}');
                    return _AgendaError(onRetry: _retry);
                  }
                  final agenda = snapshot.data;
                  if (agenda == null) return const _AgendaLoading();
                  final items = agenda.pending;
                  if (items.isEmpty) {
                    return const _AgendaLine(
                      icon: Icons.check_circle_rounded,
                      text: 'Nothing needs your attention right now.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items)
                        _AgendaLine(
                          key: ValueKey(item.kind),
                          icon: switch (item.kind) {
                            AgendaItemKind.awaitingProcessing =>
                              Icons.pending_actions_rounded,
                            AgendaItemKind.notSubmitted =>
                              Icons.assignment_late_rounded,
                          },
                          text: item.text,
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('go-to-submissions'),
            style: AppTheme.primaryButton,
            onPressed: widget.onOpenSubmissions,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Go to Attendance Submission',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.north_east, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaLine extends StatelessWidget {
  const _AgendaLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}

class _AgendaLoading extends StatelessWidget {
  const _AgendaLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: CircularProgressIndicator(
        semanticsLabel: 'Loading today’s agenda',
      ),
    ),
  );
}

class _AgendaError extends StatelessWidget {
  const _AgendaError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _AgendaLine(
        icon: Icons.error_outline_rounded,
        text: 'Couldn’t load today’s agenda.',
      ),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
    ],
  );
}
