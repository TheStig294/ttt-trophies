local TROPHY = {}
TROPHY.id = "platinum"
TROPHY.title = "The reward is yours..."
TROPHY.desc = "Earn all other trophies"
TROPHY.rarity = 4

function TROPHY:Trigger()
    self:AddHook("TTTTrophyEarned", function(trophy, ply)
        local earnedTrophies = TTTTrophies.earned[ply:SteamID()]

        for trophyID, _ in pairs(TTTTrophies.trophies) do
            if not earnedTrophies[trophyID] and trophyID ~= "platinum" then return end
        end

        self:Earn(ply)
    end)

    -- Backup check for earning the platinum, in case the last trophy becomes disabled, or some other weirdness I didn't think of
    self:AddHook("TTTPrepareRound", function()
        for _, ply in ipairs(player.GetAll()) do
            local earnedPlatinum = true
            local earnedTrophies = TTTTrophies.earned[ply:SteamID()]
            if not earnedTrophies then continue end

            for trophyID, _ in pairs(TTTTrophies.trophies) do
                if not earnedTrophies[trophyID] and trophyID ~= "platinum" then
                    earnedPlatinum = false
                    break
                end
            end

            if earnedPlatinum then
                self:Earn(ply)
            end
        end

        self:RemoveHook("TTTPrepareRound")
    end)
end

RegisterTTTTrophy(TROPHY)