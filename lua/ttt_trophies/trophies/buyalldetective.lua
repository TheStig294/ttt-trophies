local TROPHY = {}
TROPHY.id = "buyalldetective"
TROPHY.title = "Gotta buy 'em all! (Detective)"
TROPHY.desc = "Buy every detective item at least once"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item, given_by_randomat)
        if TTTTrophies.earned[ply:SteamID()] and TTTTrophies.earned[ply:SteamID()][self.id] then return end

        timer.Simple(0.1, function()
            -- Items given by randomats aren't bought by the player, so they shouldn't count
            if given_by_randomat or GetGlobalBool("DisableRandomatStats") or not IsValid(ply) then return end
            if not TTTTrophies:IsDetectiveLike(ply) then return end
            -- Using the stats data from my "100 More Randomats!" mod, if that mod isn't installed this hook won't be set and this trophy won't exist
            local stats = randomatPlayerStats
            -- Functionality of GetDetectiveBuyable() can be found in stig_randomat_base_functions.lua and stig_randomat_client_functions.lua
            local detectiveBuyable = GetDetectiveBuyable()
            local buyableEquipment = table.GetKeys(detectiveBuyable)
            local ID = ply:SteamID()
            local equipmentStats = table.Copy(stats[ID]["EquipmentItems"])
            local boughtEquipment = table.GetKeys(equipmentStats)
            local unboughtEquipment = table.Copy(buyableEquipment)

            for i, equ in ipairs(unboughtEquipment) do
                local item = tonumber(equ)
                if not item then continue end
                item = math.floor(item)
                local itemTable = GetEquipmentItem(ROLE_DETECTIVE, item)

                if itemTable and itemTable.name then
                    unboughtEquipment[i] = itemTable.name
                end
            end

            -- Remove all bought weapons from the unboughtEquipment table
            for _, equ in ipairs(boughtEquipment) do
                table.RemoveByValue(unboughtEquipment, equ)
            end

            if table.IsEmpty(unboughtEquipment) or unboughtEquipment == {} then
                self:Earn(ply)
            elseif #unboughtEquipment <= 10 then
                self:ProgressUpdate(ply, #boughtEquipment, #buyableEquipment)
            end
        end)
    end)
end

function TROPHY:Condition()
    return isfunction(GetDetectiveBuyable)
end

RegisterTTTTrophy(TROPHY)