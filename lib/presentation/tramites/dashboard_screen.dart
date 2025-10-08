import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/report_models.dart';
import '../dashboard/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(RepositoryProvider.of(context)),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(builder: (context, state) {
      if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
      if (state is DashboardError) return Center(child: Text('Error: ${state.message}'));
      if (state is DashboardLoaded) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _KpiCard(title: 'Avg Time to Finalize (days)', value: state.tiempos.averageTime.toStringAsFixed(1)),
              _KpiCard(title: 'Total Trámites', value: state.areaCounts.fold<int>(0, (p, e) => p + e.count).toString()),
              _ChartCard(areaCounts: state.areaCounts),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<AreaCount> areaCounts;
  const _ChartCard({required this.areaCounts});

  @override
  Widget build(BuildContext context) {
    final max = areaCounts.map((e) => e.count).fold<int>(0, (p, n) => n > p ? n : p);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trámites por Área', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (max.toDouble() * 1.2).clamp(1.0, double.infinity),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= areaCounts.length) return const SizedBox.shrink();
                          // Simple label widget
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              areaCounts[idx].nombre,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                  gridData: FlGridData(show: true),
                  barGroups: List.generate(areaCounts.length, (i) {
                    return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: areaCounts[i].count.toDouble(), color: Colors.blue)]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

