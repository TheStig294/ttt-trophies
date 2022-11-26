-- All client-side logic related to earning or earned trophies
hook.Add("Think", "TTTTrophiesSyncEarned", function()
    if GetGlobalBool("TTTTrophiesClientLoaded") then
        net.Start("TTTRequestEarnedTrophies")
        net.SendToServer()
        hook.Remove("Think", "TTTTrophiesSyncEarned")
    end
end)

local rainbowToggle

net.Receive("TTTSendEarnedTrophies", function()
    local count = net.ReadUInt(16)
    rainbowToggle = net.ReadBool()

    for i = 1, count do
        local trophyID = net.ReadString()
        local trophy = TTTTrophies.trophies[trophyID]
        -- Need to skip over the player's name saved in the earned trophies stats file, or anything else in the earned trophies file that isn't on the trophies list
        if not trophy then continue end
        trophy.earned = true

        if trophy.id == "platinum" then
            chat.AddText("Press '" .. string.upper(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) .. "' to toggle rainbow effect")
            rainbowToggle = true
        end
    end

    SetGlobalBool("TTTTrophiesEarnedLoaded", true)
end)

net.Receive("TTTEarnTrophy", function()
    local trophyID = net.ReadString()
    local trophy = TTTTrophies.trophies[trophyID]
    trophy.earned = true

    -- Turn on a player's rainbow if the trophy earned is the platinum
    if trophy.id == "platinum" then
        timer.Simple(9, function()
            rainbowToggle = true
            chat.AddText(Color(183, 0, 255), "Press '" .. string.upper(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) .. "' to toggle rainbow effect!")
        end)
    end
end)

-- Rainbow guns reward
CreateClientConVar("ttt_trophies_hotkey_rainbow", "J", true, false, "Hotkey for toggling rainbow effect")

hook.Add("PlayerButtonDown", "TTTTrophiesRainbowHokey", function(ply, button)
    if not TTTTrophies.trophies.platinum or not TTTTrophies.trophies.platinum.earned or button ~= input.GetKeyCode(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) then return end

    timer.Create("TTTTrophyRainbowToggleCooldown", 0.2, 1, function()
        if rainbowToggle then
            rainbowToggle = false
        else
            rainbowToggle = true
        end

        net.Start("TTTTrophiesRainbowToggle")
        net.SendToServer()
    end)
end)

-- Changes a player's weapons colours over time
local rainbowPhase = 1
local setInitialColour = false
local mult = 1
local halfMult = mult / 2

hook.Add("PreDrawViewModel", "TTTTrophiesRainbow", function(vm, ply, weapon)
    -- Don't try to do the rainbow effect while a player hasn't earned all trophies yet
    if not rainbowToggle or ply:IsSpec() or not ply:Alive() or ply:GetRenderMode() ~= RENDERMODE_NORMAL or ply:GetNoDraw() or ply:GetNWBool("disguised", false) or ply:GetMaterial() == "sprites/heatwave" then
        vm:SetColor(COLOR_WHITE)

        return
    end

    if not setInitialColour then
        vm:SetColor(COLOR_WHITE)
        setInitialColour = true
    end

    local colour = vm:GetColor()

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

    vm:SetColor(colour)
end)