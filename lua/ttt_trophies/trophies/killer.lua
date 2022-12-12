local TROPHY = {}
TROPHY.id = "killer"
TROPHY.title = "Wait, the Killer can buy stuff?"
TROPHY.desc = "As a Killer, buy an item"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_KILLER

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item)
        if ply:IsKiller() then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_killer_enabled") and GetConVar("ttt_killer_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)