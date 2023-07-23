local TROPHY = {}
TROPHY.id = "survivor"
TROPHY.title = "Survivor"
TROPHY.desc = "Survive a minute after being damaged to less than 5HP"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("PostEntityTakeDamage", function(ent, dmg, took)
        if not took or not IsValid(ent) then return end
        if not ent:IsPlayer() or not ent:Alive() or ent:IsSpec() then return end

        if ent:Health() < 5 then
            local ID = ent:SteamID64()

            timer.Create("TTTTrophiesSurvivor" .. ID, 1, 60, function()
                if not IsValid(ent) or ent:Health() >= 5 then
                    timer.Remove("TTTTrophiesSurvivor" .. ID)

                    return
                elseif timer.RepsLeft("TTTTrophiesSurvivor" .. ID) == 0 then
                    self:Earn(ent)
                end
            end)
        end
    end)

    self:AddHook("PostPlayerDeath", function(ply)
        timer.Remove("TTTTrophiesSurvivor" .. ply:SteamID64())
    end)

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            timer.Remove("TTTTrophiesSurvivor" .. ply:SteamID64())
        end
    end)
end

RegisterTTTTrophy(TROPHY)