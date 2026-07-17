import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../services/ai_tutor_service.dart';
import '../services/language_service.dart';
import '../services/speech_service.dart';
import '../services/youtube_service.dart';

class ChatScreen extends StatefulWidget {
  final AppLanguage language;
  const ChatScreen({super.key, required this.language});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ai = AiTutorService();
  final _speech = SpeechService();
  final _youtube = YoutubeService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _busy = false;
  bool _listening = false;
  String _liveText = '';

  @override
  void initState() {
    super.initState();
    _speech.init();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _busy) return;
    setState(() {
      _messages.add(ChatMessage(sender: Sender.user, text: text));
      _busy = true;
      _controller.clear();
    });
    _scrollToEnd();
    try {
      final reply = await _ai.ask(text, widget.language);
      setState(() => _messages.add(ChatMessage(sender: Sender.ai, text: reply)));
      await _speech.speak(reply, widget.language);
    } catch (e) {
      setState(() => _messages.add(ChatMessage(sender: Sender.ai, text: 'Error: $e')));
    } finally {
      setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stopListening();
      setState(() => _listening = false);
      if (_liveText.isNotEmpty) _send(_liveText);
      _liveText = '';
      return;
    }
    setState(() {
      _listening = true;
      _liveText = '';
    });
    await _speech.listen(
      lang: widget.language,
      onResult: (text, isFinal) {
        setState(() => _liveText = text);
        if (isFinal) {
          setState(() => _listening = false);
          if (text.isNotEmpty) _send(text);
        }
      },
    );
  }

  Future<void> _findVideos() async {
    if (_messages.isEmpty) return;
    final lastTopic = _messages.lastWhere((m) => m.sender == Sender.user, orElse: () => _messages.last).text;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _VideoSheet(youtube: _youtube, topic: lastTopic, lang: widget.language),
    );
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vyshu · ${widget.language.label}'),
        actions: [IconButton(icon: const Icon(Icons.smart_display), onPressed: _findVideos, tooltip: 'Find YouTube videos')],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m.sender == Sender.user;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MarkdownBody(data: m.text, shrinkWrap: true),
                  ),
                );
              },
            ),
          ),
          if (_busy) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
          if (_listening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_liveText.isEmpty ? 'Listening...' : _liveText, style: const TextStyle(color: Colors.deepPurple)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_listening ? Icons.stop_circle : Icons.mic, color: Colors.deepPurple, size: 30),
                    onPressed: _toggleMic,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Ask about Python or AI...', border: OutlineInputBorder()),
                      onSubmitted: _send,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: () => _send(_controller.text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSheet extends StatelessWidget {
  final YoutubeService youtube;
  final String topic;
  final AppLanguage lang;
  const _VideoSheet({required this.youtube, required this.topic, required this.lang});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: youtube.search(topic, langHint: lang.promptName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SizedBox(height: 150, child: Center(child: Text('Error: ${snapshot.error}')));
        }
        final videos = snapshot.data as List;
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          itemCount: videos.length,
          itemBuilder: (_, i) {
            final v = videos[i];
            return ListTile(
              leading: Image.network(v.thumbnailUrl, width: 80, fit: BoxFit.cover),
              title: Text(v.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(v.channelTitle),
              onTap: () {
                // Use url_launcher in your app to open v.url
              },
            );
          },
        );
      },
    );
  }
}
