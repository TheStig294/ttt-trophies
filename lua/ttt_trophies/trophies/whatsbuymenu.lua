local TROPHY = {}
TROPHY.id = "whatsbuymenu"
TROPHY.title = "What's a buy menu?"
TROPHY.desc = "Win a round as a traitor without buying anything"
TROPHY.rarity = 1
TROPHY.hidden = true

function TROPHY:Trigger()
    local boughtPlayers = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive, given_by_randomat)
        if given_by_randomat then return end
        boughtPlayers[ply] = true
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for _, ply in ipairs(player.GetAll()) do
                if TTTTrophies:IsTraitorTeam(ply) and not boughtPlayers[ply] then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(boughtPlayers)
    end)
end

RegisterTTTTrophy(TROPHY)