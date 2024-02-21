local TROPHY = {}
TROPHY.id = "assassin"
TROPHY.title = "Oh no! Anyway..."
TROPHY.desc = "As an Assassin, win the round after breaking your contract"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_ASSASSIN
    local failedAssassin = {}

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        timer.Simple(0.1, function()
            if not IsPlayer(attacker) then return end

            if attacker:IsAssassin() and attacker:GetNWBool("AssassinFailed") then
                failedAssassin[attacker] = true
            end
        end)
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, _ in pairs(failedAssassin) do
                self:Earn(ply)
            end
        end

        table.Empty(failedAssassin)
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_ASSASSIN)
end

RegisterTTTTrophy(TROPHY)