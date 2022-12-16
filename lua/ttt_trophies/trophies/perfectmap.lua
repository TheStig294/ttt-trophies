local TROPHY = {}
TROPHY.id = "perfectmap"
TROPHY.title = "A perfect map!"
TROPHY.desc = "Don't loose karma for a whole map"
TROPHY.rarity = 3

function TROPHY:Trigger()
    -- Using this method instead of the ShutDown hook should avoid earning this trophy when the map is manually changed
    local lostKarma = {}

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        lostKarma[ply] = true
    end)

    self:AddHook("TTTEndRound", function()
        if TTTTrophies:MapIsSwitching() then
            for _, ply in ipairs(player.GetAll()) do
                if not lostKarma[ply] then
                    self:Earn(ply)
                end
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)