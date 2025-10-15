import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:siged_app/domain/models/report_models.dart';
import '../dashboard/dashboard_cubit.dart';
// import 'package:intl/intl.dart';

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

// En dashboard_screen.dart

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
        if (state is DashboardError) return Center(child: Text('Error: ${state.message}'));
        if (state is DashboardLoaded) {
          final totalTramites = state.areaCounts.fold<int>(
            0,
            (p, e) => p + e.total,
          );
          final maxUsers = state.userActivity
              .map((e) => e.totalActivity)
              .fold<int>(0, (p, n) => n > p ? n : p);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. KPI Cards (Fila Superior) ---
                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 800 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _KpiCard(
                      title: 'Trámites Totales',
                      value: totalTramites.toString(),
                    ),
                    _KpiCard(
                      title: 'Tiempo Promedio (Días)',
                      value: state.tiempos.averageTime.toStringAsFixed(1),
                      subtitle:
                          'Min: ${state.tiempos.raw['min_days']?.toStringAsFixed(1) ?? 'N/A'} - Max: ${state.tiempos.raw['max_days']?.toStringAsFixed(1) ?? 'N/A'}',
                      color: Colors.green,
                    ),
                    // KPI adicionales usando los datos de AreaCount (ejemplo)
                    _KpiCard(
                      title: 'Trámites Pendientes',
                      value:
                          state.areaCounts
                              .fold<int>(
                                0,
                                (p, e) => p + e.recibido + e.enProceso,
                              )
                              .toString(),
                      color: Colors.orange,
                    ),
                    _KpiCard(
                      title: 'Trámites Finalizados',
                      value:
                          state.areaCounts
                              .fold<int>(0, (p, e) => p + e.finalizado)
                              .toString(),
                      color: Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- 2. Chart 1: Trámites por Área (Barra Agrupada - por estado) ---
                // Usamos un Card más grande y lo forzamos a un alto para la visualización.
                SizedBox(
                  height: 400,
                  child: _ChartCard(
                    title: 'Trámites por Área y Estado',
                    areaCounts: state.areaCounts,
                  ),
                ),

                const SizedBox(height: 32),

                // --- 3. Chart 2: Actividad por Usuario (Barra Apilada) ---
                SizedBox(
                  height: 400,
                  child: _UserActivityChart(
                    userActivity: state.userActivity,
                    maxY: (maxUsers.toDouble() * 1.2).clamp(
                      10.0,
                      double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// Actualizamos _KpiCard para aceptar color y subtítulo
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;

  const _KpiCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          color != null
              ? Color.lerp(color, Theme.of(context).cardColor, 0.9)
              : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: color ?? Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

// Modificamos _ChartCard para Gráfico de Barras Agrupadas
class _ChartCard extends StatelessWidget {
  final String title;
  final List<AreaStatusCount> areaCounts;
  const _ChartCard({required this.title, required this.areaCounts});

  @override
  Widget build(BuildContext context) {
    final maxTotal = areaCounts
        .map((e) => e.total)
        .fold<int>(0, (p, n) => n > p ? n : p);

    // Colores para los estados
    const colorRecibido = Colors.blueGrey;
    const colorEnProceso = Colors.orange;
    const colorFinalizado = Colors.green;
    const colorObservado = Colors.red;

    final barGroups = List.generate(areaCounts.length, (i) {
      final area = areaCounts[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: area.recibido.toDouble(),
            color: colorRecibido,
            width: 6,
          ),
          BarChartRodData(
            toY: area.enProceso.toDouble(),
            color: colorEnProceso,
            width: 6,
          ),
          BarChartRodData(
            toY: area.finalizado.toDouble(),
            color: colorFinalizado,
            width: 6,
          ),
          BarChartRodData(
            toY: area.observado.toDouble(),
            color: colorObservado,
            width: 6,
          ),
        ],
        // barRodsStack: false, // Barras AGRUPADAS
        // showingTooltip: true,
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxTotal.toDouble() * 1.1).clamp(1.0, double.infinity),
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final area = areaCounts[groupIndex];
                        String status;
                        Color statusColor;
                        switch (rodIndex) {
                          case 0:
                            status = 'RECIBIDO';
                            statusColor = colorRecibido;
                            break;
                          case 1:
                            status = 'EN PROCESO';
                            statusColor = colorEnProceso;
                            break;
                          case 2:
                            status = 'FINALIZADO';
                            statusColor = colorFinalizado;
                            break;
                          case 3:
                            status = 'OBSERVADO';
                            statusColor = colorObservado;
                            break;
                          default:
                            status = '';
                            statusColor = Colors.white;
                        }
                        return BarTooltipItem(
                          '${area.areaNombre}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          children: <TextSpan>[
                            // CORRECCIÓN: Usar TextSpan
                            TextSpan(
                              text: '$status: ${rod.toY.toInt()}',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                              ), // Usar el color del status
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= areaCounts.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: RotatedBox(
                              quarterTurns:
                                  -1, // Rotamos la etiqueta para ahorrar espacio
                              child: Text(
                                areaCounts[idx].areaNombre.length > 15
                                    ? '${areaCounts[idx].areaNombre.substring(0, 15)}...'
                                    : areaCounts[idx].areaNombre,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1.0,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: colorRecibido, text: 'Recibido'),
                _LegendItem(color: colorEnProceso, text: 'En Proceso'),
                _LegendItem(color: colorFinalizado, text: 'Finalizado'),
                _LegendItem(color: colorObservado, text: 'Observado'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Nuevo Widget para Actividad por Usuario (Gráfico de Barras Apiladas) ---
class _UserActivityChart extends StatelessWidget {
  final List<ReporteUsuarioModel> userActivity;
  final double maxY;
  const _UserActivityChart({required this.userActivity, required this.maxY});

  @override
  Widget build(BuildContext context) {
    if (userActivity.isEmpty) {
      return const Center(
        child: Text('No hay actividad de usuarios para mostrar.'),
      );
    }

    const colorCreated = Colors.lightBlue;
    const colorParticipated = Colors.deepPurple;

    // Filtramos usuarios con actividad para evitar barras vacías
    final activeUsers = userActivity.where((u) => u.totalActivity > 0).toList();

    final barGroups = List.generate(activeUsers.length, (i) {
      final user = activeUsers[i];

      /// Creamos la lista de ítems de stack (apilamiento)
      final List<BarChartRodStackItem> rodStackItems = [
        // Participated: base (de 0.0 a su count)
        BarChartRodStackItem(
          0,
          user.participatedCount.toDouble(),
          colorParticipated,
        ),
        // Created: encima (desde el count de Participated hasta el total)
        BarChartRodStackItem(
          user.participatedCount.toDouble(),
          user.totalActivity.toDouble(), // Altura total
          colorCreated,
        ),
      ];

      return BarChartGroupData(
        x: i,
        barRods: [
          // CORRECCIÓN: Usamos el constructor normal de BarChartRodData
          // y le pasamos los ítems apilados usando el parámetro `rodStackItems`.
          BarChartRodData(
            toY: user.totalActivity.toDouble(), // La altura total de la barra
            width: 12,
            rodStackItems: rodStackItems, // <--- ESTA ES LA SINTAXIS CORRECTA
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad por Usuario',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final user = activeUsers[groupIndex];
                        // El tooltip debe mostrar los datos Creados y Participados independientemente de qué parte de la barra toquen
                        return BarTooltipItem(
                          '${user.userName}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          children: <TextSpan>[
                            // CORRECCIÓN: Usar TextSpan
                            TextSpan(
                              text: 'Creados: ${user.createdCount}\n',
                              style: const TextStyle(
                                color: colorCreated,
                                fontSize: 10,
                              ),
                            ),
                            TextSpan(
                              text: 'Participados: ${user.participatedCount}',
                              style: const TextStyle(
                                color: colorParticipated,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= activeUsers.length) return const SizedBox.shrink();
                          final nameParts = activeUsers[idx].userName.split(
                            ' ',
                          );
                          final initials =
                              nameParts.length >= 2
                                  ? '${nameParts[0][0]}${nameParts[1][0]}'
                                  : nameParts[0].substring(0, 2);
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5.0,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: colorCreated, text: 'Creados'),
                _LegendItem(color: colorParticipated, text: 'Participados'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para la Leyenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
