local TROPHY = {}
TROPHY.id = "weee"
TROPHY.title = "Weeeeee!"
TROPHY.desc = "Look upwards and shoot a backwards shotgun"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self:AddHook("TTTBackwardsShotgunPrimary", function(ply)
        local aimVector = ply:GetAimVector()

        if aimVector.z >= 0.255 then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return weapons.Get("ttt_backwards_shotgun") ~= nil
end

RegisterTTTTrophy(TROPHY)