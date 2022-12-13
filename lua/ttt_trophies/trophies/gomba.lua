local TROPHY = {}
TROPHY.id = "gomba"
TROPHY.title = "Gomba stomp!"
TROPHY.desc = "Damage someone by landing on top of them"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("EntityTakeDamage", function(ent, dmg)
        if not IsPlayer(ent) then return end
        local attacker = dmg:GetAttacker()
        local inflictor = dmg:GetInflictor()
        if not IsPlayer(attacker) or not IsPlayer(inflictor) then return end

        if dmg:IsDamageType(DMG_CRUSH) then
            self:Earn(attacker)
        end
    end)
end

RegisterTTTTrophy(TROPHY)