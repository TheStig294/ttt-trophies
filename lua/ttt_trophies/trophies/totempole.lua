local TROPHY = {}
TROPHY.id = "totempole"
TROPHY.title = "Totem pole"
TROPHY.desc = "Survive to the end of a round while stood on another player or being stood on"
TROPHY.rarity = 3
TROPHY.forceDesc = true

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if self:IsAlive(ply) and IsPlayer(ply:GetGroundEntity()) then
                self:Earn({ply, ply:GetGroundEntity()})
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)