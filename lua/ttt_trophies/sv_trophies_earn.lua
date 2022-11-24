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
    net.Start("TTTSendEarnedTrophies")
    local id = ply:SteamID()
    local count

    if not TTTTrophies.earned[id] or table.IsEmpty(TTTTrophies.earned[id]) or TTTTrophies.earned[id] == {} then
        count = 0
        TTTTrophies.earned[id] = {}
        TTTTrophies.earned[id]["___name"] = ply:Nick()
    else
        count = table.Count(TTTTrophies.earned[id])
    end

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
        PrintMessage(HUD_PRINTTALK, "###Players have earned trophies!###")

        for nick, trophies in pairs(TTTTrophies.toMessage) do
            PrintMessage(HUD_PRINTTALK, nick .. ":")

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

                PrintMessage(HUD_PRINTTALK, "[" .. trophy.title .. "]\n" .. trophy.desc .. " " .. rarity)
            end

            PrintMessage(HUD_PRINTTALK, "##########################")
        end

        table.Empty(TTTTrophies.toMessage)
    end)
end)