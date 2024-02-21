local TROPHY = {}
TROPHY.id = "drunk"
TROPHY.title = "Maximise the odds"
TROPHY.desc = "As a Drunk, remember your role while only 1 other player is alive"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_DRUNK

    self:AddHook("TTTWinCheckBlocks", function()
        local drunk
        local otherPlayer

        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) then
                if ply:IsDrunk() then
                    if IsPlayer(drunk) then return end
                    drunk = ply
                else
                    if IsPlayer(otherPlayer) then return end
                    otherPlayer = ply
                end
            end
        end

        if IsPlayer(drunk) and IsPlayer(otherPlayer) then
            self:Earn(drunk)
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_DRUNK)
end

RegisterTTTTrophy(TROPHY)