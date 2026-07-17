import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../services/language_service.dart';

class MockQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  MockQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory MockQuestion.fromJson(Map<String, dynamic> j) => MockQuestion(
        question: j['question'],
        options: List<String>.from(j['options']),
        correctIndex: j['correct_index'],
        explanation: j['explanation'],
      );
}

class MockTestService {
  Future<List<MockQuestion>> generateTest({
    required String topic,
    required AppLanguage lang,
    int count = 5,
  }) async {
    final prompt = '''
Create a $count-question multiple choice mock test on the topic "$topic"
(Python programming or AI, whichever fits) for a self-taught beginner-to-intermediate learner.

Reply ONLY with raw JSON, no markdown fences, no preamble, in exactly this shape:
[
  {
    "question": "question text in ${lang.promptName}",
    "options": ["A", "B", "C", "D"],
    "correct_index": 0,
    "explanation": "short explanation in ${lang.promptName}"
  }
]
Keep code snippets inside questions in English; everything else in ${lang.promptName}.
''';

    final response = await http.post(
      Uri.parse(Config.anthropicEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': Config.anthropicApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': Config.model,
        'max_tokens': 2048,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Test generation failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);
    String text = (data['content'] as List)
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join();

    text = text.replaceAll('```json', '').replaceAll('```', '').trim();

    final List<dynamic> parsed = jsonDecode(text);
    return parsed.map((q) => MockQuestion.fromJson(q)).toList();
  }
}
