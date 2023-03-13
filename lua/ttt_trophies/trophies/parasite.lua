local TROPHY = {}
TROPHY.id = "parasite"
TROPHY.title = "How's your tummy feeling?"
TROPHY.desc = "As a Parasite, win the round within 2 seconds of taking over a player"
TROPHY.rarity = 3

function TROPHY:Trigger()
    local parasiteKillers = {}

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        print(attacker, dmg:GetInflictor(), attacker:IsParasite())
        print("Position:", dmg:GetReportedPosition(), "Ammo type:", dmg:GetAmmoType(), "Damage type:", dmg:GetDamageType())
        if not IsPlayer(attacker) then return end
        local inflictor = dmg:GetInflictor()
        if not IsValid(inflictor) and inflictor:IsPlayer() then return end

        if attacker == inflictor and dmg:GetAmmoType() == -1 and dmg:GetDamageType() == DMG_NEVERGIB and dmg:GetReportedPosition() == Vector(0, 0, 0) then
            parasiteKillers[ply] = true

            timer.Simple(2, function()
                parasiteKillers[ply] = false
            end)
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for ply, value in pairs(parasiteKillers) do
                if value == true then
                    self:Earn(ply)
                end
            end
        end
    end)
end

function TROPHY:Condition()
    return ConVarExists("ttt_parasite_enabled") and GetConVar("ttt_parasite_enabled"):GetBool()
end
-- RegisterTTTTrophy(TROPHY)