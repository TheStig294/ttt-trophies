-- This file sets up all the core important logic of the trophies, as well as loads all other lua files in the right order
-- The global table used by the client and server to access all trophy data
TTTTrophies = {}
TTTTrophies.trophies = {}
TTTTrophies.earned = {}
TTTTrophies.toMessage = {}
TTTTrophies.toRegister = {}
TTTTrophies.roleMessage = {}
TTTTrophies.rainbowPlayers = {}
TTTTrophies.stats = {}
-- Creating a fake class of "TROPHY" using metatables, borrowed from the randomat's "EVENT" class
local trophies_meta = {}
trophies_meta.__index = trophies_meta

if SERVER then
    util.AddNetworkString("TTTEarnTrophy")
    util.AddNetworkString("TTTDoTrophyPopup")

    function trophies_meta:Earn(plys)
        if not istable(plys) then
            plys = {plys}
        end

        -- Hook to stop trophies from being earned
        if hook.Run("TTTBlockTrophyEarned", self, plys) == true then return end
        -- Check if trophy is disabled by an admin or not
        if not GetGlobalBool("trophies_" .. self.id) then return end

        for _, ply in ipairs(plys) do
            local plyID = ply:SteamID()
            -- Don't earn trophies that are already earned
            if TTTTrophies.earned[plyID] and TTTTrophies.earned[plyID][self.id] then continue end
            -- Add the player to the earnedTrophies table if they haven't earned a trophy before
            TTTTrophies.earned[plyID] = TTTTrophies.earned[plyID] or {}
            -- Make the trophy as earned
            TTTTrophies.earned[plyID][self.id] = true
            -- Also mark the trophy to show a message at the end of the round
            local nick = ply:Nick()
            TTTTrophies.toMessage[nick] = TTTTrophies.toMessage[nick] or {}
            table.insert(TTTTrophies.toMessage[nick], self.id)

            -- Make the trophy unlock delayed by a few seconds so the platinum doesn't overlap the last trophy earned
            if self.id == "platinum" then
                TTTTrophies.rainbowPlayers[plyID] = true
            end

            net.Start("TTTEarnTrophy")
            net.WriteString(self.id)
            net.Send(ply)
            -- Show the earned trophy popup for the player
            net.Start("TTTDoTrophyPopup")
            net.WriteString(self.id)
            net.Send(ply)
            hook.Run("TTTTrophyEarned", self, ply)
        end
    end

    function trophies_meta:Trigger()
    end

    function trophies_meta:Condition()
        return true
    end
end

function RegisterTTTTrophy(trophy)
    table.insert(TTTTrophies.toRegister, trophy)
end

-- These 2 functions are from Malivil's randomat mod, to save having to come up with a unique ID for a hook every time...
function trophies_meta:AddHook(hooktype, callbackfunc, suffix)
    callbackfunc = callbackfunc or self[hooktype]
    local id = "TTTTrophy." .. self.id .. ":" .. hooktype

    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end

    hook.Add(hooktype, id, function(...) return callbackfunc(...) end)
    self.Hooks = self.Hooks or {}

    table.insert(self.Hooks, {hooktype, id})
end

function trophies_meta:RemoveHook(hooktype, suffix)
    local id = "TTTTrophy." .. self.id .. ":" .. hooktype

    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end

    for idx, ahook in ipairs(self.Hooks or {}) do
        if ahook[1] == hooktype and ahook[2] == id then
            hook.Remove(ahook[1], ahook[2])
            table.remove(self.Hooks, idx)

            return
        end
    end
end

function trophies_meta:IsAlive(ply)
    return ply:Alive() and not ply:IsSpec()
end

function trophies_meta:ProgressUpdate(plys, numerator, denominator)
    -- Check if trophy is disabled by an admin or not
    if not GetGlobalBool("trophies_" .. self.id) then return end

    if not istable(plys) then
        plys = {plys}
    end

    for _, ply in ipairs(plys) do
        if ply.DisableTrophyChatMessages then continue end
        local plyID = ply:SteamID()
        if TTTTrophies.earned[plyID] and TTTTrophies.earned[plyID][self.id] then continue end
        ply:ChatPrint("[Trophy progress]\n" .. self.desc .. "\n(" .. numerator .. "/" .. denominator .. ")")
    end
end

-- Reading all trophy lua files
local function AddServer(fil)
    if SERVER then
        include(fil)
    end
end

local function AddClient(fil)
    if SERVER then
        AddCSLuaFile(fil)
    end

    if CLIENT then
        include(fil)
    end
end

AddServer("ttt_trophies/sv_trophies_earn.lua")
AddServer("ttt_trophies/trophies_shared.lua")
AddClient("ttt_trophies/trophies_shared.lua")
AddClient("ttt_trophies/cl_trophies_earn.lua")
AddClient("ttt_trophies/cl_trophies_f1_tab.lua")
AddClient("ttt_trophies/cl_trophy_popup.lua")
local files, _ = file.Find("ttt_trophies/trophies/*.lua", "LUA")

for _, fil in ipairs(files) do
    AddServer("ttt_trophies/trophies/" .. fil)
    AddClient("ttt_trophies/trophies/" .. fil)
end

if SERVER then
    -- Loading server-side convars, including all convars controlling whether trophies are disabled by admins
    local convars = {"ttt_trophies_hide_all_trophies"}

    CreateConVar("ttt_trophies_hide_all_trophies", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether trophies should have their descriptions hidden if not yet earned", 0, 1)

    hook.Add("TTTPrepareRound", "TTTTrophiesConvarSync", function()
        SetGlobalBool("ttt_trophies_hide_all_trophies", GetConVar("ttt_trophies_hide_all_trophies"):GetBool())
    end)

    util.AddNetworkString("TTTTrophiesToggleConvar")

    net.Receive("TTTTrophiesToggleConvar", function(len, ply)
        if not ply:IsAdmin() then return end
        local cvarName = net.ReadString()
        local found = false

        for _, validCvar in ipairs(convars) do
            if cvarName == validCvar then
                found = true
                break
            end
        end

        if not found then return end
        local cvar = GetConVar(cvarName)

        if cvar:GetBool() then
            cvar:SetBool(false)
        else
            cvar:SetBool(true)
        end

        SetGlobalBool(cvarName, cvar:GetBool())
    end)

    -- Loading the trophies list on the server
    -- Don't process trophies list until the first round begins to give time for server configs to load,
    -- so the trophy:Condition() function can use them to check if certain mods are installed/enabled
    hook.Add("TTTPrepareRound", "TTTTrophiesPopulateList", function()
        for _, trophy in ipairs(TTTTrophies.toRegister) do
            trophy.__index = trophy
            setmetatable(trophy, trophies_meta)
            -- Don't add trophies that don't have their required mods installed
            if not trophy:Condition() then continue end
            SetGlobalBool("TTTTrophy" .. trophy.id, true)

            -- Create an admin enabled/disable convar
            local cvar = CreateConVar("trophies_" .. trophy.id, "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

            SetGlobalBool("trophies_" .. trophy.id, cvar:GetBool())
            table.insert(convars, cvar:GetName())
            -- Apply the trophy's trigger hooks
            trophy:Trigger()
            TTTTrophies.trophies[trophy.id] = trophy
            -- Mark a trophy as role specific to give a suggestion in chat when you are that role to earn that trophy
            local role = trophy.roleMessage

            if role then
                if not TTTTrophies.roleMessage[role] then
                    TTTTrophies.roleMessage[role] = {}
                end

                table.insert(TTTTrophies.roleMessage[role], trophy.id)
            end
        end

        SetGlobalBool("TTTTrophiesServerLoaded", true)
        hook.Remove("TTTPrepareRound", "TTTTrophiesPopulateList")
    end)
else
    -- Loading the trophies list on the client
    -- Don't process trophies list until the server has loaded, and all trophy files on the client have loaded
    hook.Add("Think", "TTTTrophiesPopulateList", function()
        if GetGlobalBool("TTTTrophiesServerLoaded") then
            for _, trophy in ipairs(TTTTrophies.toRegister) do
                trophy.__index = trophy
                setmetatable(trophy, trophies_meta)
                -- Don't add trophies on the client that aren't enabled on the server
                if not GetGlobalBool("TTTTrophy" .. trophy.id) then continue end
                TTTTrophies.trophies[trophy.id] = trophy
            end

            SetGlobalBool("TTTTrophiesClientLoaded", true)
            hook.Remove("Think", "TTTTrophiesPopulateList")
        end
    end)
end