local TROPHY = {}
TROPHY.id = "impersonator"
TROPHY.title = "Playing the long game"
TROPHY.desc = "As an Impersonator, search a body and buy a detective item in 1 round"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_IMPERSONATOR
    local boughtItem = {}
    local searchedBody = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item, given_by_randomat)
        if given_by_randomat or not ply:IsImpersonator() then return end
        local detectiveItem = false

        if is_item then
            for _, item in ipairs(EquipmentItems[ROLE_DETECTIVE]) do
                if item.id == equipment then
                    detectiveItem = true
                    break
                end
            end
        else
            local wep = weapons.Get(equipment)

            if table.HasValue(wep.CanBuy, ROLE_DETECTIVE) then
                detectiveItem = true
            end
        end

        if detectiveItem then
            boughtItem[ply] = true

            if searchedBody[ply] then
                self:Earn(ply)
            end
        end
    end)

    self:AddHook("TTTBodyFound", function(ply, deadply, rag)
        if ply:IsImpersonator() then
            searchedBody[ply] = true

            if boughtItem[ply] then
                self:Earn(ply)
            end
        end
    end)

    self:AddHook("TTTEndRound", function()
        table.Empty(boughtItem)
        table.Empty(searchedBody)
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_impersonator_enabled") and GetConVar("ttt_impersonator_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)