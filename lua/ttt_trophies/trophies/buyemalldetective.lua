local TROPHY = {}
TROPHY.id = "buyemalldetective"
TROPHY.title = "Bought 'em all! (Detective)"
TROPHY.desc = "Buy every detective item at least once"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_DETECTIVE
    util.AddNetworkString("TTTTrophiesBuyEmAllDetectiveGetUnbought")
    util.AddNetworkString("TTTTrophiesBuyEmAllDetectiveSendUnbought")
    -- Getting the list of buyable detective items
    -- At the start of the first round of a map, ask the first connected client for the printnames of all detective and detective weapons
    -- Items are sent as ClassNames for active items, and PrintNames for passive items to uniquely identify them
    local detectiveBuyable = {}

    -- First check if its on the SWEP list
    for _, v in pairs(weapons.GetList()) do
        if TTTTrophies:IsBuyableItem(ROLE_DETECTIVE, v) then
            detectiveBuyable[v.ClassName] = true
        end
    end

    -- If its not on the SWEP list, then check the equipment items table
    -- Because TTT2 passes a string ID for passive items, we can actually use the ID of an item to uniquely identify it
    -- (For once a win for TTT2...)
    if TTT2 then
        for _, equ in ipairs(items.GetList()) do
            if TTTTrophies:IsBuyableItem(ROLE_DETECTIVE, equ) then
                detectiveBuyable[equ.id] = true
            end
        end
    else
        for _, equ in ipairs(EquipmentItems[ROLE_DETECTIVE]) do
            if TTTTrophies:IsBuyableItem(ROLE_DETECTIVE, equ) then
                detectiveBuyable[equ.name] = true
            end
        end
    end

    self:AddHook("TTTRoleWeaponUpdated", function(role, weapon, inc, exc, noRandom)
        if role ~= ROLE_DETECTIVE then return end

        if inc then
            detectiveBuyable[weapon] = true
        end

        if exc then
            detectiveBuyable[weapon] = nil
        end
    end)

    if not TTTTrophies.stats[self.id] then
        TTTTrophies.stats[self.id] = {}
    end

    local function GetUnboughtEquipment(plyID)
        local buyableEquipment = table.GetKeys(detectiveBuyable)
        local equipmentStats = table.Copy(TTTTrophies.stats[self.id][plyID])
        local boughtEquipment = {}

        if equipmentStats then
            boughtEquipment = table.GetKeys(equipmentStats)
        end

        local unboughtEquipment = table.Copy(buyableEquipment)

        -- Remove all bought weapons from the unboughtEquipment table
        -- Doing it this way avoids counting detective items that have been since removed from the server counting towards the total number bought
        for _, equ in ipairs(boughtEquipment) do
            table.RemoveByValue(unboughtEquipment, equ)
        end

        local noOfBuyableEquipment = #buyableEquipment
        local noOfBoughtItems = noOfBuyableEquipment - #unboughtEquipment

        return unboughtEquipment, noOfBoughtItems, noOfBuyableEquipment
    end

    self:AddHook("TTTOrderedEquipment", function(ply, equipment, is_item, given_by_randomat)
        local plyID = ply:SteamID()
        if TTTTrophies.earned[plyID] and TTTTrophies.earned[plyID][self.id] then return end

        timer.Simple(0.1, function()
            -- Items given by randomats aren't bought by the player, so they shouldn't count
            if given_by_randomat or GetGlobalBool("DisableRandomatStats") or not IsValid(ply) then return end
            if not TTTTrophies:IsDetectiveLike(ply) then return end

            -- Recording the item as bought
            -- If an item is a passive item, then the passed item id in the equipment parameter needs to be converted to the item's print name
            -- This is so as items are uninstalled/reinstalled old items don't count as bought for new items and vice-versa, as item ids change
            if is_item and not TTT2 then
                equipment = tonumber(equipment)

                if equipment then
                    equipment = math.floor(equipment)
                    -- If is_item is truthy but the passed equipment failed to be converted to a number then something went wrong here
                else
                    return
                end

                local item = GetEquipmentItem(ROLE_DETECTIVE, equipment)
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

                -- If TTT2 passes an item with a number ID, we have to convert it into its TTT2 string ID equivalent
                -- (to ensure IDs don't change as passive items are added or removed from the server)
                if is_item and TTT2 and tonumber(equipment) then
                    for _, item in ipairs(items.GetList()) do
                        local oldID = item.oldId

                        if oldID and oldID == equipment then
                            equipment = item.id
                            break
                        end
                    end
                end

                TTTTrophies.stats[self.id][plyID][equipment] = true
            end

            local unboughtEquipment, noOfBoughtItems, noOfBuyableEquipment = GetUnboughtEquipment(plyID)

            if table.IsEmpty(unboughtEquipment) or unboughtEquipment == {} then
                self:Earn(ply)
                -- Only show progress towards the trophy if the number of detective items bought has changed
            elseif not TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] or noOfBoughtItems ~= TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] then
                TTTTrophies.stats[self.id][plyID]["___noOfBoughtItems"] = noOfBoughtItems
                self:ProgressUpdate(ply, noOfBoughtItems, noOfBuyableEquipment)

                if #unboughtEquipment < 5 then
                    for _, equ in ipairs(unboughtEquipment) do
                        TTTTrophies:PrintWeaponName(equ, ply)
                    end
                end
            end
        end)
    end)

    net.Receive("TTTTrophiesBuyEmAllDetectiveGetUnbought", function(_, ply)
        local unboughtEquipment, noOfBoughtItems, noOfBuyableEquipment = GetUnboughtEquipment(ply:SteamID())
        local noOfUnboughtEquipment = #unboughtEquipment

        -- Only start adding icons to the buy menu if the player has bought at least half of all items in the buy menu before
        -- and they haven't bought all of them, in which case no icons would be added anyway
        if noOfBuyableEquipment > 0 and noOfBoughtItems / noOfBuyableEquipment >= 0.5 and noOfUnboughtEquipment > 0 then
            net.Start("TTTTrophiesBuyEmAllDetectiveSendUnbought")
            net.WriteUInt(noOfUnboughtEquipment, 8)

            for _, id in ipairs(unboughtEquipment) do
                net.WriteString(id)
            end

            net.Send(ply)
        end
    end)
end

if CLIENT then
    -- 
    -- Adding icons to the buy menu to show if a weapon is unbought or not
    -- 
    hook.Add("PostGamemodeLoaded", "TTTTrophiesBuyEmAllDetective", function()
        -- Travels down the panel hierarchy of the buy menu, and returns a table of all buy menu icons
        local function GetItemIconPanels(dsheet)
            if not dsheet then return end
            local panelHierachy

            -- The way the buy menu panels are laid out depends on what version of TTT you are using
            -- In Custom Roles, the search bar is in the way, on the main dsheet on the left hand side
            -- In the regular Better Equipment Menu UI, and TTT2, the search bar is on the right hand side, a different panel to the main dsheet
            -- First index is the scroll panel child, the second index is the "Equipment Items" child, its children are all of the buy menu icons
            -- A table of the children of that panel is returned (The buy menu icons)
            if CR_VERSION then
                panelHierachy = {2, 1}
            else
                panelHierachy = {1, 1}
            end

            local buyMenu

            for _, tab in ipairs(dsheet:GetItems()) do
                if tab.Name == "Order Equipment" then
                    buyMenu = tab.Panel
                    break
                end
            end

            if not buyMenu then return end
            buyMenu = buyMenu:GetChildren()

            -- From here, things get unavoidably arbitrary
            -- Hopefully Panel:GetChildren() always returns these child panels the same way every time since they don't have any sort of ID
            -- Being super careful here to check for nil or empty table values at each step,
            -- since Gmod store skins or future updates for the buy menu could render it unusable otherwise
            for _, childIndex in ipairs(panelHierachy) do
                if not buyMenu or table.IsEmpty(buyMenu) then return end
                buyMenu = buyMenu[childIndex]
                if not buyMenu then return end
                buyMenu = buyMenu:GetChildren()
            end

            return buyMenu
        end

        local mainBuyMenuPanel

        hook.Add("TTTEquipmentTabs", "TTTTrophiesAddBuyMenuIconsDetective", function(dsheet)
            -- Don't ask the server for unbought items if this trophy has been disabled
            -- (This also then prevents any icons from being added, since there's then no need)
            -- Also disable icons if the player has disabled trophy chat messages since they likely aren't interested in hunting trophies
            if not GetGlobalBool("trophies_buyemalldetective") or not TTTTrophies.trophies.buyemalldetective or TTTTrophies.trophies.buyemalldetective.earned or not TTTTrophies:IsDetectiveLike(LocalPlayer()) or not GetConVar("ttt_trophies_chat"):GetBool() then return end
            mainBuyMenuPanel = dsheet
            net.Start("TTTTrophiesBuyEmAllDetectiveGetUnbought")
            net.SendToServer()
        end)

        net.Receive("TTTTrophiesBuyEmAllDetectiveSendUnbought", function()
            -- If the player has closed the buy menu in the time it takes for the server to respond with the list of unbought items, then don't do anything
            if not mainBuyMenuPanel or not mainBuyMenuPanel.GetItems then return end
            local unboughtEquipment = {}
            local noOfUnboughtEquipment = net.ReadUInt(8)
            if noOfUnboughtEquipment == 0 then return end

            for i = 1, noOfUnboughtEquipment do
                unboughtEquipment[net.ReadString()] = true
            end

            -- First traverse down the buy menu panel hierarchy
            local itemIcons = GetItemIconPanels(mainBuyMenuPanel)
            if not itemIcons or table.IsEmpty(itemIcons) then return end

            -- Now we've finally made it, start looping through the buy menu icons
            -- Then create the icons, either showing unbought, or not unbought, whichever adds less icons
            for _, iconPanel in ipairs(itemIcons) do
                if not iconPanel.item or (not iconPanel.item.id and not iconPanel.item.name) then return end
                local unbought = unboughtEquipment[iconPanel.item.id] or unboughtEquipment[iconPanel.item.name]
                if not unbought then continue end
                local icon = vgui.Create("DImage")
                icon:SetImage("ttt_trophies/gold16.png")
                icon:SetTooltip("Never Bought")
                -- Set the icon to be faded if the buy menu icon is faded (e.g. weapon is not re-buyable)
                icon:SetImageColor(iconPanel.Icon:GetImageColor())

                -- This is how other overlayed icons are done in vanilla TTT, so we do the same here
                -- This normally used for the slot icon and custom item icon
                icon.PerformLayout = function(s)
                    s:AlignTop(4)
                    s:CenterHorizontal()
                    s:SetSize(16, 16)
                end

                -- Vanilla TTT doesn't support adding icons onto passive items, so we have to add the required functions ourselves...
                if not iconPanel.AddLayer then
                    iconPanel.Layers = {}

                    function iconPanel:AddLayer(pnl)
                        if not IsValid(pnl) then return end
                        pnl:SetParent(self)
                        pnl:SetMouseInputEnabled(false)
                        pnl:SetKeyboardInputEnabled(false)
                        table.insert(self.Layers, pnl)
                    end

                    function iconPanel:PerformLayout()
                        if self.animPress:Active() then return end
                        self:SetSize(self.m_iIconSize, self.m_iIconSize)
                        self.Icon:StretchToParent(0, 0, 0, 0)

                        for _, p in ipairs(self.Layers) do
                            p:SetPos(0, 0)
                            p:InvalidateLayout()
                        end
                    end

                    function iconPanel:EnableMousePassthrough(pnl)
                        for _, p in pairs(self.Layers) do
                            if p == pnl then
                                p.OnMousePressed = function(s, mc)
                                    s:GetParent():OnMousePressed(mc)
                                end

                                p.OnCursorEntered = function(s)
                                    s:GetParent():OnCursorEntered()
                                end

                                p.OnCursorExited = function(s)
                                    s:GetParent():OnCursorExited()
                                end

                                p:SetMouseInputEnabled(true)
                            end
                        end
                    end
                end

                iconPanel:AddLayer(icon)
                iconPanel:EnableMousePassthrough(icon)
            end
        end)
    end)
end

RegisterTTTTrophy(TROPHY)