// Feature: ROMAN URDU DETECTION — detect language and adjust response
class LanguageDetector {
  // Common Roman Urdu words and patterns
  static const List<String> _romanUrduKeywords = [
    'mera', 'meri', 'aap', 'kya', 'nahi', 'hain', 'hai', 'tha', 'thi',
    'ho', 'kar', 'karo', 'karna', 'dard', 'takleef', 'bimari', 'doctor',
    'dawai', 'dawa', 'sehat', 'tabiyat', 'bukhar', 'sir', 'pet', 'peeth',
    'thakan', 'kamzori', 'neend', 'bhook', 'pani', 'khana', 'theek',
    'achha', 'bura', 'zyada', 'kam', 'kuch', 'bahut', 'bohat', 'bilkul',
    'zaroor', 'chahiye', 'lagta', 'feel', 'hota', 'rehta', 'uthna',
    'sona', 'chalna', 'baat', 'masla', 'problem', 'koi', 'woh', 'yeh',
    'main', 'hum', 'tum', 'unhe', 'inhe', 'uski', 'mere', 'apna',
    'abhi', 'kal', 'parso', 'kaafi', 'thora', 'lambay', 'andar',
    'bahar', 'upar', 'neeche', 'roz', 'rozana', 'subah', 'raat', 'sham',
    'khoon', 'khanda', 'test', 'result', 'report', 'injection',
    'capsule', 'tablet', 'syrup', 'clinic', 'hospital', 'doctor sahib',
  ];

  static const List<String> _urduArabicChars = [
    'آ', 'ا', 'ب', 'پ', 'ت', 'ٹ', 'ث', 'ج', 'چ', 'ح', 'خ',
    'د', 'ڈ', 'ذ', 'ر', 'ڑ', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض',
    'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن',
    'ں', 'و', 'ہ', 'ھ', 'ی', 'ے',
  ];

  /// Returns true if text contains Roman Urdu
  static bool isRomanUrdu(String text) {
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'[\s,\.!?]+'));

    int matchCount = 0;
    for (final word in words) {
      if (_romanUrduKeywords.contains(word)) {
        matchCount++;
      }
    }

    // If >= 2 Roman Urdu words found, likely Roman Urdu
    return matchCount >= 2;
  }

  /// Returns true if text contains native Urdu script
  static bool isNativeUrdu(String text) {
    for (final char in _urduArabicChars) {
      if (text.contains(char)) return true;
    }
    return false;
  }

  /// Returns the detected language type
  static LanguageType detect(String text) {
    if (isNativeUrdu(text)) return LanguageType.urduScript;
    if (isRomanUrdu(text)) return LanguageType.romanUrdu;
    return LanguageType.english;
  }

  /// Build system instruction addition for detected language
  static String getLanguageInstruction(String text) {
    final lang = detect(text);
    switch (lang) {
      case LanguageType.romanUrdu:
        return '''
The user is writing in Roman Urdu (Urdu written in English letters).
IMPORTANT: Respond in a natural mix of simple English and Roman Urdu. 
Use warm, simple language. Example: "Aap ki Vitamin D bohat low hai, aur yeh thakan aur kamzori ki wajah ho sakti hai. Main suggest karoonga ke..."
Keep medical terms in English but explanations in Roman Urdu.''';

      case LanguageType.urduScript:
        return '''
The user is writing in Urdu script.
IMPORTANT: Respond in Urdu script mixed with English medical terms.
Be warm and patient-friendly.''';

      case LanguageType.english:
      default:
        return '';
    }
  }
}

enum LanguageType { english, romanUrdu, urduScript }
