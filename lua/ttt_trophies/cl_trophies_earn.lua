hook.Add("InitPostEntity", "TTTTrophiesSyncEarned", function()
    net.Start("TTTRequestEarnedTrophies")
    net.SendToServer()
end)

net.Receive("TTTSendEarnedTrophies", function()
    local count = net.ReadUInt(16)

    for i = 1, count do
        local trophyID = net.ReadString()
        -- Trophies would have loaded in by now, as the InitPostEntity hook delays when this net message is sent
        local trophy = TTTTrophies.trophies[trophyID]
        -- Need to skip over the player's name saved in the earned trophies stats file, or anything else in the earned trophies file that isn't on the trophies list
        if not trophy then return end
        trophy.earned = true
    end
end)