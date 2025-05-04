-- Enable http extension
CREATE EXTENSION IF NOT EXISTS http;

CREATE OR REPLACE FUNCTION send_message(
  p_chat_id UUID,
  p_message TEXT,
  p_message_type TEXT DEFAULT 'text',
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
BEGIN
  -- Validate parameters
  IF p_chat_id IS NULL OR p_message IS NULL THEN
    RAISE EXCEPTION 'chat_id and message are required';
  END IF;

  -- Get workflow info for this chat
  SELECT cs.workflow_id INTO v_workflow_id
  FROM chat_session cs
  WHERE cs.chat_id = p_chat_id;
  
  IF v_workflow_id IS NULL THEN
    RAISE EXCEPTION 'Chat session not found';
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
  
  -- Return success response with message details
  RETURN json_build_object(
    'success', true,
    'message_id', v_message_id,
    'chat_id', p_chat_id,
    'workflow_id', v_workflow_id
  );
END;
$$;