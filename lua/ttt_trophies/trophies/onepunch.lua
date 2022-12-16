local TROPHY = {}
TROPHY.id = "onepunch"
TROPHY.title = "Don't worry, it's the detective"
TROPHY.desc = "See a detective equip a One Punch"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self:AddHook("PlayerSwitchWeapon", function(ply, oldWep, newWep)
        if TTTTrophies:IsGoodDetectiveLike(ply) and IsValid(newWep) and newWep:GetClass() == "one_punch_skin" then
            self:Earn(player.GetAll())
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("one_punch_skin")
end

RegisterTTTTrophy(TROPHY)