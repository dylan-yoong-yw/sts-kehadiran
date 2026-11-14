import 'package:flutter/material.dart';

/// Body content for unfinished tabs; TeacherShell owns the shared navigation.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({super.key, required this.title, this.action});

  final String title;

  /// Optional widget shown below the message, e.g. a sign-out button.
  final Widget? action;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF064C3D),
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$title is under development.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 20),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
