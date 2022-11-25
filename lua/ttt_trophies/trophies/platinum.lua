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
                self:Earn(ply)
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)