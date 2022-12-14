local TROPHY = {}
TROPHY.id = "headshot"
TROPHY.title = "Boom! Headshot!"
TROPHY.desc = "Kill someone with a headshot to prevent them from making a noise"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        if hitgroup == HITGROUP_HEAD then
            local attacker = dmginfo:GetAttacker()
            if not IsPlayer(attacker) then return end

            timer.Simple(0.1, function()
                if IsValid(ply) and IsValid(attacker) and not self:IsAlive(ply) then
                    self:Earn(attacker)
                end
            end)
        end
    end)
end

function TROPHY:Condition()
    return not ConVarExists("ttt_disable_headshots") or not GetConVar("ttt_disable_headshots"):GetBool()
end

RegisterTTTTrophy(TROPHY)