local TROPHY = {}
TROPHY.id = "bloxwich"
TROPHY.title = "Two for one"
TROPHY.desc = "Type \"bloxwich\" in chat"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self:AddHook("PlayerSay", function(sender, text, teamChat)
        if text == "bloxwich" then
            self:Earn(sender)
        end
    end)
end

RegisterTTTTrophy(TROPHY)