import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/medical_report.dart';
import '../models/chat_message.dart';
import '../utils/language_detector.dart';

class GeminiService {
  static const String _geminiApiKey = 'AIzaSyDzT3KR_af1qo3iT9vmBRysuXn5gZiHbi0';
  static const String _visionApiKey = 'AIzaSyD_9NDFRJsQ7c4mLpyV06yDWQtvOVooEIg';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _chatModel = 'gemini-1.5-flash';
  static const String _visionModel = 'gemini-1.5-flash';

  // ─── Analyze medical report image using Vision+Gemini ──────────────────────
  Future<MedicalReport> analyzeReportImage({
    required Uint8List imageBytes,
    required String fileName,
    required String userId,
  }) async {
    final String base64Image = base64Encode(imageBytes);
    final String mimeType = _getMimeType(fileName);

    final prompt = '''
You are a highly precise clinical scanner and doctor. Analyze this medical report image carefully.
Extract ALL diagnostic parameters, their results, units, reference ranges.
Evaluate each parameter as LOW, NORMAL, HIGH, or ABNORMAL.
Generate comprehensive doctor-grade insights and actionable clinical recommendations.

Respond ONLY with valid JSON in this exact format:
{
  "title": "Name of the report (e.g. Complete Blood Count)",
  "status": "Normal or Abnormal",
  "trendSummary": "Brief trend analysis comparing to normal ranges",
  "insights": "Clinical breakdown in patient-friendly language",
  "parameters": [
    {
      "name": "Parameter name",
      "result": "Numeric or text result",
      "unit": "Measurement unit",
      "referenceRange": "Normal reference range",
      "status": "LOW|NORMAL|HIGH|ABNORMAL"
    }
  ],
  "recommendations": [
    {
      "task": "Action title",
      "detail": "Specific actionable guidance"
    }
  ]
}
''';

    final url = Uri.parse(
        '$_geminiBaseUrl/$_visionModel:generateContent?key=$_visionApiKey');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 4096,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Vision API error: ${response.statusCode} - ${response.body}');
    }

    final responseJson = jsonDecode(response.body);
    final rawText = responseJson['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

    // Clean markdown code fences if present
    final cleaned = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    return _buildReport(parsed, userId);
  }

  // ─── Chat with AI Doctor ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> chat({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final url = Uri.parse(
        '$_geminiBaseUrl/$_chatModel:generateContent?key=$_geminiApiKey');

    // Detect language and build appropriate system instruction
    final langInstruction = LanguageDetector.getLanguageInstruction(message);

    final systemInstruction = '''You are "MediScan AI", an elite, highly empathetic clinical AI health companion.
You help interpret diagnostic lab results including CBC, Urine, Cardiac, Lipid, Vitamin D reports.
Always communicate with professional composure. Keep insights patient-friendly and easily digestible.
IMPORTANT:
- If the user writes in Hinglish or romanized Urdu/Hindi (e.g. "Mera pet dard ho raha hai"), respond in a natural mix of simple English and romanized Urdu/Hindi.
- Indicate when further clinical diagnostic tests are highly recommended.
- Never claim clinical certainty - always advise consulting a physician for ultimate diagnostics.
- Give direct actionable bullet guides for health queries.
- Keep responses concise but comprehensive.
$langInstruction''';

    // Build conversation history
    final contents = <Map<String, dynamic>>[];
    for (final msg in history) {
      contents.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'model',
        'parts': [{'text': msg.text}]
      });
    }
    contents.add({
      'role': 'user',
      'parts': [{'text': message}]
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': systemInstruction}]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body);
    final reply =
        responseJson['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'I was unable to process your query. Please consult a healthcare professional.';

    final lower = reply.toLowerCase();
    final suggestedTests = lower.contains('test') ||
        lower.contains('checkup') ||
        lower.contains('cbc') ||
        lower.contains('vitamin') ||
        lower.contains('blood work') ||
        lower.contains('lab');

    return {'reply': reply, 'suggestedTests': suggestedTests};
  }

  // ─── Helper: build MedicalReport from parsed JSON ─────────────────────────
  MedicalReport _buildReport(Map<String, dynamic> parsed, String userId) {
    final now = DateTime.now();
    final dateStr =
        '${_monthName(now.month)} ${now.day.toString().padLeft(2, '0')}, ${now.year}';

    final parameters = (parsed['parameters'] as List<dynamic>? ?? [])
        .map((p) =>
            DiagnosticParameter.fromMap(p as Map<String, dynamic>))
        .toList();

    final recommendations = (parsed['recommendations'] as List<dynamic>? ?? [])
        .map((r) {
          final rec = r as Map<String, dynamic>;
          final icon = _iconForTask(rec['task']?.toString() ?? '');
          return ReportRecommendation(
            task: rec['task'] ?? '',
            detail: rec['detail'] ?? '',
            icon: icon,
          );
        })
        .toList();

    return MedicalReport(
      id: 'rep-${now.millisecondsSinceEpoch}',
      title: parsed['title'] ?? 'Clinical Report',
      type: _inferType(parsed['title'] ?? ''),
      date: dateStr,
      location: 'AI Diagnosed Clinical Insights',
      status: parsed['status'] ?? 'Normal',
      trendSummary: parsed['trendSummary'],
      insights: parsed['insights'],
      parameters: parameters,
      recommendations: recommendations,
      userId: userId,
    );
  }

  String _inferType(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('blood') || lower.contains('cbc') ||
        lower.contains('lipid') || lower.contains('vitamin')) {
      return 'Blood Test';
    } else if (lower.contains('urine')) {
      return 'Urine Test';
    } else if (lower.contains('cardiac') || lower.contains('ecg')) {
      return 'Cardiac Test';
    }
    return 'Diagnostic Scan';
  }

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lower.endsWith('.png')) {
      return 'image/png';
    } else if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'image/jpeg';
  }

  String _iconForTask(String task) {
    final lower = task.toLowerCase();
    if (lower.contains('eat') || lower.contains('food') ||
        lower.contains('diet') || lower.contains('iron')) return 'restaurant';
    if (lower.contains('supplement') || lower.contains('pill') ||
        lower.contains('vitamin')) return 'pill';
    if (lower.contains('sun') || lower.contains('outdoor')) return 'wb_sunny';
    if (lower.contains('repeat') || lower.contains('re-test') ||
        lower.contains('retest')) return 'repeat';
    if (lower.contains('exercise') || lower.contains('run') ||
        lower.contains('walk')) return 'directions_run';
    return 'assignment_turned_in';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
