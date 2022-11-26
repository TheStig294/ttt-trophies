local fontSize = 22

surface.CreateFont("TTTTrophyPopup", {
    font = "Arial",
    extended = false,
    size = fontSize,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false,
})

local soundAndDelay = CreateClientConVar("ttt_trophies_sound_and_delay", "1", true, false, "Whether there should be a delay and sound played when a trophy is earned")

net.Receive("TTTDoTrophyPopup", function()
    local trophyID = net.ReadString()
    local trophy = TTTTrophies.trophies[trophyID]
    -- Drawing the popup
    local width = 360
    local height = 85
    local leftEdge = ScrW() - width - 80
    local topEdge = 50
    local icon = Material("ttt_trophies/icons/" .. trophyID .. ".png", "noclamp smooth")
    local rarityIcon = Material("ttt_trophies/" .. trophy.rarity .. ".png", "noclamp smooth")
    local greyColour = Color(66, 66, 66)
    local offSet = 10
    local iconSize = 64
    local rarityIconSize = 20

    local topText = {
        text = "You have earned a trophy.",
        font = "TTTTrophyPopup",
        pos = {leftEdge + offSet + iconSize + offSet, topEdge + height / 2 - fontSize - 3}
    }

    local titleText = trophy.title
    surface.SetFont("TTTTrophyPopup")
    local textWidth = surface.GetTextSize(titleText)
    surface.SetFont("Default")

    if textWidth > 244 then
        titleText = string.Left(titleText, 25) .. "..."
    end

    local bottomText = {
        text = titleText,
        font = "TTTTrophyPopup",
        pos = {leftEdge + offSet + iconSize + offSet + rarityIconSize + 2, topEdge + offSet + fontSize + offSet}
    }

    local alpha = 0
    local delay = 0

    if soundAndDelay:GetBool() then
        delay = 6
    end

    -- Emulating the trophy popup delay from the old playstation 3 days...
    timer.Simple(delay, function()
        if soundAndDelay:GetBool() then
            surface.PlaySound("ttt_trophies/trophypop.mp3")
        end

        timer.Create("TTTTrophyPopupFadeIn", 0.01, 10, function()
            alpha = alpha + 0.1
        end)

        hook.Add("DrawOverlay", "TTTTrophyPopup", function()
            surface.SetAlphaMultiplier(alpha)
            -- Background box
            draw.RoundedBox(10, leftEdge, topEdge, width, height, greyColour)
            -- Icon
            surface.SetMaterial(icon)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(leftEdge + offSet, topEdge + offSet, iconSize, iconSize)
            -- Rarity Icon
            surface.SetMaterial(rarityIcon)
            surface.DrawTexturedRect(leftEdge + offSet + iconSize + offSet, topEdge + offSet + fontSize + offSet, rarityIconSize, rarityIconSize)
            -- Top text
            draw.TextShadow(topText, 2, 200)
            draw.Text(topText)
            -- Bottom text
            draw.TextShadow(bottomText, 2, 200)
            draw.Text(bottomText)
            surface.SetAlphaMultiplier(1)
        end)

        timer.Simple(5, function()
            timer.Create("TTTTrophyPopupFadeOut", 0.01, 10, function()
                alpha = alpha - 0.1
            end)

            timer.Simple(0.1, function()
                hook.Remove("HUDPaint", "TTTTrophyPopup")
            end)
        end)
    end)
end)