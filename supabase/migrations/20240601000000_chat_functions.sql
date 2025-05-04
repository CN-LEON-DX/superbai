-- Chat Functions for Supabase with Webhook Integration

-- Function to create a new chat session for a workflow
CREATE OR REPLACE FUNCTION create_chat_session(
  p_title TEXT,
  p_workflow_id UUID,
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_chat_id UUID;
BEGIN
  -- Validate parameters
  IF p_workflow_id IS NULL THEN
    RAISE EXCEPTION 'workflow_id is required';
  END IF;

  -- Verify user has access to the workflow
  IF NOT EXISTS (
    SELECT 1 FROM workflow_access 
    WHERE id_workflow = p_workflow_id AND user_id = p_user_id AND can_view = true
  ) THEN
    -- Check if this is a public workflow that doesn't require explicit access
    IF NOT EXISTS (
      SELECT 1 FROM workflow WHERE id_workflow = p_workflow_id
    ) THEN
      RAISE EXCEPTION 'Workflow not found';
    END IF;
  END IF;

  -- Create a new chat session
  INSERT INTO chat_session (
    chat_id,
    title,
    workflow_id,
    created_at
  ) VALUES (
    gen_random_uuid(),
    COALESCE(p_title, 'Chat with ' || (SELECT name FROM workflow WHERE id_workflow = p_workflow_id)),
    p_workflow_id,
    now()
  )
  RETURNING chat_id INTO v_chat_id;
  
  RETURN v_chat_id;
END;
$$;

-- Function to get or create a chat session for a workflow
CREATE OR REPLACE FUNCTION get_or_create_chat_session(
  p_workflow_id UUID,
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_chat_id UUID;
  v_workflow_name TEXT;
BEGIN
  -- Try to find an existing chat session for this user and workflow
  SELECT cs.chat_id INTO v_chat_id
  FROM chat_session cs
  JOIN chat_message cm ON cs.chat_id = cm.chat_id
  WHERE cs.workflow_id = p_workflow_id
  AND cm.sender_id = p_user_id
  GROUP BY cs.chat_id
  ORDER BY MAX(cm.created_at) DESC
  LIMIT 1;

  -- If no existing chat session found, create a new one
  IF v_chat_id IS NULL THEN
    SELECT name INTO v_workflow_name FROM workflow WHERE id_workflow = p_workflow_id;
    
    IF v_workflow_name IS NULL THEN
      RAISE EXCEPTION 'Workflow not found';
    END IF;
    
    INSERT INTO chat_session (
      chat_id,
      title,
      workflow_id,
      created_at
    ) VALUES (
      gen_random_uuid(),
      'Chat with ' || v_workflow_name,
      p_workflow_id,
      now()
    )
    RETURNING chat_id INTO v_chat_id;
  END IF;
  
  RETURN v_chat_id;
END;
$$;

-- Function to send a message and call the webhook for a response
CREATE OR REPLACE FUNCTION send_message(
  p_chat_id UUID,
  p_message TEXT,
  p_audio_url TEXT DEFAULT NULL,
  p_file_url TEXT DEFAULT NULL,
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS JSON
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
  v_response JSON;
  v_bot_response TEXT;
  v_bot_message_id BIGINT;
BEGIN
  -- Validate parameters
  IF p_chat_id IS NULL OR p_message IS NULL THEN
    RAISE EXCEPTION 'chat_id and message are required';
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
    audio_url,
    file_url,
    created_at
  ) VALUES (
    p_chat_id,
    p_user_id,
    p_message,
    p_audio_url,
    p_file_url,
    now()
  )
  RETURNING id INTO v_message_id;
  
  -- Prepare response to return even if webhook call fails
  v_response := json_build_object(
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
      created_at
    ) VALUES (
      p_chat_id,
      '00000000-0000-0000-0000-000000000000', -- System/bot user ID
      v_bot_response,
      now()
    )
    RETURNING id INTO v_bot_message_id;
    
    -- Add bot response to the return value
    v_response := v_response || json_build_object(
      'bot_response', v_bot_response,
      'bot_message_id', v_bot_message_id
    );
  END IF;
  
  RETURN v_response;
END;
$$;

-- Function to get messages for a specific chat
CREATE OR REPLACE FUNCTION get_chat_messages(
  p_chat_id UUID,
  p_limit INT DEFAULT 50,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id BIGINT,
  chat_id UUID,
  sender_id UUID,
  message TEXT,
  message_type TEXT,
  audio_url TEXT,
  file_url TEXT,
  created_at TIMESTAMPTZ,
  is_from_user BOOLEAN,
  sender_name TEXT
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
    cm.message::TEXT,
    cm.message_type::TEXT,
    cm.audio_url::TEXT,
    cm.file_url::TEXT,
    cm.created_at,
    (cm.sender_id = auth.uid())::BOOLEAN AS is_from_user,
    (CASE 
      WHEN cm.sender_id = '00000000-0000-0000-0000-000000000000' THEN 'AI Assistant'
      WHEN cm.sender_id = auth.uid() THEN 'You'
      ELSE COALESCE(up.name, 'User')
    END)::TEXT AS sender_name
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

-- Function to get all chat sessions for a user
CREATE OR REPLACE FUNCTION get_user_chats(
  p_user_id UUID DEFAULT auth.uid(),
  p_limit INT DEFAULT 10,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  chat_id UUID,
  title TEXT,
  workflow_id UUID,
  workflow_name TEXT,
  last_message TEXT,
  last_message_time TIMESTAMPTZ,
  workflow_logo TEXT,
  message_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  WITH user_messages AS (
    SELECT DISTINCT chat_id
    FROM chat_message
    WHERE sender_id = p_user_id
  )
  SELECT 
    cs.chat_id,
    cs.title,
    cs.workflow_id,
    w.name AS workflow_name,
    (SELECT message FROM chat_message
     WHERE chat_id = cs.chat_id
     ORDER BY created_at DESC LIMIT 1) AS last_message,
    (SELECT created_at FROM chat_message
     WHERE chat_id = cs.chat_id
     ORDER BY created_at DESC LIMIT 1) AS last_message_time,
    w.logo AS workflow_logo,
    COUNT(cm.id) AS message_count
  FROM 
    chat_session cs
  JOIN
    workflow w ON cs.workflow_id = w.id_workflow
  JOIN
    chat_message cm ON cs.chat_id = cm.chat_id
  WHERE 
    cs.chat_id IN (SELECT chat_id FROM user_messages)
  GROUP BY
    cs.chat_id, cs.title, cs.workflow_id, w.name, w.logo
  ORDER BY 
    last_message_time DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Enable Row Level Security on tables
ALTER TABLE chat_session ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_message ENABLE ROW LEVEL SECURITY;

-- Create policies for chat_session
CREATE POLICY "Users can view their own chat sessions"
  ON chat_session FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM workflow_access wa
    WHERE wa.id_workflow = chat_session.workflow_id
    AND wa.user_id = auth.uid()
    AND wa.can_view = true
  ) OR EXISTS (
    SELECT 1 FROM workflow w
    WHERE w.id_workflow = chat_session.workflow_id
  ));

CREATE POLICY "Users can insert chat sessions"
  ON chat_session FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM workflow_access wa
    WHERE wa.id_workflow = workflow_id
    AND wa.user_id = auth.uid()
    AND wa.can_view = true
  ) OR EXISTS (
    SELECT 1 FROM workflow w
    WHERE w.id_workflow = workflow_id
  ));

-- Create policies for chat_message
CREATE POLICY "Users can view messages in chats they participate in"
  ON chat_message FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM chat_session cs
    WHERE cs.chat_id = chat_message.chat_id
    AND EXISTS (
      SELECT 1 FROM chat_message cm
      WHERE cm.chat_id = cs.chat_id
      AND cm.sender_id = auth.uid()
    )
  ));

CREATE POLICY "Users can insert messages"
  ON chat_message FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM chat_session cs
      WHERE cs.chat_id = chat_id
    )
  );

-- Set up realtime publication for messages
DROP PUBLICATION IF EXISTS supabase_realtime CASCADE;
CREATE PUBLICATION supabase_realtime FOR TABLE chat_message; 