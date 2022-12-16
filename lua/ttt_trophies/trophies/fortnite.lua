local TROPHY = {}
TROPHY.id = "fortnite"
TROPHY.title = "Totally not suspicious..."
TROPHY.desc = "Witness someone use a fortnite building tool while they're not a detective"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    local function EarnTrophy(plys)
        self:Earn(plys)
    end

    local SWEP = weapons.GetStored("weapon_ttt_fortnite_building")

    function SWEP:Equip(owner)
        hook.Add("PlayerButtonDown", "TTTTrophiesFortniteUse", function(ply, button)
            if TTTTrophies:IsDetectiveLike(ply) then return end

            if IsPlayer(owner) and ply == owner and button == MOUSE_LEFT and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() == self then
                EarnTrophy(player.GetAll())
            end
        end)
    end

    self:AddHook("TTTPrepareRound", function()
        hook.Remove("PlayerButtonDown", "TTTTrophiesFortniteUse")
    end)
end

-- Check the fortnite building tool can actually be bought by a traitor
function TROPHY:Condition()
    if weapons.Get("weapon_ttt_fortnite_building") and isfunction(GetTraitorBuyable) then
        local traitorWeapons = GetTraitorBuyable()
        if traitorWeapons["weapon_ttt_fortnite_building"] then return true end
    else
        return false
    end
end

RegisterTTTTrophy(TROPHY)