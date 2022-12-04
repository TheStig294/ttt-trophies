local TROPHY = {}
TROPHY.id = "marshal"
TROPHY.title = "But I did not kill the deputy!"
TROPHY.desc = "As a Marshal, win a round with a player you promoted still alive"
TROPHY.rarity = 2
TROPHY.roleMessage = ROLE_MARSHAL

function TROPHY:Trigger()
    local promotionPair = {}

    self:AddHook("TTTPlayerRoleChangedByItem", function(ply, tgt, item)
        if item:GetClass() == "weapon_mhl_badge" and tgt:IsDeputy() then
            promotionPair[tgt] = ply
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result ~= WIN_INNOCENT then return end

        for _, ply in ipairs(player.GetAll()) do
            if ply:IsDeputy() and self:IsAlive(ply) and IsPlayer(promotionPair[ply]) then
                self:Earn(promotionPair[ply])
            end
        end

        table.Empty(promotionPair)
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_marshal_enabled") and GetConVar("ttt_marshal_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)