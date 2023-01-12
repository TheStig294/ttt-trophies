local TROPHY = {}
TROPHY.id = "gamemode"
TROPHY.title = "Wait, what are we playing?"
TROPHY.desc = "Though the randomat, win a round where you aren't playing TTT!"
TROPHY.rarity = 2

local gamemodeEvents = {
    ["murder"] = true,
    ["prophunt"] = true,
    ["amongus"] = true,
    ["deathmatch"] = true,
    ["battleroyale"] = true,
    ["battleroyale2"] = true
}

function TROPHY:Trigger()
    local eventTriggered = false

    self:AddHook("TTTRandomatTriggered", function(id, owner)
        if gamemodeEvents[id] then
            eventTriggered = true
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if eventTriggered then
            if result == WIN_TRAITOR then
                for _, ply in ipairs(player.GetAll()) do
                    if self:IsAlive(ply) and TTTTrophies:IsTraitorTeam(ply) then
                        self:Earn(ply)
                    end
                end
            else
                for _, ply in ipairs(player.GetAll()) do
                    if self:IsAlive(ply) then
                        self:Earn(ply)
                    end
                end
            end
        end

        eventTriggered = false
    end)
end

function TROPHY:Condition()
    if not Randomat then return false end

    for event, _ in pairs(gamemodeEvents) do
        if ConVarExists("ttt_randomat_" .. event) and GetConVar("ttt_randomat_" .. event):GetBool() then return true end
    end

    return false
end

RegisterTTTTrophy(TROPHY)