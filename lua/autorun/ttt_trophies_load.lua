-- The global table used by the client and server to access all trophy data
TTTTrophies = {}
TTTTrophies.trophies = {}
TTTTrophies.earned = {}
TTTTrophies.toMessage = {}
TTTTrophies.toRegister = {}
-- Creating a fake class of "TROPHY" using metatables, borrowed from the randomat's "EVENT" class
local trophies_meta = {}
trophies_meta.__index = trophies_meta

if SERVER then
    util.AddNetworkString("TTTEarnTrophy")

    function trophies_meta:Earn(plys)
        if not istable(plys) then
            plys = {plys}
        end

        for _, ply in ipairs(plys) do
            local plyID = ply:SteamID()
            -- Don't earn trophies that are already earned
            if TTTTrophies.earned[plyID] and TTTTrophies.earned[plyID][self.id] then return end
            -- Add the player to the earnedTrophies table if they haven't earned a trophy before
            TTTTrophies.earned[plyID] = TTTTrophies.earned[plyID] or {}
            -- Make the trophy as earned
            TTTTrophies.earned[plyID][self.id] = true
            -- Also mark the trophy to show a message at the end of the round
            TTTTrophies.toMessage[plyID] = TTTTrophies.toMessage[plyID] or {}
            table.insert(TTTTrophies.toMessage[plyID], self.id)
            -- Show the earned trophy popup for the player
            net.Start("TTTEarnTrophy")
            net.WriteString(self.id)
            net.Send(ply)
        end
    end
end

function trophies_meta:Trigger()
end

function trophies_meta:Condition()
    return true
end

-- These 3 functions are from Malivil's randomat mod
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

function trophies_meta:CleanUpHooks()
    if not self.Hooks then return end

    for _, ahook in ipairs(self.Hooks) do
        hook.Remove(ahook[1], ahook[2])
    end

    table.Empty(self.Hooks)
end

if SERVER then
    function RegisterTTTTrophy(trophy)
        table.insert(TTTTrophies.toRegister, trophy)
    end

    hook.Add("InitPostEntity", "TTTTrophiesPopulateList", function()
        for _, trophy in ipairs(TTTTrophies.toRegister) do
            trophy.__index = trophy
            setmetatable(trophy, trophies_meta)
            -- Don't add trophies that don't have their required mods installed
            if not trophy:Condition() then return end
            SetGlobalBool("TTTTrophy" .. trophy.id, true)
            -- Apply the trophy's trigger hooks
            trophy:Trigger()
            TTTTrophies.trophies[trophy.id] = trophy
        end
    end)
else
    function RegisterTTTTrophy(trophy)
        table.insert(TTTTrophies.toRegister, trophy)
    end

    hook.Add("InitPostEntity", "TTTTrophiesPopulateList", function()
        for _, trophy in ipairs(TTTTrophies.toRegister) do
            trophy.__index = trophy
            setmetatable(trophy, trophies_meta)
            -- Don't add trophies on the client that aren't enabled on the server
            if not GetGlobalBool("TTTTrophy" .. trophy.id) then return end
            TTTTrophies.trophies[trophy.id] = trophy
        end
    end)
end

-- Reading all trophy lua files and adding them to the global table
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
AddClient("ttt_trophies/cl_trophies_earn.lua")
AddClient("ttt_trophies/cl_trophies_f1_tab.lua")
AddClient("ttt_trophies/cl_trophy_popup.lua")
local files, _ = file.Find("ttt_trophies/trophies/*.lua", "LUA")

for _, fil in ipairs(files) do
    AddServer("ttt_trophies/trophies/" .. fil)
    AddClient("ttt_trophies/trophies/" .. fil)
end