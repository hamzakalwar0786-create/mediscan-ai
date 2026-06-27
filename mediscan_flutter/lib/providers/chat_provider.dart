import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();
  final FirestoreService _firestore = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _userId = '';

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _initMessages();
  }

  void _initMessages() {
    _messages = [
      ChatMessage(
        id: 'init-01',
        sender: MessageSender.ai,
        text:
            'Hello, I am MediScan AI, your clinical health companion. Ask me anything about your scanned reports, blood counts, or hormonal trends.',
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        suggestedTests: false,
      ),
    ];
  }

  void setUserId(String uid) {
    if (_userId != uid) {
      _userId = uid;
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _firestore.fetchChatHistory(_userId);
      if (history.isNotEmpty) {
        _messages = history;
        notifyListeners();
      }
    } catch (_) {
      // Keep initial messages on error
    }
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      text: text,
      timestamp: DateFormat('hh:mm a').format(DateTime.now()),
    );

    _messages = [..._messages, userMsg];
    _isTyping = true;
    notifyListeners();

    // Save user message to Firestore
    if (_userId.isNotEmpty) {
      try {
        await _firestore.saveMessage(_userId, userMsg);
      } catch (_) {}
    }

    try {
      final result = await _gemini.chat(
        message: text,
        history: _messages
            .where((m) => m.id != userMsg.id)
            .toList(),
      );

      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        sender: MessageSender.ai,
        text: result['reply'] as String,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        suggestedTests: result['suggestedTests'] as bool? ?? false,
      );

      _messages = [..._messages, aiMsg];
      _isTyping = false;
      notifyListeners();

      // Save AI message to Firestore
      if (_userId.isNotEmpty) {
        try {
          await _firestore.saveMessage(_userId, aiMsg);
        } catch (_) {}
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: _uuid.v4(),
        sender: MessageSender.ai,
        text:
            'I analyzed your query about "$text". To provide precise feedback, consulting with a registered physician alongside additional blood work is highly recommended. I\'m here to help guide you further.',
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        suggestedTests: true,
      );
      _messages = [..._messages, errorMsg];
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _initMessages();
    notifyListeners();
    if (_userId.isNotEmpty) {
      try {
        await _firestore.clearChatHistory(_userId);
      } catch (_) {}
    }
  }
}
