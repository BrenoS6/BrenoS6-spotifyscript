local uiOpen = false

local function openMusic(admin)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        admin = admin or false
    })

    TriggerServerEvent('bs_spotify:requestHome')
end

RegisterCommand(Config.OpenCommand, function()
    openMusic(false)
end, false)

RegisterCommand(Config.AdminCommand, function()
    TriggerServerEvent('bs_spotify:requestAdmin')
end, false)

RegisterNetEvent('bs_spotify:openAdmin', function()
    openMusic(true)
end)

RegisterNetEvent('bs_spotify:sendHome', function(payload)
    SendNUIMessage({
        action = 'homeData',
        data = payload
    })
end)

RegisterNetEvent('bs_spotify:searchResults', function(results)
    SendNUIMessage({
        action = 'searchResults',
        results = results
    })
end)

RegisterNetEvent('bs_spotify:updateFavorites', function(favorites)
    SendNUIMessage({
        action = 'favoritesUpdated',
        favorites = favorites
    })
end)

RegisterNetEvent('bs_spotify:playTrack', function(track)
    SendNUIMessage({
        action = 'playTrack',
        track = track
    })
end)

RegisterNetEvent('bs_spotify:notify', function(message)
    SendNUIMessage({
        action = 'notify',
        message = message
    })
end)

RegisterNUICallback('close', function(_, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('search', function(data, cb)
    TriggerServerEvent('bs_spotify:search', data.query or '')
    cb('ok')
end)

RegisterNUICallback('playTrack', function(data, cb)
    TriggerServerEvent('bs_spotify:playTrack', data.id)
    cb('ok')
end)

RegisterNUICallback('toggleFavorite', function(data, cb)
    TriggerServerEvent('bs_spotify:toggleFavorite', data.id)
    cb('ok')
end)

RegisterNUICallback('pause', function(_, cb)
    SendNUIMessage({ action = 'pause' })
    cb('ok')
end)

RegisterNUICallback('resume', function(_, cb)
    SendNUIMessage({ action = 'resume' })
    cb('ok')
end)

RegisterNUICallback('setVolume', function(data, cb)
    SendNUIMessage({
        action = 'setVolume',
        volume = tonumber(data.volume) or Config.DefaultVolume
    })
    cb('ok')
end)

RegisterNUICallback('createTrack', function(data, cb)
    TriggerServerEvent('bs_spotify:createTrack', data)
    cb('ok')
end)