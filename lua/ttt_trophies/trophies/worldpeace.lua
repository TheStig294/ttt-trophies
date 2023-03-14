local TROPHY = {}
TROPHY.id = "worldpeace"
TROPHY.title = "We achieved world peace?"
TROPHY.desc = "Have 1/2 the round go on without anyone dying"
TROPHY.rarity = 3

function TROPHY:Trigger()
    local roundtime

    local function ResetTimer()
        timer.Create("TTTTrophiesWorldPeace", roundtime, 1, function()
            self:Earn(player.GetAll())
        end)
    end

    self:AddHook("TTTBeginRound", function()
        roundtime = (GetGlobalFloat("ttt_round_end") - CurTime()) / 2
        ResetTimer()
    end)

    self:AddHook("PostPlayerDeath", ResetTimer)

    self:AddHook("TTTEndRound", function()
        timer.Remove("TTTTrophiesWorldPeace")
    end)
end

RegisterTTTTrophy(TROPHY)