local TROPHY = {}
TROPHY.id = "dreadthrall"
TROPHY.title = "Swiss army knife"
TROPHY.desc = "Use every dread thrall ability, and damage someone using a bone charm"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_DREADTHRALL
    local dreadThrallPowers = {}
    local knifeDamage = {}

    self:AddHook("TTTDreadThrallPowerUsed", function(ply, power)
        if not istable(dreadThrallPowers[ply]) then
            dreadThrallPowers[ply] = {}
        end

        dreadThrallPowers[ply][power] = true

        if table.Count(dreadThrallPowers[ply]) == 3 and knifeDamage[ply] then
            self:Earn(ply)
        end
    end)

    self:AddHook("PostEntityTakeDamage", function(ent, dmg, took)
        if not took or not IsPlayer(ent) then return end
        local inflictor = dmg:GetInflictor()
        local attacker = dmg:GetAttacker()
        if not IsValid(inflictor) or not IsValid(attacker) then return end

        if inflictor:GetClass() == "weapon_thr_bonecharm" then
            knifeDamage[attacker] = true

            if dreadThrallPowers[attacker] and table.Count(dreadThrallPowers[attacker]) == 3 then
                self:Earn(attacker)
            end
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_dreadthrall_enabled") and GetConVar("ttt_dreadthrall_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)