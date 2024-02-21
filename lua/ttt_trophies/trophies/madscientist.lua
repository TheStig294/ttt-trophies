local TROPHY = {}
TROPHY.id = "madscientist"
TROPHY.title = "Nope, doesn't work!"
TROPHY.desc = "As a Mad Scientist, try to revive someone that's already a zombie"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_MADSCIENTIST

    self:AddHook("TTTMadScientistZombifyBegin", function(ply, tgt)
        if tgt:IsZombie() then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_MADSCIENTIST)
end

RegisterTTTTrophy(TROPHY)