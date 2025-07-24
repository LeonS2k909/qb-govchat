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

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "[Government]", msg }
    })
end, false)
