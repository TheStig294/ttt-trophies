local TROPHY = {}
TROPHY.id = "zombie"
TROPHY.title = "Zombies can buy stuff?"
TROPHY.desc = "As a Zombie, buy an item"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_ZOMBIE

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item)
        if ply:IsZombie() then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_zombie_enabled") and GetConVar("ttt_zombie_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)