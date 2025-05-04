-- Add message_type column to chat_message table
ALTER TABLE chat_message 
ADD COLUMN message_type TEXT NOT NULL DEFAULT 'text';

-- Add check constraint to ensure valid message types
ALTER TABLE chat_message
ADD CONSTRAINT valid_message_type 
CHECK (message_type IN ('text', 'image', 'file', 'audio', 'video', 'system'));

-- Drop existing functions with exact parameter types
DROP FUNCTION IF EXISTS send_message(p_chat_id UUID, p_message TEXT, p_audio_url TEXT, p_file_url TEXT, p_user_id UUID);
DROP FUNCTION IF EXISTS send_message(p_chat_id UUID, p_message TEXT, p_message_type TEXT, p_audio_url TEXT, p_file_url TEXT, p_user_id UUID);
DROP FUNCTION IF EXISTS get_chat_messages(UUID, INT, INT);

-- Update the send_message function to include message_type
CREATE OR REPLACE FUNCTION send_message(
  p_chat_id UUID,
  p_message TEXT,
  p_message_type TEXT DEFAULT 'text',
  p_audio_url TEXT DEFAULT NULL,
  p_file_url TEXT DEFAULT NULL,
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_message_id BIGINT;
  v_workflow_id UUID;
  v_webhook_url TEXT;
  v_header_auth_key TEXT;
  v_header_auth_value TEXT;
  v_response JSONB;
  v_bot_response TEXT;
  v_bot_message_id BIGINT;
BEGIN
  -- Validate parameters
  IF p_chat_id IS NULL OR p_message IS NULL THEN
    RAISE EXCEPTION 'chat_id and message are required';
  END IF;

  -- Validate message_type
  IF p_message_type NOT IN ('text', 'image', 'file', 'audio', 'video', 'system') THEN
    RAISE EXCEPTION 'Invalid message_type. Must be one of: text, image, file, audio, video, system';
  END IF;

  -- Get workflow info for this chat
  SELECT cs.workflow_id, w.webhook_url, w.header_auth_key, w.header_auth_value
  INTO v_workflow_id, v_webhook_url, v_header_auth_key, v_header_auth_value
  FROM chat_session cs
  JOIN workflow w ON cs.workflow_id = w.id_workflow
  WHERE cs.chat_id = p_chat_id;
  
  IF v_workflow_id IS NULL THEN
    RAISE EXCEPTION 'Chat session not found or workflow not associated';
  END IF;

  -- Insert user message
  INSERT INTO chat_message (
    chat_id,
    sender_id,
    message,
    message_type,
    audio_url,
    file_url,
    created_at
  ) VALUES (
    p_chat_id,
    p_user_id,
    p_message,
    p_message_type,
    p_audio_url,
    p_file_url,
    now()
  )
  RETURNING id INTO v_message_id;
  
  -- Prepare response to return even if webhook call fails
  v_response := jsonb_build_object(
    'success', true,
    'message_id', v_message_id,
    'chat_id', p_chat_id,
    'workflow_id', v_workflow_id
  );
  
  -- If webhook URL is available, call it
  IF v_webhook_url IS NOT NULL AND v_webhook_url != '' THEN
    -- This is a placeholder for webhook call
    -- In a real implementation, you would use pg_net extension or similar
    -- to make an HTTP request to the webhook URL
    
    -- Mock the webhook response for demonstration
    -- In production, replace this with actual HTTP call logic
    v_bot_response := 'This is a simulated bot response to your message: "' || p_message || '"';
    
    -- Insert bot response message
    INSERT INTO chat_message (
      chat_id,
      sender_id,
      message,
      message_type,
      created_at
    ) VALUES (
      p_chat_id,
      '00000000-0000-0000-0000-000000000000', -- System/bot user ID
      v_bot_response,
      'text', -- Bot responses are typically text
      now()
    )
    RETURNING id INTO v_bot_message_id;
    
    -- Add bot response to the return value using jsonb_build_object and jsonb concatenation
    v_response := v_response || jsonb_build_object(
      'bot_response', v_bot_response,
      'bot_message_id', v_bot_message_id
    );
  END IF;
  
  RETURN v_response;
END;
$$;

-- Update get_chat_messages function to include message_type
CREATE OR REPLACE FUNCTION get_chat_messages(
  p_chat_id UUID,
  p_limit INT DEFAULT 50,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id BIGINT,
  chat_id UUID,
  sender_id UUID,
  message VARCHAR,
  message_type VARCHAR,
  audio_url VARCHAR,
  file_url VARCHAR,
  created_at TIMESTAMPTZ,
  is_from_user BOOLEAN,
  sender_name VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Validate parameters
  IF p_chat_id IS NULL THEN
    RAISE EXCEPTION 'chat_id is required';
  END IF;

  RETURN QUERY
  SELECT 
    cm.id,
    cm.chat_id,
    cm.sender_id,
    cm.message::VARCHAR,
    cm.message_type::VARCHAR,
    cm.audio_url::VARCHAR,
    cm.file_url::VARCHAR,
    cm.created_at,
    cm.sender_id = auth.uid() AS is_from_user,
    (CASE 
      WHEN cm.sender_id = '00000000-0000-0000-0000-000000000000' THEN 'AI Assistant'
      WHEN cm.sender_id = auth.uid() THEN 'You'
      ELSE COALESCE(up.name, 'User')
    END)::VARCHAR AS sender_name
  FROM 
    chat_message cm
  LEFT JOIN
    userprofile up ON cm.sender_id = up.user_id
  WHERE 
    cm.chat_id = p_chat_id
  ORDER BY 
    cm.created_at ASC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$; 