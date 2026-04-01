local function getLicense(src)
    return GetPlayerIdentifierByType(src, 'license') or ('player_' .. src)
end

local function isAdmin(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, identifier in ipairs(identifiers) do
        for _, allowed in ipairs(Config.AdminIdentifiers) do
            if identifier == allowed then
                return true
            end
        end
    end
    return false
end

local function getFavoritesMap(license)
    local rows = MySQL.query.await('SELECT track_id FROM music_favorites WHERE player_license = ?', { license })
    local map = {}
    for _, row in ipairs(rows or {}) do
        map[row.track_id] = true
    end
    return map
end

RegisterNetEvent('bs_spotify:requestHome', function()
    local src = source
    local license = getLicense(src)

    local tracks = MySQL.query.await([[
        SELECT id, title, artist, album, cover_url, audio_url, duration
        FROM music_tracks
        ORDER BY id DESC
        LIMIT 100
    ]])

    local history = MySQL.query.await([[
        SELECT t.id, t.title, t.artist, t.album, t.cover_url, t.audio_url, t.duration, h.played_at
        FROM music_history h
        INNER JOIN music_tracks t ON t.id = h.track_id
        WHERE h.player_license = ?
        ORDER BY h.played_at DESC
        LIMIT 10
    ]], { license })

    TriggerClientEvent('bs_spotify:sendHome', src, {
        tracks = tracks or {},
        history = history or {},
        favorites = getFavoritesMap(license),
        isAdmin = isAdmin(src)
    })
end)

RegisterNetEvent('bs_spotify:requestAdmin', function()
    local src = source
    if isAdmin(src) then
        TriggerClientEvent('bs_spotify:openAdmin', src)
    else
        TriggerClientEvent('bs_spotify:notify', src, 'Você não tem permissão.')
    end
end)

RegisterNetEvent('bs_spotify:search', function(query)
    local src = source
    local q = '%' .. (query or '') .. '%'

    local results = MySQL.query.await([[
        SELECT id, title, artist, album, cover_url, audio_url, duration
        FROM music_tracks
        WHERE title LIKE ? OR artist LIKE ? OR album LIKE ?
        ORDER BY title ASC
        LIMIT 50
    ]], { q, q, q })

    TriggerClientEvent('bs_spotify:searchResults', src, results or {})
end)

RegisterNetEvent('bs_spotify:playTrack', function(trackId)
    local src = source
    local license = getLicense(src)

    local track = MySQL.single.await([[
        SELECT id, title, artist, album, cover_url, audio_url, duration
        FROM music_tracks
        WHERE id = ?
    ]], { tonumber(trackId) })

    if not track then
        TriggerClientEvent('bs_spotify:notify', src, 'Música não encontrada.')
        return
    end

    MySQL.insert.await([[
        INSERT INTO music_history (player_license, track_id, played_at)
        VALUES (?, ?, NOW())
    ]], { license, track.id })

    TriggerClientEvent('bs_spotify:playTrack', src, track)
end)

RegisterNetEvent('bs_spotify:toggleFavorite', function(trackId)
    local src = source
    local license = getLicense(src)
    trackId = tonumber(trackId)

    local exists = MySQL.single.await([[
        SELECT id FROM music_favorites
        WHERE player_license = ? AND track_id = ?
    ]], { license, trackId })

    if exists then
        MySQL.query.await('DELETE FROM music_favorites WHERE player_license = ? AND track_id = ?', { license, trackId })
    else
        MySQL.insert.await('INSERT INTO music_favorites (player_license, track_id) VALUES (?, ?)', { license, trackId })
    end

    TriggerClientEvent('bs_spotify:updateFavorites', src, getFavoritesMap(license))
end)

RegisterNetEvent('bs_spotify:createTrack', function(data)
    local src = source
    if not isAdmin(src) then
        TriggerClientEvent('bs_spotify:notify', src, 'Sem permissão.')
        return
    end

    local title = tostring(data.title or '')
    local artist = tostring(data.artist or '')
    local album = tostring(data.album or '')
    local cover = tostring(data.cover_url or '')
    local audio = tostring(data.audio_url or '')
    local duration = tonumber(data.duration) or 0

    if title == '' or artist == '' or audio == '' then
        TriggerClientEvent('bs_spotify:notify', src, 'Preencha título, artista e áudio.')
        return
    end

    MySQL.insert.await([[
        INSERT INTO music_tracks (title, artist, album, cover_url, audio_url, duration)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], { title, artist, album, cover, audio, duration })

    TriggerClientEvent('bs_spotify:notify', src, 'Música adicionada com sucesso.')

    local license = getLicense(src)
    local tracks = MySQL.query.await([[
        SELECT id, title, artist, album, cover_url, audio_url, duration
        FROM music_tracks
        ORDER BY id DESC
        LIMIT 100
    ]])

    TriggerClientEvent('bs_spotify:sendHome', src, {
        tracks = tracks or {},
        history = {},
        favorites = getFavoritesMap(license),
        isAdmin = true
    })
end)
