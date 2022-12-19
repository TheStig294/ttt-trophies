local TROPHY = {}
TROPHY.id = "backwardsshotgun"
TROPHY.title = "Completely impractical"
TROPHY.desc = "As a traitor, get a kill with a backwards shotgun"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(attacker) or not TTTTrophies:IsTraitorTeam(attacker) then return end

        if IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "ttt_backwards_shotgun" then
            self:Earn(attacker)
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("ttt_backwards_shotgun") ~= nil
end

RegisterTTTTrophy(TROPHY)