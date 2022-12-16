local TROPHY = {}
TROPHY.id = "madscientist"
TROPHY.title = "Nope, doesn't work!"
TROPHY.desc = "As a Mad Scientist, try to revive someone that's already a zombie"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self:AddHook("TTTMadScientistZombifyBegin", function(ply, tgt)
        if tgt:IsZombie() then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_madscientist_enabled") and GetConVar("ttt_madscientist_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)