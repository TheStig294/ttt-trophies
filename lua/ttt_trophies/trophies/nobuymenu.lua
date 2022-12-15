local TROPHY = {}
TROPHY.id = "nobuymenu"
TROPHY.title = "What's a buy menu?"
TROPHY.desc = "Win a round as a traitor without buying anything"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR
    local boughtTraitors = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive)
        if ply:IsTraitorTeam(ply) then
            boughtTraitors[ply] = true
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for _, ply in ipairs(player.GetAll()) do
                if not boughtTraitors[ply] then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(boughtTraitors)
    end)
end

RegisterTTTTrophy(TROPHY)