import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../services/language_service.dart';

class AiTutorService {
  /// Keeps the running conversation so the AI has context (like a real tutor).
  final List<Map<String, dynamic>> _history = [];

  String _systemPrompt(AppLanguage lang) => '''
You are Vyshu, a friendly AI tutor teaching Python programming and core AI/ML
concepts to a self-taught learner who builds everything from a phone.

Rules:
- Always reply in ${lang.promptName}. Code itself stays in English, but ALL
  explanation text must be in ${lang.promptName}.
- Explain concepts step by step, with short simple examples, like a patient
  teacher, not a textbook.
- When the learner asks about something recent (new Python release, new AI
  model, new library, current best practice), use the web_search tool to
  check before answering instead of relying on memory.
- When a topic would benefit from a video walkthrough, tell the learner to
  tap the YouTube button for that topic instead of describing a video you
  haven't seen.
- Keep answers focused and not overly long, since this is read on a phone.
''';

  Future<String> ask(String userMessage, AppLanguage lang) async {
    _history.add({
      'role': 'user',
      'content': userMessage,
    });

    final response = await http.post(
      Uri.parse(Config.anthropicEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': Config.anthropicApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': Config.model,
        'max_tokens': 1024,
        'system': _systemPrompt(lang),
        'messages': _history,
        'tools': [
          {'type': 'web_search_20250305', 'name': 'web_search'}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);
    final blocks = (data['content'] as List);

    // Concatenate all text blocks; ignore tool_use/tool_result blocks.
    final text = blocks
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n');

    _history.add({'role': 'assistant', 'content': text});
    return text;
  }

  void resetConversation() => _history.clear();
}
