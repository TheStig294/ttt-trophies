local TROPHY = {}
TROPHY.id = "randomitems"
TROPHY.title = "Random item button?"
TROPHY.desc = "As a detective, win only using items bought with the \"buy random item\" button"
TROPHY.rarity = 2

if CLIENT then
    hook.Add("TTTShopRandomBought", "TTTTrophiesBoughtRandomItem", function(client, item)
        if not TTTTrophies:IsGoodDetectiveLike(client) then return end
        net.Start("TTTTrophiesBoughtRandomItem")
        net.WriteString(tostring(item.id))
        net.SendToServer()
    end)
end

function TROPHY:Trigger()
    self.roleMessage = ROLE_DETECTIVE
    util.AddNetworkString("TTTTrophiesBoughtRandomItem")
    local randomItemsBought = {}

    net.Receive("TTTTrophiesBoughtRandomItem", function(len, ply)
        local item = net.ReadString()

        if not randomItemsBought[ply] then
            randomItemsBought[ply] = {}
        end

        randomItemsBought[ply][item] = true
    end)

    local itemsBought = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive, given_by_randomat)
        if given_by_randomat or not TTTTrophies:IsGoodDetectiveLike(ply) then return end

        -- Don't count loadout items as bought
        if passive then
            local passiveItem = GetEquipmentItem(ply:GetRole(), equ)
            if not passiveItem then return end
            if passiveItem.loadout == true then return end
        end

        if not itemsBought[ply] then
            itemsBought[ply] = {}
        end

        itemsBought[ply][tostring(equ)] = true
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_INNOCENT or result == WIN_TIMELIMIT then
            for _, ply in ipairs(player.GetAll()) do
                if not randomItemsBought[ply] or not TTTTrophies:IsGoodDetectiveLike(ply) then continue end
                local earnedTrophy = true

                for item, _ in pairs(itemsBought[ply]) do
                    if not randomItemsBought[ply][item] then
                        earnedTrophy = false
                        break
                    end
                end

                if earnedTrophy then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(randomItemsBought)
        table.Empty(itemsBought)
    end)
end

function TROPHY:Condition()
    return CR_VERSION
end

RegisterTTTTrophy(TROPHY)