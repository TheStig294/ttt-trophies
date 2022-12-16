local TROPHY = {}
TROPHY.id = "traitorchat"
TROPHY.title = "Super secret traitor chat!"
TROPHY.desc = "Communicate to your fellow traitors in secret using \"traitor chat\" (Press 'U')"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    self:AddHook("PlayerSay", function(ply, txt, teamChat)
        if teamChat and TTTTrophies:IsTraitorTeam(ply) then
            self:Earn(ply)
        end
    end)
end

RegisterTTTTrophy(TROPHY)