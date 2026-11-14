import 'package:flutter/material.dart';

import '../../widgets/feature_placeholder.dart';

/// Attendance registers submitted by teachers (FR-05, FR-08). Placeholder.
class AdminSubmissionsScreen extends StatelessWidget {
  const AdminSubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const FeaturePlaceholder(title: 'Attendance Submission');
}
