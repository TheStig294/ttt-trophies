local TROPHY = {}
TROPHY.id = "traitor"
TROPHY.title = "CoD but hide-and-seek!"
TROPHY.desc = "As a traitor, win a round without taking damage and killing at least 1 innocent"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR
    local takenDamage = {}
    local innocentKill = {}

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(attacker) then return end

        if TTTTrophies:IsTraitorTeam(attacker) and TTTTrophies:IsInnocentTeam(ply) then
            innocentKill[attacker] = true
        end
    end)

    self:AddHook("PostEntityTakeDamage", function(ent, dmg, took)
        if not IsPlayer(ent) or not took then return end
        takenDamage[ent] = true
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, _ in pairs(innocentKill) do
                if not takenDamage[ply] then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(takenDamage)
        table.Empty(innocentKill)
    end)
end

RegisterTTTTrophy(TROPHY)