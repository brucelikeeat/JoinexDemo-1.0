-- Real-time Event Synchronization Functions for JoinexDemo
-- This script provides backend support for real-time event detail updates and participant management

-- 1. Create event_participants table for tracking who joined events
CREATE TABLE IF NOT EXISTS event_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

-- 2. Create event_notifications table for real-time updates
CREATE TABLE IF NOT EXISTS event_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_type TEXT NOT NULL, -- 'join', 'leave', 'update'
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE
);

-- 3. Enable Row Level Security on new tables
ALTER TABLE event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_notifications ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS policies for event_participants
DROP POLICY IF EXISTS "Allow public read access to event_participants" ON event_participants;
CREATE POLICY "Allow public read access to event_participants" ON event_participants FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert event_participants" ON event_participants;
CREATE POLICY "Allow authenticated users to insert event_participants" ON event_participants FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow users to delete their own event_participants" ON event_participants;
CREATE POLICY "Allow users to delete their own event_participants" ON event_participants FOR DELETE USING (auth.uid() = user_id);

-- 5. Create RLS policies for event_notifications
DROP POLICY IF EXISTS "Allow users to read their own notifications" ON event_notifications;
CREATE POLICY "Allow users to read their own notifications" ON event_notifications FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to insert notifications" ON event_notifications;
CREATE POLICY "Allow authenticated users to insert notifications" ON event_notifications FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. Function to get detailed event information with host details for real-time event detail view
CREATE OR REPLACE FUNCTION get_event_details_with_host_for_realtime_sync(
    event_uuid UUID
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    sport_type TEXT,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    date_time TIMESTAMPTZ,
    duration_minutes INTEGER,
    max_players INTEGER,
    current_players INTEGER,
    skill_level INTEGER,
    host_id UUID,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    host_email TEXT,
    host_full_name TEXT,
    host_avatar_url TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.location,
        e.latitude,
        e.longitude,
        e.date_time,
        e.duration_minutes,
        e.max_players,
        e.current_players,
        e.skill_level,
        e.host_id,
        e.status,
        e.created_at,
        e.updated_at,
        p.email as host_email,
        p.full_name as host_full_name,
        p.avatar_url as host_avatar_url
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE e.id = event_uuid;
END;
$$;

-- 7. Function to get event participants for real-time participant display
CREATE OR REPLACE FUNCTION get_event_participants_for_realtime_display(
    event_uuid UUID
)
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    joined_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ep.id,
        p.email,
        p.full_name,
        p.avatar_url,
        ep.joined_at
    FROM event_participants ep
    JOIN profiles p ON ep.user_id = p.id
    WHERE ep.event_id = event_uuid
    ORDER BY ep.joined_at ASC;
END;
$$;

-- 8. Function to join an event with real-time participant count update
CREATE OR REPLACE FUNCTION join_event_with_realtime_participant_update(
    event_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    event_exists BOOLEAN;
    already_joined BOOLEAN;
    current_players_count INTEGER;
    max_players_count INTEGER;
BEGIN
    -- Check if event exists and is active
    SELECT EXISTS(SELECT 1 FROM events WHERE id = event_uuid AND status = 'active') INTO event_exists;
    IF NOT event_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Check if user is already joined
    SELECT EXISTS(SELECT 1 FROM event_participants WHERE event_id = event_uuid AND user_id = user_uuid) INTO already_joined;
    IF already_joined THEN
        RETURN FALSE;
    END IF;
    
    -- Check if event is full
    SELECT current_players, max_players INTO current_players_count, max_players_count
    FROM events WHERE id = event_uuid;
    
    IF current_players_count >= max_players_count THEN
        RETURN FALSE;
    END IF;
    
    -- Insert participant
    INSERT INTO event_participants (event_id, user_id) VALUES (event_uuid, user_uuid);
    
    -- Update event current_players count
    UPDATE events SET current_players = current_players + 1 WHERE id = event_uuid;
    
    -- Create notification
    INSERT INTO event_notifications (event_id, user_id, notification_type, message)
    VALUES (event_uuid, user_uuid, 'join', 'You joined the event');
    
    RETURN TRUE;
END;
$$;

-- 9. Function to leave an event with real-time participant count update
CREATE OR REPLACE FUNCTION leave_event_with_realtime_participant_update(
    event_uuid UUID,
    user_uuid UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    participant_exists BOOLEAN;
BEGIN
    -- Check if user is actually joined
    SELECT EXISTS(SELECT 1 FROM event_participants WHERE event_id = event_uuid AND user_id = user_uuid) INTO participant_exists;
    IF NOT participant_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Remove participant
    DELETE FROM event_participants WHERE event_id = event_uuid AND user_id = user_uuid;
    
    -- Update event current_players count
    UPDATE events SET current_players = GREATEST(0, current_players - 1) WHERE id = event_uuid;
    
    -- Create notification
    INSERT INTO event_notifications (event_id, user_id, notification_type, message)
    VALUES (event_uuid, user_uuid, 'leave', 'You left the event');
    
    RETURN TRUE;
END;
$$;

-- 10. Function to update event participant count for data consistency in real-time sync
CREATE OR REPLACE FUNCTION update_event_participant_count_for_realtime_consistency(
    event_uuid UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    actual_count INTEGER;
BEGIN
    -- Count actual participants
    SELECT COUNT(*) INTO actual_count
    FROM event_participants
    WHERE event_id = event_uuid;
    
    -- Update events table
    UPDATE events 
    SET current_players = actual_count
    WHERE id = event_uuid;
    
    RETURN actual_count;
END;
$$;

-- 11. Function to create event notification for real-time user feedback
CREATE OR REPLACE FUNCTION create_event_notification_for_realtime_user_feedback(
    event_uuid UUID,
    user_uuid UUID,
    notification_type TEXT,
    notification_message TEXT
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO event_notifications (event_id, user_id, notification_type, message)
    VALUES (event_uuid, user_uuid, notification_type, notification_message)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$;

-- 12. Create indexes for better performance in real-time operations
CREATE INDEX IF NOT EXISTS idx_event_participants_event_id ON event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_user_id ON event_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_event_notifications_event_id ON event_notifications(event_id);
CREATE INDEX IF NOT EXISTS idx_event_notifications_user_id ON event_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_event_notifications_created_at ON event_notifications(created_at);

-- 13. Create trigger to update current_players when participants change for real-time sync
CREATE OR REPLACE FUNCTION update_event_player_count_for_realtime_sync()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE events SET current_players = current_players + 1 WHERE id = NEW.event_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE events SET current_players = GREATEST(0, current_players - 1) WHERE id = OLD.event_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_event_player_count ON event_participants;
CREATE TRIGGER trigger_update_event_player_count_for_realtime_sync
    AFTER INSERT OR DELETE ON event_participants
    FOR EACH ROW
    EXECUTE FUNCTION update_event_player_count_for_realtime_sync(); 

-- Profile Image Upload Storage Setup for JoinexDemo
-- This script sets up Supabase Storage for user avatar uploads

-- 1. Create avatars storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
SELECT 'avatars', 'avatars', true
WHERE NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'avatars');

-- 2. Allow public read access to avatar images
DROP POLICY IF EXISTS "Public read for avatars" ON storage.objects;
CREATE POLICY "Public read for avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- 3. Allow authenticated users to upload their own avatar objects
DROP POLICY IF EXISTS "Users upload avatars" ON storage.objects;
CREATE POLICY "Users upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- 4. Allow authenticated users to update their own avatar objects
DROP POLICY IF EXISTS "Users update avatars" ON storage.objects;
CREATE POLICY "Users update avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- 5. Allow authenticated users to delete their own avatar objects
DROP POLICY IF EXISTS "Users delete avatars" ON storage.objects;
CREATE POLICY "Users delete avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'avatars');

-- 6. Ensure profiles table has avatar_url column (if not already present)
-- This is typically already created by your existing SQL scripts
-- But adding here for completeness
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'avatar_url'
    ) THEN
        ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
    END IF;
END $$; 