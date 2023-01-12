local TROPHY = {}
TROPHY.id = "oops"
TROPHY.title = "Oops..."
TROPHY.desc = "Die before the round has even started"
TROPHY.rarity = 1
TROPHY.hidden = true

function TROPHY:Trigger()
    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if GetRoundState() == ROUND_PREP then
            self:Earn(ply)
        end
    end)
end

RegisterTTTTrophy(TROPHY)