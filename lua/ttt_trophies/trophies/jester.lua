local TROPHY = {}
TROPHY.id = "jester"
TROPHY.title = "Directed by Robert B. Weide"
TROPHY.desc = "As a Jester, win"
TROPHY.rarity = 2
TROPHY.hidden = true

function TROPHY:Trigger()
    self:AddHook("TTTEndRound", function(result)
        if result == WIN_JESTER then
            for _, ply in ipairs(player.GetAll()) do
                -- Give the trophy to all dead jesters when the jester has won
                if ply:GetRole() == ROLE_JESTER and not ply:Alive() and ply:IsSpec() then
                    self:Earn(ply)
                end
            end
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_JESTER)
end

RegisterTTTTrophy(TROPHY)