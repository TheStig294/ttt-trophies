hook.Add("TTTBeginRound", "TTTTrophiesSyncEarned", function()
    timer.Simple(1, function()
        net.Start("TTTRequestEarnedTrophies")
        net.SendToServer()
        hook.Remove("TTTBeginRound", "TTTTrophiesSyncEarned")
    end)
end)

net.Receive("TTTSendEarnedTrophies", function()
    local count = net.ReadUInt(16)

    for i = 1, count do
        local trophyID = net.ReadString()
        -- Trophies would have loaded in by now, as the TTTPrepareRound hook delays when this net message is sent
        local trophy = TTTTrophies.trophies[trophyID]
        -- Need to skip over the player's name saved in the earned trophies stats file, or anything else in the earned trophies file that isn't on the trophies list
        if not trophy then continue end
        trophy.earned = true
    end
end)