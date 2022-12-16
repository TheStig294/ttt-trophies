local TROPHY = {}
TROPHY.id = "crowbarpush"
TROPHY.title = "The pusher strikes again"
TROPHY.desc = "Get a kill with a crowbar push"
TROPHY.rarity = 3

function TROPHY:Trigger()
    self:AddHook("EntityTakeDamage", function(ent, dmg)
        if not ent.was_pushed or not IsPlayer(ent) then return end
        local attacker = ent.was_pushed.att
        local inflictor = ent.was_pushed.wep
        if not IsPlayer(attacker) or inflictor ~= "weapon_zm_improvised" then return end
        -- In vanilla TTT the crowbar stores the time a player was pushed with a crowbar
        local timePushed = ent.was_pushed.t

        -- If the player was pushed within 5 seconds of dying, give the pusher the credit for the kill
        if timePushed and CurTime() - timePushed < 5 then
            timer.Simple(0.1, function()
                if IsValid(attacker) and IsValid(ent) and not self:IsAlive(ent) then
                    self:Earn(attacker)
                end
            end)
        end
    end)
end

RegisterTTTTrophy(TROPHY)