-- All server-side logic related to earning or earned trophies
-- Reads the earned trophies, and players with the rainbow effect on, from a file
if file.Exists("ttt/trophies.txt", "DATA") then
    local fileContent = file.Read("ttt/trophies.txt")
    fileContent = util.JSONToTable(fileContent) or {}
    TTTTrophies.earned = fileContent.earned or {}
    TTTTrophies.rainbowPlayers = fileContent.rainbowPlayers or {}
    TTTTrophies.stats = fileContent.stats or {}
else
    -- Creates the earned trophies file if it doesn't exist
    file.CreateDir("ttt")
    file.Write("ttt/trophies.txt", {})
end

-- Sends each player their list of earned trophies when they have loaded in enough
util.AddNetworkString("TTTRequestEarnedTrophies")
util.AddNetworkString("TTTSendEarnedTrophies")

net.Receive("TTTRequestEarnedTrophies", function(len, ply)
    local chatMessagesCvar = net.ReadBool()
    ply.DisableTrophyChatMessages = not chatMessagesCvar
    local id = ply:SteamID()
    local count

    if not TTTTrophies.earned[id] or table.IsEmpty(TTTTrophies.earned[id]) or TTTTrophies.earned[id] == {} then
        count = 0
        TTTTrophies.earned[id] = {}
        TTTTrophies.earned[id]["___name"] = ply:Nick()
    else
        count = table.Count(TTTTrophies.earned[id])
    end

    net.Start("TTTSendEarnedTrophies")
    net.WriteUInt(count, 16)
    net.WriteBool(TTTTrophies.rainbowPlayers[id] or false)

    if count > 0 then
        for trophyID, earned in pairs(TTTTrophies.earned[id]) do
            net.WriteString(trophyID)
        end
    end

    net.Send(ply)
end)

-- Saves the trophies earned, and players with the rainbow effect on, to a file so they persist
hook.Add("ShutDown", "TTTTrophiesSaveEarned", function()
    local fileContent = {}
    fileContent.earned = TTTTrophies.earned
    fileContent.rainbowPlayers = TTTTrophies.rainbowPlayers
    fileContent = util.TableToJSON(fileContent, true)
    file.Write("ttt/trophies.txt", fileContent)
end)

-- Shows a chat alert to everyone at the end of the round if someone has earned a trophy
util.AddNetworkString("TTTEarnedTrophiesChatMessage")

hook.Add("TTTEndRound", "TTTTrophiesChatAnnouncement", function()
    if table.IsEmpty(TTTTrophies.toMessage) or TTTTrophies.toMessage == {} then return end

    timer.Simple(6, function()
        for nick, trophies in pairs(TTTTrophies.toMessage) do
            for _, trophyID in ipairs(trophies) do
                net.Start("TTTEarnedTrophiesChatMessage")
                net.WriteString(nick)
                net.WriteString(trophyID)
                net.Broadcast()
            end
        end

        table.Empty(TTTTrophies.toMessage)
    end)
end)

-- Displays a chat message at the start of the round if a player is a role that they could earn a trophy with
hook.Add("TTTBeginRound", "TTTTrophiesRoleSpecificChatSuggestion", function()
    timer.Simple(3, function()
        for _, ply in ipairs(player.GetAll()) do
            if ply.DisableTrophyChatMessages then continue end
            if not ply:Alive() or ply:IsSpec() then continue end
            local role = ply:GetRole()
            -- Make trophies suggested to innocents have a rarer chance of showing up
            if role == ROLE_INNOCENT and math.random() < 0.5 then return end
            local trophies = TTTTrophies.roleMessage[role]

            if trophies then
                for _, trophyID in ipairs(trophies) do
                    local earned = TTTTrophies.earned[ply:SteamID()] and TTTTrophies.earned[ply:SteamID()][trophyID]
                    if earned then continue end
                    local trophy = TTTTrophies.trophies[trophyID]
                    ply:ChatPrint("[Trophy suggestion]\n" .. trophy.desc)
                    break
                end
            end
        end
    end)
end)

-- Controls toggling a player's rainbow effect on and off
util.AddNetworkString("TTTTrophiesRainbowToggle")

net.Receive("TTTTrophiesRainbowToggle", function(len, ply)
    local earnedPlatinum = net.ReadBool()

    if earnedPlatinum then
        if TTTTrophies.rainbowPlayers[ply:SteamID()] then
            TTTTrophies.rainbowPlayers[ply:SteamID()] = false
            ply:ChatPrint("Rainbow disabled")
        else
            TTTTrophies.rainbowPlayers[ply:SteamID()] = true
            ply:ChatPrint("Rainbow enabled")
        end
    else
        if ply.DisableTrophyChatMessages then
            ply.DisableTrophyChatMessages = false
        else
            ply.DisableTrophyChatMessages = true
        end
    end
end)

-- Changes a player's playermodel colours over time
local rainbowPhase = 1
local colourSetPlayers = {}
local mult = 1
local halfMult = mult / 2

hook.Add("PlayerPostThink", "TTTPlatinumTrophyReward", function(ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    -- Don't try to do the rainbow effect while a player is disguised, invisible, dead or hasn't earned all trophies yet
    if not TTTTrophies.rainbowPlayers[ply:SteamID()] or ply:IsSpec() or not ply:Alive() or ply:GetRenderMode() ~= RENDERMODE_NORMAL or ply:GetNoDraw() or ply:GetNWBool("disguised", false) or ply:GetMaterial() == "sprites/heatwave" then
        wep:SetColor(COLOR_WHITE)

        return
    end

    if not colourSetPlayers[ply] then
        wep:SetColor(COLOR_WHITE)
        colourSetPlayers[ply] = true
    end

    local colour = wep:GetColor()

    if rainbowPhase == 1 then
        colour.r = colour.r + mult
        colour.g = colour.g - halfMult
        colour.b = colour.b - mult

        if colour.r + mult == 255 then
            rainbowPhase = 2
        end
    elseif rainbowPhase == 2 then
        colour.r = colour.r - mult
        colour.g = colour.g + mult
        colour.b = colour.b - halfMult

        if colour.g + mult == 255 then
            rainbowPhase = 3
        end
    elseif rainbowPhase == 3 then
        colour.r = colour.r - halfMult
        colour.g = colour.g - mult
        colour.b = colour.b + mult

        if colour.b + mult == 255 then
            rainbowPhase = 1
        end
    end

    wep:SetColor(colour)
end)