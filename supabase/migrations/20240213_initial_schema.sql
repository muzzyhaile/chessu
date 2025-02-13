-- Create games table
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR NOT NULL UNIQUE,
    status VARCHAR NOT NULL DEFAULT 'waiting',
    moves JSONB[] DEFAULT ARRAY[]::JSONB[],
    white_player JSONB,
    black_player JSONB,
    winner VARCHAR,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table (for registered users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR NOT NULL UNIQUE,
    email VARCHAR UNIQUE,
    games_played INT DEFAULT 0,
    games_won INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_games_updated_at
    BEFORE UPDATE ON games
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Create RLS policies
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Games policies
CREATE POLICY "Games are viewable by everyone"
    ON games FOR SELECT
    USING (true);

CREATE POLICY "Games can be created by anyone"
    ON games FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Games can be updated by players"
    ON games FOR UPDATE
    USING (
        (auth.uid()::TEXT = (white_player->>'id')) OR
        (auth.uid()::TEXT = (black_player->>'id'))
    );

-- Users policies
CREATE POLICY "Users are viewable by everyone"
    ON users FOR SELECT
    USING (true);

CREATE POLICY "Users can be created by authenticated users"
    ON users FOR INSERT
    WITH CHECK (auth.uid()::TEXT = id::TEXT);

CREATE POLICY "Users can be updated by themselves"
    ON users FOR UPDATE
    USING (auth.uid()::TEXT = id::TEXT);
