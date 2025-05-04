import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatScreen extends StatefulWidget {
  final String aiModelName;
  final String? modelType;
  final String workflowId;
  final String? chatId;

  const ChatScreen({
    Key? key, 
    required this.aiModelName,
    required this.workflowId,
    this.modelType,
    this.chatId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _currentChatId;
  RealtimeChannel? _chatChannel;
  bool _isWaitingForResponse = false;

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // If no existing chatId, create a new chat session
      if (_currentChatId == null) {
        print('Creating new chat session for workflow: ${widget.workflowId}');
        _currentChatId = await ChatService.getOrCreateChatSession(
          workflowId: widget.workflowId,
        );
        print('Created new chat session: $_currentChatId');
      } else {
        print('Using existing chat session: $_currentChatId');
      }

      // Load messages for the current chat
      await _loadMessages();

      // Start listening for new messages
      _subscribeToMessages();

    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing chat: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Scroll to bottom when messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_currentChatId == null) {
      return;
    }
    
    try {
      final messages = await ChatService.getChatMessages(_currentChatId!);
      final currentUserId = ChatService.supabase.auth.currentUser?.id ?? '';
      
      if (mounted) {
        setState(() {
          _messages = messages
              .map((m) => ChatMessage.fromMap(m, currentUserId))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: ${e.toString()}')),
        );
      }
    }
  }

  void _subscribeToMessages() {
    if (_currentChatId == null) return;
    
    // Dispose of any existing subscription
    if (_chatChannel != null) {
      ChatService.unsubscribeFromChat(_chatChannel!);
    }
    
    // Set up real-time subscription
    _chatChannel = ChatService.subscribeToChat(
      _currentChatId!,
      (newMessageData) {
        final currentUserId = ChatService.supabase.auth.currentUser?.id ?? '';
        final newMessage = ChatMessage.fromMap(newMessageData, currentUserId);
        
        // Check if this message is already in the list
        final isDuplicate = _messages.any((m) => m.id == newMessage.id);
        
        if (!isDuplicate && mounted) {
          setState(() {
            _messages.add(newMessage);
            // Sort messages by timestamp
            _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            
            // If this is a bot response, mark that we're no longer waiting
            if (newMessage.senderId != currentUserId) {
              _isWaitingForResponse = false;
            }
          });
          _scrollToBottom();
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_currentChatId == null) {
      await _initializeChat();
      if (_currentChatId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize chat session. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    _controller.clear();
    final _secureStorage = const FlutterSecureStorage();
    final currentUserId = await _secureStorage.read(key: 'user_id');
    
    // Create optimistic message to show immediately
    final optimisticMessage = ChatMessage.createLocalMessage(
      _currentChatId!,
      currentUserId ?? '',
      text,
      messageType: 'text',
    );
    
    setState(() {
      _messages.add(optimisticMessage);
      _isWaitingForResponse = true;
    });
    
    // Scroll to show the new message
    await Future.delayed(const Duration(milliseconds: 50));
    _scrollToBottom();
    
    try {
      print('Sending message to server...');
      final response = await ChatService.sendMessage(
        chatId: _currentChatId!,
        message: text,
        messageType: 'text',
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: ${e.toString()}'),
            backgroundColor: Colors.red[700],
          ),
        );
        
        setState(() {
          _messages.removeWhere((m) => 
            m.message == text && 
            m.senderId == currentUserId &&
            m.id == null
          );
          _isWaitingForResponse = false;
        });
      }
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (_chatChannel != null) {
      ChatService.unsubscribeFromChat(_chatChannel!);
    }
    super.dispose();
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
            // AI Avatar - Using a Material icon instead of SVG
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[700],
              child: const Icon(
                Icons.smart_toy_outlined, 
                color: Colors.white,
                size: 20,
              ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chat Messages Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    itemCount: _messages.length,
                    addAutomaticKeepAlives: true,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        key: ValueKey(message.id ?? '${message.senderId}-${message.createdAt.millisecondsSinceEpoch}'),
                        message: message.message,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Waiting for response indicator
            if (_isWaitingForResponse)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
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
                    enabled: !_isWaitingForResponse, // Disable input during processing
                  ),
                ),
                const SizedBox(width: 8),

                // Microphone Button
                IconButton(
                  icon: Icon(Icons.mic_none_outlined, color: Colors.grey[400]),
                  iconSize: 26,
                  onPressed: _isWaitingForResponse ? null : () {
                    // Handle voice input
                  },
                ),

                // Send Button
                IconButton(
                  icon: Transform.rotate(
                    angle: -math.pi / 9,
                    child: Icon(
                      Icons.send, 
                      color: _isWaitingForResponse ? Colors.grey[700] : Colors.grey[400],
                    ),
                  ),
                  iconSize: 24,
                  onPressed: _isWaitingForResponse ? null : _sendMessage,
                ),
                const SizedBox(width: 4), // Small final padding
              ],
            ),
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