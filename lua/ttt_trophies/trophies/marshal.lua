local TROPHY = {}
TROPHY.id = "marshal"
TROPHY.title = "...but I did not kill the deputy!"
TROPHY.desc = "As a Marshal, win a round with a player you promoted still alive"
TROPHY.rarity = 2

-- Condition for trophy to work
function TROPHY:Condition()
    return ConVarExists("ttt_marshal_enabled") and GetConVar("ttt_marshal_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)