local TROPHY = {}
TROPHY.id = "basics"
TROPHY.title = "Back to basics"
TROPHY.desc = "Win a round as a traitor after buying only original TTT items"
TROPHY.rarity = 2

function TROPHY:Trigger()
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

    self:AddHook("TTTOrderedEquipment", function(ply, equ, passive)
        if not ogItem[equ] then
            newItemPlayers[ply] = true
        end
    end)

    self:AddHook("TTTEndRound", function(result)
        if result == WIN_TRAITOR then
            for _, ply in ipairs(player.GetAll()) do
                if TTTTrophies:IsTraitorTeam(ply) and not newItemPlayers[ply] then
                    self:Earn(ply)
                end
            end
        end

        table.Empty(newItemPlayers)
    end)
end

RegisterTTTTrophy(TROPHY)