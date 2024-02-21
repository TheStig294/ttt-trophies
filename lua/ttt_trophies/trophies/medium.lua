local TROPHY = {}
TROPHY.id = "medium"
TROPHY.title = "Trust the ghosts?"
TROPHY.desc = "As a Medium, kill a traitor while a dead player is near them"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_MEDIUM

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(attacker) or not attacker:IsMedium() or not TTTTrophies:IsTraitorTeam(ply) then return end
        local entTbl = ents.FindInSphere(ply:GetPos(), 100)

        for _, ent in ipairs(entTbl) do
            if IsPlayer(ent) and not self:IsAlive(ent) and ent ~= ply then
                self:Earn(attacker)

                return
            end
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_MEDIUM)
end

RegisterTTTTrophy(TROPHY)