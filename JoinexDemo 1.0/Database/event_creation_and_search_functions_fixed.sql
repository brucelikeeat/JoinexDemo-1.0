-- Event Creation and Search Functions for JoinexDemo (FIXED VERSION)
-- This file provides backend support for event creation with validation and advanced search/filtering

-- ============================================================================
-- 1. TABLE CREATION (One-time setup)
-- ============================================================================

-- Drop existing tables if they exist and recreate them properly
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS popular_locations CASCADE;
DROP TABLE IF EXISTS sports CASCADE;

-- Create locations table
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_name TEXT NOT NULL,
    city TEXT,
    province TEXT,
    country TEXT DEFAULT 'Canada',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create popular_locations table
CREATE TABLE popular_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_name TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create sports table
CREATE TABLE sports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_name TEXT NOT NULL UNIQUE,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 2. SAMPLE DATA INSERTION
-- ============================================================================

-- Insert popular locations
INSERT INTO popular_locations (location_name, latitude, longitude) VALUES
('Surrey, British Columbia', 49.1913, -122.8490),
('Vancouver, British Columbia', 49.2827, -123.1207),
('Burnaby, British Columbia', 49.2488, -122.9805),
('Richmond, British Columbia', 49.1666, -123.1336),
('Coquitlam, British Columbia', 49.2838, -122.7932),
('Delta, British Columbia', 49.0847, -123.0582),
('Langley, British Columbia', 49.1044, -122.5826),
('New Westminster, British Columbia', 49.2068, -122.9112),
('Port Coquitlam, British Columbia', 49.2621, -122.7816),
('Maple Ridge, British Columbia', 49.2194, -122.6019);

-- Insert sample locations
INSERT INTO locations (location_name, city, province, latitude, longitude) VALUES
('Surrey Central', 'Surrey', 'British Columbia', 49.1913, -122.8490),
('Vancouver Downtown', 'Vancouver', 'British Columbia', 49.2827, -123.1207),
('Burnaby Metrotown', 'Burnaby', 'British Columbia', 49.2488, -122.9805),
('Richmond Centre', 'Richmond', 'British Columbia', 49.1666, -123.1336),
('Coquitlam Centre', 'Coquitlam', 'British Columbia', 49.2838, -122.7932),
('Delta Town Centre', 'Delta', 'British Columbia', 49.0847, -123.0582),
('Langley City Centre', 'Langley', 'British Columbia', 49.1044, -122.5826),
('New Westminster Station', 'New Westminster', 'British Columbia', 49.2068, -122.9112),
('Port Coquitlam Station', 'Port Coquitlam', 'British Columbia', 49.2621, -122.7816),
('Maple Ridge Centre', 'Maple Ridge', 'British Columbia', 49.2194, -122.6019);

-- Insert comprehensive sports list
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

-- ============================================================================
-- 3. SECURITY SETUP
-- ============================================================================

-- Enable Row Level Security
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE popular_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sports ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
DROP POLICY IF EXISTS "Allow public read access to locations" ON locations;
CREATE POLICY "Allow public read access to locations" ON locations
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access to popular_locations" ON popular_locations;
CREATE POLICY "Allow public read access to popular_locations" ON popular_locations
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public read access to sports" ON sports;
CREATE POLICY "Allow public read access to sports" ON sports
    FOR SELECT USING (true);

-- ============================================================================
-- 4. LOCATION SEARCH FUNCTIONS
-- ============================================================================

-- Search locations function
CREATE OR REPLACE FUNCTION search_locations(
    search_query TEXT DEFAULT '',
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    display_name TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    distance DOUBLE PRECISION
) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- If search query is empty, return popular locations
    IF search_query = '' OR search_query IS NULL THEN
        RETURN QUERY
        SELECT 
            gen_random_uuid() as id,
            location_name as display_name,
            latitude as lat,
            longitude as lon,
            NULL as distance
        FROM popular_locations
        LIMIT limit_count;
    ELSE
        -- Search in locations table with fuzzy matching
        RETURN QUERY
        SELECT 
            gen_random_uuid() as id,
            location_name as display_name,
            latitude as lat,
            longitude as lon,
            NULL as distance
        FROM locations 
        WHERE 
            location_name ILIKE '%' || search_query || '%'
            OR city ILIKE '%' || search_query || '%'
            OR province ILIKE '%' || search_query || '%'
        ORDER BY 
            CASE 
                WHEN location_name ILIKE search_query || '%' THEN 1
                WHEN location_name ILIKE '%' || search_query || '%' THEN 2
                ELSE 3
            END,
            location_name
        LIMIT limit_count;
    END IF;
END;
$$;

-- ============================================================================
-- 5. SPORT MANAGEMENT FUNCTIONS
-- ============================================================================

-- Get all available sports
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

-- Search sports function
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

-- Validate sport type
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

-- ============================================================================
-- 6. EVENT CREATION WITH VALIDATION (FIXED VERSION)
-- ============================================================================

-- Create event with sport validation (FIXED parameter order)
CREATE OR REPLACE FUNCTION create_event_with_validation(
    event_title TEXT,
    event_description TEXT,
    event_sport_type TEXT,
    event_location TEXT,
    event_date_time TIMESTAMPTZ,
    event_duration_minutes INTEGER,
    event_max_players INTEGER,
    event_skill_level INTEGER,
    event_host_id UUID,
    event_latitude DOUBLE PRECISION DEFAULT NULL,
    event_longitude DOUBLE PRECISION DEFAULT NULL
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
        event_latitude,  -- Can be NULL
        event_longitude, -- Can be NULL
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

-- ============================================================================
-- 7. EVENT SEARCH AND FILTERING FUNCTIONS
-- ============================================================================

-- Advanced event search with all filters
CREATE OR REPLACE FUNCTION search_events_advanced(
    search_text TEXT DEFAULT '',
    sport_type_filter TEXT DEFAULT 'All Sports',
    date_filter TEXT DEFAULT '',
    location_filter TEXT DEFAULT '',
    radius_km INTEGER DEFAULT 40,
    user_lat DOUBLE PRECISION DEFAULT NULL,
    user_lon DOUBLE PRECISION DEFAULT NULL,
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
DECLARE
    start_date TIMESTAMPTZ;
    end_date TIMESTAMPTZ;
    lat_delta DOUBLE PRECISION;
    lon_delta DOUBLE PRECISION;
BEGIN
    -- Build the base query
    CREATE TEMP TABLE temp_events AS
    SELECT * FROM events WHERE status = 'active';
    
    -- Apply text search filter
    IF search_text != '' THEN
        DELETE FROM temp_events 
        WHERE NOT (
            title ILIKE '%' || search_text || '%'
            OR description ILIKE '%' || search_text || '%'
            OR location ILIKE '%' || search_text || '%'
            OR sport_type ILIKE '%' || search_text || '%'
        );
    END IF;
    
    -- Apply sport type filter with validation
    IF sport_type_filter != 'All Sports' THEN
        -- Validate sport type
        IF NOT validate_sport_type(sport_type_filter) THEN
            RAISE EXCEPTION 'Invalid sport type: %', sport_type_filter;
        END IF;
        
        DELETE FROM temp_events 
        WHERE sport_type != sport_type_filter;
    END IF;
    
    -- Apply date filter
    IF date_filter != '' THEN
        start_date := date_filter::DATE;
        end_date := start_date + INTERVAL '1 day';
        
        DELETE FROM temp_events 
        WHERE date_time < start_date OR date_time >= end_date;
    END IF;
    
    -- Apply location filter
    IF location_filter != '' THEN
        DELETE FROM temp_events 
        WHERE NOT (
            location ILIKE '%' || location_filter || '%'
            OR title ILIKE '%' || location_filter || '%'
        );
    END IF;
    
    -- Apply distance filter (if coordinates provided)
    IF user_lat IS NOT NULL AND user_lon IS NOT NULL THEN
        lat_delta := radius_km::DOUBLE PRECISION / 111.0;
        lon_delta := radius_km::DOUBLE PRECISION / (111.0 * COS(RADIANS(user_lat)));
        
        DELETE FROM temp_events 
        WHERE latitude IS NULL 
           OR longitude IS NULL
           OR latitude < (user_lat - lat_delta)
           OR latitude > (user_lat + lat_delta)
           OR longitude < (user_lon - lon_delta)
           OR longitude > (user_lon + lon_delta);
    END IF;
    
    -- Return filtered results
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
    FROM temp_events e
    ORDER BY e.date_time ASC
    LIMIT limit_count;
    
    -- Clean up
    DROP TABLE temp_events;
END;
$$;

-- Get events by sport (with validation)
CREATE OR REPLACE FUNCTION get_events_by_sport(
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

-- Get events by date range
CREATE OR REPLACE FUNCTION get_events_by_date_range(
    start_date TEXT,
    end_date TEXT,
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
      AND e.date_time >= start_date::DATE
      AND e.date_time < (end_date::DATE + INTERVAL '1 day')
    ORDER BY e.date_time ASC
    LIMIT limit_count;
END;
$$;

-- ============================================================================
-- 8. PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(location_name);
CREATE INDEX IF NOT EXISTS idx_popular_locations_name ON popular_locations(location_name);
CREATE INDEX IF NOT EXISTS idx_sports_name ON sports(sport_name);
CREATE INDEX IF NOT EXISTS idx_sports_active ON sports(is_active);
CREATE INDEX IF NOT EXISTS idx_events_sport_type ON events(sport_type);
CREATE INDEX IF NOT EXISTS idx_events_date_time ON events(date_time);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- Create trigger to update updated_at timestamp for sports
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