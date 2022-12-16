local TROPHY = {}
TROPHY.id = "onemistake"
TROPHY.title = "One mistake is all it takes..."
TROPHY.desc = "Don't loose karma at all for 5 maps in a row, good luck!"
TROPHY.rarity = 3

function TROPHY:Trigger()
    -- Using this method instead of the ShutDown hook should avoid earning this trophy when the map is manually changed
    local perfectMaps = TTTTrophies.stats[self.id] or {}

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        perfectMaps[ply:SteamID()] = 0
    end)

    self:AddHook("TTTEndRound", function()
        if TTTTrophies:MapIsSwitching() then
            for _, ply in ipairs(player.GetAll()) do
                local plyID = ply:SteamID()

                if not perfectMaps[plyID] then
                    perfectMaps[plyID] = 0
                end

                perfectMaps[plyID] = perfectMaps[plyID] + 1

                if perfectMaps[plyID] < 5 then
                    self:ProgressUpdate(ply, perfectMaps[plyID], 5)
                elseif perfectMaps[plyID] == 5 then
                    self:Earn(ply)
                end

                TTTTrophies.stats[self.id] = perfectMaps
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)