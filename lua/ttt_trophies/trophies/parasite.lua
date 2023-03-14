local TROPHY = {}
TROPHY.id = "parasite"
TROPHY.title = "How's your tummy feeling?"
TROPHY.desc = "As a Parasite, win a round within 2 seconds of taking over a player"
TROPHY.rarity = 3

function TROPHY:Trigger()
    local parasiteKillers = {}

    self:AddHook("TTTParasiteRespawn", function(parasite, victim)
        parasiteKillers[parasite] = true

        timer.Simple(2, function()
            if not IsPlayer(parasite) then return end
            parasiteKillers[parasite] = false
        end)
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, value in pairs(parasiteKillers) do
                if value == true and IsPlayer(ply) then
                    self:Earn(ply)
                end
            end
        end
    end)
end

-- TTTParasiteRespawn hook was only added in Custom Roles version 1.8.2
function TROPHY:Condition()
    return ConVarExists("ttt_parasite_enabled") and GetConVar("ttt_parasite_enabled"):GetBool() and CRVersion("1.8.2")
end

RegisterTTTTrophy(TROPHY)