local TROPHY = {}
TROPHY.id = "blazeit"
TROPHY.title = "Blaze it"
TROPHY.desc = "Play 420 rounds of TTT"
TROPHY.rarity = 2

function TROPHY:Trigger()
    local notSpectator = {}

    self:AddHook("TTTBeginRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                notSpectator[ply] = true
            end
        end
    end)

    self:AddHook("TTTEndRound", function()
        -- Use the stats from the "nice" trophy
        if not TTTTrophies.stats["nice"] then
            TTTTrophies.stats["nice"] = {}
        end

        for _, ply in ipairs(player.GetAll()) do
            if notSpectator[ply] then
                local rounds = TTTTrophies.stats["nice"][ply:SteamID()]

                if not rounds then
                    rounds = 0
                else
                    rounds = rounds + 1
                end

                TTTTrophies.stats["nice"][ply:SteamID()] = rounds

                if rounds >= 420 then
                    self:Earn(ply)
                end
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)