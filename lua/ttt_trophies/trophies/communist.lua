local TROPHY = {}
TROPHY.id = "communist"
TROPHY.title = "Our win, comrade"
TROPHY.desc = "As a Communist, win with 5 or more players converted to communism"
TROPHY.rarity = 2

function TROPHY:Trigger()
    self.roleMessage = ROLE_COMMUNIST

    self:AddHook("TTTEndRound", function(result)
        local communists = {}

        for _, ply in ipairs(player.GetAll()) do
            if ply:IsCommunist() and self:IsAlive(ply) then
                table.insert(communists, ply)
            end
        end

        if #communists >= 5 then
            self:Earn(communists)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_communist_enabled") and GetConVar("ttt_communist_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)