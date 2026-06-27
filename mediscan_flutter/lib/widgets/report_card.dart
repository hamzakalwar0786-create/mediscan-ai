import 'package:flutter/material.dart';
import '../models/medical_report.dart';
import '../theme/app_theme.dart';

class ReportCard extends StatelessWidget {
  final MedicalReport report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: report.isAbnormal
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: report.isAbnormal
                    ? AppTheme.red
                    : AppTheme.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${report.date}  •  ${report.location}',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: report.isAbnormal
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                report.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: report.isAbnormal
                      ? AppTheme.red
                      : const Color(0xFF15803D),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
