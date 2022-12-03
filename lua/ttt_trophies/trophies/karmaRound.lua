local TROPHY = {}
TROPHY.id = "karmaRound"
TROPHY.title = "Rythian-Doing-Murders"
TROPHY.desc = "Don't lose karma for a whole round"
TROPHY.rarity = 1

function TROPHY:Trigger()
    local noKarmaLostPlayers = {}

    self:AddHook("TTTBeginRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                table.insert(noKarmaLostPlayers, ply)
            end
        end
    end)

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        table.RemoveByValue(noKarmaLostPlayers, ply)
    end)

    self:AddHook("TTTEndRound", function()
        if not table.IsEmpty(noKarmaLostPlayers) and noKarmaLostPlayers ~= {} then
            self:Earn(noKarmaLostPlayers)
        end

        table.Empty(noKarmaLostPlayers)
    end)
end

RegisterTTTTrophy(TROPHY)