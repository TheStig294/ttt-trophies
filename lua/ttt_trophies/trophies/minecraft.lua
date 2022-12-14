local TROPHY = {}
TROPHY.id = "minecraft"
TROPHY.title = "Sure, just play Minecraft..."
TROPHY.desc = "Place 50 or more blocks down using the Minecraft Block"
TROPHY.rarity = 1

function TROPHY:Trigger()
    local function EarnTrophy(plys)
        self:Earn(plys)
    end

    local SWEP = weapons.GetStored("minecraft_swep")
    local minecraftUses = {}

    function SWEP:Equip(owner)
        hook.Add("PlayerButtonDown", "TTTTrophiesMinecraftUse", function(ply, button)
            if IsPlayer(owner) and ply == owner and button == MOUSE_RIGHT and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() == self then
                if not minecraftUses[ply] then
                    minecraftUses[ply] = 1
                else
                    minecraftUses[ply] = minecraftUses[ply] + 1
                end

                if minecraftUses[ply] == 50 then
                    EarnTrophy(ply)
                end
            end
        end)
    end

    self:AddHook("TTTPrepareRound", function()
        hook.Remove("PlayerButtonDown", "TTTTrophiesMinecraftUse")
        table.Empty(minecraftUses)
    end)
end

-- Check the minecraft block is actually a TTT weapon
function TROPHY:Condition()
    local SWEP = weapons.Get("minecraft_swep")
    if not istable(SWEP) then return false end

    return SWEP.Base and SWEP.Base == "weapon_tttbase"
end

RegisterTTTTrophy(TROPHY)