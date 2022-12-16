local TROPHY = {}
TROPHY.id = "innocent"
TROPHY.title = "Rythian-Doing-Murders"
TROPHY.desc = "As an innocent, don't lose karma for a whole round"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT
    local noKarmaLostPlayers = {}

    self:AddHook("TTTBeginRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                noKarmaLostPlayers[ply] = true
            end
        end
    end)

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        noKarmaLostPlayers[ply] = false
    end)

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if noKarmaLostPlayers[ply] and TTTTrophies:IsInnocentTeam(ply) then
                self:Earn(ply)
            end
        end

        table.Empty(noKarmaLostPlayers)
    end)
end

RegisterTTTTrophy(TROPHY)