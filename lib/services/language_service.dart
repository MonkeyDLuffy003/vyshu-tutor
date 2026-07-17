/// Central place for the 5 supported languages.
/// Add a new language by adding one line to this list.
class AppLanguage {
  final String code; // used internally
  final String label; // shown in UI
  final String speechLocale; // used by speech_to_text
  final String ttsLocale; // used by flutter_tts
  final String promptName; // used when telling the AI which language to reply in

  const AppLanguage({
    required this.code,
    required this.label,
    required this.speechLocale,
    required this.ttsLocale,
    required this.promptName,
  });
}

class LanguageService {
  static const List<AppLanguage> supported = [
    AppLanguage(
      code: 'en',
      label: 'English',
      speechLocale: 'en_IN',
      ttsLocale: 'en-IN',
      promptName: 'English',
    ),
    AppLanguage(
      code: 'hi',
      label: 'हिंदी (Hindi)',
      speechLocale: 'hi_IN',
      ttsLocale: 'hi-IN',
      promptName: 'Hindi',
    ),
    AppLanguage(
      code: 'ta',
      label: 'தமிழ் (Tamil)',
      speechLocale: 'ta_IN',
      ttsLocale: 'ta-IN',
      promptName: 'Tamil',
    ),
    AppLanguage(
      code: 'te',
      label: 'తెలుగు (Telugu)',
      speechLocale: 'te_IN',
      ttsLocale: 'te-IN',
      promptName: 'Telugu',
    ),
    AppLanguage(
      code: 'kn',
      label: 'ಕನ್ನಡ (Kannada)',
      speechLocale: 'kn_IN',
      ttsLocale: 'kn-IN',
      promptName: 'Kannada',
    ),
  ];

  static AppLanguage byCode(String code) =>
      supported.firstWhere((l) => l.code == code, orElse: () => supported.first);
}
