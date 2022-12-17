local TROPHY = {}
TROPHY.id = "nice"
TROPHY.title = "Nice"
TROPHY.desc = "Play 69 rounds of TTT"
TROPHY.rarity = 1

function TROPHY:Trigger()
    if not TTTTrophies.stats[self.id] then
        TTTTrophies.stats[self.id] = {}
    end

    local notSpectator = {}

    self:AddHook("TTTBeginRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                notSpectator[ply] = true
            end
        end
    end)

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if notSpectator[ply] then
                local rounds = TTTTrophies.stats[self.id][ply:SteamID()]

                if not rounds then
                    rounds = 0
                else
                    rounds = rounds + 1
                end

                TTTTrophies.stats[self.id][ply:SteamID()] = rounds

                if rounds >= 69 then
                    self:Earn(ply)
                end
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)