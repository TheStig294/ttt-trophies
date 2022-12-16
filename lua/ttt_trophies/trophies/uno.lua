local TROPHY = {}
TROPHY.id = "uno"
TROPHY.title = "no u"
TROPHY.desc = "Kill someone with an uno reverse card"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_DETECTIVE

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) or not IsPlayer(attacker) then return end

        if inflictor:GetClass() == "weapon_unoreverse" then
            self:Earn(attacker)
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("weapon_unoreverse") ~= nil
end

RegisterTTTTrophy(TROPHY)