local TROPHY = {}
TROPHY.id = "barnacle"
TROPHY.title = "No-one saw that..."
TROPHY.desc = "Get freed from a barnacle you placed"
TROPHY.rarity = 2

function TROPHY:Trigger()
    local caughtPlayers = {}
    local freedPlayers = {}

    self:AddHook("WeaponEquip", function(weapon, owner)
        if not IsValid(weapon) then return end

        if weapon:GetClass() == "weapon_ttt_barnacle" then
            timer.Create("TTTTrophiesCheckBarnacleCaught", 0.1, 0, function()
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsEFlagSet(EFL_IS_BEING_LIFTED_BY_BARNACLE) then
                        caughtPlayers[ply] = true
                    elseif caughtPlayers[ply] then
                        freedPlayers[ply] = true

                        timer.Simple(0.3, function()
                            caughtPlayers[ply] = false
                            freedPlayers[ply] = false
                        end)
                    end
                end
            end)
        end
    end)

    self:AddHook("OnNPCKilled", function(npc, attacker, inflictor)
        if not IsPlayer(attacker) or not IsValid(npc) then return end
        if npc:GetClass() ~= "npc_barnacle" or not IsPlayer(npc.Owner) then return end

        timer.Simple(0.2, function()
            if freedPlayers[npc.Owner] then
                self:Earn(npc.Owner)
            end
        end)
    end)

    self:AddHook("TTTPrepareRound", function()
        table.Empty(caughtPlayers)
        table.Empty(freedPlayers)
        timer.Remove("TTTTrophiesCheckBarnacleCaught")
    end)
end

function TROPHY:Condition()
    return weapons.Get("weapon_ttt_barnacle") ~= nil
end

RegisterTTTTrophy(TROPHY)