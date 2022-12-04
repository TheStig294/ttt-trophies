local TROPHY = {}
TROPHY.id = "santa"
TROPHY.title = "Christmas spirit"
TROPHY.desc = "As a Santa, get someone to open a present, and kill a traitor with a coal piece"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self.roleMessage = ROLE_SANTA
    local openedPresents = {}
    local killedATraitor = {}

    self:AddHook("TTTSantaPresentOpened", function(ply, tgt, item_id)
        openedPresents[ply] = true
    end)

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsValid(dmg:GetInflictor()) or dmg:GetInflictor():GetClass() ~= "" then return end

        if IsPlayer(attacker) and attacker:IsSanta() and TTTTrophies:IsTraitorTeam(ply) then
            killedATraitor[attacker] = true
        end
    end)

    self:AddHook("TTTEndRound", function()
        for ply, value in pairs(killedATraitor) do
            if openedPresents[ply] then
                self:Earn(ply)
            end
        end

        table.Empty(openedPresents)
        table.Empty(killedATraitor)
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_santa_enabled") and GetConVar("ttt_santa_enabled"):GetBool()
end

RegisterTTTTrophy(TROPHY)