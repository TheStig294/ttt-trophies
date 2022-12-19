local TROPHY = {}
TROPHY.id = "whatsbuymenu"
TROPHY.title = "What's a buy menu?"
TROPHY.desc = "Win a round as a traitor without buying anything"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR
    local boughtPlayers = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive)
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