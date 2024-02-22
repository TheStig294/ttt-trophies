local TROPHY = {}
TROPHY.id = "waitwhat"
TROPHY.title = "Wait, what?"
TROPHY.desc = "Kill someone as a jester"
TROPHY.rarity = 3

function TROPHY:Trigger()
    local function IsActiveClownLike(ply)
        return ply:IsRoleActive() and (ply:IsClown() or (ply.IsDetectoclown and ply:IsDetectoclown()) or (ply.IsFrenchman and ply:IsFrenchman()))
    end

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsValid(attacker) or not attacker:IsPlayer() then return end

        if attacker ~= ply and TTTTrophies:IsJesterTeam(attacker) and not IsActiveClownLike(attacker) then
            self:Earn(attacker)
        end
    end)
end

-- Check there is at least 1 jester role in existence and is enabled
function TROPHY:Condition()
    if not JESTER_ROLES or not ROLE_STRINGS_RAW then return false end
    local jesterRoleEnabled = false

    for role, _ in pairs(JESTER_ROLES) do
        if TTTTrophies:CanRoleSpawn(role) then
            jesterRoleEnabled = true
            break
        end
    end

    return jesterRoleEnabled
end

RegisterTTTTrophy(TROPHY)