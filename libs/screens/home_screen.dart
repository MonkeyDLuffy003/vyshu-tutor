import 'package:flutter/material.dart';
import '../services/language_service.dart';
import 'chat_screen.dart';
import 'mock_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _selected = LanguageService.supported.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vyshu AI Tutor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Learn Python & AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Choose your language', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LanguageService.supported.map((lang) {
                final isSelected = lang.code == _selected.code;
                return ChoiceChip(
                  label: Text(lang.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selected = lang),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _ModeCard(
              icon: Icons.mic,
              title: 'Voice Chat with Vyshu',
              subtitle: 'Ask anything about Python or AI, by voice or text',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ChatScreen(language: _selected))),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.quiz,
              title: 'Mock Test',
              subtitle: 'AI-generated MCQ test to check your progress',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MockTestScreen(language: _selected))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
