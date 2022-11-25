local TROPHY = {}
TROPHY.id = "dna"
TROPHY.title = "Wait, this thing is useful?"
TROPHY.desc = "As a Detective, use your DNA Scanner on a body to track their killer"
TROPHY.rarity = 1
TROPHY.roleSpecific = ROLE_DETECTIVE

function TROPHY:Trigger()
    self:AddHook("TTTFoundDNA", function(ply, dna_owner, ent)
        if TTTTrophies:IsGoodDetectiveLike(ply) then
            self:Earn(ply)
        end
    end)
end

RegisterTTTTrophy(TROPHY)