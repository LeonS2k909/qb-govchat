local QBCore = exports['qb-core']:GetCoreObject()

local govQuickMsgs = {
    ["10-3"] = "Stop trasmitting.",
    ["10-4"] = "10-4: Understood.",
    ["10-9"] = "Repeat last transmission.",
    ["10-13"] = "Avice weather and road conditions.",
    ["10-19"] = "Returning to station.",
    ["10-20"] = "Location?",
    ["10-23"] = "Standby.",
    ["10-45"] = "What is the condition of the patient?",
    ["10-45A"] = "Condition of patient is good.",
    ["10-45B"] = "Condition of patient is serious",
    ["10-45C"] = "Condition of patient is critical.",
    ["10-45D"] = "Patient is deceased.",
    ["10-56"] = "Suicide",
    ["10-72"] = "Knifing",
    ["10-98"] = "Available to assign.",
    ["10-91v"] = "Vicious animal",
    ["10-95"] = "Traffic stop",
    ["10-56A"] = "Suicide attempt",
    ["10-57"] = "Firearm discharged",
    ["10-71"] = "Shooting",
    ["11-44"] = "Coroner required",
    ["11-24"] = "Abanonded vehicle",
    ["11-51"] = "Escort",
    ["11-54"] = "Suspicious vehicle",
    ["11-71"] = "Fire.",
    ["11-79"] = "Accident - ambulance has been sent",
    ["11-80"] = "Accident - major injuries",
    ["11-81"] = "Accident - minor injuries",
    ["11-82"] = "Accident - no injuries.",
    ["11-83"] = "Accident - no details",
    ["11-84"] = "Direct traffic",
    ["11-85"] = "Tow truck required",
    ["code 2"] = "Urgent. No lights or sirens.",
    ["code 3"] = "Emergency/lights and siren",
    ["code 6"] = "Stay out of area",
    ["code 7"] = "Mealtime",
    ["code 8"] = "Request backup",
    ["code 9"] = "Set up a roadblock.",
    ["code 10"] = "Bomb threat.",
    --["code 10"] = "TFU pre-callup.",
    --["code 11"] = "TFU required",
    ["code 4"] = "Code 4: Situation requires no further assistance."
}

AddEventHandler('chatMessage', function(source, name, msg)
    CancelEvent()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if string.sub(msg, 1, 1) == "/" then
        return -- allow commands
    end

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local rpname = firstname .. " " .. lastname

    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local tgtPed = GetPlayerPed(v)
        local tgtCoords = GetEntityCoords(tgtPed)
        local dist = #(srcCoords - tgtCoords)
        if dist <= 20.0 then -- Change distance for "vicinity" as needed
            TriggerClientEvent('chat:addMessage', v, {
                color = { 130, 130, 255 },
                multiline = true,
                args = { "(Vicinity)", rpname .. ": " .. msg }
            })
        end
    end
end)

RegisterCommand("ooc", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('QBCore:Notify', source, "You must enter a message.", "error")
        return
    end

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local rpname = firstname .. " " .. lastname

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 220, 220, 220 },
        multiline = true,
        args = { "(OOC)", rpname .. ": " .. msg }
    })
end, false)

RegisterCommand("gov", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if job ~= "police" and job ~= "ambulance" then
        TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this.", "error")
        return
    end

    if not args[1] then
        local quickMsgList = "^3Quick Messages:^7"
        for k, v in pairs(govQuickMsgs) do
            quickMsgList = quickMsgList .. "\n^5" .. k .. "^7 - " .. v
        end
        TriggerClientEvent('chat:addMessage', source, {
            color = { 200, 200, 200 },
            multiline = true,
            args = { "[Gov QuickMsgs]", quickMsgList }
        })
        return
    end

    local msg = table.concat(args, " ")

    if job == "police" then
        local lowerMsg = string.lower(msg)
        if govQuickMsgs[lowerMsg] then
            msg = govQuickMsgs[lowerMsg]
        end
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

RegisterCommand("panic", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if job ~= "police" and job ~= "ambulance" then
        TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this.", "error")
        return
    end

    local msg = table.concat(args, " ")

    if job == "police" then
        local lowerMsg = string.lower(msg)
        if govQuickMsgs[lowerMsg] then
            msg = govQuickMsgs[lowerMsg]
        end
    end

    local header, color
    if job == "police" then
        header = "[PANIC. Gov - Police]"
        color = { 255, 0, 0  } -- red
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
