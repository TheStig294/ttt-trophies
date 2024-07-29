-- All client-side logic related to earning or earned trophies
local chatMessagesCvar = CreateClientConVar("ttt_trophies_chat", "1", true, false, "Whether messages should be printed to chat showing trophy progress or suggesting trophies")

hook.Add("Think", "TTTTrophiesSyncEarned", function()
    if GetGlobalBool("TTTTrophiesClientLoaded") then
        net.Start("TTTRequestEarnedTrophies")
        net.WriteBool(chatMessagesCvar:GetBool())
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
        end
    end

    SetGlobalBool("TTTTrophiesEarnedLoaded", true)
end)

net.Receive("TTTEarnTrophy", function()
    -- This net message is set up before the trophy list, so don't run this before the trophy list is initialised
    if not GetGlobalBool("TTTTrophiesClientLoaded") then return end
    local trophyID = net.ReadString()
    local trophy = TTTTrophies.trophies[trophyID]
    if not trophy then return end
    trophy.earned = true

    -- Turn on a player's rainbow if the trophy earned is the platinum
    if trophy.id == "platinum" then
        timer.Simple(12, function()
            rainbowToggle = true
            chat.AddText(Color(183, 0, 255), "Press '" .. string.upper(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) .. "' to toggle rainbow effect!")
        end)
    end
end)

net.Receive("TTTEarnedTrophiesChatMessage", function()
    -- This net message is set up before the trophy list, so don't run this before the trophy list is initialised
    if not GetGlobalBool("TTTTrophiesClientLoaded") then return end
    if not chatMessagesCvar:GetBool() then return end
    local nick = net.ReadString()
    local id = net.ReadString()
    local trophy = TTTTrophies.trophies[id]
    if not trophy then return end
    local rarityColour

    if trophy.rarity == 1 then
        rarityColour = Color(231, 131, 82)
    elseif trophy.rarity == 2 then
        rarityColour = Color(192, 192, 192)
    elseif trophy.rarity == 3 then
        rarityColour = Color(212, 175, 55)
    elseif trophy.rarity == 4 then
        rarityColour = Color(46, 104, 165)
    end

    chat.AddText(COLOR_YELLOW, nick, COLOR_WHITE, " has earned a trophy ", rarityColour, "[", trophy.title, "]")

    -- Hide descriptions of hidden trophies unless the trophy is earned, or its description is flagged as forced to show
    -- (Some trophies are too hard to discover if all trophy descriptions are hidden)
    if trophy.earned or (not trophy.hidden and not GetGlobalBool("ttt_trophies_hide_all_trophies")) or trophy.forceDesc then
        chat.AddText(COLOR_WHITE, "\"", trophy.desc, "\"")
    end
end)

-- Rainbow guns reward/toggle for chat trophy suggestions
CreateClientConVar("ttt_trophies_hotkey_rainbow", "J", true, false, "Hotkey for toggling trophy chat messages, or rainbow effect if all trophies are earned")

hook.Add("PlayerButtonDown", "TTTTrophiesRainbowHokey", function(ply, button)
    if button ~= input.GetKeyCode(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) then return end

    timer.Create("TTTTrophyRainbowToggleCooldown", 0.2, 1, function()
        if TTTTrophies.trophies.platinum and TTTTrophies.trophies.platinum.earned then
            if rainbowToggle then
                rainbowToggle = false
            else
                rainbowToggle = true
            end

            net.Start("TTTTrophiesRainbowToggle")
            net.WriteBool(true)
            net.SendToServer()
        else
            if chatMessagesCvar:GetBool() then
                chatMessagesCvar:SetBool(false)
                chat.AddText("Trophy chat messages and buy menu icons disabled\n(\"Trophy earned\" popups on the top right will still show)")
            else
                chatMessagesCvar:SetBool(true)
                chat.AddText("Trophy chat messages and buy menu icons enabled")
            end

            net.Start("TTTTrophiesRainbowToggle")
            net.WriteBool(false)
            net.SendToServer()
        end
    end)
end)

-- Changes a player's weapons colours over time
local rainbowPhase = 1
local setInitialColour = false
local mult = 1
local halfMult = mult / 2

hook.Add("PreDrawViewModel", "TTTTrophiesRainbow", function(vm, ply, weapon)
    -- Don't try to do the rainbow effect while a player is disguised, invisible, dead, hasn't earned all trophies yet or has an upgraded weapon
    if not rainbowToggle or ply:IsSpec() or not ply:Alive() or ply:GetRenderMode() ~= RENDERMODE_NORMAL or ply:GetNoDraw() or ply:GetNWBool("disguised", false) or ply:GetMaterial() == "sprites/heatwave" or weapon.PAPUpgrade then
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