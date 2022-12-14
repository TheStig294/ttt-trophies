local TROPHY = {}
TROPHY.id = "beeswin"
TROPHY.title = "Bees win!"
TROPHY.desc = "Witness a round end with everyone dead"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("TTTEndRound", function()
        local plys = player.GetAll()

        for _, ply in ipairs(plys) do
            if self:IsAlive(ply) then return end
        end

        self:Earn(plys)
    end)
end

RegisterTTTTrophy(TROPHY)