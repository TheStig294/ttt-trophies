local TROPHY = {}
TROPHY.id = "buyemalltraitor"
TROPHY.title = "Gotta buy 'em all! (Traitor)"
TROPHY.desc = "Buy every traitor item at least once"
TROPHY.rarity = 3

if CLIENT then
    net.Receive("TTTTrophies_TraitorWeaponsList", function()
        local excludeWepsExist = istable(WEPS.ExcludeWeapons) and istable(WEPS.ExcludeWeapons[ROLE_TRAITOR])
        local includeWepsExist = istable(WEPS.BuyableWeapons) and istable(WEPS.BuyableWeapons[ROLE_TRAITOR])

        -- First check if its on the SWEP list
        for _, v in pairs(weapons.GetList()) do
            if TTTTrophies:IsBuyableItem(ROLE_TRAITOR, v, includeWepsExist, excludeWepsExist) then
                net.Start("TTTTrophies_SendTraitorEquipment")
                net.WriteString(v.ClassName)
                net.SendToServer()
            end
        end

        -- If its not on the SWEP list, then check the equipment items table
        for _, v in pairs(EquipmentItems[ROLE_TRAITOR]) do
            if TTTTrophies:IsBuyableItem(ROLE_TRAITOR, v, includeWepsExist, excludeWepsExist) then
                net.Start("TTTTrophies_SendTraitorEquipment")
                net.WriteString(v.name)
                net.SendToServer()
            end
        end
    end)
end

function TROPHY:Trigger()
    if not TTTTrophies.stats[self.id] then
        TTTTrophies.stats[self.id] = {}
    end

    -- Getting the list of buyable traitor items
    -- At the start of the first round of a map, ask the first connected client for the printnames of all traitor and traitor weapons
    -- Passive items are stored by their item ids
    util.AddNetworkString("TTTTrophies_TraitorWeaponsList")
    util.AddNetworkString("TTTTrophies_SendTraitorEquipment")

    self:AddHook("TTTBeginRound", function()
        net.Start("TTTTrophies_TraitorWeaponsList")
        net.Send(Entity(1))
        self:RemoveHook("TTTBeginRound")
    end)

    local traitorBuyable = {}

    net.Receive("TTTTrophies_SendTraitorEquipment", function(len, ply)
        local name = net.ReadString()
        traitorBuyable[name] = true
    end)

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item, given_by_randomat)
        if TTTTrophies.earned[ply:SteamID()] and TTTTrophies.earned[ply:SteamID()][self.plyID] then return end

        timer.Simple(0.1, function()
            -- Items given by randomats aren't bought by the player, so they shouldn't count
            if given_by_randomat or GetGlobalBool("DisableRandomatStats") or not IsValid(ply) then return end
            if not TTTTrophies:IsTraitorTeam(ply) then return end
            -- Recording the item as bought
            local plyID = ply:SteamID()

            -- If an item is a passive item, then the passed item id in the equipment parameter needs to be converted to the item's print name
            -- This is so as items are uninstalled/reinstalled old items don't count as bought for new items and vice-versa, as item ids change
            if is_item then
                equipment = tonumber(equipment)

                if equipment then
                    equipment = math.floor(equipment)
                else
                    -- If is_item is truthy but the passed equipment failed to be converted to a number then something went wrong here
                    return
                end

                local item = GetEquipmentItem(ROLE_TRAITOR, equipment)
                -- Don't count loadout items towards stats
                if item.loadout then return end

                if item and item.name then
                    if not TTTTrophies.stats[self.id][plyID] then
                        TTTTrophies.stats[self.id][plyID] = {}
                    end

                    TTTTrophies.stats[self.id][plyID][item.name] = true
                end
            else
                -- Active items are indexed by their classname, which this hook passes by itself
                if not TTTTrophies.stats[self.id][plyID] then
                    TTTTrophies.stats[self.id][plyID] = {}
                end

                TTTTrophies.stats[self.id][plyID][equipment] = true
            end

            local buyableEquipment = table.GetKeys(traitorBuyable)
            local equipmentStats = table.Copy(TTTTrophies.stats[self.id][plyID])
            local boughtEquipment = table.GetKeys(equipmentStats)
            local unboughtEquipment = table.Copy(buyableEquipment)

            -- Remove all bought weapons from the unboughtEquipment table
            -- Doing it this way avoids counting traitor items that have been since removed from the server counting towards the total number bought
            for _, equ in ipairs(boughtEquipment) do
                table.RemoveByValue(unboughtEquipment, equ)
            end

            if table.IsEmpty(unboughtEquipment) or unboughtEquipment == {} then
                self:Earn(ply)
            else
                -- Only show progress towards the trophy if the number of traitor items bought has changed
                local noOfBoughtItems = #buyableEquipment - #unboughtEquipment

                if not TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] or noOfBoughtItems ~= TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] then
                    TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] = noOfBoughtItems
                    self:ProgressUpdate(ply, noOfBoughtItems, #buyableEquipment)
                end
            end
        end)
    end)
end

RegisterTTTTrophy(TROPHY)