local TROPHY = {}
TROPHY.id = "turncoat"
TROPHY.title = "Twist ending"
TROPHY.desc = "As a Turncoat, win the round within 2 seconds of turning"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_TURNCOAT
    local turnedPlayers = {}

    self:AddHook("TTTTurncoatTeamChanged", function(ply, traitor)
        if traitor then
            turnedPlayers[ply] = true

            timer.Simple(2, function()
                turnedPlayers[ply] = false
            end)
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, value in pairs(turnedPlayers) do
                if value == true then
                    self:Earn(ply)
                end
            end
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_TURNCOAT)
end

RegisterTTTTrophy(TROPHY)