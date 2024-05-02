local TROPHY = {}
TROPHY.id = "paprandomat"
TROPHY.title = "Unique Upgrade"
TROPHY.desc = "Pack-a-Punch a classic randomat-only weapon"
TROPHY.rarity = 3

local randomatWeapons = {
    ["weapon_ttt_randomatclub"] = true,
    ["weapon_clearrandomat_defib"] = true,
    ["weapon_patientconf_defib"] = true,
    ["weapon_patdown_crowbar"] = true,
    ["weapon_ttt_randomatbeecannon"] = true,
    ["weapon_ttt_randomatcandycane"] = true,
    ["weapon_randomat_boxgloves"] = true,
    ["weapon_randomat_christmas_cannon"] = true,
    ["weapon_ttt_secretsantaknife"] = true,
    ["weapon_ttt_randomatdetonator"] = true,
    ["weapon_ttt_randomatknife"] = true,
    ["weapon_ttt_randomatrevolver"] = true,
    ["weapon_ttt_baguette_randomat"] = true,
    ["weapon_ttt_boomerang_randomat"] = true,
    ["weapon_ttt_duel_revolver_randomat"] = true,
    ["weapon_ttt_pistol_randomat"] = true,
    ["weapon_ttt_revolver_randomat"] = true,
    ["weapon_ttt_whoa_randomat"] = true,
    ["weapon_ttt_cloak_randomat"] = true,
    ["weapon_ttt_donconnon_randomat"] = true,
    ["weapon_ttt_knife_randomat"] = true,
    ["weapon_ttt_impostor_knife_randomat"] = true,
    ["weapon_ttt_mud_device_randomat"] = true,
    ["weapon_ttt_cracker"] = true,
    ["weapon_yeti_club"] = true
}

function TROPHY:Trigger()
    self:AddHook("TTTPAPOrder", function(ply, SWEP, UPGRADE)
        if not IsValid(SWEP) then return end
        local class = WEPS.GetClass(SWEP)

        if randomatWeapons[class] then
            self:Earn(ply)
        end
    end)
end

function TROPHY:Condition()
    return TTTPAP and TTTPAP.OrderPAP and Randomat
end

RegisterTTTTrophy(TROPHY)