local TROPHY = {}
TROPHY.id = "platinum"
TROPHY.title = "The reward is yours..."
TROPHY.desc = "Earn all other trophies"
TROPHY.rarity = 4

function TROPHY:Trigger()
    self:AddHook("TTTTrophyEarned", function(trophy, ply)
        local earnedTrophies = TTTTrophies.earned[ply:SteamID()]

        if table.Count(TTTTrophies.trophies) == table.Count(earnedTrophies) then
            self:Earn(ply)
        end
    end)

    -- Backup check for earning the platinum, in case the last trophy becomes disabled, or some other weirdness I didn't think of
    self:AddHook("TTTPrepareRound", function()
        for _, ply in ipairs(player.GetAll()) do
            local earnedTrophies = TTTTrophies.earned[ply:SteamID()]

            if table.Count(TTTTrophies.trophies) == table.Count(earnedTrophies) then
                self:Earn(ply)
            end
        end

        self:RemoveHook("TTTPrepareRound")
    end)
end

RegisterTTTTrophy(TROPHY)