local TROPHY = {}
TROPHY.id = "innocent"
TROPHY.title = "Clean kills"
TROPHY.desc = "As an Innocent, kill at least 2 traitors without damaging an innocent in 1 round"
TROPHY.rarity = 2

function TROPHY:Trigger()
    local killedTraitor = {}
    local killed2Traitors = {}

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if TTTTrophies:IsInnocentTeam(attacker) and TTTTrophies:IsTraitorTeam(ply) then
            if killedTraitor[attacker] then
                killed2Traitors[attacker] = true
            end

            killedTraitor[attacker] = true
        end
    end)

    local damagedInnocent = {}

    self:AddHook("PostEntityTakeDamage", function(ent, dmg, took)
        if not took or not IsPlayer(ent) then return end
        local attacker = dmg:GetAttacker()
        if not IsPlayer(attacker) then return end

        if TTTTrophies:IsInnocentTeam(attacker) and TTTTrophies:IsInnocentTeam(ent) then
            damagedInnocent[attacker] = true
        end
    end)

    self:AddHook("TTTEndRound", function()
        for ply, value in pairs(killed2Traitors) do
            if not damagedInnocent[ply] then
                self:Earn(ply)
            end
        end

        table.Empty(killedTraitor)
        table.Empty(killed2Traitors)
        table.Empty(damagedInnocent)
    end)
end

RegisterTTTTrophy(TROPHY)