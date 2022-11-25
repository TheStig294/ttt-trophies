local TROPHY = {}
TROPHY.id = "platinum"
TROPHY.title = "It. Is. DONE."
TROPHY.desc = "Earn all other trophies"
TROPHY.rarity = 4

function TROPHY:Trigger()
    self:AddHook("TTTTrophyEarned", function(trophy, plys)
        for _, ply in ipairs(plys) do
            local earnedTrophies = TTTTrophies.earned[ply:SteamID()]

            if table.Count(TTTTrophies.trophies) == table.Count(earnedTrophies) then
                -- Make the trophy unlock delayed by a few seconds so it doesn't overlap the last trophy earned
                timer.Simple(3, function()
                    self:Earn(ply)
                end)
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)