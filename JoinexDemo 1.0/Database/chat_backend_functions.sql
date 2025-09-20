-- Chat Backend Functions for JoinexDemo
-- This script provides backend support for real-time chat functionality

-- 1. Create conversations table
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user1_id, user2_id)
);

-- 2. Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable Row Level Security
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS policies for conversations
DROP POLICY IF EXISTS "Users can view their own conversations" ON conversations;
CREATE POLICY "Users can view their own conversations" ON conversations
    FOR SELECT USING (
        auth.uid() = user1_id OR auth.uid() = user2_id
    );

DROP POLICY IF EXISTS "Users can create conversations" ON conversations;
CREATE POLICY "Users can create conversations" ON conversations
    FOR INSERT WITH CHECK (
        auth.uid() = user1_id OR auth.uid() = user2_id
    );

DROP POLICY IF EXISTS "Users can update their own conversations" ON conversations;
CREATE POLICY "Users can update their own conversations" ON conversations
    FOR UPDATE USING (
        auth.uid() = user1_id OR auth.uid() = user2_id
    );

-- 5. Create RLS policies for messages
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON messages;
CREATE POLICY "Users can view messages in their conversations" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations 
            WHERE id = conversation_id 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can send messages in their conversations" ON messages;
CREATE POLICY "Users can send messages in their conversations" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM conversations 
            WHERE id = conversation_id 
            AND (user1_id = auth.uid() OR user2_id = auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can update their own messages" ON messages;
CREATE POLICY "Users can update their own messages" ON messages
    FOR UPDATE USING (
        sender_id = auth.uid()
    );

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversations_user1_id ON conversations(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2_id ON conversations(user2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at ON conversations(updated_at);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- 7. Function to get or create conversation
CREATE OR REPLACE FUNCTION get_or_create_conversation(
    other_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    conversation_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    -- Check if conversation already exists
    SELECT id INTO conversation_id
    FROM conversations
    WHERE (user1_id = current_user_id AND user2_id = other_user_id)
       OR (user1_id = other_user_id AND user2_id = current_user_id);
    
    -- If conversation doesn't exist, create it
    IF conversation_id IS NULL THEN
        INSERT INTO conversations (user1_id, user2_id)
        VALUES (current_user_id, other_user_id)
        RETURNING id INTO conversation_id;
    END IF;
    
    RETURN conversation_id;
END;
$$;

-- 8. Function to get user conversations
CREATE OR REPLACE FUNCTION get_user_conversations()
RETURNS TABLE (
    id UUID,
    user1_id UUID,
    user2_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    other_user_id UUID,
    other_user_name TEXT,
    last_message_content TEXT,
    last_message_time TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    RETURN QUERY
    SELECT 
        c.id,
        c.user1_id,
        c.user2_id,
        c.created_at,
        c.updated_at,
        CASE 
            WHEN c.user1_id = current_user_id THEN c.user2_id
            ELSE c.user1_id
        END as other_user_id,
        p.username as other_user_name,
        m.content as last_message_content,
        m.created_at as last_message_time
    FROM conversations c
    LEFT JOIN profiles p ON (
        CASE 
            WHEN c.user1_id = current_user_id THEN c.user2_id
            ELSE c.user1_id
        END = p.id
    )
    LEFT JOIN LATERAL (
        SELECT content, created_at
        FROM messages
        WHERE conversation_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
    ) m ON true
    WHERE c.user1_id = current_user_id OR c.user2_id = current_user_id
    ORDER BY c.updated_at DESC;
END;
$$;

-- 9. Function to get conversation messages
CREATE OR REPLACE FUNCTION get_conversation_messages(
    conv_id UUID
) RETURNS TABLE (
    id UUID,
    conversation_id UUID,
    sender_id UUID,
    content TEXT,
    message_type TEXT,
    created_at TIMESTAMPTZ,
    sender_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if user has access to this conversation
    IF NOT EXISTS (
        SELECT 1 FROM conversations 
        WHERE id = conv_id 
        AND (user1_id = auth.uid() OR user2_id = auth.uid())
    ) THEN
        RAISE EXCEPTION 'Access denied to conversation';
    END IF;
    
    RETURN QUERY
    SELECT 
        m.id,
        m.conversation_id,
        m.sender_id,
        m.content,
        m.message_type,
        m.created_at,
        p.username as sender_name
    FROM messages m
    LEFT JOIN profiles p ON m.sender_id = p.id
    WHERE m.conversation_id = conv_id
    ORDER BY m.created_at ASC;
END;
$$;

-- 10. Function to send message
CREATE OR REPLACE FUNCTION send_message(
    conv_id UUID,
    message_content TEXT,
    message_type TEXT DEFAULT 'text'
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    message_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    -- Check if user has access to this conversation
    IF NOT EXISTS (
        SELECT 1 FROM conversations 
        WHERE id = conv_id 
        AND (user1_id = current_user_id OR user2_id = current_user_id)
    ) THEN
        RAISE EXCEPTION 'Access denied to conversation';
    END IF;
    
    -- Insert message
    INSERT INTO messages (conversation_id, sender_id, content, message_type)
    VALUES (conv_id, current_user_id, message_content, message_type)
    RETURNING id INTO message_id;
    
    -- Update conversation's updated_at timestamp
    UPDATE conversations 
    SET updated_at = NOW()
    WHERE id = conv_id;
    
    RETURN message_id;
END;
$$;

-- 11. Trigger to update conversation timestamp when messages are added
CREATE OR REPLACE FUNCTION update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations 
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_conversation_timestamp ON messages;
CREATE TRIGGER trigger_update_conversation_timestamp
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_timestamp();

-- 12. Function to search conversations by user name
CREATE OR REPLACE FUNCTION search_conversations(
    search_query TEXT DEFAULT ''
) RETURNS TABLE (
    id UUID,
    user1_id UUID,
    user2_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    other_user_id UUID,
    other_user_name TEXT,
    last_message_content TEXT,
    last_message_time TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    RETURN QUERY
    SELECT 
        c.id,
        c.user1_id,
        c.user2_id,
        c.created_at,
        c.updated_at,
        CASE 
            WHEN c.user1_id = current_user_id THEN c.user2_id
            ELSE c.user1_id
        END as other_user_id,
        p.username as other_user_name,
        m.content as last_message_content,
        m.created_at as last_message_time
    FROM conversations c
    LEFT JOIN profiles p ON (
        CASE 
            WHEN c.user1_id = current_user_id THEN c.user2_id
            ELSE c.user1_id
        END = p.id
    )
    LEFT JOIN LATERAL (
        SELECT content, created_at
        FROM messages
        WHERE conversation_id = c.id
        ORDER BY created_at DESC
        LIMIT 1
    ) m ON true
    WHERE (c.user1_id = current_user_id OR c.user2_id = current_user_id)
    AND (search_query = '' OR p.username ILIKE '%' || search_query || '%')
    ORDER BY c.updated_at DESC;
END;
$$; 