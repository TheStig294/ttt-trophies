local TROPHY = {}
TROPHY.id = "papexperimenter"
TROPHY.title = "PaP Experimenter"
TROPHY.desc = "Pack-a-Punch 30 unique weapons" -- 30 is the total number of weapons TTT has by default
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    if not TTTTrophies.stats[self.id] then
        TTTTrophies.stats[self.id] = {}
    end

    self:AddHook("TTTPAPOrder", function(ply, SWEP, UPGRADE)
        if not IsValid(SWEP) then return end
        local class = WEPS.GetClass(SWEP)
        local plyID = ply:SteamID()

        if not TTTTrophies.stats[self.id][plyID] then
            TTTTrophies.stats[self.id][plyID] = {}
        end

        TTTTrophies.stats[self.id][plyID][class] = true

        if table.Count(TTTTrophies.stats[self.id][plyID]) >= 30 then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return TTTPAP and TTTPAP.OrderPAP
end

RegisterTTTTrophy(TROPHY)