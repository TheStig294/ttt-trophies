local TROPHY = {}
TROPHY.id = "randoman"
TROPHY.title = "What is happening?"
TROPHY.desc = "As a Randoman, be alive while 4 or more randomats are active"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_RANDOMAN

    self:AddHook("TTTRandomatTriggered", function(id, owner)
        if #Randomat.ActiveEvents == 4 then
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsRandoman() then
                    self:Earn(ply)
                end
            end
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_randoman_enabled") and GetConVar("ttt_randoman_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)