local TROPHY = {}
TROPHY.id = "mercenary"
TROPHY.title = "See? I'm not a traitor!"
TROPHY.desc = "As a Mercenary, kill a traitor using a weapon you bought"
TROPHY.rarity = 1
TROPHY.hidden = true

function TROPHY:Trigger()
    local boughtItems = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item, given_by_randomat)
        if given_by_randomat then return end

        if ply:GetRole() == ROLE_MERCENARY and not is_item then
            if not boughtItems[ply] then
                boughtItems[ply] = {}
            end

            boughtItems[ply][equipment] = true
        end
    end)

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(attacker) then return end
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) then return end
        local activeWeapon = attacker:GetActiveWeapon()

        if attacker:GetRole() == ROLE_MERCENARY and TTTTrophies:IsTraitorTeam(ply) and boughtItems[attacker] then
            if IsValid(inflictor) and boughtItems[attacker][inflictor:GetClass()] then
                self:Earn(attacker)
            elseif IsValid(activeWeapon) and boughtItems[attacker][activeWeapon:GetClass()] then
                self:Earn(attacker)
            end
        end
    end)

    self:AddHook("TTTPrepareRound", function()
        table.Empty(boughtItems)
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_MERCENARY)
end

RegisterTTTTrophy(TROPHY)