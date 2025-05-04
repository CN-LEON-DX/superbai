import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static final supabase = Supabase.instance.client;

  // Get or create a chat session for a workflow
  static Future<String> getOrCreateChatSession({
    required String workflowId,
  }) async {
    try {
      final response = await supabase
          .rpc('get_or_create_chat_session', params: {
            'p_workflow_id': workflowId,
          });
      
      return response as String;
    } catch (e) {
      print('Error getting/creating chat session: $e');
      throw Exception('Failed to get or create chat session: $e');
    }
  }

  // Create a new chat session
  static Future<String> createChatSession({
    required String title,
    required String workflowId,
  }) async {
    try {
      final response = await supabase
          .rpc('create_chat_session', params: {
            'p_title': title,
            'p_workflow_id': workflowId,
          });
      
      return response as String;
    } catch (e) {
      print('Error creating chat session: $e');
      throw Exception('Failed to create chat session: $e');
    }
  }

  // Get messages for a specific chat
  static Future<List<Map<String, dynamic>>> getChatMessages(String chatId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await supabase
          .rpc('get_chat_messages', params: {
            'p_chat_id': chatId,
            'p_limit': limit,
            'p_offset': offset,
          });
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting chat messages: $e');
      throw Exception('Failed to load chat messages: $e');
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
    required String messageType,
  }) async {
    try {
      print('=== Starting sendMessage process ===');
      print('Chat ID: $chatId');
      print('Message: $message');
      print('Message Type: $messageType');

      // First, send the message to the database
      print('\n1. Sending message to database...');
      final response = await supabase.rpc(
        'send_message',
        params: {
          'p_chat_id': chatId,
          'p_message': message,
          'p_message_type': messageType,
        },
      );
      print('Database response: $response');

      if (response['success'] == true) {
        print('\n2. Getting workflow info...');
        // Get workflow info for webhook
        final workflowResponse = await supabase
            .from('chat_session')
            .select('workflow_id')
            .eq('chat_id', chatId)
            .single();
        print('Workflow response: $workflowResponse');

        final workflowId = workflowResponse['workflow_id'];
        print('Workflow ID: $workflowId');
        
        print('\n3. Getting webhook details...');
        // Get webhook details
        final webhookResponse = await supabase
            .from('workflow')
            .select('webhook_url, header_auth_key, header_auth_value')
            .eq('id_workflow', workflowId)
            .single();
        print('Webhook details: $webhookResponse');

        final webhookUrl = webhookResponse['webhook_url'];
        final authKey = webhookResponse['header_auth_key'];
        final authValue = webhookResponse['header_auth_value'];

        if (webhookUrl != null && webhookUrl.isNotEmpty) {
          print('\n4. Preparing webhook call...');
          final headers = <String, String>{
            'Content-Type': 'application/json',
            if (authKey != null && authValue != null) authKey: authValue,
          };
          print('Headers: $headers');

          final body = {
            'message': message,
            'message_type': messageType,
            'chat_id': chatId,
            'workflow_id': workflowId,
            'user_id': supabase.auth.currentUser?.id,
          };
          print('Request body: $body');

          print('\n5. Making webhook call to: $webhookUrl');
          final webhookResponse = await http.post(
            Uri.parse(webhookUrl),
            headers: headers,
            body: jsonEncode(body),
          );
          print('Webhook response status: ${webhookResponse.statusCode}');
          print('Webhook response body: ${webhookResponse.body}');

          if (webhookResponse.statusCode == 200) {
            final botResponse = jsonDecode(webhookResponse.body)['response'];
            print('\n6. Bot response received: $botResponse');
            
            print('\n7. Inserting bot response to database...');
            // Insert bot response into database
            await supabase.from('chat_message').insert({
              'chat_id': chatId,
              'sender_id': '00000000-0000-0000-0000-000000000000',
              'message': botResponse,
              'message_type': messageType,
              'created_at': DateTime.now().toIso8601String(),
            });
            print('Bot response inserted successfully');
          } else {
            print('\n6. Webhook call failed with status: ${webhookResponse.statusCode}');
            print('Error response: ${webhookResponse.body}');
          }
        } else {
          print('\n4. No webhook URL configured for this workflow');
        }
      }

      print('\n=== End of sendMessage process ===');
      return response;
    } catch (e, stackTrace) {
      print('\n=== Error in sendMessage process ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get all chats for current user
  static Future<List<Map<String, dynamic>>> getUserChats({int limit = 10, int offset = 0}) async {
    try {
      final response = await supabase.rpc('get_user_chats', params: {
        'p_limit': limit,
        'p_offset': offset,
      });
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting user chats: $e');
      throw Exception('Failed to load user chats: $e');
    }
  }

  // Subscribe to chat messages
  static RealtimeChannel subscribeToChat(
    String chatId,
    Function(Map<String, dynamic>) onMessageReceived,
  ) {
    final channel = supabase.channel('public:chat_message:chat_id=eq.$chatId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_message',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'chat_id',
        value: chatId,
      ),
      callback: (payload) {
        // Handle the new message received
        if (payload.newRecord != null) {
          onMessageReceived(payload.newRecord!);
        }
      },
    ).subscribe();

    return channel;
  }
  
  // Unsubscribe from a channel
  static void unsubscribeFromChat(RealtimeChannel channel) {
    supabase.removeChannel(channel);
  }
} 