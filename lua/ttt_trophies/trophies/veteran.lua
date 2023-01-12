local TROPHY = {}
TROPHY.id = "veteran"
TROPHY.title = "All alone..."
TROPHY.desc = "As a Veteran, be the last innocent alive"
TROPHY.rarity = 3
TROPHY.hidden = true

function TROPHY:Trigger()
    self:AddHook("DoPlayerDeath", function()
        if GetRoundState() ~= ROUND_ACTIVE then return end
        local veteranAlive

        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                if ply:GetRole() == ROLE_VETERAN then
                    if veteranAlive then return end
                    veteranAlive = ply
                elseif TTTTrophies:IsInnocentTeam(ply) then
                    return
                end
            end
        end

        if veteranAlive then
            self:Earn(veteranAlive)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_veteran_enabled") and GetConVar("ttt_veteran_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)