local TROPHY = {}
TROPHY.id = "timeup"
TROPHY.title = "Time's up!"
TROPHY.desc = "Witness a round end from the time running out"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TIMELIMIT then
            self:Earn(player.GetAll())
        end
    end)
end

RegisterTTTTrophy(TROPHY)