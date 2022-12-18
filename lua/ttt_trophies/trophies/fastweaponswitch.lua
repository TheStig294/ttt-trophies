local TROPHY = {}
TROPHY.id = "fastweaponswitch"
TROPHY.title = "Fast weapon switch!"
TROPHY.desc = "In the settings tab, turn on the checkbox for \"Fast weapon switch\""
TROPHY.rarity = 1

if CLIENT then
    hook.Add("TTTBeginRound", "TTTTrophiesDelayFastWeaponsTrophy", function()
        cvars.AddChangeCallback("ttt_weaponswitcher_fast", function(convar, oldValue, newValue)
            if newValue == "1" then
                if not GetGlobalBool("TTTTrophiesServerLoaded") then
                    if not GetGlobalBool("TTTTrophiesServerLoaded") then return end
                    net.Start("TTTTrophiesChangeFastWeapons")
                    net.SendToServer()
                else
                    net.Start("TTTTrophiesChangeFastWeapons")
                    net.SendToServer()
                end
            end
        end)

        hook.Remove("TTTBeginRound", "TTTTrophiesDelayFastWeaponsTrophy")
    end)
end

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT
    util.AddNetworkString("TTTTrophiesChangeFastWeapons")

    net.Receive("TTTTrophiesChangeFastWeapons", function(len, ply)
        self:Earn(ply)
    end)
end

RegisterTTTTrophy(TROPHY)