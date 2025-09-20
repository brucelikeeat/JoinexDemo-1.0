-- =====================================================
-- SUPABASE BACKEND FUNCTIONS FOR JOINEX APP
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- 1. ADVANCED SEARCH FUNCTION
-- =====================================================

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
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        -- Text search (title, description, location)
        (
            search_text = '' OR 
            e.title ILIKE '%' || search_text || '%' OR
            e.description ILIKE '%' || search_text || '%' OR
            e.location ILIKE '%' || search_text || '%'
        )
        -- Sport type filter
        AND (sport_type_filter = 'All Sports' OR e.sport_type = sport_type_filter)
        -- Date filter
        AND (
            date_filter = '' OR 
            DATE(e.event_date) = date_filter::DATE
        )
        -- Location filter
        AND (
            location_filter = '' OR 
            e.location ILIKE '%' || location_filter || '%'
        )
        -- Distance filter (if coordinates provided)
        AND (
            user_lat IS NULL OR user_lon IS NULL OR
            (
                6371 * acos(
                    cos(radians(user_lat)) * cos(radians(e.latitude)) *
                    cos(radians(e.longitude) - radians(user_lon)) +
                    sin(radians(user_lat)) * sin(radians(e.latitude))
                ) <= radius_km
            )
        )
        -- Only show active events
        AND e.event_status = 'active'
    ORDER BY 
        CASE 
            WHEN search_text != '' THEN 
                CASE 
                    WHEN e.title ILIKE search_text THEN 1
                    WHEN e.title ILIKE '%' || search_text || '%' THEN 2
                    WHEN e.description ILIKE '%' || search_text || '%' THEN 3
                    ELSE 4
                END
            ELSE 1
        END,
        e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. SPORT-SPECIFIC SEARCH FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_events_by_sport(
    sport_type_filter TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    sport_type TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        e.sport_type = sport_type_filter
        AND e.event_status = 'active'
        AND e.event_date >= NOW()
    ORDER BY e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. DATE RANGE SEARCH FUNCTION
-- =====================================================

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
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        DATE(e.event_date) BETWEEN start_date::DATE AND end_date::DATE
        AND e.event_status = 'active'
    ORDER BY e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. LOCATION SEARCH FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION search_locations(
    search_query TEXT,
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    place_type TEXT,
    relevance_score INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.name,
        l.address,
        l.city,
        l.state,
        l.country,
        l.latitude,
        l.longitude,
        l.place_type,
        CASE 
            WHEN l.name ILIKE search_query THEN 10
            WHEN l.name ILIKE '%' || search_query || '%' THEN 8
            WHEN l.city ILIKE search_query THEN 6
            WHEN l.city ILIKE '%' || search_query || '%' THEN 4
            WHEN l.address ILIKE '%' || search_query || '%' THEN 2
            ELSE 1
        END as relevance_score
    FROM locations l
    WHERE 
        l.name ILIKE '%' || search_query || '%' OR
        l.city ILIKE '%' || search_query || '%' OR
        l.address ILIKE '%' || search_query || '%'
    ORDER BY relevance_score DESC, l.name ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. NEARBY EVENTS FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_nearby_events(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_km INTEGER DEFAULT 40,
    limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    sport_type TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_km DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        (
            6371 * acos(
                cos(radians(user_lat)) * cos(radians(e.latitude)) *
                cos(radians(e.longitude) - radians(user_lon)) +
                sin(radians(user_lat)) * sin(radians(e.latitude))
            )
        ) as distance_km,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        e.event_status = 'active'
        AND e.event_date >= NOW()
        AND (
            6371 * acos(
                cos(radians(user_lat)) * cos(radians(e.latitude)) *
                cos(radians(e.longitude) - radians(user_lon)) +
                sin(radians(user_lat)) * sin(radians(e.latitude))
            )
        ) <= radius_km
    ORDER BY distance_km ASC, e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. POPULAR LOCATIONS FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_popular_locations(
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    place_type TEXT,
    event_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.name,
        l.address,
        l.city,
        l.state,
        l.country,
        l.latitude,
        l.longitude,
        l.place_type,
        COUNT(e.id) as event_count
    FROM locations l
    LEFT JOIN events e ON 
        e.latitude = l.latitude AND 
        e.longitude = l.longitude AND
        e.event_status = 'active' AND
        e.event_date >= NOW()
    GROUP BY l.id, l.name, l.address, l.city, l.state, l.country, l.latitude, l.longitude, l.place_type
    ORDER BY event_count DESC, l.name ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. EVENT STATISTICS FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_event_statistics(
    user_id UUID DEFAULT NULL
)
RETURNS TABLE (
    total_events BIGINT,
    upcoming_events BIGINT,
    past_events BIGINT,
    hosted_events BIGINT,
    joined_events BIGINT,
    favorite_sport TEXT,
    total_participants BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM events WHERE event_status = 'active') as total_events,
        (SELECT COUNT(*) FROM events WHERE event_status = 'active' AND event_date >= NOW()) as upcoming_events,
        (SELECT COUNT(*) FROM events WHERE event_status = 'active' AND event_date < NOW()) as past_events,
        (SELECT COUNT(*) FROM events WHERE host_id = user_id AND event_status = 'active') as hosted_events,
        (SELECT COUNT(*) FROM event_participants WHERE user_id = user_id AND status = 'confirmed') as joined_events,
        (
            SELECT sport_type 
            FROM events 
            WHERE event_status = 'active' 
            GROUP BY sport_type 
            ORDER BY COUNT(*) DESC 
            LIMIT 1
        ) as favorite_sport,
        (SELECT COALESCE(SUM(current_participants), 0) FROM events WHERE event_status = 'active') as total_participants;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. USER RECOMMENDATIONS FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_recommendations(
    user_id UUID,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    sport_type TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    recommendation_score DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        (
            -- Sport preference score
            CASE 
                WHEN e.sport_type IN (
                    SELECT DISTINCT e2.sport_type 
                    FROM events e2 
                    JOIN event_participants ep ON e2.id = ep.event_id 
                    WHERE ep.user_id = user_id AND ep.status = 'confirmed'
                ) THEN 3.0
                ELSE 1.0
            END *
            -- Time preference score
            CASE 
                WHEN EXTRACT(HOUR FROM e.start_time) BETWEEN 9 AND 18 THEN 1.5
                ELSE 1.0
            END *
            -- Availability score
            CASE 
                WHEN e.current_participants < e.max_participants THEN 2.0
                ELSE 0.5
            END
        ) as recommendation_score,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        e.event_status = 'active'
        AND e.event_date >= NOW()
        AND e.host_id != user_id
        AND e.id NOT IN (
            SELECT event_id 
            FROM event_participants 
            WHERE user_id = user_id
        )
    ORDER BY recommendation_score DESC, e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. REAL-TIME SEARCH FUNCTION
-- =====================================================

CREATE OR REPLACE FUNCTION real_time_search(
    search_text TEXT,
    user_lat DOUBLE PRECISION DEFAULT NULL,
    user_lon DOUBLE PRECISION DEFAULT NULL,
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    sport_type TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    start_time TIME,
    end_time TIME,
    location TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_km DOUBLE PRECISION,
    max_participants INTEGER,
    current_participants INTEGER,
    host_id UUID,
    host_name TEXT,
    host_avatar TEXT,
    event_status TEXT,
    search_rank INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.title,
        e.description,
        e.sport_type,
        e.event_date,
        e.start_time,
        e.end_time,
        e.location,
        e.latitude,
        e.longitude,
        CASE 
            WHEN user_lat IS NOT NULL AND user_lon IS NOT NULL THEN
                (
                    6371 * acos(
                        cos(radians(user_lat)) * cos(radians(e.latitude)) *
                        cos(radians(e.longitude) - radians(user_lon)) +
                        sin(radians(user_lat)) * sin(radians(e.latitude))
                    )
                )
            ELSE NULL
        END as distance_km,
        e.max_participants,
        e.current_participants,
        e.host_id,
        p.full_name as host_name,
        p.avatar_url as host_avatar,
        e.event_status,
        CASE 
            WHEN e.title ILIKE search_text THEN 1
            WHEN e.title ILIKE '%' || search_text || '%' THEN 2
            WHEN e.description ILIKE '%' || search_text || '%' THEN 3
            WHEN e.location ILIKE '%' || search_text || '%' THEN 4
            WHEN e.sport_type ILIKE '%' || search_text || '%' THEN 5
            ELSE 6
        END as search_rank,
        e.created_at,
        e.updated_at
    FROM events e
    LEFT JOIN profiles p ON e.host_id = p.id
    WHERE 
        e.event_status = 'active'
        AND e.event_date >= NOW()
        AND (
            e.title ILIKE '%' || search_text || '%' OR
            e.description ILIKE '%' || search_text || '%' OR
            e.location ILIKE '%' || search_text || '%' OR
            e.sport_type ILIKE '%' || search_text || '%'
        )
    ORDER BY search_rank ASC, e.event_date ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Events table indexes
CREATE INDEX IF NOT EXISTS idx_events_sport_type ON events(sport_type);
CREATE INDEX IF NOT EXISTS idx_events_event_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(event_status);
CREATE INDEX IF NOT EXISTS idx_events_location ON events USING gin(to_tsvector('english', location));
CREATE INDEX IF NOT EXISTS idx_events_title ON events USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS idx_events_description ON events USING gin(to_tsvector('english', description));
CREATE INDEX IF NOT EXISTS idx_events_coordinates ON events(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_events_host_id ON events(host_id);

-- Event participants table indexes
CREATE INDEX IF NOT EXISTS idx_event_participants_user_id ON event_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_event_id ON event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_status ON event_participants(status);

-- Locations table indexes
CREATE INDEX IF NOT EXISTS idx_locations_name ON locations USING gin(to_tsvector('english', name));
CREATE INDEX IF NOT EXISTS idx_locations_city ON locations(city);
CREATE INDEX IF NOT EXISTS idx_locations_coordinates ON locations(latitude, longitude);

-- Profiles table indexes
CREATE INDEX IF NOT EXISTS idx_profiles_full_name ON profiles(full_name);

-- =====================================================
-- 11. GRANT PERMISSIONS
-- =====================================================

-- Grant execute permissions on all functions
GRANT EXECUTE ON FUNCTION search_events_advanced TO authenticated;
GRANT EXECUTE ON FUNCTION get_events_by_sport TO authenticated;
GRANT EXECUTE ON FUNCTION get_events_by_date_range TO authenticated;
GRANT EXECUTE ON FUNCTION search_locations TO authenticated;
GRANT EXECUTE ON FUNCTION get_nearby_events TO authenticated;
GRANT EXECUTE ON FUNCTION get_popular_locations TO authenticated;
GRANT EXECUTE ON FUNCTION get_event_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_recommendations TO authenticated;
GRANT EXECUTE ON FUNCTION real_time_search TO authenticated;

-- =====================================================
-- 12. SAMPLE DATA INSERTION (OPTIONAL)
-- =====================================================

-- Insert sample locations
INSERT INTO locations (id, name, address, city, state, country, latitude, longitude, place_type) VALUES
(uuid_generate_v4(), 'Central Park', 'Central Park, New York, NY', 'New York', 'NY', 'USA', 40.7829, -73.9654, 'park'),
(uuid_generate_v4(), 'Golden Gate Park', 'Golden Gate Park, San Francisco, CA', 'San Francisco', 'CA', 'USA', 37.7694, -122.4862, 'park'),
(uuid_generate_v4(), 'Griffith Park', 'Griffith Park, Los Angeles, CA', 'Los Angeles', 'CA', 'USA', 34.1361, -118.2949, 'park'),
(uuid_generate_v4(), 'Lincoln Park', 'Lincoln Park, Chicago, IL', 'Chicago', 'IL', 'USA', 41.9217, -87.6334, 'park'),
(uuid_generate_v4(), 'Prospect Park', 'Prospect Park, Brooklyn, NY', 'Brooklyn', 'NY', 'USA', 40.6602, -73.9690, 'park')
ON CONFLICT DO NOTHING;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

/*
-- Example 1: Advanced search with all filters
SELECT * FROM search_events_advanced(
    search_text := 'basketball',
    sport_type_filter := 'Basketball',
    date_filter := '2024-01-15',
    location_filter := 'Central Park',
    radius_km := 20,
    user_lat := 40.7829,
    user_lon := -73.9654,
    limit_count := 10
);

-- Example 2: Sport-specific search
SELECT * FROM get_events_by_sport('Soccer', 20);

-- Example 3: Date range search
SELECT * FROM get_events_by_date_range('2024-01-01', '2024-01-31', 15);

-- Example 4: Location search
SELECT * FROM search_locations('Central Park', 10);

-- Example 5: Nearby events
SELECT * FROM get_nearby_events(40.7829, -73.9654, 25, 20);

-- Example 6: Real-time search
SELECT * FROM real_time_search('basketball', 40.7829, -73.9654, 15);

-- Example 7: User recommendations
SELECT * FROM get_user_recommendations('user-uuid-here', 10);

-- Example 8: Event statistics
SELECT * FROM get_event_statistics('user-uuid-here');
*/ 