local TROPHY = {}
TROPHY.id = "paramedic"
TROPHY.title = "Confirmed innocent buddies!"
TROPHY.desc = "As a Paramedic, revive an innocent who's body has been searched"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_PARAMEDIC
    local searchedPlys = {}

    self:AddHook("TTTBodyFound", function(ply, deadply, rag)
        if not IsPlayer(deadply) or not TTTTrophies:IsInnocentTeam(deadply) then return end
        searchedPlys[deadply] = true
    end)

    self:AddHook("TTTPlayerRoleChangedByItem", function(ply, tgt, item)
        if item:GetClass() == "weapon_med_defib" and searchedPlys[tgt] then
            self:Earn(ply)
        end
    end)

    self:AddHook("TTTPrepareRound", function()
        table.Empty(searchedPlys)
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_PARAMEDIC)
end

RegisterTTTTrophy(TROPHY)