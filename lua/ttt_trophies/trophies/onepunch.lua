local TROPHY = {}
TROPHY.id = "onepunch"
TROPHY.title = "Don't worry, it's the detective"
TROPHY.desc = "See a detective equip a One Punch"
TROPHY.rarity = 1
TROPHY.hidden = true

function TROPHY:Trigger()
    self:AddHook("PlayerSwitchWeapon", function(ply, oldWep, newWep)
        if TTTTrophies:IsGoodDetectiveLike(ply) and IsValid(newWep) and newWep:GetClass() == "weapon_ttt_one_punch" then
            self:Earn(player.GetAll())
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("weapon_ttt_one_punch")
end

RegisterTTTTrophy(TROPHY)