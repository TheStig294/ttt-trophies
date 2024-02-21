local TROPHY = {}
TROPHY.id = "veteran"
TROPHY.title = "All alone..."
TROPHY.desc = "As a Veteran, be the last innocent alive and win"
TROPHY.rarity = 3
TROPHY.hidden = true

function TROPHY:Trigger()
    local veteranAlive

    self:AddHook("DoPlayerDeath", function()
        if GetRoundState() ~= ROUND_ACTIVE then return end

        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                if ply:GetRole() == ROLE_VETERAN then
                    if veteranAlive then
                        veteranAlive = nil

                        return
                    else
                        veteranAlive = ply
                    end
                elseif TTTTrophies:IsInnocentTeam(ply) then
                    veteranAlive = nil

                    return
                end
            end
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if IsValid(veteranAlive) and (result == WIN_INNOCENT or result == WIN_TIMELIMIT) and self:IsAlive(veteranAlive) and veteranAlive:GetRole() == ROLE_VETERAN then
            self:Earn(veteranAlive)
        end

        veteranAlive = nil
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_VETERAN)
end

RegisterTTTTrophy(TROPHY)