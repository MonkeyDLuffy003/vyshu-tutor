enum Sender { user, ai }

class ChatMessage {
  final Sender sender;
  final String text;
  final DateTime time;

  ChatMessage({required this.sender, required this.text, DateTime? time})
      : time = time ?? DateTime.now();
}
