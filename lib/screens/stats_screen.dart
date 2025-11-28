import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../components/simple_bar_chart.dart';
import '../components/simple_line_chart.dart';
import '../utils/time_utils.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const route = '/stats';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final weekly = app.dailyTotals(days: 7);
    final monthly = app.monthlyTotals(12);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _SummaryRow(app: app),
            const SizedBox(height: 16),
            Text('Last 7 days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SimpleBarChart(
              values: weekly.values.toList(),
              labels: weekly.keys
                  .map((d) => d.day == DateTime.now().day ? 'Today' : '${d.month}/${d.day}')
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('This year', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SimpleLineChart(values: monthly.values.toList()),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Row(
        children: [
          _Card(label: 'Total Focus', value: formatDuration(app.totalFocusTime())),
          const SizedBox(width: 12),
          _Card(label: 'Sessions', value: app.totalSessions().toString()),
          const SizedBox(width: 12),
          _Card(label: 'Streak', value: '${app.streak}d'),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
