local TROPHY = {}
TROPHY.id = "paladin"
TROPHY.title = "Vertical healing"
TROPHY.desc = "As a Paladin, heal a player while being above or below them"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_PALADIN

    self:AddHook("TTTPaladinAuraHealed", function(ply, tgt, healed)
        local paladinHeight = ply:GetPos().z
        local targetHeight = tgt:GetPos().z
        local dist = math.abs(paladinHeight - targetHeight)

        if dist > 50 then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_paladin_enabled") and GetConVar("ttt_paladin_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)