-- The popup that appears on the top right of the screen when you earn a trophy
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

local function TrophyPopup(trophyID)
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
        titleText = string.Left(titleText, 21) .. "..."
    end

    local bottomText = {
        text = titleText,
        font = "TTTTrophyPopup",
        pos = {leftEdge + offSet + iconSize + offSet + rarityIconSize + 2, topEdge + offSet + fontSize + offSet}
    }

    local alpha = 0
    surface.PlaySound("ttt_trophies/trophypop.mp3")

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
end

-- A buffer to prevent trophy popups from appearing on top of each other
local buffer = {}
local secondsPassed = 0
-- Time between trophy popups
local secondsPadding = 6
-- PlayStation trophies had a delay of 6 seconds before the popup showed (on the PS3), this delay emulates that
local delay = 6

net.Receive("TTTDoTrophyPopup", function()
    local id = net.ReadString()

    if table.IsEmpty(buffer) or buffer == {} then
        buffer[delay] = id
    else
        buffer[table.Count(buffer) * secondsPadding + delay] = id
    end

    timer.Create("TTTTrophyPopupBuffer", secondsPadding, 0, function()
        secondsPassed = secondsPassed + secondsPadding
        local trophy = buffer[secondsPassed]

        if trophy then
            TrophyPopup(trophy)
        end

        if (table.Count(buffer) - 1) * secondsPadding + delay <= secondsPassed then
            table.Empty(buffer)
            secondsPassed = 0
            timer.Remove("TTTTrophyPopupBuffer")

            return
        end
    end)
end)