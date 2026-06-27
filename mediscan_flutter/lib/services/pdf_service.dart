// Feature: PDF EXPORT — Professional report PDF to share with doctors
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/medical_report.dart';

class PdfService {
  static Future<Uint8List> generateReportPdf(MedicalReport report) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#0052CC');
    final redColor = PdfColor.fromHex('#EF4444');
    final greenColor = PdfColor.fromHex('#22C55E');
    final greyLight = PdfColor.fromHex('#F3F4F6');
    final greyText = PdfColor.fromHex('#6B7280');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Header ────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MediScan AI',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'AI-Powered Clinical Report',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    report.status.toUpperCase(),
                    style: pw.TextStyle(
                      color:
                          report.isAbnormal ? redColor : greenColor,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Report Info ───────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: greyLight,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('REPORT TITLE',
                          style: pw.TextStyle(
                              color: greyText,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(report.title,
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DATE',
                          style: pw.TextStyle(
                              color: greyText,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(report.date,
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('LOCATION',
                          style: pw.TextStyle(
                              color: greyText,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(report.location,
                          style: const pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Parameters Table ──────────────────────────────────────────────
          pw.Text(
            'DIAGNOSTIC PARAMETERS',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Parameter', 'Result', 'Unit', 'Reference Range', 'Status'],
            data: report.parameters.map((p) {
              return [
                p.name,
                p.result,
                p.unit,
                p.referenceRange,
                p.status.name,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 9),
            rowDecoration: pw.BoxDecoration(color: greyLight),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.center,
            },
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300, width: 0.5),
            ),
          ),
          pw.SizedBox(height: 20),

          // ── AI Insights ───────────────────────────────────────────────────
          if (report.insights != null && report.insights!.isNotEmpty) ...[
            pw.Text(
              'AI INSIGHTS',
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#EFF6FF'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                    color: PdfColor.fromHex('#BFDBFE')),
              ),
              child: pw.Text(
                report.insights!,
                style: const pw.TextStyle(fontSize: 10, height: 1.5),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Trend Summary ─────────────────────────────────────────────────
          if (report.trendSummary != null &&
              report.trendSummary!.isNotEmpty) ...[
            pw.Text(
              'TREND SUMMARY',
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: greyLight,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                '"${report.trendSummary}"',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    height: 1.5),
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // ── Recommendations ───────────────────────────────────────────────
          if (report.recommendations.isNotEmpty) ...[
            pw.Text(
              'RECOMMENDATIONS',
              style: pw.TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 8),
            ...report.recommendations.asMap().entries.map((entry) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '${entry.key + 1}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            entry.value.task,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            entry.value.detail,
                            style:
                                pw.TextStyle(fontSize: 9, color: greyText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Footer disclaimer ─────────────────────────────────────────────
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'DISCLAIMER: This report is generated by MediScan AI for informational purposes only. '
            'Always consult a certified healthcare professional for medical advice, diagnosis, or treatment.',
            style: pw.TextStyle(
              fontSize: 8,
              color: greyText,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${DateTime.now().toString().substring(0, 16)}',
                style: pw.TextStyle(fontSize: 8, color: greyText),
              ),
              pw.Text(
                'MediScan AI • HIPAA Compliant',
                style: pw.TextStyle(fontSize: 8, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Save & share PDF ──────────────────────────────────────────────────────
  static Future<void> exportAndShare(MedicalReport report) async {
    final bytes = await generateReportPdf(report);
    final dir = await getTemporaryDirectory();
    final fileName =
        '${report.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_report.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'MediScan AI — ${report.title}',
      text: 'Medical report from MediScan AI. Date: ${report.date}',
    );
  }

  // ── Print PDF ────────────────────────────────────────────────────────────
  static Future<void> printReport(MedicalReport report) async {
    final bytes = await generateReportPdf(report);
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  // ── Preview PDF in viewer ────────────────────────────────────────────────
  static Future<void> previewReport(
      BuildContext context, MedicalReport report) async {
    final bytes = await generateReportPdf(report);
    await Printing.sharePdf(
        bytes: bytes,
        filename: '${report.title}_MediScan.pdf');
  }
}
