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
    local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6))
    local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())

    return rounds_left <= 0 or time_left <= 0
end

function TTTTrophies:IsBuyableItem(role, wep)
    if isstring(wep) then
        wep = weapons.Get(wep)
    end

    if not role or not wep then return false end
    local classname = wep.ClassName
    local id = wep.id
    local excludeWepsExist = istable(WEPS.ExcludeWeapons) and istable(WEPS.ExcludeWeapons[role])
    local includeWepsExist = istable(WEPS.BuyableWeapons) and istable(WEPS.BuyableWeapons[role])

    -- Checking if item is an active item
    if isstring(classname) and wep.CanBuy then
        -- Also take into account the weapon exclude and include lists from Custom Roles, if they exist
        if includeWepsExist then
            for i, includedWep in ipairs(WEPS.BuyableWeapons[role]) do
                if classname == includedWep then return true end
            end
        end

        if excludeWepsExist then
            for i, excludedWep in ipairs(WEPS.ExcludeWeapons[role]) do
                if classname == excludedWep then return false end
            end
        end

        if table.HasValue(wep.CanBuy, role) then return true end
        -- Checking if item is a passive item
    elseif isnumber(id) then
        id = tonumber(id)
        -- Loadout items cannot be bought as they are automatically given
        local item = GetEquipmentItem(role, id)
        if item.loadout then return false end
        if not item.name then return false end

        if includeWepsExist then
            for i, includedWep in ipairs(WEPS.BuyableWeapons[role]) do
                if item.name == includedWep then return true end
            end
        end

        if excludeWepsExist then
            for i, excludedWep in ipairs(WEPS.ExcludeWeapons[role]) do
                if item.name == excludedWep then return false end
            end
        end

        return true
    end

    return false
end

function TTTTrophies:CanRoleSpawn(role)
    if not role or role == -1 then return false end
    if util.CanRoleSpawn then return util.CanRoleSpawn(role) end
    if role == ROLE_DETECTIVE or role == ROLE_INNOCENT or role == ROLE_TRAITOR then return true end

    if ROLE_STRINGS_RAW then
        local cvar = "ttt_" .. ROLE_STRINGS_RAW[role] .. "_enabled"

        return ConVarExists(cvar) and GetConVar(cvar):GetBool()
    end

    return false
end

if SERVER then
    util.AddNetworkString("TTTTrophiesRequestWeaponName")
    util.AddNetworkString("TTTTrophiesSendWeaponName")
end

local nameCache = {}

local function GetWeaponName(classname)
    if nameCache[classname] then return nameCache[classname] end
    local SWEP = weapons.Get(classname)

    if SWEP then
        local printname = SWEP.PrintName

        if LANG and LANG.TryTranslation then
            printname = LANG.TryTranslation(printname)
        end

        return printname
    end
end

-- Can return nil if the weapon name hasn't been cached yet
function TTTTrophies:GetWeaponName(classname)
    if nameCache[classname] then return nameCache[classname] end

    if SERVER then
        local firstPly = Entity(1)
        if not IsValid(firstPly) then return end
        net.Start("TTTTrophiesRequestWeaponName")
        net.WriteString(classname)
        net.Send(firstPly)
    else
        nameCache[classname] = GetWeaponName(classname)

        return nameCache[classname]
    end
end

if CLIENT then
    net.Receive("TTTTrophiesRequestWeaponName", function()
        local classname = net.ReadString()
        local printname = GetWeaponName(classname)
        net.Start("TTTTrophiesSendWeaponName")
        net.WriteString(classname)
        net.WriteString(printname)
        net.SendToServer()
    end)
end

if SERVER then
    net.Receive("TTTTrophiesSendWeaponName", function(_, ply)
        if ply:EntIndex() ~= 1 then return end
        local classname = net.ReadString()
        local printname = net.ReadString()
        nameCache[classname] = printname
    end)
end