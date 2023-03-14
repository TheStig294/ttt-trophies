local TROPHY = {}
TROPHY.id = "jesterheal"
TROPHY.title = "Reverse healing"
TROPHY.desc = "As a jester, use a health station while injured to lose max health"
TROPHY.rarity = 3
TROPHY.forceDesc = true

function TROPHY:Trigger()
    self.roleMessage = ROLE_JESTER

    self:AddHook("TTTPlayerUsedHealthStation", function(ply, ent_station, healed)
        if TTTTrophies:IsJesterTeam(ply) and ply:Health() < ply:GetMaxHealth() then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_clown_enabled") and (GetConVar("ttt_jester_enabled"):GetBool() or GetConVar("ttt_swapper_enabled"):GetBool() or GetConVar("ttt_clown_enabled"):GetBool() or GetConVar("ttt_beggar_enabled"):GetBool() or GetConVar("ttt_bodysnatcher_enabled"):GetBool() or GetConVar("ttt_lootgoblin_enabled"):GetBool())
end

RegisterTTTTrophy(TROPHY)