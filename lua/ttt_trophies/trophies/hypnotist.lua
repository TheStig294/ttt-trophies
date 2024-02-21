local TROPHY = {}
TROPHY.id = "hypnotist"
TROPHY.title = "Risky move"
TROPHY.desc = "As a Hypnotist, win the round after reviving a detective"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_HYPNOTIST
    local revivedDetective = {}

    self:AddHook("TTTPlayerRoleChangedByItem", function(ply, tgt, item)
        if item:GetClass() == "weapon_hyp_brainwash" and TTTTrophies:IsGoodDetectiveLike(tgt) then
            revivedDetective[ply] = true
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, _ in pairs(revivedDetective) do
                self:Earn(ply)
            end
        end

        table.Empty(revivedDetective)
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_HYPNOTIST)
end

RegisterTTTTrophy(TROPHY)