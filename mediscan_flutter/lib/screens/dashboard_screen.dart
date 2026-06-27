import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../models/medical_report.dart';
import '../theme/app_theme.dart';
import '../widgets/report_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onScanClick;
  final void Function(MedicalReport) onSelectReport;
  final void Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.onScanClick,
    required this.onSelectReport,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>().reports;
    final hasAbnormal = context.watch<ReportsProvider>().hasAbnormal;
    final user = context.watch<ap.AuthProvider>().user;
    final name = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'there';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Good morning, $name 👋',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              children: [
                const TextSpan(text: 'Your health metrics look '),
                TextSpan(
                  text: hasAbnormal ? 'abnormal' : 'normal',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        hasAbnormal ? AppTheme.red : AppTheme.green,
                  ),
                ),
                const TextSpan(text: ' today.'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Scan CTA card
          GestureDetector(
            onTap: onScanClick,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan New Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AI-POWERED DIAGNOSTICS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Health Overview',
                  value: hasAbnormal ? 'Abnormal' : 'Normal',
                  subtitle:
                      'Based on ${reports.length} diagnostic sessions',
                  icon: hasAbnormal
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
                  iconColor:
                      hasAbnormal ? AppTheme.red : AppTheme.green,
                  progress: hasAbnormal ? 0.45 : 0.92,
                  progressColor:
                      hasAbnormal ? AppTheme.red : AppTheme.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Next Appointment',
                  value: 'Dr. Sarah Chen',
                  subtitle: 'Cardiology • Tomorrow, 10:30 AM',
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppTheme.primaryBlue,
                  onTap: () => onNavigateToTab(2),
                  tapLabel: 'Ask health question',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily insight card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: AppTheme.primaryBlue, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'DAILY INSIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '"Increasing raw iron and Vitamin C intake by 25% today can significantly strengthen the haemoglobin carrying structures scanned in your blood profiles."',
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nutritional AI Companion',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent reports
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Scan Reports',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () => onNavigateToTab(3),
                child: Text(
                  'See All',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reports
              .take(5)
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReportCard(
                      report: r,
                      onTap: () => onSelectReport(r),
                    ),
                  )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double? progress;
  final Color? progressColor;
  final VoidCallback? onTap;
  final String? tapLabel;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.progress,
    this.progressColor,
    this.onTap,
    this.tapLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade100,
                color: progressColor,
                minHeight: 4,
              ),
            ),
          ],
          if (onTap != null && tapLabel != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    tapLabel!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward,
                      size: 12, color: AppTheme.primaryBlue),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
