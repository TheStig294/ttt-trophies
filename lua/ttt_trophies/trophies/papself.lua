local TROPHY = {}
TROPHY.id = "papself"
TROPHY.title = "Quake Pro"
TROPHY.desc = "Pack-a-Punch yourself!"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_DETECTIVE

    self:AddHook("TTTPAPOrder", function(ply, SWEP, UPGRADE)
        if not IsValid(SWEP) then return end
        local class = WEPS.GetClass(SWEP)

        if class == "weapon_ttt_unarmed" then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return TTTPAP and TTTPAP.OrderPAP
end

RegisterTTTTrophy(TROPHY)