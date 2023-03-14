local TROPHY = {}
TROPHY.id = "lootgoblin"
TROPHY.title = "Sneaky little goblin"
TROPHY.desc = "As a Loot Goblin, survive to the end of the round"
TROPHY.rarity = 2
TROPHY.hidden = true

function TROPHY:Trigger()
    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetRole() == ROLE_LOOTGOBLIN and self:IsAlive(ply) then
                self:Earn(ply)
            end
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_lootgoblin_enabled") and GetConVar("ttt_lootgoblin_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)