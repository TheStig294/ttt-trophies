local TROPHY = {}
TROPHY.id = "onemistake"
TROPHY.title = "One mistake is all it takes..."
TROPHY.desc = "Don't loose karma at all for 5 maps in a row"
TROPHY.rarity = 3

function TROPHY:Trigger()
    -- Using this method instead of the ShutDown hook should avoid earning this trophy when the map is manually changed
    local perfectMaps = TTTTrophies.stats[self.id] or {}
    local karmaLost = {}

    self:AddHook("TTTKarmaGivePenalty", function(ply, penalty, victim)
        local plys = {ply}

        if hook.Run("TTTBlockTrophyEarned", self, plys) == true then return end
        perfectMaps[ply:SteamID()] = 0
        karmaLost[ply] = true
    end)

    self:AddHook("TTTEndRound", function()
        if TTTTrophies:MapIsSwitching() then
            for _, ply in ipairs(player.GetAll()) do
                local plyID = ply:SteamID()

                if not perfectMaps[plyID] then
                    perfectMaps[plyID] = 1
                elseif not karmaLost[ply] then
                    perfectMaps[plyID] = perfectMaps[plyID] + 1
                end

                if perfectMaps[plyID] < 5 then
                    self:ProgressUpdate(ply, perfectMaps[plyID], 5)
                elseif perfectMaps[plyID] >= 5 then
                    self:Earn(ply)
                end

                TTTTrophies.stats[self.id] = perfectMaps
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)