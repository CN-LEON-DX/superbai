# Supabase Chat System Implementation

This project implements a real-time chat system using Supabase PostgreSQL functions and Supabase Realtime for instant message delivery. The implementation is designed for high performance and scalability.

## Database Schema

The chat system uses the following database schema:

- `chat_session`: Stores information about chat sessions
- `chat_message`: Stores individual messages with support for text, audio, and file attachments
- `workflow`: Defines workflows that chat sessions belong to
- `workflow_access`: Controls user access to workflows
- `auth_tokens`: Manages authentication tokens
- `account`: Stores user account information
- `userprofile`: Stores user profile information

## Main Features

1. **Real-time Chat**: Instant message delivery using Supabase Realtime
2. **Authentication**: Secure token-based authentication
3. **File/Audio Attachments**: Support for file and audio message attachments
4. **Access Control**: Fine-grained permissions for chat sessions through workflow access
5. **Session Management**: Organizing chats by workflows with proper metadata

## Implementation Files

- `chat_functions.sql`: Core PostgreSQL functions implementing chat logic
- `api_endpoints.sql`: API functions for interacting with the chat system
- `realtime_subscriptions.js`: Client-side code for real-time message subscriptions
- `chatApi.js`: JavaScript service for interacting with the chat API

## Performance Optimizations

1. **Security Definer Functions**: All database functions use `SECURITY DEFINER` to run with elevated privileges for better performance
2. **Efficient Queries**: Designed with optimal indexing and query patterns
3. **Real-time Channels**: Uses specific channels for each chat to reduce overhead
4. **Pagination**: All message retrieval supports pagination for large chat histories



## Security Considerations

1. All API functions validate user tokens before performing any operations
2. Access control is enforced at the database level
3. User input is properly sanitized and validated
4. Row-level security policies are recommended for additional protection

## Performance Tips

1. Use `subscribeToChat` for real-time updates instead of polling
2. Implement pagination when displaying large chat histories
3. Consider implementing a message seen/read status to optimize retrieval
4. Use caching for frequently accessed chat sessions

## Extension Points

1. **Webhooks**: The system supports webhook_url configuration for integration with external systems
2. **Chat Stats**: Could be extended to track chat analytics
3. **Typing Indicators**: Could be implemented using Supabase Presence channels
4. **Message Reactions**: Could be added as a new table relating to messages
