local TROPHY = {}
TROPHY.id = "spinning"
TROPHY.title = "I'm, spinnin' around..."
TROPHY.desc = "Turn around instantly by right-clicking with the backwards shotgun"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT

    self:AddHook("TTTBackwardsShotgunFlip", function(ply)
        self:Earn(ply)
    end)
end

function TROPHY:Condition()
    return weapons.Get("ttt_backwards_shotgun") ~= nil
end

RegisterTTTTrophy(TROPHY)