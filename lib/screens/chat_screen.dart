import 'package:flutter/material.dart';
import 'dart:math' as math;

class Message {
  final String text;
  final bool isMe; // True if the message is from the current user

  Message({required this.text, required this.isMe});
}

class ChatScreen extends StatefulWidget {
  final String aiModelName;
  final String? modelType;

  const ChatScreen({
    Key? key, 
    required this.aiModelName,
    this.modelType,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock Chat Messages
  final List<Message> _messages = [
    Message(text: 'Hello! How can I assist you today?', isMe: false),
    Message(text: 'Can you help me with my project?', isMe: true),
    Message(
        text: 'Of course! Please tell me more about your project and what specific help you need.',
        isMe: false),
  ];

  @override
  void initState() {
    super.initState();
    // Optional: Scroll to bottom when screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: text, isMe: true));
        // Simulate response from AI after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _messages.add(Message(text: 'I\'m processing your request about "$text"...', isMe: false));
          });
          _scrollToBottom(durationMillis: 100);
        });
      });
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom({int durationMillis = 300}) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: durationMillis),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // AI Avatar
            CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://via.placeholder.com/150/771796'),
              backgroundColor: Colors.grey[700],
            ),
            const SizedBox(width: 10),
            // AI Name & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.aiModelName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent[400]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Options Menu
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
              
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message.text,
                  isMe: message.isMe,
                );
              },
            ),
          ),
          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  // Widget for input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text Input Field
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Message',
                  filled: true,
                  fillColor: const Color(0xFF2C2F37),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),

            // Microphone Button
            IconButton(
              icon: Icon(Icons.mic_none_outlined, color: Colors.grey[400]),
              iconSize: 26,
              onPressed: () {
                // Handle voice input
                
              },
            ),

            // Send Button
            IconButton(
              icon: Transform.rotate(
                angle: -math.pi / 9,
                child: Icon(Icons.send, color: Colors.grey[400])
              ),
              iconSize: 24,
              onPressed: _sendMessage,
            ),
            const SizedBox(width: 4), // Small final padding
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(16.0);
    final borderRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: isMe ? radius : Radius.zero,
      bottomRight: isMe ? Radius.zero : radius,
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F37),
          borderRadius: borderRadius,
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15.0, height: 1.3),
        ),
      ),
    );
  }
} 