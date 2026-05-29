import 'package:flutter/material.dart';
import 'package:supervisor_app/shared/widgets/empty_state.dart';

class WageSummaryPage extends StatelessWidget {
  const WageSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wage Summary')),
      body: const EmptyState(message: 'Monthly wage summaries appear here'),
    );
  }
}
