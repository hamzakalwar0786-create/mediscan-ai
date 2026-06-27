import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/medical_report.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';
import '../services/local_db_service.dart';
import '../services/connectivity_service.dart';

// Seed mock data shown before user scans anything
final List<MedicalReport> _seedReports = [
  MedicalReport(
    id: 'rep-cbc-01',
    title: 'Complete Blood Count (CBC)',
    type: 'Blood Test',
    date: 'Aug 12, 2023',
    location: 'Metro General Hospital Lab',
    status: 'Normal',
    trendSummary:
        'Hemoglobin level is steady at 14.2 g/dL over the past 6 months.',
    insights:
        'Your Complete Blood Count is fully within normal limits. This indicates robust red and white cell production and normal clotting capability.',
    parameters: [
      DiagnosticParameter(
          name: 'Hemoglobin',
          result: '14.2',
          unit: 'g/dL',
          referenceRange: '13.5 – 17.5 g/dL',
          status: ParameterStatus.NORMAL),
      DiagnosticParameter(
          name: 'WBC Count',
          result: '7.2',
          unit: 'x10³/µL',
          referenceRange: '4.5 – 11.0 x10³/µL',
          status: ParameterStatus.NORMAL),
      DiagnosticParameter(
          name: 'Platelets',
          result: '210',
          unit: 'x10³/µL',
          referenceRange: '150 – 450 x10³/µL',
          status: ParameterStatus.NORMAL),
      DiagnosticParameter(
          name: 'MCV',
          result: '88',
          unit: 'fL',
          referenceRange: '80 – 100 fL',
          status: ParameterStatus.NORMAL),
    ],
    recommendations: [
      ReportRecommendation(
          task: 'Maintain Balanced Diet',
          detail: 'Continue a diet rich in trace minerals and leafy greens.',
          icon: 'restaurant'),
      ReportRecommendation(
          task: 'Routine Annual Checkup',
          detail: 'General follow-up schedule remains unchanged.',
          icon: 'calendar_today'),
    ],
    userId: 'seed',
  ),
  MedicalReport(
    id: 'rep-lipid-02',
    title: 'Lipid Profile',
    type: 'Blood Test',
    date: 'July 28, 2023',
    location: 'City Health Diagnostics Lab',
    status: 'Abnormal',
    trendSummary:
        'Cholesterol levels are elevated with high LDL and low protective HDL, showing a steady rise from previous checkups.',
    insights:
        'Your elevated Total and LDL cholesterol levels (hyperlipidemia) pose an increased risk of cardiovascular deposits. HDL is also slightly sub-optimal, highlighting a clear need for lifestyle adjustment.',
    parameters: [
      DiagnosticParameter(
          name: 'Total Cholesterol',
          result: '245',
          unit: 'mg/dL',
          referenceRange: '< 200 mg/dL',
          status: ParameterStatus.HIGH),
      DiagnosticParameter(
          name: 'Triglycerides',
          result: '185',
          unit: 'mg/dL',
          referenceRange: '< 150 mg/dL',
          status: ParameterStatus.HIGH),
      DiagnosticParameter(
          name: 'HDL Cholesterol',
          result: '38',
          unit: 'mg/dL',
          referenceRange: '> 40 mg/dL',
          status: ParameterStatus.LOW),
      DiagnosticParameter(
          name: 'LDL Cholesterol',
          result: '160',
          unit: 'mg/dL',
          referenceRange: '< 100 mg/dL',
          status: ParameterStatus.HIGH),
    ],
    recommendations: [
      ReportRecommendation(
          task: 'Reduce Saturated Fats',
          detail:
              'Cut down on deep-fried food, red meat, and processed snacks.',
          icon: 'restaurant'),
      ReportRecommendation(
          task: 'Aerobic Exercise',
          detail: 'Engage in 30 minutes of brisk walking or cardio 5 days a week.',
          icon: 'directions_run'),
      ReportRecommendation(
          task: 'Re-test Lipid Panel',
          detail: 'Monitor LDL metrics in 6 weeks.',
          icon: 'repeat'),
    ],
    userId: 'seed',
  ),
  MedicalReport(
    id: 'rep-vit-03',
    title: 'Vitamin D Panel',
    type: 'Blood Test',
    date: 'July 02, 2023',
    location: 'City Health Diagnostics Lab',
    status: 'Abnormal',
    trendSummary:
        'Severe deficiency observed at 12.5 ng/mL - represents a downward trajectory over the last 90 days.',
    insights:
        'Your screening indicates severe Vitamin D deficiency. This essential hormone supports bone dense signaling, immunity pathways, and general wellness.',
    parameters: [
      DiagnosticParameter(
          name: '25-Hydroxy Vitamin D',
          result: '12.5',
          unit: 'ng/mL',
          referenceRange: '30.0 – 100.0 ng/mL',
          status: ParameterStatus.LOW),
    ],
    recommendations: [
      ReportRecommendation(
          task: 'Supplementation',
          detail:
              'Consult with a physician regarding oral weekly Vitamin D3 supplements.',
          icon: 'pill'),
      ReportRecommendation(
          task: 'Sunlight Exposure',
          detail: 'Spend 15-20 minutes in early morning sunlight daily.',
          icon: 'wb_sunny'),
      ReportRecommendation(
          task: 'Calcium-Rich Diet',
          detail: 'Incorporate fortified dairy, milk, or calcium foods.',
          icon: 'local_cafe'),
    ],
    userId: 'seed',
  ),
];

class ReportsProvider extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();
  final FirestoreService _firestore = FirestoreService();
  final LocalDbService _localDb = LocalDbService();
  final ConnectivityService _connectivity = ConnectivityService();

  List<MedicalReport> _reports = List.from(_seedReports);
  bool _isScanning = false;
  String _scanStatus = '';
  String? _scanError;
  String _userId = '';
  bool _isOnline = true;

  List<MedicalReport> get reports => _reports;
  bool get isScanning => _isScanning;
  String get scanStatus => _scanStatus;
  String? get scanError => _scanError;
  bool get isOnline => _isOnline;

  bool get hasAbnormal => _reports.any((r) => r.isAbnormal);

  ReportsProvider() {
    // Monitor connectivity
    _connectivity.onlineStream.listen((online) {
      _isOnline = online;
      notifyListeners();
      if (online && _userId.isNotEmpty) {
        _syncOfflineReports();
      }
    });
    _connectivity.isOnline().then((v) => _isOnline = v);
  }

  void setUserId(String uid) {
    if (_userId != uid) {
      _userId = uid;
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    // Load local first for instant display
    final localReports = await _localDb.getAllLocalReports();
    if (localReports.isNotEmpty) {
      _reports = localReports;
      notifyListeners();
    }
    // Then try Firestore
    if (_isOnline) {
      try {
        final fetched = await _firestore.fetchReports(_userId);
        if (fetched.isNotEmpty) {
          _reports = fetched;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> _syncOfflineReports() async {
    try {
      final unsynced = await _localDb.getUnsyncedReports();
      for (final report in unsynced) {
        if (report.userId == _userId) {
          await _firestore.saveReport(report);
          await _localDb.markReportSynced(report.id);
        }
      }
    } catch (_) {}
  }

  Future<MedicalReport?> scanReport({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    _isScanning = true;
    _scanError = null;
    _scanStatus = 'Reading clinical documents...';
    notifyListeners();

    final isOnline = await _connectivity.isOnline();

    if (!isOnline) {
      _scanError =
          'No internet connection. Please connect to scan a new report. Previously saved reports are available offline.';
      _isScanning = false;
      notifyListeners();
      return null;
    }

    try {
      _scanStatus = 'Correlating parameters with Gemini AI...';
      notifyListeners();

      final report = await _gemini.analyzeReportImage(
        imageBytes: imageBytes,
        fileName: fileName,
        userId: _userId.isEmpty ? 'anonymous' : _userId,
      );

      _scanStatus = 'Decoding checkup parameters complete!';
      notifyListeners();

      // Save locally always
      await _localDb.saveReportLocally(report);

      // Save to Firestore if online
      if (_userId.isNotEmpty && _userId != 'anonymous') {
        try {
          await _firestore.saveReport(report);
          await _localDb.markReportSynced(report.id);
        } catch (_) {
          // Will sync later when online
        }
      }

      _reports = [report, ..._reports];
      _isScanning = false;
      notifyListeners();
      return report;
    } catch (e) {
      _scanError =
          'Failed to analyze report. Ensure image is clear and internet is available.\n\nError: $e';
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  // Quick simulation for demo/testing
  MedicalReport simulateScan(int index) {
    final base = _seedReports[index % _seedReports.length];
    final report = MedicalReport(
      id: 'rep-sim-${DateTime.now().millisecondsSinceEpoch}',
      title: base.title,
      type: base.type,
      date: _todayStr(),
      location: base.location,
      status: base.status,
      trendSummary: base.trendSummary,
      insights: base.insights,
      parameters: base.parameters,
      recommendations: base.recommendations,
      userId: _userId.isEmpty ? 'anonymous' : _userId,
    );
    _reports = [report, ..._reports];
    notifyListeners();
    return report;
  }

  String _todayStr() {
    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month]} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
  }

  void clearError() {
    _scanError = null;
    notifyListeners();
  }
}
