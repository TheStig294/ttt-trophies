util.AddNetworkString("TTTRequestEarnedTrophies")
util.AddNetworkString("TTTSendEarnedTrophies")

-- Reads the earned trophies from a file
if file.Exists("ttt/trophies.txt", "DATA") then
    local fileContent = file.Read("ttt/trophies.txt")
    TTTTrophies.earnedTrophies = util.JSONToTable(fileContent)
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

    if not TTTTrophies.earnedTrophies[id] or table.IsEmpty(TTTTrophies.earnedTrophies[id]) or TTTTrophies.earnedTrophies[id] == {} then
        count = 0
    else
        count = table.Count(TTTTrophies.earnedTrophies[id])
    end

    net.WriteUInt(count, 16)

    if count > 0 then
        for trophyID, earned in ipairs(TTTTrophies.earnedTrophies[id]) do
            net.WriteString(trophyID)
        end
    end

    net.Send(ply)
end)

-- Saves the trophies earned to a file so they persist
hook.Add("ShutDown", "TTTTrophiesSaveEarned", function()
    local fileContent = util.TableToJSON(TTTTrophies.earnedTrophies, true)
    file.Write("ttt/trophies.txt", fileContent)
end)

-- Shows a chat alert to everyone at the end of the round if someone has earned a trophy
hook.Add("TTTEndRound", "TTTTrophiesChatAnnouncement", function()
    if table.IsEmpty(TTTTrophies.toMessageTrophies) or TTTTrophies.toMessageTrophies == {} then return end

    timer.Simple(6, function()
        BroadcastLua("surface.PlaySound(\"ttt_trophies/trophypop.mp3\")")

        for nick, trophies in pairs(TTTTrophies.toMessageTrophies) do
            PrintMessage(HUD_PRINTTALK, nick .. ":")

            for _, trophyID in ipairs(trophies) do
                local trophy = TTTTrophies.trophies[trophyID]
                PrintMessage(HUD_PRINTTALK, "[" .. trophy.title .. "]\n" .. trophy.desc)
            end
        end

        table.Empty(TTTTrophies.toMessageTrophies)
    end)
end)