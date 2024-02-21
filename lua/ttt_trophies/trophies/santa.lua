local TROPHY = {}
TROPHY.id = "santa"
TROPHY.title = "Naughty list"
TROPHY.desc = "As a Santa, kill a traitor with a coal piece by right-clicking"
TROPHY.rarity = 3
TROPHY.forceDesc = true

function TROPHY:Trigger()
    self.roleMessage = ROLE_SANTA

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsValid(dmg:GetInflictor()) or not IsPlayer(attacker) then return end

        if dmg:GetInflictor():GetClass() == "ttt_santa_coal" and attacker:IsSanta() and TTTTrophies:IsTraitorTeam(ply) then
            self:Earn(attacker)
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_SANTA)
end

RegisterTTTTrophy(TROPHY)