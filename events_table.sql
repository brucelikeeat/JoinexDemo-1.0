-- Create events table SQL for Supabase
-- Run this in your Supabase SQL Editor

-- Drop the table if it exists to recreate it properly
DROP TABLE IF EXISTS events CASCADE;

-- Create the events table
CREATE TABLE events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    sport_type TEXT NOT NULL,
    location TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 120,
    max_players INTEGER NOT NULL,
    current_players INTEGER NOT NULL DEFAULT 0,
    skill_level INTEGER NOT NULL CHECK (skill_level >= 1 AND skill_level <= 10),
    host_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Allow users to view all events
CREATE POLICY "Allow users to view all events" ON events
    FOR SELECT USING (true);

-- Allow users to create events
CREATE POLICY "Allow users to create events" ON events
    FOR INSERT WITH CHECK (auth.uid()::text = host_id::text);

-- Allow event hosts to update their events
CREATE POLICY "Allow hosts to update their events" ON events
    FOR UPDATE USING (auth.uid()::text = host_id::text);

-- Allow event hosts to delete their events
CREATE POLICY "Allow hosts to delete their events" ON events
    FOR DELETE USING (auth.uid()::text = host_id::text);

-- Create function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_events_updated_at 
    BEFORE UPDATE ON events 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert a test event to verify the table works
INSERT INTO events (
    title, 
    description, 
    sport_type, 
    location, 
    date_time, 
    duration_minutes, 
    max_players, 
    current_players, 
    skill_level, 
    host_id, 
    status
) VALUES (
    'Test Event',
    'This is a test event',
    'Badminton',
    'Vancouver, BC',
    NOW() + INTERVAL '1 day',
    120,
    8,
    0,
    5,
    (SELECT id FROM auth.users LIMIT 1),
    'active'
);
