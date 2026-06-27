import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/medical_report.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  final MedicalReport report;
  final VoidCallback onBack;
  final VoidCallback onConsult;

  const AnalysisScreen({
    super.key,
    required this.report,
    required this.onBack,
    required this.onConsult,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back,
                    size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 4),
                Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.date}  •  ${report.title}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Generating PDF...')),
                          );
                          try {
                            await PdfService.exportAndShare(report);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('PDF error: $e'),
                                    backgroundColor:
                                        AppTheme.red),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: const Text('Download PDF',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: BorderSide(
                              color: AppTheme.primaryBlue, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConsult,
                        icon: const Icon(Icons.smart_toy_outlined, size: 16),
                        label: const Text('Consult AI',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Parameters table
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'DIAGNOSTIC PARAMETERS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Color(0xFF003D9B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: report.isAbnormal
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${report.status.toUpperCase()} REPORT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: report.isAbnormal
                                ? AppTheme.red
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Parameter rows
                ...report.parameters.asMap().entries.map((entry) {
                  final param = entry.value;
                  final isLast =
                      entry.key == report.parameters.length - 1;
                  return _ParameterRow(
                    param: param,
                    showDivider: !isLast,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bar chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biological Parameters Trend',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Comparison over last 6 months',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: _buildBarChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Insights card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.smart_toy_outlined,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'AI Insights Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  report.insights ??
                      'No insight details generated. Ask the health doctor inside clinic chat.',
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (report.trendSummary != null &&
                    report.trendSummary!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      '"${report.trendSummary}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations
          if (report.recommendations.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'RECOMMENDATIONS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...report.recommendations.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final rec = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.task,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rec.detail,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final months = ['MAY', 'JUN', 'JUL', 'AUG', 'OCT'];
    final values = [0.75, 0.80, 0.70, 0.65, 0.52];
    final isAbnormal = report.isAbnormal;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    months[value.toInt()],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: value.toInt() == 4 && isAbnormal
                          ? AppTheme.red
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(months.length, (i) {
          final isLast = i == months.length - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: isLast && isAbnormal
                    ? AppTheme.red
                    : AppTheme.primaryBlue.withOpacity(0.25),
                width: 32,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ParameterRow extends StatelessWidget {
  final DiagnosticParameter param;
  final bool showDivider;

  const _ParameterRow({required this.param, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final isAbnormal = param.isAbnormal;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isAbnormal ? AppTheme.red : Colors.transparent,
            width: 3,
          ),
          bottom: showDivider
              ? const BorderSide(color: Color(0xFFF3F4F6))
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              param.name,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: param.result,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isAbnormal ? AppTheme.red : AppTheme.green,
                    ),
                  ),
                  TextSpan(
                    text: ' ${param.unit}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              param.referenceRange,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF)),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isAbnormal
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAbnormal
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  size: 10,
                  color: isAbnormal
                      ? AppTheme.red
                      : const Color(0xFF15803D),
                ),
                const SizedBox(width: 2),
                Text(
                  param.status.name,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: isAbnormal
                        ? AppTheme.red
                        : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
