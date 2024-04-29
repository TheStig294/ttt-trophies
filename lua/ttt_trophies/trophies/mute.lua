local TROPHY = {}
TROPHY.id = "mute"
TROPHY.title = "Don't wanna hear this noise"
TROPHY.desc = "Use the mute button to mute and unmute music (Press 'M')"
TROPHY.rarity = 1

if SERVER then
    util.AddNetworkString("TTTTrophyMusicMuteButton")
end

if CLIENT then
    hook.Add("TTTMusicMuteButton", "TTTTrophiesMusicMuteButton", function()
        net.Start("TTTTrophyMusicMuteButton")
        net.SendToServer()
    end)
end

function TROPHY:Trigger()
    self.roleMessage = ROLE_INNOCENT

    net.Receive("TTTTrophyMusicMuteButton", function(len, ply)
        self:Earn(ply)
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_music_mute_m_button") and GetConVar("ttt_music_mute_m_button"):GetBool()
end

RegisterTTTTrophy(TROPHY)