import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/mock_test_service.dart';

class MockTestScreen extends StatefulWidget {
  final AppLanguage language;
  const MockTestScreen({super.key, required this.language});

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  final _service = MockTestService();
  final _topicController = TextEditingController(text: 'Python basics');
  List<MockQuestion>? _questions;
  final Map<int, int> _answers = {};
  bool _loading = false;
  bool _submitted = false;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _questions = null;
      _answers.clear();
      _submitted = false;
    });
    try {
      final qs = await _service.generateTest(topic: _topicController.text, lang: widget.language);
      setState(() => _questions = qs);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  int get _score {
    int score = 0;
    _questions?.asMap().forEach((i, q) {
      if (_answers[i] == q.correctIndex) score++;
    });
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mock Test · ${widget.language.label}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loading ? null : _generate, child: const Text('Generate')),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
            if (_questions != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _questions!.length + 1,
                  itemBuilder: (_, i) {
                    if (i == _questions!.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 32),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => _submitted = true),
                              child: const Text('Submit'),
                            ),
                            if (_submitted)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text('Score: $_score / ${_questions!.length}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    }
                    final q = _questions![i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${i + 1}. ${q.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(q.options.length, (oi) {
                              final selected = _answers[i] == oi;
                              final showCorrectness = _submitted;
                              Color? tileColor;
                              if (showCorrectness) {
                                if (oi == q.correctIndex) tileColor = Colors.green.shade100;
                                else if (selected) tileColor = Colors.red.shade100;
                              }
                              return RadioListTile<int>(
                                value: oi,
                                groupValue: _answers[i],
                                title: Text(q.options[oi]),
                                tileColor: tileColor,
                                onChanged: _submitted ? null : (v) => setState(() => _answers[i] = v!),
                              );
                            }),
                            if (_submitted)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('Explanation: ${q.explanation}', style: const TextStyle(color: Colors.grey)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
