-- Location Search and Advanced Filtering Functions for JoinexDemo
-- These functions provide backend support for location search and advanced filtering

-- 1. Search Locations Function
-- This function searches for locations based on user input
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

-- 2. Advanced Event Search Function
-- This function provides comprehensive event filtering with multiple criteria
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
    
    -- Apply sport type filter
    IF sport_type_filter != 'All Sports' THEN
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

-- 3. Get Events by Sport Function
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

-- 4. Get Events by Date Range Function
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

-- 5. Create locations table if it doesn't exist
CREATE TABLE IF NOT EXISTS locations (
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

-- 6. Create popular_locations table for fallback
CREATE TABLE IF NOT EXISTS popular_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_name TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Insert sample popular locations
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
('Maple Ridge, British Columbia', 49.2194, -122.6019)
ON CONFLICT DO NOTHING;

-- 8. Insert sample locations into locations table
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
('Maple Ridge Centre', 'Maple Ridge', 'British Columbia', 49.2194, -122.6019)
ON CONFLICT DO NOTHING;

-- 9. Enable Row Level Security on new tables
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE popular_locations ENABLE ROW LEVEL SECURITY;

-- 10. Create RLS policies for locations tables
CREATE POLICY "Allow public read access to locations" ON locations
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to popular_locations" ON popular_locations
    FOR SELECT USING (true); 