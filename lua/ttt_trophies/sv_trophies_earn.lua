util.AddNetworkString("TTTRequestEarnedTrophies")
util.AddNetworkString("TTTSendEarnedTrophies")

-- Reads the earned trophies from a file
if file.Exists("ttt/trophies.txt", "DATA") then
    local fileContent = file.Read("ttt/trophies.txt")
    TTTTrophies.earned = util.JSONToTable(fileContent) or {}
else
    -- Creates the earned trophies file if it doesn't exist
    file.CreateDir("ttt")
    file.Write("ttt/trophies.txt", {})
end

-- Sends each player their list of earned trophies when they have loaded in enough
net.Receive("TTTRequestEarnedTrophies", function(len, ply)
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

    if count > 0 then
        for trophyID, earned in pairs(TTTTrophies.earned[id]) do
            net.WriteString(trophyID)
        end
    end

    net.Send(ply)
end)

-- Saves the trophies earned to a file so they persist
hook.Add("ShutDown", "TTTTrophiesSaveEarned", function()
    local fileContent = util.TableToJSON(TTTTrophies.earned, true)
    file.Write("ttt/trophies.txt", fileContent)
end)

-- Shows a chat alert to everyone at the end of the round if someone has earned a trophy
hook.Add("TTTEndRound", "TTTTrophiesChatAnnouncement", function()
    if table.IsEmpty(TTTTrophies.toMessage) or TTTTrophies.toMessage == {} then return end

    timer.Simple(6, function()
        for nick, trophies in pairs(TTTTrophies.toMessage) do
            PrintMessage(HUD_PRINTTALK, "##########################\n" .. nick .. " has earned trophies!")

            for _, trophyID in ipairs(trophies) do
                local trophy = TTTTrophies.trophies[trophyID]
                local rarity = ""

                if trophy.rarity == 1 then
                    rarity = "Bronze"
                elseif trophy.rarity == 2 then
                    rarity = "Silver"
                elseif trophy.rarity == 3 then
                    rarity = "Gold"
                elseif trophy.rarity == 4 then
                    rarity = "Platinum"
                end

                PrintMessage(HUD_PRINTTALK, "[" .. trophy.title .. "] (" .. rarity .. ")\n" .. trophy.desc)
            end
        end

        table.Empty(TTTTrophies.toMessage)
    end)
end)

-- Displays a chat message at the start of the round if a player is a role that they could earn a trophy with
hook.Add("TTTBeginRound", "TTTTrophiesRoleSpecificChatSuggestion", function()
    timer.Simple(3, function()
        for _, ply in ipairs(player.GetAll()) do
            if not ply:Alive() or ply:IsSpec() then continue end
            local role = ply:GetRole()
            local trophies = TTTTrophies.roleSpecific[role]

            if trophies then
                for _, trophyID in ipairs(trophies) do
                    local earned = TTTTrophies.earned[ply:SteamID()][trophyID]
                    if earned then continue end
                    local trophy = TTTTrophies.trophies[trophyID]
                    ply:ChatPrint("[Trophy suggestion]\n" .. trophy.desc)
                    break
                end
            end
        end
    end)
end)

-- Changes a player's playermodel colours over time
local rainbowPhase = 1
local colourSetPlayers = {}
local mult = 1
local halfMult = mult / 2

hook.Add("PlayerPostThink", "TTTPlatinumTrophyReward", function(ply)
    -- if not TTTTrophies.platinumPlayers[ply:SteamID()] or not ply:Alive() or ply:IsSpec() then return end
    if not colourSetPlayers[ply] then
        ply:SetColor(COLOR_WHITE)
        colourSetPlayers[ply] = true
    end

    local colour = ply:GetColor()
    --print(colour)

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
	
    --print(rainbowPhase)
    ply:SetColor(colour)
end)