local TROPHY = {}
TROPHY.id = "buyemalltraitor"
TROPHY.title = "Bought 'em all! (Traitor)"
TROPHY.desc = "Buy every traitor item at least once"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    if SERVER then
        util.AddNetworkString("TTTTrophiesBuyEmAllTraitor")
    end

    -- Getting the list of buyable traitor items
    -- At the start of the first round of a map, ask the first connected client for the printnames of all traitor and traitor weapons
    -- Items are sent as ClassNames for active items, and PrintNames for passive items to uniquely identify them
    local traitorBuyable = {}

    -- First check if its on the SWEP list
    for _, v in pairs(weapons.GetList()) do
        if TTTTrophies:IsBuyableItem(ROLE_TRAITOR, v) then
            traitorBuyable[v.ClassName] = true
        end
    end

    -- If its not on the SWEP list, then check the equipment items table
    for _, v in pairs(EquipmentItems[ROLE_TRAITOR]) do
        if TTTTrophies:IsBuyableItem(ROLE_TRAITOR, v) then
            traitorBuyable[v.name] = true
        end
    end

    self:AddHook("TTTRoleWeaponUpdated", function(role, weapon, inc, exc, noRandom)
        if role ~= ROLE_TRAITOR then return end

        if inc then
            traitorBuyable[weapon] = true
        end

        if exc then
            traitorBuyable[weapon] = nil
        end
    end)

    if not TTTTrophies.stats[self.id] then
        TTTTrophies.stats[self.id] = {}
    end

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
                    -- If is_item is truthy but the passed equipment failed to be converted to a number then something went wrong here
                else
                    return
                end

                local item = GetEquipmentItem(ROLE_TRAITOR, equipment)
                if not item then return end
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
                local unboughtCount = #unboughtEquipment
                local noOfBoughtItems = #buyableEquipment - unboughtCount

                if not TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] or noOfBoughtItems ~= TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] then
                    TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] = noOfBoughtItems
                    self:ProgressUpdate(ply, noOfBoughtItems, #buyableEquipment)

                    if unboughtCount <= 5 then
                        net.Start("TTTTrophiesBuyEmAllTraitor")
                        net.WriteUInt(unboughtCount, 4)

                        for _, class in ipairs(unboughtEquipment) do
                            net.WriteString(class)
                        end

                        net.Send(ply)
                    end
                end
            end
        end)
    end)
end

if CLIENT then
    net.Receive("TTTTrophiesBuyEmAllTraitor", function()
        local unboughtCount = net.ReadUInt(4)
        chat.AddText("Unbought items:")

        for i = 1, unboughtCount do
            local class = net.ReadString()
            local wep = weapons.Get(class)

            if wep then
                chat.AddText(LANG.TryTranslation(wep.PrintName) or class)
            else
                chat.AddText(class)
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)