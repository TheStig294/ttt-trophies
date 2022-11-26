CreateClientConVar("ttt_trophies_hotkey_rainbow", "J", true, false, "Hotkey for toggling rainbow effect")
local earnedPlatinum = false

hook.Add("Think", "TTTTrophiesSyncEarned", function()
    if GetGlobalBool("TTTTrophiesClientLoaded") then
        net.Start("TTTRequestEarnedTrophies")
        net.SendToServer()
        hook.Remove("Think", "TTTTrophiesSyncEarned")
    end
end)

net.Receive("TTTSendEarnedTrophies", function()
    local count = net.ReadUInt(16)

    for i = 1, count do
        local trophyID = net.ReadString()
        local trophy = TTTTrophies.trophies[trophyID]
        -- Need to skip over the player's name saved in the earned trophies stats file, or anything else in the earned trophies file that isn't on the trophies list
        if not trophy then continue end
        trophy.earned = true

        if trophy.id == "platinum" then
            earnedPlatinum = true
        end
    end

    if earnedPlatinum then
        chat.AddText("Press '" .. string.upper(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) .. "' to toggle rainbow effect")
    end

    SetGlobalBool("TTTTrophiesEarnedLoaded", true)
end)

hook.Add("PlayerButtonDown", "TTTTrophiesRainbowHokey", function(ply, button)
    if not earnedPlatinum or button ~= input.GetKeyCode(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) then return end

    timer.Create("TTTTrophyRainbowToggleCooldown", 0.2, 1, function()
        net.Start("TTTTrophiesRainbowToggle")
        net.SendToServer()
    end)
end)