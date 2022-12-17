local TROPHY = {}
TROPHY.id = "rolecolours"
TROPHY.title = "Customise your colours!"
TROPHY.desc = "In the settings tab, scroll down and set your role colours setting to \"Simplified\""
TROPHY.rarity = 1

if CLIENT then
    cvars.AddChangeCallback("ttt_color_mode", function(convar, oldValue, newValue)
        if newValue == "simple" then
            if not GetGlobalBool("TTTTrophiesServerLoaded") then
                hook.Add("TTTBeginRound", "TTTTrophiesDelayRoleColoursTrophy", function()
                    if not GetGlobalBool("TTTTrophiesServerLoaded") then return end
                    net.Start("TTTTrophiesChangeRoleColours")
                    net.SendToServer()
                    hook.Remove("TTTBeginRound", "TTTTrophiesDelayRoleColoursTrophy")
                end)
            else
                net.Start("TTTTrophiesChangeRoleColours")
                net.SendToServer()
            end
        end
    end)
end

function TROPHY:Trigger()
    self.roleMessage = ROLE_GLITCH
    util.AddNetworkString("TTTTrophiesChangeRoleColours")

    net.Receive("TTTTrophiesChangeRoleColours", function(len, ply)
        self:Earn(ply)
    end)
end

function TROPHY:Condition()
    return CR_VERSION
end

RegisterTTTTrophy(TROPHY)