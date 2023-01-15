-- The tab added to TTT's F1 settings menu
local hotkeyPressed = false
local earnedTrophies = {}
local unearnedTrophies = {}

surface.CreateFont("TrophyDesc", {
    font = "Arial",
    extended = false,
    size = 16,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = true,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

local hideCheckboxesCvar = CreateClientConVar("ttt_trophies_hide_enabled_checkboxes", "0", true, false, "Whether the enabled/disabled trophy checkboxes are hidden (Normally only seen by admins, an admin can hide the checkboxes from appearing in their trophies list)")

local function DrawTrophyBar(list, trophy)
    -- Don't display a trophy if it is disabled and the player is not an admin
    if not GetGlobalBool("trophies_" .. trophy.id) and not LocalPlayer():IsAdmin() then return end
    -- Icon
    local icon = list:Add("DImage")

    if not trophy.earned then
        icon:SetImage("ttt_trophies/locked64.png")
    else
        icon:SetImage("ttt_trophies/icons/" .. trophy.id .. ".png")
    end

    icon:SetSize(64, 64)
    -- Background box
    local background = list:Add("DPanel")
    background:SetSize(480, 64)
    background:DockPadding(10, 0, 10, 5)
    local alpha = 255

    if trophy.earned then
        alpha = 100
    end

    background.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(40, 40, 40, alpha))
    end

    -- Rarity icon
    local rarityIcon = vgui.Create("DImage", background)
    rarityIcon:SetImage("ttt_trophies/" .. trophy.rarity .. ".png")
    rarityIcon:SetSize(20, 20)
    rarityIcon:SetPos(5, 7)
    -- Title
    local title = vgui.Create("DLabel", background)
    title:SetText(trophy.title)
    title:SetPos(30, 5)
    title:SetFont("Trebuchet24")
    local colour

    if trophy.rarity == 1 then
        colour = Color(231, 131, 82)
    elseif trophy.rarity == 2 then
        colour = Color(192, 192, 192)
    elseif trophy.rarity == 3 then
        colour = Color(212, 175, 55)
    elseif trophy.rarity == 4 then
        colour = Color(46, 104, 165)
    end

    title:SetTextColor(colour)
    title:SizeToContents()

    -- Description
    -- Hide descriptions of hidden trophies unless the trophy is earned, or it's the platinum trophy
    if trophy.earned or (not GetGlobalBool("ttt_trophies_hide_all_trophies") and not trophy.hidden) or trophy.id == "platinum" then
        local desc = vgui.Create("DLabel", background)
        local descText = trophy.desc
        desc:SetText(descText)
        desc:Dock(BOTTOM)
        desc:SetFont("TrophyDesc")
        desc:SetTextColor(COLOUR_WHITE)
        desc:SizeToContents()
    end

    -- Enabled/disabled checkbox
    if LocalPlayer():IsAdmin() and not hideCheckboxesCvar:GetBool() then
        local enabledBox = vgui.Create("DCheckBoxLabel", background)
        enabledBox:SetText("Enabled")
        enabledBox:SetChecked(GetGlobalBool("trophies_" .. trophy.id))
        enabledBox:SetIndent(10)
        enabledBox:SizeToContents()
        enabledBox:SetPos(400, 5)

        function enabledBox:OnChange()
            net.Start("TTTTrophiesToggleConvar")
            net.WriteString("trophies_" .. trophy.id)
            net.SendToServer()
        end
    end
end

local function AdminOptionsMenu()
    if not LocalPlayer():IsAdmin() then return end
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 150)
    frame:SetTitle("Admin Options")
    frame:MakePopup()
    frame:Center()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local layout = vgui.Create("DListLayout", scroll)
    layout:Dock(FILL)
    local spacing = 10
    local text = layout:Add("DLabel")
    text:SetText("    Re-open trophies window to see changes take effect")
    text:SizeToContents()
    local padding1 = layout:Add("DPanel")
    padding1:SetBackgroundColor(COLOR_BLACK)
    padding1:SetHeight(spacing)
    local hideTrophiesBox = layout:Add("DCheckBoxLabel")
    hideTrophiesBox:SetText("Hide trophy descriptions for all players until earned")
    hideTrophiesBox:SetChecked(GetGlobalBool("ttt_trophies_hide_all_trophies"))
    hideTrophiesBox:SetIndent(spacing)
    hideTrophiesBox:SizeToContents()

    function hideTrophiesBox:OnChange()
        net.Start("TTTTrophiesToggleConvar")
        net.WriteString("ttt_trophies_hide_all_trophies")
        net.SendToServer()
    end

    local padding2 = layout:Add("DPanel")
    padding2:SetBackgroundColor(COLOR_BLACK)
    padding2:SetHeight(spacing)
    local hideEnabledBox = layout:Add("DCheckBoxLabel")
    hideEnabledBox:SetText("Hide enable/disable trophy checkboxes in trophies list\n -Only admins see the checkboxes at all\n -This setting only affects you")
    hideEnabledBox:SetConVar("ttt_trophies_hide_enabled_checkboxes")
    hideEnabledBox:SetIndent(spacing)
    hideEnabledBox:SizeToContents()
end

-- Adds the trophies list to the F1 menu
local function AddTrophiesList()
    hook.Add("TTTSettingsTabs", "TTTTrophies", function(dtabs)
        -- Base panel
        local basePnl = vgui.Create("DPanel")
        basePnl:Dock(FILL)
        basePnl:SetBackgroundColor(COLOR_BLACK)
        -- List outside the scrollbar
        local nonScrollList = vgui.Create("DIconLayout", basePnl)
        nonScrollList:Dock(TOP)
        -- Sets the space between the image and text boxes
        nonScrollList:SetSpaceY(10)
        nonScrollList:SetSpaceX(10)
        -- Sets the space between the edge of the window and the edges of the tab's contents
        nonScrollList:SetBorder(10)

        nonScrollList.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
        end

        -- Admin options menu
        local spacerPanelWidth = 200

        if LocalPlayer():IsAdmin() then
            local optionsButton = nonScrollList:Add("DButton")
            optionsButton:SetText("Admin Options")
            optionsButton:SizeToContents()
            spacerPanelWidth = spacerPanelWidth - optionsButton:GetSize()

            function optionsButton:DoClick()
                AdminOptionsMenu()
            end
        end

        local spacerPanel = nonScrollList:Add("DPanel")
        spacerPanel:SetBackgroundColor(COLOR_BLACK)
        spacerPanel:SetWidth(spacerPanelWidth)
        -- Progress bar text
        local earnedCount = 0

        for _, trophy in pairs(TTTTrophies.trophies) do
            if trophy.earned then
                earnedCount = earnedCount + 1
            end
        end

        local pctEarned = (earnedCount / table.Count(TTTTrophies.trophies)) * 100
        pctEarned = math.Round(pctEarned)
        local progressBarText = nonScrollList:Add("DLabel")
        progressBarText:SetText(pctEarned .. "% of trophies earned!")
        progressBarText:SetFont("TrophyDesc")
        progressBarText:SetTextColor(COLOUR_WHITE)
        progressBarText:SizeToContents()
        -- Progress bar
        local progressBar = nonScrollList:Add("DProgress")
        progressBar:SetFraction(pctEarned / 100)
        progressBar.OwnLine = true
        progressBar:SetSize(580, 20)
        -- Textbox for changing the hotkey to open the trophy list
        local textboxText = nonScrollList:Add("DLabel")
        textboxText:SetText("   Key that opens this window:")
        textboxText:SetFont("TrophyDesc")
        textboxText:SetTextColor(COLOUR_WHITE)
        textboxText:SizeToContents()
        local textbox = nonScrollList:Add("DTextEntry")
        textbox:SetSize(20, 20)
        textbox:SetText(GetConVar("ttt_trophies_hotkey"):GetString())

        textbox.OnLoseFocus = function(self)
            GetConVar("ttt_trophies_hotkey"):SetString(string.upper(self:GetText()))
        end

        textbox.OnEnter = function(self)
            GetConVar("ttt_trophies_hotkey"):SetString(string.upper(self:GetText()))
        end

        -- Textbox for changing the hotkey to toggle the reward for earning all trophies
        local textboxTextReward = nonScrollList:Add("DLabel")
        textboxTextReward:SetText("Key to toggle messages, or reward if all trophies earned:")
        textboxTextReward:SetFont("TrophyDesc")
        textboxTextReward:SetTextColor(COLOUR_WHITE)
        textboxTextReward:SizeToContents()
        local textboxReward = nonScrollList:Add("DTextEntry")
        textboxReward:SetSize(20, 20)
        textboxReward:SetText(GetConVar("ttt_trophies_hotkey_rainbow"):GetString())

        textboxReward.OnLoseFocus = function(self)
            GetConVar("ttt_trophies_hotkey_rainbow"):SetString(string.upper(self:GetText()))
        end

        textboxReward.OnEnter = function(self)
            GetConVar("ttt_trophies_hotkey_rainbow"):SetString(string.upper(self:GetText()))
        end

        -- Scrollbar
        local scroll = vgui.Create("DScrollPanel", basePnl)
        scroll:Dock(BOTTOM)
        scroll:SetSize(600, 280)
        -- List of trophies in scrollbar
        local list = vgui.Create("DIconLayout", scroll)
        list:Dock(FILL)
        -- Sets the space between the image and text boxes
        list:SetSpaceY(10)
        list:SetSpaceX(10)
        -- Sets the space between the edge of the window and the edges of the tab's contents
        list:SetBorder(10)

        list.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
        end

        -- Sorts the trophies by earned/unearned and rarity
        if table.IsEmpty(earnedTrophies) and table.IsEmpty(unearnedTrophies) then
            for id, trophy in pairs(TTTTrophies.trophies) do
                if trophy.earned then
                    table.insert(earnedTrophies, trophy)
                else
                    table.insert(unearnedTrophies, trophy)
                end
            end
        end

        -- The list of trophies, showing if they are earned or not
        for id, trophy in SortedPairsByMemberValue(unearnedTrophies, "rarity", false) do
            DrawTrophyBar(list, trophy)
        end

        for id, trophy in SortedPairsByMemberValue(earnedTrophies, "rarity", false) do
            DrawTrophyBar(list, trophy)
        end

        -- Adds the tab panel to TTT's F1 menu
        dtabs:AddSheet("Trophies", basePnl, "ttt_trophies/bronze16.png", false, false, "TTT Trophies/Achievements")

        if hotkeyPressed then
            hotkeyPressed = false
            dtabs:SwitchToName("Trophies")
        end
    end)
end

-- Hotkey for opening the trophies tab
CreateClientConVar("ttt_trophies_hotkey", "L", true, false, "Hotkey for opening the trophies list")
local trophiesListLoaded = false

hook.Add("PlayerButtonDown", "TTTTrophiesListHokey", function(ply, button)
    if button ~= input.GetKeyCode(GetConVar("ttt_trophies_hotkey"):GetString()) then return end

    if not trophiesListLoaded then
        chat.AddText("Trophies list will load once the next round begins")

        return
    end

    hotkeyPressed = true
    RunConsoleCommand("ttt_helpscreen")
end)

-- Prints a message to chat to say the trophies list has loaded and is ready to be used, controlled by a global bool set in cl_trophies_earn.lua
hook.Add("Think", "TTTTrophiesMessage", function()
    if GetGlobalBool("TTTTrophiesEarnedLoaded") then
        AddTrophiesList()
        trophiesListLoaded = true

        if GetConVar("ttt_trophies_chat"):GetBool() and not TTTTrophies.trophies.platinum.earned then
            chat.AddText("Press '" .. string.upper(GetConVar("ttt_trophies_hotkey"):GetString()) .. "' to open trophies list")
            chat.AddText("Press '" .. string.upper(GetConVar("ttt_trophies_hotkey_rainbow"):GetString()) .. "' to turn off trophy chat messages")
        end

        hook.Remove("Think", "TTTTrophiesMessage")
    end
end)