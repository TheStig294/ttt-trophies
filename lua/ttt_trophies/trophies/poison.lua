local TROPHY = {}
TROPHY.id = "poison"
TROPHY.title = "Oops, wrong button"
TROPHY.desc = "Use a poison potion on yourself"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(attacker) or ply ~= attacker then return end

        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_ttt_mc_poison" then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("weapon_ttt_mc_poison") ~= nil
end

RegisterTTTTrophy(TROPHY)