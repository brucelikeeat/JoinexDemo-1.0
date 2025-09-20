-- Sport Management Functions for JoinexDemo
-- These functions ensure proper sport type synchronization between Create Event and Explore views

-- 1. Create sports table to maintain consistent sport types
CREATE TABLE IF NOT EXISTS sports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_name TEXT NOT NULL UNIQUE,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Insert comprehensive sports list
INSERT INTO sports (sport_name, category) VALUES
('All Sports', 'General'),
('General (Casual/Any)', 'General'),
('Badminton', 'Racket Sports'),
('Basketball', 'Team Sports'),
('Soccer (Football)', 'Team Sports'),
('Volleyball', 'Team Sports'),
('Table Tennis', 'Racket Sports'),
('Tennis', 'Racket Sports'),
('Pickleball', 'Racket Sports'),
('Baseball', 'Team Sports'),
('Softball', 'Team Sports'),
('Running', 'Individual Sports'),
('Cycling', 'Individual Sports'),
('Swimming', 'Individual Sports'),
('Climbing (Indoor/Outdoor)', 'Adventure Sports'),
('Skating (Ice/Roller)', 'Individual Sports'),
('Skiing/Snowboarding', 'Winter Sports'),
('Golf', 'Individual Sports'),
('Ultimate Frisbee', 'Team Sports'),
('Flag Football', 'Team Sports'),
('Martial Arts (e.g., Judo, Taekwondo)', 'Combat Sports'),
('Boxing', 'Combat Sports'),
('Wrestling', 'Combat Sports'),
('Dance Fitness (Zumba, Hip-Hop, etc.)', 'Fitness'),
('Yoga/Pilates', 'Fitness'),
('CrossFit/HIIT/Bootcamp', 'Fitness'),
('Esports/Gaming Tournaments', 'Gaming'),
('Dodgeball', 'Team Sports'),
('Cricket', 'Team Sports'),
('Rugby', 'Team Sports'),
('Lacrosse', 'Team Sports'),
('Hockey (Field/Ice)', 'Team Sports'),
('Surfing', 'Water Sports'),
('Archery', 'Individual Sports'),
('Rowing', 'Water Sports'),
('Bouldering', 'Adventure Sports'),
('Kendo/Fencing', 'Combat Sports'),
('Cheerleading', 'Team Sports'),
('Horseback Riding', 'Individual Sports')
ON CONFLICT (sport_name) DO NOTHING;

-- 3. Function to get all available sports
CREATE OR REPLACE FUNCTION get_available_sports()
RETURNS TABLE (
    sport_name TEXT,
    category TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.sport_name, s.category
    FROM sports s
    WHERE s.is_active = true
    ORDER BY 
        CASE WHEN s.sport_name = 'All Sports' THEN 0 ELSE 1 END,
        s.sport_name;
END;
$$;

-- 4. Function to search sports
CREATE OR REPLACE FUNCTION search_sports(search_query TEXT DEFAULT '')
RETURNS TABLE (
    sport_name TEXT,
    category TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF search_query = '' OR search_query IS NULL THEN
        RETURN QUERY
        SELECT s.sport_name, s.category
        FROM sports s
        WHERE s.is_active = true
        ORDER BY 
            CASE WHEN s.sport_name = 'All Sports' THEN 0 ELSE 1 END,
            s.sport_name;
    ELSE
        RETURN QUERY
        SELECT s.sport_name, s.category
        FROM sports s
        WHERE s.is_active = true
          AND s.sport_name ILIKE '%' || search_query || '%'
        ORDER BY 
            CASE 
                WHEN s.sport_name ILIKE search_query || '%' THEN 1
                WHEN s.sport_name ILIKE '%' || search_query || '%' THEN 2
                ELSE 3
            END,
            s.sport_name;
    END IF;
END;
$$;

-- 5. Function to validate sport type
CREATE OR REPLACE FUNCTION validate_sport_type(sport_type_to_validate TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    sport_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM sports 
        WHERE sport_name = sport_type_to_validate 
          AND is_active = true
    ) INTO sport_exists;
    
    RETURN sport_exists;
END;
$$;

-- 6. Function to get events by sport with validation
CREATE OR REPLACE FUNCTION get_events_by_sport_validated(
    sport_type_filter TEXT DEFAULT 'All Sports',
    limit_count INTEGER DEFAULT 50
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
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate sport type if not "All Sports"
    IF sport_type_filter != 'All Sports' THEN
        IF NOT validate_sport_type(sport_type_filter) THEN
            RAISE EXCEPTION 'Invalid sport type: %', sport_type_filter;
        END IF;
    END IF;
    
    IF sport_type_filter = 'All Sports' THEN
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
            e.updated_at
        FROM events e
        WHERE e.status = 'active'
        ORDER BY e.date_time ASC
        LIMIT limit_count;
    ELSE
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
            e.updated_at
        FROM events e
        WHERE e.status = 'active' AND e.sport_type = sport_type_filter
        ORDER BY e.date_time ASC
        LIMIT limit_count;
    END IF;
END;
$$;

-- 7. Function to create event with sport validation
CREATE OR REPLACE FUNCTION create_event_with_validation(
    event_title TEXT,
    event_description TEXT,
    event_sport_type TEXT,
    event_location TEXT,
    event_latitude DOUBLE PRECISION,
    event_longitude DOUBLE PRECISION,
    event_date_time TIMESTAMPTZ,
    event_duration_minutes INTEGER,
    event_max_players INTEGER,
    event_skill_level INTEGER,
    event_host_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    new_event_id UUID;
BEGIN
    -- Validate sport type
    IF NOT validate_sport_type(event_sport_type) THEN
        RAISE EXCEPTION 'Invalid sport type: %. Please select a valid sport from the list.', event_sport_type;
    END IF;
    
    -- Create the event
    INSERT INTO events (
        title,
        description,
        sport_type,
        location,
        latitude,
        longitude,
        date_time,
        duration_minutes,
        max_players,
        current_players,
        skill_level,
        host_id,
        status
    ) VALUES (
        event_title,
        event_description,
        event_sport_type,
        event_location,
        event_latitude,
        event_longitude,
        event_date_time,
        event_duration_minutes,
        event_max_players,
        1, -- Start with host as current player
        event_skill_level,
        event_host_id,
        'active'
    ) RETURNING id INTO new_event_id;
    
    RETURN new_event_id;
END;
$$;

-- 8. Enable Row Level Security on sports table
ALTER TABLE sports ENABLE ROW LEVEL SECURITY;

-- 9. Create RLS policies for sports table
CREATE POLICY "Allow public read access to sports" ON sports
    FOR SELECT USING (true);

-- 10. Create index for better performance
CREATE INDEX IF NOT EXISTS idx_sports_name ON sports(sport_name);
CREATE INDEX IF NOT EXISTS idx_sports_active ON sports(is_active);

-- 11. Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_sports_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_sports_updated_at
    BEFORE UPDATE ON sports
    FOR EACH ROW
    EXECUTE FUNCTION update_sports_updated_at(); 