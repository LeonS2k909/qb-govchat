local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand("gov", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if job ~= "police" and job ~= "ambulance" then
        TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this.", "error")
        return
    end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('QBCore:Notify', source, "You must enter a message.", "error")
        return
    end

    local header, color
    if job == "police" then
        header = "[Gov - Police]"
        color = { 0, 102, 204 } -- blue
    else
        header = "[Government]"
        color = { 255, 0, 0 } -- red
    end

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local name = firstname .. " " .. lastname

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(v)
        if target and (target.PlayerData.job.name == "police" or target.PlayerData.job.name == "ambulance") then
            TriggerClientEvent('chat:addMessage', v, {
                color = color,
                multiline = true,
                args = { header, name .. ": " .. msg }
            })
        end
    end
end, false)

RegisterCommand("broadcast", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if job ~= "police" and job ~= "ambulance" then
        TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this.", "error")
        return
    end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('QBCore:Notify', source, "You must enter a message.", "error")
        return
    end

    local header, color
    if job == "police" then
        header = "(Broadcast) [Gov - Police]"
        color = { 0, 102, 204 } -- blue
    else
        header = "(Broadcast) [Government]"
        color = { 255, 0, 0 } -- red
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = color,
        multiline = true,
        args = { header, msg }
    })
end, false)
