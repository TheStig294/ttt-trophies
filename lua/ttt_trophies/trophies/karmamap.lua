local TROPHY = {}
TROPHY.id = "karmamap"
TROPHY.title = "A perfect map!"
TROPHY.desc = "Don't loose karma for a whole map"
TROPHY.rarity = 3

function TROPHY:Trigger()
    -- Using this method instead of the ShutDown hook should avoid earning this trophy when the map is manually changed
    local function MapIsSwitching()
        local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
        local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

        return rounds_left <= 0 or time_left <= 0
    end

    local lostKarma = {}

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        lostKarma[ply] = true
    end)

    self:AddHook("TTTEndRound", function()
        if MapIsSwitching() then
            for _, ply in ipairs(player.GetAll()) do
                if not lostKarma[ply] then
                    self:Earn(ply)
                end
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)