local TROPHY = {}
TROPHY.id = "speedrun"
TROPHY.title = "Traitor speedrun!"
TROPHY.desc = "As a traitor, win a round in less than 60 seconds"
TROPHY.rarity = 3
TROPHY.hidden = true

function TROPHY:Trigger()
    local roundStartTime

    self:AddHook("TTTBeginRound", function()
        roundStartTime = CurTime()
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR and CurTime() - roundStartTime < 60 then
            for _, ply in ipairs(player.GetAll()) do
                if TTTTrophies:IsTraitorTeam(ply) then
                    self:Earn(ply)
                end
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)