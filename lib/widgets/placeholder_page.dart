import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A full page, opened on top of the current screen, for a feature that is
/// not built yet. The app bar's back button returns to where it was opened.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  /// Opens a [PlaceholderPage] titled [title].
  static Future<void> open(BuildContext context, String title) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PlaceholderPage(title: title)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: AppColors.darkGreen),
      ),
    ),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Text(
            '$title is under development.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    ),
  );
}
