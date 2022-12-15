local TROPHY = {}
TROPHY.id = "fastweaponswitch"
TROPHY.title = "Fast weapon switch!"
TROPHY.desc = "In the settings tab above, turn on the 'Fast weapon switch' checkbox"
TROPHY.rarity = 1

if CLIENT then
    cvars.AddChangeCallback("ttt_weaponswitcher_fast", function(convar, oldValue, newValue)
        if newValue == "1" then
            if not GetGlobalBool("TTTTrophiesServerLoaded") then
                hook.Add("TTTBeginRound", "TTTTrophiesDelayFastWeaponsTrophy", function()
                    net.Start("TTTTrophiesChangeFastWeapons")
                    net.SendToServer()
                    hook.Remove("TTTBeginRound", "TTTTrophiesDelayFastWeaponsTrophy")
                end)
            else
                net.Start("TTTTrophiesChangeFastWeapons")
                net.SendToServer()
            end
        end
    end)
end

function TROPHY:Trigger()
    util.AddNetworkString("TTTTrophiesChangeFastWeapons")

    net.Receive("TTTTrophiesChangeFastWeapons", function(len, ply)
        self:Earn(ply)
    end)
end

RegisterTTTTrophy(TROPHY)