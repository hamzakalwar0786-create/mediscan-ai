import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Microphone not available on this device.')),
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _inputCtrl.text = result.recognizedWords;
            _inputCtrl.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputCtrl.text.length),
            );
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        localeId: 'en_US',
      );
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;
    final isTyping = chat.isTyping;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      children: [
        // Doctor header
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryBlue,
                    child: const Icon(Icons.smart_toy,
                        color: Colors.white, size: 22),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MediScan AI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    Text(
                      'AI HEALTH ASSISTANT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppTheme.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear Chat History'),
                      content: const Text(
                          'This will delete all messages. Continue?'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Clear',
                                style: TextStyle(
                                    color: Color(0xFFEF4444)))),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<ChatProvider>().clearHistory();
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: messages.length + (isTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == messages.length && isTyping) {
                return _TypingIndicator();
              }
              return _MessageBubble(
                message: messages[i],
                onViewTests: () {
                  // Navigate to categories
                },
              );
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: TextField(
                      controller: _inputCtrl,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Describe your symptoms...',
                        border: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Voice mic button
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppTheme.red
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening
                          ? Icons.mic
                          : Icons.mic_none_outlined,
                      color: _isListening
                          ? Colors.white
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onViewTests;

  const _MessageBubble({required this.message, this.onViewTests});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? AppTheme.primaryBlue
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: isUser
                  ? null
                  : Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 12, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'CLINICAL ANALYSIS',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isUser ? Colors.white : null,
                    height: 1.5,
                  ),
                ),
                if (!isUser && message.recommendation != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                            color: AppTheme.primaryBlue, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECOMMENDATION',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${message.recommendation}"',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isUser && message.suggestedTests) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewTests,
                      icon: const Icon(Icons.biotech, size: 14),
                      label: const Text('View Suggested Tests',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            message.timestamp,
            style: const TextStyle(
                fontSize: 9, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(
          reverse: true,
          period: Duration(milliseconds: 600 + i * 150),
        );
    });
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: -8).animate(c))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, _anims[i].value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
