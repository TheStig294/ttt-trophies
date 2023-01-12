local TROPHY = {}
TROPHY.id = "fall"
TROPHY.title = "Nice save!"
TROPHY.desc = "Save yourself from a high damage fall by double-jumping"
TROPHY.rarity = 2
TROPHY.hidden = true

function TROPHY:Trigger()
    local doubleJumping = {}

    self:AddHook("OnPlayerHitGround", function(ply, inWater, onFloater, speed)
        doubleJumping[ply] = false
    end)

    self:AddHook("PlayerButtonDown", function(ply, button)
        if button == KEY_SPACE and not ply:OnGround() then
            if button == KEY_SPACE and not ply:OnGround() and not doubleJumping[ply] then
                local velocity = ply:GetVelocity().z

                if velocity <= -700 then
                    self:Earn(ply)
                end
            end

            doubleJumping[ply] = true
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("multijump_default_jumps") and GetConVar("multijump_default_jumps"):GetInt() == 1 and ConVarExists("multijump_can_jump_while_falling") and GetConVar("multijump_can_jump_while_falling"):GetBool()
end

RegisterTTTTrophy(TROPHY)