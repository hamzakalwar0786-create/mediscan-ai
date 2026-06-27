import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final String timestamp;
  final String? recommendation;
  final bool suggestedTests;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.recommendation,
    this.suggestedTests = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      sender: map['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? '',
      recommendation: map['recommendation'],
      suggestedTests: map['suggestedTests'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'sender': sender == MessageSender.user ? 'user' : 'ai',
        'text': text,
        'timestamp': timestamp,
        'recommendation': recommendation,
        'suggestedTests': suggestedTests,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
