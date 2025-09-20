-- =====================================================
-- SETUP MISSING COMPONENTS ONLY
-- =====================================================

-- 1. Enable extensions (safe to run multiple times)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 2. Create tables only if they don't exist
DO $$ 
BEGIN
    -- Create profiles table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'profiles') THEN
        CREATE TABLE profiles (
            id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
            full_name TEXT,
            avatar_url TEXT,
            bio TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created profiles table';
    ELSE
        RAISE NOTICE 'profiles table already exists';
    END IF;

    -- Create events table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'events') THEN
        CREATE TABLE events (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            sport_type TEXT NOT NULL,
            event_date TIMESTAMP WITH TIME ZONE NOT NULL,
            start_time TIME NOT NULL,
            end_time TIME NOT NULL,
            location TEXT NOT NULL,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            max_participants INTEGER DEFAULT 10,
            current_participants INTEGER DEFAULT 0,
            host_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            event_status TEXT DEFAULT 'active' CHECK (event_status IN ('active', 'cancelled', 'completed')),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created events table';
    ELSE
        RAISE NOTICE 'events table already exists';
    END IF;

    -- Create event_participants table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'event_participants') THEN
        CREATE TABLE event_participants (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            event_id UUID REFERENCES events(id) ON DELETE CASCADE,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'declined')),
            joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(event_id, user_id)
        );
        RAISE NOTICE 'Created event_participants table';
    ELSE
        RAISE NOTICE 'event_participants table already exists';
    END IF;

    -- Create locations table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'locations') THEN
        CREATE TABLE locations (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT,
            city TEXT,
            state TEXT,
            country TEXT,
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            place_type TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created locations table';
    ELSE
        RAISE NOTICE 'locations table already exists';
    END IF;

    -- Create chat_rooms table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'chat_rooms') THEN
        CREATE TABLE chat_rooms (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            event_id UUID REFERENCES events(id) ON DELETE CASCADE,
            name TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created chat_rooms table';
    ELSE
        RAISE NOTICE 'chat_rooms table already exists';
    END IF;

    -- Create chat_messages table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'chat_messages') THEN
        CREATE TABLE chat_messages (
            id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
            room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
            user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
            message TEXT NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created chat_messages table';
    ELSE
        RAISE NOTICE 'chat_messages table already exists';
    END IF;
END $$;

-- 3. Enable RLS on tables (safe to run multiple times)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- 4. Create policies only if they don't exist
DO $$ 
BEGIN
    -- Profiles policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can view all profiles') THEN
        CREATE POLICY "Users can view all profiles" ON profiles FOR SELECT USING (true);
        RAISE NOTICE 'Created profiles view policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can update own profile') THEN
        CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
        RAISE NOTICE 'Created profiles update policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can insert own profile') THEN
        CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
        RAISE NOTICE 'Created profiles insert policy';
    END IF;

    -- Events policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'events' AND policyname = 'Anyone can view active events') THEN
        CREATE POLICY "Anyone can view active events" ON events FOR SELECT USING (event_status = 'active');
        RAISE NOTICE 'Created events view policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'events' AND policyname = 'Users can create events') THEN
        CREATE POLICY "Users can create events" ON events FOR INSERT WITH CHECK (auth.uid() = host_id);
        RAISE NOTICE 'Created events insert policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'events' AND policyname = 'Hosts can update their events') THEN
        CREATE POLICY "Hosts can update their events" ON events FOR UPDATE USING (auth.uid() = host_id);
        RAISE NOTICE 'Created events update policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'events' AND policyname = 'Hosts can delete their events') THEN
        CREATE POLICY "Hosts can delete their events" ON events FOR DELETE USING (auth.uid() = host_id);
        RAISE NOTICE 'Created events delete policy';
    END IF;

    -- Event participants policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'event_participants' AND policyname = 'Users can view event participants') THEN
        CREATE POLICY "Users can view event participants" ON event_participants FOR SELECT USING (true);
        RAISE NOTICE 'Created event_participants view policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'event_participants' AND policyname = 'Users can join events') THEN
        CREATE POLICY "Users can join events" ON event_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
        RAISE NOTICE 'Created event_participants insert policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'event_participants' AND policyname = 'Users can update their participation') THEN
        CREATE POLICY "Users can update their participation" ON event_participants FOR UPDATE USING (auth.uid() = user_id);
        RAISE NOTICE 'Created event_participants update policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'event_participants' AND policyname = 'Users can leave events') THEN
        CREATE POLICY "Users can leave events" ON event_participants FOR DELETE USING (auth.uid() = user_id);
        RAISE NOTICE 'Created event_participants delete policy';
    END IF;

    -- Locations policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'locations' AND policyname = 'Anyone can view locations') THEN
        CREATE POLICY "Anyone can view locations" ON locations FOR SELECT USING (true);
        RAISE NOTICE 'Created locations view policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'locations' AND policyname = 'Authenticated users can insert locations') THEN
        CREATE POLICY "Authenticated users can insert locations" ON locations FOR INSERT WITH CHECK (auth.role() = 'authenticated');
        RAISE NOTICE 'Created locations insert policy';
    END IF;

    -- Chat rooms policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'chat_rooms' AND policyname = 'Event participants can view chat rooms') THEN
        CREATE POLICY "Event participants can view chat rooms" ON chat_rooms FOR SELECT USING (
            EXISTS (
                SELECT 1 FROM event_participants ep 
                WHERE ep.event_id = chat_rooms.event_id 
                AND ep.user_id = auth.uid()
            )
        );
        RAISE NOTICE 'Created chat_rooms view policy';
    END IF;

    -- Chat messages policies
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'chat_messages' AND policyname = 'Event participants can view messages') THEN
        CREATE POLICY "Event participants can view messages" ON chat_messages FOR SELECT USING (
            EXISTS (
                SELECT 1 FROM event_participants ep 
                JOIN chat_rooms cr ON ep.event_id = cr.event_id 
                WHERE cr.id = chat_messages.room_id 
                AND ep.user_id = auth.uid()
            )
        );
        RAISE NOTICE 'Created chat_messages view policy';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_policies WHERE tablename = 'chat_messages' AND policyname = 'Event participants can send messages') THEN
        CREATE POLICY "Event participants can send messages" ON chat_messages FOR INSERT WITH CHECK (
            auth.uid() = user_id AND
            EXISTS (
                SELECT 1 FROM event_participants ep 
                JOIN chat_rooms cr ON ep.event_id = cr.event_id 
                WHERE cr.id = chat_messages.room_id 
                AND ep.user_id = auth.uid()
            )
        );
        RAISE NOTICE 'Created chat_messages insert policy';
    END IF;
END $$;

-- 5. Create triggers only if they don't exist
DO $$
BEGIN
    -- Create update_updated_at_column function if it doesn't exist
    IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        RAISE NOTICE 'Created update_updated_at_column function';
    END IF;

    -- Create triggers if they don't exist
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_profiles_updated_at') THEN
        CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE 'Created profiles updated_at trigger';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_events_updated_at') THEN
        CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE 'Created events updated_at trigger';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_locations_updated_at') THEN
        CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE 'Created locations updated_at trigger';
    END IF;
END $$;

-- 6. Insert sample data only if locations table is empty
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM locations) = 0 THEN
        INSERT INTO locations (id, name, address, city, state, country, latitude, longitude, place_type) VALUES
        (uuid_generate_v4(), 'Central Park', 'Central Park, New York, NY', 'New York', 'NY', 'USA', 40.7829, -73.9654, 'park'),
        (uuid_generate_v4(), 'Golden Gate Park', 'Golden Gate Park, San Francisco, CA', 'San Francisco', 'CA', 'USA', 37.7694, -122.4862, 'park'),
        (uuid_generate_v4(), 'Griffith Park', 'Griffith Park, Los Angeles, CA', 'Los Angeles', 'CA', 'USA', 34.1361, -118.2949, 'park'),
        (uuid_generate_v4(), 'Lincoln Park', 'Lincoln Park, Chicago, IL', 'Chicago', 'IL', 'USA', 41.9217, -87.6334, 'park'),
        (uuid_generate_v4(), 'Prospect Park', 'Prospect Park, Brooklyn, NY', 'Brooklyn', 'NY', 'USA', 40.6602, -73.9690, 'park');
        RAISE NOTICE 'Inserted sample locations';
    ELSE
        RAISE NOTICE 'Locations table already has data';
    END IF;
END $$; 