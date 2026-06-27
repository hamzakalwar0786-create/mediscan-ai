// Feature: HEALTH TRENDS — charts showing improvement over time
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../models/medical_report.dart';
import '../theme/app_theme.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({super.key});

  @override
  State<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>().reports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Trends'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Parameters'),
            Tab(text: 'Overview'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ParameterTrendsTab(reports: reports),
          _OverviewTab(reports: reports),
          _TimelineTab(reports: reports),
        ],
      ),
    );
  }
}

// ── Tab 1: Parameter-level line charts ───────────────────────────────────────
class _ParameterTrendsTab extends StatelessWidget {
  final List<MedicalReport> reports;
  const _ParameterTrendsTab({required this.reports});

  @override
  Widget build(BuildContext context) {
    // Group by parameter name across all reports
    final Map<String, List<_DataPoint>> grouped = {};
    for (int i = reports.length - 1; i >= 0; i--) {
      final r = reports[i];
      for (final p in r.parameters) {
        final value = double.tryParse(p.result);
        if (value != null) {
          grouped.putIfAbsent(p.name, () => []);
          grouped[p.name]!.add(_DataPoint(
            label: r.date.substring(0, 3),
            value: value,
            isAbnormal: p.isAbnormal,
          ));
        }
      }
    }

    if (grouped.isEmpty) {
      return const Center(
        child: Text('No quantitative data available yet.\nScan more reports to see trends.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final name = grouped.keys.elementAt(i);
        final points = grouped[name]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _ParameterChart(name: name, points: points),
        );
      },
    );
  }
}

class _ParameterChart extends StatelessWidget {
  final String name;
  final List<_DataPoint> points;
  const _ParameterChart({required this.name, required this.points});

  @override
  Widget build(BuildContext context) {
    final hasAbnormal = points.any((p) => p.isAbnormal);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasAbnormal
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasAbnormal ? 'Abnormal' : 'Normal',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: hasAbnormal ? AppTheme.red : AppTheme.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(points[idx].label,
                            style: const TextStyle(fontSize: 9));
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map((e) =>
                            FlSpot(e.key.toDouble(), e.value.value))
                        .toList(),
                    isCurved: true,
                    color: hasAbnormal ? AppTheme.red : AppTheme.green,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        final isAb = points[spot.x.toInt()].isAbnormal;
                        return FlDotCirclePainter(
                          radius: 4,
                          color: isAb ? AppTheme.red : AppTheme.green,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (hasAbnormal ? AppTheme.red : AppTheme.green)
                          .withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: Overall health pie chart ──────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final List<MedicalReport> reports;
  const _OverviewTab({required this.reports});

  @override
  Widget build(BuildContext context) {
    final normal = reports.where((r) => !r.isAbnormal).length;
    final abnormal = reports.where((r) => r.isAbnormal).length;
    final total = reports.length;
    if (total == 0) {
      return const Center(
          child: Text('No reports yet.', style: TextStyle(color: Colors.grey)));
    }

    // Count all parameters
    int totalParams = 0, abnormalParams = 0;
    for (final r in reports) {
      totalParams += r.parameters.length;
      abnormalParams += r.parameters.where((p) => p.isAbnormal).length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Donut chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                const Text('Reports Overview',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: normal.toDouble(),
                          color: AppTheme.green,
                          title: '$normal\nNormal',
                          titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: abnormal.toDouble(),
                          color: AppTheme.red,
                          title: '$abnormal\nAbnormal',
                          titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppTheme.green, label: 'Normal'),
                    const SizedBox(width: 20),
                    _LegendDot(color: AppTheme.red, label: 'Abnormal'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.assessment_outlined,
                  label: 'Total Reports',
                  value: '$total',
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.biotech_outlined,
                  label: 'Parameters Tested',
                  value: '$totalParams',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.check_circle_outline,
                  label: 'Normal Parameters',
                  value: '${totalParams - abnormalParams}',
                  color: AppTheme.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.warning_amber_outlined,
                  label: 'Abnormal Parameters',
                  value: '$abnormalParams',
                  color: AppTheme.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Health score bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Health Score',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalParams == 0
                              ? 0
                              : (totalParams - abnormalParams) /
                                  totalParams,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          color: const Color(0xFF6BFF8F),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      totalParams == 0
                          ? '0%'
                          : '${((totalParams - abnormalParams) / totalParams * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 3: Report timeline ────────────────────────────────────────────────────
class _TimelineTab extends StatelessWidget {
  final List<MedicalReport> reports;
  const _TimelineTab({required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(
          child: Text('No reports yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        final isLast = i == reports.length - 1;
        return IntrinsicHeight(
          child: Row(
            children: [
              // Timeline line + dot
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: r.isAbnormal
                            ? AppTheme.red
                            : AppTheme.green,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade200,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.date,
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(r.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: r.isAbnormal
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                r.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: r.isAbnormal
                                      ? AppTheme.red
                                      : AppTheme.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${r.parameters.length} params',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DataPoint {
  final String label;
  final double value;
  final bool isAbnormal;
  const _DataPoint(
      {required this.label,
      required this.value,
      required this.isAbnormal});
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
