local TROPHY = {}
TROPHY.id = "informant"
TROPHY.title = "I've got you now!"
TROPHY.desc = "As an Informant, track someone through walls by looking at them long enough"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_INFORMANT

    self:AddHook("TTTInformantScanStageChanged", function(ply, tgt, stage)
        if stage == 3 then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return TTTTrophies:CanRoleSpawn(ROLE_INFORMANT)
end

RegisterTTTTrophy(TROPHY)