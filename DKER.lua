local ADDON_NAME = "DKER"
local SPECS = { "Blood", "Frost", "Unholy" }

-- DK-specific weapon enchant (rune) IDs.
-- Verify TWW additions in-game: /run print(select(4, GetWeaponEnchantInfo()))
local ENCHANTS = {
    { id = 0,    name = "None" },
    { id = 3368, name = "Rune of the Fallen Crusader" },
    { id = 3370, name = "Rune of Razorice" },
    { id = 3847, name = "Rune of the Stoneskin Gargoyle" },
    { id = 3369, name = "Rune of Swordshattering" },
    { id = 6241, name = "Rune of the Apocalypse" },   -- verify ID in-game
    { id = 6586, name = "Rune of Unending Thirst" },  -- verify ID in-game
    { id = 6587, name = "Rune of Spellwarding" },     -- verify ID in-game
}


-- ============================================================
-- Saved Variables
-- ============================================================
local function InitSettings()
    if type(DKERSettings) ~= "table" then
        DKERSettings = {
            Blood  = { mh = 0, oh = 0 },
            Frost  = { mh = 0, oh = 0 },
            Unholy = { mh = 0, oh = 0 },
            hideMinimapButton = false,
        }
    end
    for _, spec in ipairs(SPECS) do
        if type(DKERSettings[spec]) ~= "table" then
            DKERSettings[spec] = { mh = 0, oh = 0 }
        end
    end
end

-- ============================================================
-- Warning frame — red text, bobs up and down for 5 seconds
-- ============================================================
local warnFrame = CreateFrame("Frame", nil, UIParent)
warnFrame:SetSize(700, 60)
warnFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
warnFrame:SetFrameStrata("HIGH")
warnFrame:Hide()

local warnText = warnFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
warnText:SetAllPoints()
warnText:SetTextColor(1, 0, 0, 1)
warnText:SetJustifyH("CENTER")

local bobAnim = warnFrame:CreateAnimationGroup()
bobAnim:SetLooping("BOUNCE")
local moveUp = bobAnim:CreateAnimation("Translation")
moveUp:SetDuration(0.45)
moveUp:SetOffset(0, 12)
moveUp:SetSmoothing("IN_OUT")

local function ShowWarning(msg)
    warnText:SetText(msg)
    warnFrame:Show()
    bobAnim:Play()
    C_Timer.After(5, function()
        bobAnim:Stop()
        warnFrame:Hide()
    end)
end

-- ============================================================
-- Enchant check
-- ============================================================
local function GetEnchantName(id)
    for _, e in ipairs(ENCHANTS) do
        if e.id == id then return e.name end
    end
    return "Unknown"
end

local function CheckEnchant()
    if not IsInGroup() then return end

    local specIndex = GetSpecialization()
    if not specIndex then return end
    local specName = SPECS[specIndex]

    local settings = DKERSettings and DKERSettings[specName]
    if not settings then return end

    local expectedMH = settings.mh or 0
    local expectedOH = settings.oh or 0
    if expectedMH == 0 and expectedOH == 0 then return end

    local hasMain, _, _, mainId, hasOff, _, _, offId = GetWeaponEnchantInfo()
    local currentMH = hasMain and mainId or 0
    local currentOH = hasOff and offId or 0

    local msgs = {}
    if expectedMH ~= 0 and currentMH ~= expectedMH then
        table.insert(msgs, "MH: " .. GetEnchantName(expectedMH))
    end
    if expectedOH ~= 0 and currentOH ~= expectedOH then
        table.insert(msgs, "OH: " .. GetEnchantName(expectedOH))
    end

    if #msgs > 0 then
        ShowWarning("WRONG ENCHANT! Expected: " .. table.concat(msgs, " | "))
    end
end

-- ============================================================
-- Settings frame
-- ============================================================
local FRAME_W = 530
local FRAME_H = 205

local frame = CreateFrame("Frame", "DKERFrame", UIParent, "BackdropTemplate")
frame:SetSize(FRAME_W, FRAME_H)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetToplevel(true)
frame:SetFrameStrata("DIALOG")
frame:Hide()
table.insert(UISpecialFrames, "DKERFrame")

frame:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
frame:SetBackdropColor(0.04, 0.04, 0.04, 0.85)
frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

local headerBg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
headerBg:SetTexture("Interface\\Buttons\\WHITE8X8")
headerBg:SetVertexColor(0.06, 0.06, 0.06, 1)
headerBg:SetPoint("TOPLEFT",  frame, "TOPLEFT",   4, -4)
headerBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT",  -4, -4)
headerBg:SetHeight(34)

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -12)
titleText:SetText("|cFFFF0000DKER|r – Weapon Enchant Reminder")

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

local mhHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
mhHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 148, -43)
mhHeader:SetText("Main Hand")
mhHeader:SetTextColor(0.8, 0.8, 0.8, 1)

local ohHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
ohHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 343, -43)
ohHeader:SetText("Off Hand")
ohHeader:SetTextColor(0.8, 0.8, 0.8, 1)

local dropdowns = {}

local function CreateSpecRow(specName, rowIndex)
    local yOff = -57 - (rowIndex - 1) * 44

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, yOff + 4)
    label:SetText(specName)

    dropdowns[specName] = {}

    for i, slot in ipairs({ "mh", "oh" }) do
        local xOff = (i == 1) and 100 or 295
        local ddName = "DKER_" .. specName .. "_" .. slot
        local dd = CreateFrame("Frame", ddName, frame, "UIDropDownMenuTemplate")
        dd:SetPoint("TOPLEFT", frame, "TOPLEFT", xOff, yOff)
        UIDropDownMenu_SetWidth(dd, 155)
        UIDropDownMenu_Initialize(dd, function()
            for _, enchant in ipairs(ENCHANTS) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = enchant.name
                info.value = enchant.id
                info.notCheckable = true
                info.func = function()
                    DKERSettings[specName][slot] = enchant.id
                    UIDropDownMenu_SetText(dd, enchant.name)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        dropdowns[specName][slot] = dd
    end
end

for i, spec in ipairs(SPECS) do
    CreateSpecRow(spec, i)
end

frame:SetScript("OnShow", function()
    if not DKERSettings then return end
    for _, specName in ipairs(SPECS) do
        for _, slot in ipairs({ "mh", "oh" }) do
            local dd = dropdowns[specName] and dropdowns[specName][slot]
            if dd then
                local id = DKERSettings[specName] and DKERSettings[specName][slot] or 0
                for _, e in ipairs(ENCHANTS) do
                    if e.id == id then
                        UIDropDownMenu_SetText(dd, e.name)
                        break
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- Slash command
-- ============================================================
SLASH_DKER1 = "/dker"
SlashCmdList["DKER"] = function(msg)
    if msg and msg:lower() == "minimap" then
        if DKERSettings then
            DKERSettings.hideMinimapButton = false
        end
        if DKER_RefreshMinimapButton then
            DKER_RefreshMinimapButton()
        end
        print("|cFFFF0000DKER|r: minimap button shown.")
    else
        frame:SetShown(not frame:IsShown())
    end
end

-- ============================================================
-- Events
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GROUP_JOINED")
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitSettings()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "GROUP_JOINED"
        or (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player")
        or event == "PLAYER_SPECIALIZATION_CHANGED" then
        CheckEnchant()
    end
end)
