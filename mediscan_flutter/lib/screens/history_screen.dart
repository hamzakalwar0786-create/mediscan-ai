import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../models/medical_report.dart';
import '../theme/app_theme.dart';
class HistoryScreen extends StatefulWidget {
  final void Function(MedicalReport) onSelectReport;
  const HistoryScreen({super.key, required this.onSelectReport});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>().reports;
    final filtered = reports.where((r) {
      final q = _query.toLowerCase();
      return r.title.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.type.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report History',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'REVIEW AND TRACK YOUR PAST MEDICAL DIAGNOSTIC DATA',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppTheme.primaryBlue, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Icon(Icons.tune,
                    size: 18, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reports list
          ...filtered.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryCard(
                  report: r,
                  onTap: () => widget.onSelectReport(r),
                ),
              )),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                    style: BorderStyle.solid,
                    color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No diagnostic sessions matched your search.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Aggregate health card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.darkBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up,
                        color: AppTheme.green, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'AGGREGATE HEALTH PROGRESSION',
                      style: TextStyle(
                        color: Color(0xFF6BFF8F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Based on your last parsed lipid profiles and CBC reports, your cholesterol levels indicate a 12% improvement toward the stable normal medical reference limits.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.80,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: const Color(0xFF6BFF8F),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MedicalReport report;
  final VoidCallback onTap;

  const _HistoryCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAbnormal = report.isAbnormal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: isAbnormal ? AppTheme.red : Colors.transparent,
              width: 3,
            ),
            right:
                BorderSide(color: Colors.grey.shade100, width: 1),
            top: BorderSide(color: Colors.grey.shade100, width: 1),
            bottom:
                BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report.date.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
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
                            ? Icons.warning_amber_outlined
                            : Icons.check_circle_outline,
                        size: 10,
                        color: isAbnormal
                            ? AppTheme.red
                            : const Color(0xFF15803D),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isAbnormal
                            ? 'Deficiencies Found'
                            : 'Stable Normal',
                        style: TextStyle(
                          fontSize: 9,
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
            const SizedBox(height: 6),
            Text(
              report.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.biotech_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right,
                    size: 16, color: AppTheme.primaryBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
