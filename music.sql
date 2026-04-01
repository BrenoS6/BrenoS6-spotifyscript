CREATE TABLE IF NOT EXISTS music_tracks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist VARCHAR(255) NOT NULL,
    album VARCHAR(255) DEFAULT '',
    cover_url TEXT,
    audio_url TEXT NOT NULL,
    duration INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS music_favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_license VARCHAR(100) NOT NULL,
    track_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_player_track (player_license, track_id)
);

CREATE TABLE IF NOT EXISTS music_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_license VARCHAR(100) NOT NULL,
    track_id INT NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO music_tracks (title, artist, album, cover_url, audio_url, duration) VALUES
('Midnight Run', 'Nova', 'After Hours', 'https://placehold.co/300x300', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 320),
('Blue Skyline', 'Aero', 'Dreamstate', 'https://placehold.co/300x300', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 280),
('City Vibes', 'Nightshift', 'Downtown', 'https://placehold.co/300x300', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 301);