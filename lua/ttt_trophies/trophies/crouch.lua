local TROPHY = {}
TROPHY.id = "crouch"
TROPHY.title = "Squat walk"
TROPHY.desc = "Stay crouched and alive from the beginning to the end of a round"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT
    local startedCrouching = {}
    local stoppedCrouching = {}

    self:AddHook("PlayerButtonDown", function(ply, button)
        if button == KEY_LCONTROL and GetRoundState() == ROUND_PREP then
            startedCrouching[ply] = true
            stoppedCrouching[ply] = false
        end
    end)

    self:AddHook("PlayerButtonUp", function(ply, button)
        if button == KEY_LCONTROL then
            stoppedCrouching[ply] = true
        end
    end)

    self:AddHook("TTTEndRound", function()
        for _, ply in ipairs(player.GetAll()) do
            if not stoppedCrouching[ply] and startedCrouching[ply] and self:IsAlive(ply) then
                self:Earn(ply)
            end
        end
    end)
end

RegisterTTTTrophy(TROPHY)