local TROPHY = {}
TROPHY.id = "quack"
TROPHY.title = "A lesson in trickery..."
TROPHY.desc = "As a Quack, kill someone using a bomb station"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_QUACK

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) then return end

        if inflictor:GetClass() == "ttt_bomb_station" then
            local placer = inflictor:GetPlacer()

            if IsPlayer(placer) then
                self:Earn(placer)
            end
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_quack_enabled") and GetConVar("ttt_quack_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)