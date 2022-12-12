local TROPHY = {}
TROPHY.id = "vampire"
TROPHY.title = "Jack of all trades"
TROPHY.desc = "As a Vampire, use every fangs ability in 1 round"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_VAMPIRE
    local vampireAbilities = {}

    local function AddVampireAbility(ply, ability)
        if not istable(vampireAbilities[ply]) then
            vampireAbilities[ply] = {}
        end

        vampireAbilities[ply][ability] = true

        if table.Count(vampireAbilities[ply]) == 4 then
            self:Earn(ply)
        end
    end

    self:AddHook("TTTVampireBodyEaten", function(ply, ent, living, healed)
        if living then
            AddVampireAbility(ply, "kill")
        else
            AddVampireAbility(ply, "eat")
        end
    end)

    self:AddHook("TTTVampireInvisibilityChange", function(ply, invisible)
        AddVampireAbility(ply, "invisible")
    end)

    self:AddHook("TTTPlayerRoleChangedByItem", function(ply, tgt, item)
        if item:GetClass() == "weapon_vam_fangs" then
            AddVampireAbility(ply, "convert")
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        table.Empty(vampireAbilities)
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_vampire_enabled") and GetConVar("ttt_vampire_enabled"):GetBool() and GetConVar("ttt_vampire_convert_enable"):GetBool()
end

RegisterTTTTrophy(TROPHY)