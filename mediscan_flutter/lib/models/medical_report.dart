import 'package:cloud_firestore/cloud_firestore.dart';

enum ParameterStatus { LOW, NORMAL, HIGH, ABNORMAL }

class DiagnosticParameter {
  final String name;
  final String result;
  final String unit;
  final String referenceRange;
  final ParameterStatus status;

  DiagnosticParameter({
    required this.name,
    required this.result,
    required this.unit,
    required this.referenceRange,
    required this.status,
  });

  factory DiagnosticParameter.fromMap(Map<String, dynamic> map) {
    ParameterStatus st = ParameterStatus.NORMAL;
    switch ((map['status'] ?? '').toString().toUpperCase()) {
      case 'LOW':
        st = ParameterStatus.LOW;
        break;
      case 'HIGH':
        st = ParameterStatus.HIGH;
        break;
      case 'ABNORMAL':
        st = ParameterStatus.ABNORMAL;
        break;
      default:
        st = ParameterStatus.NORMAL;
    }
    return DiagnosticParameter(
      name: map['name'] ?? '',
      result: map['result'] ?? '',
      unit: map['unit'] ?? '',
      referenceRange: map['referenceRange'] ?? '',
      status: st,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'result': result,
        'unit': unit,
        'referenceRange': referenceRange,
        'status': status.name,
      };

  bool get isAbnormal =>
      status == ParameterStatus.LOW ||
      status == ParameterStatus.HIGH ||
      status == ParameterStatus.ABNORMAL;
}

class ReportRecommendation {
  final String task;
  final String detail;
  final String icon;

  ReportRecommendation({
    required this.task,
    required this.detail,
    this.icon = 'assignment_turned_in',
  });

  factory ReportRecommendation.fromMap(Map<String, dynamic> map) =>
      ReportRecommendation(
        task: map['task'] ?? '',
        detail: map['detail'] ?? '',
        icon: map['icon'] ?? 'assignment_turned_in',
      );

  Map<String, dynamic> toMap() => {
        'task': task,
        'detail': detail,
        'icon': icon,
      };
}

class MedicalReport {
  final String id;
  final String title;
  final String type;
  final String date;
  final String location;
  final List<DiagnosticParameter> parameters;
  final String status; // 'Normal' or 'Abnormal'
  final String? trendSummary;
  final String? insights;
  final List<ReportRecommendation> recommendations;
  final String userId;

  MedicalReport({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.location,
    required this.parameters,
    required this.status,
    this.trendSummary,
    this.insights,
    required this.recommendations,
    required this.userId,
  });

  bool get isAbnormal => status == 'Abnormal';

  factory MedicalReport.fromMap(Map<String, dynamic> map, String docId) {
    return MedicalReport(
      id: docId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'Diagnostic Scan',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? 'Normal',
      trendSummary: map['trendSummary'],
      insights: map['insights'],
      userId: map['userId'] ?? '',
      parameters: (map['parameters'] as List<dynamic>? ?? [])
          .map((p) => DiagnosticParameter.fromMap(p as Map<String, dynamic>))
          .toList(),
      recommendations: (map['recommendations'] as List<dynamic>? ?? [])
          .map((r) =>
              ReportRecommendation.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type,
        'date': date,
        'location': location,
        'status': status,
        'trendSummary': trendSummary,
        'insights': insights,
        'userId': userId,
        'parameters': parameters.map((p) => p.toMap()).toList(),
        'recommendations': recommendations.map((r) => r.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };
}
