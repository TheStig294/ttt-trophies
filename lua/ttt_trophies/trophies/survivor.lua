local TROPHY = {}
TROPHY.id = "survivor"
TROPHY.title = "Survivor"
TROPHY.desc = "Survive 2 minutes after being damaged to less than 5HP"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("PostEntityTakeDamage", function(ent, dmg, took)
        if not took or not IsValid(ent) then return end
        if not ent:IsPlayer() or not ent:Alive() or ent:IsSpec() then return end

        if ent:Health() <= 5 then
            timer.Create("TTTTrophies2hp" .. ent:SteamID64(), 120, 1, function()
                if IsValid(ent) then
                    self:Earn(ent)
                end
            end)
        end
    end)

    self:AddHook("PostPlayerDeath", function(ply)
        timer.Remove("TTTTrophies2hp" .. ply:SteamID64())
    end)

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            timer.Remove("TTTTrophies2hp" .. ply:SteamID64())
        end
    end)
end

RegisterTTTTrophy(TROPHY)