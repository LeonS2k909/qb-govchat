local QBCore = exports['qb-core']:GetCoreObject()

local govQuickMsgs = {
    ["10-3"] = "Stop trasmitting.",
    ["10-4"] = "10-4: Understood.",
    ["10-9"] = "Repeat last transmission.",
    ["10-13"] = "Advise weather and road conditions.",
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

local broadcastCooldowns = {}
local messageTracking = {}

local lastChatMessageTime = GetGameTimer() -- Our inactivity tracker

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
        if dist <= 20.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 130, 130, 255 },
                multiline = true,
                args = { "(Vicinity)", rpname .. ": " .. msg }
            })
        end
    end
    lastChatMessageTime = GetGameTimer()
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
    lastChatMessageTime = GetGameTimer()
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
        color = { 0, 102, 204 }
    else
        header = "[Government]"
        color = { 255, 0, 0 }
    end

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local name = firstname .. " " .. lastname

    local messageId = tostring(GetGameTimer()) .. "_" .. source

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(v)
        if target and (target.PlayerData.job.name == "police" or target.PlayerData.job.name == "ambulance") then
            TriggerClientEvent('chat:addMessage', v, {
                color = color,
                multiline = true,
                args = { header, name .. ": " .. msg }
            })
            messageTracking[messageId] = {
                player = v,
                message = header .. " " .. name .. ": " .. msg,
                time = GetGameTimer()
            }
        end
    end

    Citizen.CreateThread(function()
        Wait(10000)
        if messageTracking[messageId] then
            messageTracking[messageId] = nil
        end
    end)

    lastChatMessageTime = GetGameTimer()
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
        color = { 255, 0, 0 }
    else
        header = "[Government]"
        color = { 255, 0, 0 }
    end

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local name = firstname .. " " .. lastname

    local messageId = tostring(GetGameTimer()) .. "_" .. source

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(v)
        if target and (target.PlayerData.job.name == "police" or target.PlayerData.job.name == "ambulance") then
            TriggerClientEvent('chat:addMessage', v, {
                color = color,
                multiline = true,
                args = { header, name .. ": " .. msg }
            })
            messageTracking[messageId] = {
                player = v,
                message = header .. " " .. name .. ": " .. msg,
                time = GetGameTimer()
            }
        end
    end

    Citizen.CreateThread(function()
        Wait(10000)
        if messageTracking[messageId] then
            messageTracking[messageId] = nil
        end
    end)

    lastChatMessageTime = GetGameTimer()
end, false)

RegisterCommand("broadcast", function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local job = Player.PlayerData.job.name
    if job ~= "police" and job ~= "ambulance" then
        TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this.", "error")
        return
    end

    -- Check cooldown
    if broadcastCooldowns[source] and broadcastCooldowns[source] > GetGameTimer() then
        local remaining = math.ceil((broadcastCooldowns[source] - GetGameTimer()) / 1000)
        TriggerClientEvent('QBCore:Notify', source, "You must wait " .. remaining .. " seconds before sending another broadcast.", "error")
        return
    end

    local msg = table.concat(args, " ")
    if msg == "" then
        TriggerClientEvent('QBCore:Notify', source, "You must enter a message.", "error")
        return
    end

    -- Set cooldown (5 seconds)
    broadcastCooldowns[source] = GetGameTimer() + 5000

    local header, color
    if job == "police" then
        header = "(Broadcast) [Gov - Police]"
        color = { 0, 102, 204 }
    else
        header = "(Broadcast) [Government]"
        color = { 255, 0, 0 }
    end

    local messageId = tostring(GetGameTimer()) .. "_" .. source

    TriggerClientEvent('chat:addMessage', -1, {
        color = color,
        multiline = true,
        args = { header, msg }
    })

    Citizen.CreateThread(function()
        Wait(10000)
        if messageTracking[messageId] then
            messageTracking[messageId] = nil
        end
    end)

    lastChatMessageTime = GetGameTimer()
end, false)

AddEventHandler('playerDropped', function(source)
    broadcastCooldowns[source] = nil
end)

RegisterNetEvent('qb-chat:server:deleteMessage')
AddEventHandler('qb-chat:server:deleteMessage', function(messageId)
    messageTracking[messageId] = nil
end)

RegisterCommand('clear', function(source, args, raw)
    TriggerClientEvent('chat:clear', -1)
end, false)

-- ===========================================
-- 5-Second Chat Clearer (core logic)
-- ===========================================
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000) -- Wait 30,000 ms (30 seconds)
        if (GetGameTimer() - lastChatMessageTime) >= 30000 then -- 30,000 ms = 30 sec
            TriggerClientEvent('chat:clear', -1)
            lastChatMessageTime = GetGameTimer()
        end
    end
end)


--LOOC

RegisterCommand("looc", function(source, args)
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

    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local tgtPed = GetPlayerPed(v)
        local tgtCoords = GetEntityCoords(tgtPed)
        local dist = #(srcCoords - tgtCoords)
        if dist <= 20.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 255, 135, 0 },
                multiline = true,
                args = { "(LOOC)", rpname .. ": " .. msg }
            })
        end
    end
end, false)

local function handleYellCommand(source, args)
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

    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local tgtPed = GetPlayerPed(v)
        local tgtCoords = GetEntityCoords(tgtPed)
        local dist = #(srcCoords - tgtCoords)
        if dist <= 40.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = { 255, 255, 0 }, -- Yellow
                multiline = true,
                args = { "(YELL)", rpname .. ": " .. msg }
            })
        end
    end
end

RegisterCommand("yell", handleYellCommand, false)
RegisterCommand("shout", handleYellCommand, false)


local function handleWhisperCommand(source, args)
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

    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local tgtPed = GetPlayerPed(v)
        local tgtCoords = GetEntityCoords(tgtPed)
        local dist = #(srcCoords - tgtCoords)
        if dist <= 4.0 then -- whisper distance
            TriggerClientEvent('chat:addMessage', v, {
                color = { 180, 180, 255 }, -- soft blue
                multiline = true,
                args = { "(Whisper)", rpname .. ": " .. msg }
            })
        end
    end
end

RegisterCommand("whisper", handleWhisperCommand, false)
RegisterCommand("w", handleWhisperCommand, false)

local function handleRollCommand(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local min, max = 1, 100 -- default dice range

    if #args == 1 then
        max = tonumber(args[1]) or 100
    elseif #args == 2 then
        min = tonumber(args[1]) or 1
        max = tonumber(args[2]) or 100
    end

    if min >= max then
        TriggerClientEvent('QBCore:Notify', source, "Invalid range.", "error")
        return
    end

    local result = math.random(min, max)

    local firstname = Player.PlayerData.charinfo.firstname or ""
    local lastname = Player.PlayerData.charinfo.lastname or ""
    local rpname = firstname .. " " .. lastname

    local srcPed = GetPlayerPed(source)
    local srcCoords = GetEntityCoords(srcPed)

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local tgtPed = GetPlayerPed(v)
        local tgtCoords = GetEntityCoords(tgtPed)
        local dist = #(srcCoords - tgtCoords)
        if dist <= 20.0 then -- vicinity distance
            TriggerClientEvent('chat:addMessage', v, {
                color = { 120, 255, 120 }, -- green
                multiline = true,
                args = { "(Roll)", rpname .. " rolls a dice [" .. min .. "-" .. max .. "] and gets: " .. result }
            })
        end
    end
end

RegisterCommand("roll", handleRollCommand, false)
RegisterCommand("dice", handleRollCommand, false)


