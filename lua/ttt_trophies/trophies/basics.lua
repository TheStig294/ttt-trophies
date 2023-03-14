local TROPHY = {}
TROPHY.id = "basics"
TROPHY.title = "Back to basics"
TROPHY.desc = "As a traitor, win a round after buying only original TTT items"
TROPHY.rarity = 1

function TROPHY:Trigger()
    self.roleMessage = ROLE_TRAITOR

    local ogItem = {
        [EQUIP_ARMOR] = true,
        [EQUIP_RADAR] = true,
        [EQUIP_DISGUISE] = true,
        ["weapon_ttt_cse"] = true,
        ["weapon_ttt_defuser"] = true,
        ["weapon_ttt_teleport"] = true,
        ["weapon_ttt_binoculars"] = true,
        ["weapon_ttt_stungun"] = true,
        ["weapon_ttt_health_station"] = true,
        ["weapon_ttt_flaregun"] = true,
        ["weapon_ttt_knife"] = true,
        ["weapon_ttt_teleport"] = true,
        ["weapon_ttt_radio"] = true,
        ["weapon_ttt_push"] = true,
        ["weapon_ttt_sipistol"] = true,
        ["weapon_ttt_decoy"] = true,
        ["weapon_ttt_c4"] = true,
        ["weapon_ttt_phammer"] = true
    }

    local newItemPlayers = {}
    local boughtItemPlayers = {}

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive, from_randomat)
        if from_randomat then return end
        if not TTTTrophies:IsTraitorTeam(ply) then return end
        boughtItemPlayers[ply] = true

        if not ogItem[equ] then
            newItemPlayers[ply] = true
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for _, ply in ipairs(player.GetAll()) do
                if boughtItemPlayers[ply] and not newItemPlayers[ply] then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(newItemPlayers)
        table.Empty(boughtItemPlayers)
    end)
end

RegisterTTTTrophy(TROPHY)