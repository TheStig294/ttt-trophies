-- These shared functions were created by Malivil, and are taken from his "Randomat for Custom Roles for TTT" mod
-- Used for making trophy trigger functions
ROLE_JESTER = ROLE_JESTER or -1
ROLE_SWAPPER = ROLE_SWAPPER or -1
ROLE_GLITCH = ROLE_GLITCH or -1
ROLE_PHANTOM = ROLE_PHANTOM or ROLE_PHOENIX or -1
ROLE_HYPNOTIST = ROLE_HYPNOTIST or -1
ROLE_REVENGER = ROLE_REVENGER or -1
ROLE_DRUNK = ROLE_DRUNK or -1
ROLE_CLOWN = ROLE_CLOWN or -1
ROLE_DEPUTY = ROLE_DEPUTY or -1
ROLE_IMPERSONATOR = ROLE_IMPERSONATOR or -1
ROLE_BEGGAR = ROLE_BEGGAR or -1
ROLE_OLDMAN = ROLE_OLDMAN or -1
ROLE_MERCENARY = ROLE_MERCENARY or ROLE_SURVIVALIST or -1
ROLE_BODYSNATCHER = ROLE_BODYSNATCHER or -1
ROLE_VETERAN = ROLE_VETERAN or -1
ROLE_ASSASSIN = ROLE_ASSASSIN or -1
ROLE_KILLER = ROLE_KILLER or ROLE_SERIALKILLER or -1
ROLE_ZOMBIE = ROLE_ZOMBIE or ROLE_INFECTED or -1
ROLE_VAMPIRE = ROLE_VAMPIRE or -1
ROLE_DOCTOR = ROLE_DOCTOR or -1
ROLE_QUACK = ROLE_QUACK or -1
ROLE_PARASITE = ROLE_PARASITE or -1
ROLE_TRICKSTER = ROLE_TRICKSTER or -1
ROLE_DETRAITOR = ROLE_DETRAITOR or -1
ROLE_LOOTGOBLIN = ROLE_LOOTGOBLIN or -1

-- Team Functions
function TTTTrophies:IsInnocentTeam(ply, skip_detective)
    -- Handle this early because IsInnocentTeam doesn't
    if skip_detective and TTTTrophies:IsGoodDetectiveLike(ply) then return false end
    if ply.IsInnocentTeam then return ply:IsInnocentTeam() end
    local role = ply:GetRole()

    return role == ROLE_DETECTIVE or role == ROLE_INNOCENT or role == ROLE_MERCENARY or role == ROLE_PHANTOM or role == ROLE_GLITCH
end

function TTTTrophies:IsTraitorTeam(ply, skip_evil_detective)
    -- Handle this early because IsTraitorTeam doesn't
    if skip_evil_detective and TTTTrophies:IsEvilDetectiveLike(ply) then return false end
    if player.IsTraitorTeam then return player.IsTraitorTeam(ply) end
    if ply.IsTraitorTeam then return ply:IsTraitorTeam() end
    local role = ply:GetRole()

    return role == ROLE_TRAITOR or role == ROLE_HYPNOTIST or role == ROLE_ASSASSIN or role == ROLE_DETRAITOR
end

function TTTTrophies:IsMonsterTeam(ply)
    if ply.IsMonsterTeam then return ply:IsMonsterTeam() end
    local role = ply:GetRole()

    return role == ROLE_ZOMBIE or role == ROLE_VAMPIRE
end

function TTTTrophies:IsJesterTeam(ply)
    if ply.IsJesterTeam then return ply:IsJesterTeam() end
    local role = ply:GetRole()

    return role == ROLE_JESTER or role == ROLE_SWAPPER
end

function TTTTrophies:IsIndependentTeam(ply)
    if ply.IsIndependentTeam then return ply:IsIndependentTeam() end
    local role = ply:GetRole()

    return role == ROLE_KILLER
end

-- Role Functions
function TTTTrophies:IsDetectiveLike(ply)
    if ply.IsDetectiveLike then return ply:IsDetectiveLike() end
    local role = ply:GetRole()

    return role == ROLE_DETECTIVE or role == ROLE_DETRAITOR
end

function TTTTrophies:IsGoodDetectiveLike(ply)
    local role = ply:GetRole()
    if role == ROLE_DEPUTY or role == ROLE_IMPERSONATOR then return false end

    return role == ROLE_DETECTIVE or (TTTTrophies:IsDetectiveLike(ply) and TTTTrophies:IsInnocentTeam(ply))
end

function TTTTrophies:IsEvilDetectiveLike(ply)
    local role = ply:GetRole()

    return role == ROLE_DETRAITOR or (TTTTrophies:IsDetectiveLike(ply) and TTTTrophies:IsTraitorTeam(ply))
end

function TTTTrophies:ShouldActLikeJester(ply)
    if ply.ShouldActLikeJester then return ply:ShouldActLikeJester() end

    return TTTTrophies:IsJesterTeam(ply)
end

function TTTTrophies:MapIsSwitching()
    local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
    local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

    return rounds_left <= 0 or time_left <= 0
end