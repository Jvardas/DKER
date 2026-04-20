local addon = LibStub("AceAddon-3.0"):NewAddon("DKER")
DKERIcon = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("DKERButton", {
    type = "data source",
    text = "DKER",
    icon = "Interface\\Icons\\spell_deathknight_runeweapon",
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            DKERFrame:SetShown(not DKERFrame:IsShown())
        elseif btn == "RightButton" then
            MenuUtil.CreateContextMenu(self, function(_, root)
                root:CreateTitle("DKER")
                root:CreateButton("Hide minimap button", function()
                    if DKERSettings then
                        DKERSettings.hideMinimapButton = true
                    end
                    DKER_RefreshMinimapButton()
                end)
            end)
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine("|cFFFF0000DKER|r")
        tooltip:AddLine(" ")
        tooltip:AddLine("Left-click: open / close settings")
        tooltip:AddLine("Right-click: options")
        tooltip:AddLine("Drag: reposition")
        tooltip:AddLine(" ")
        tooltip:AddLine("To restore a hidden button:", 0.6, 0.6, 0.6)
        tooltip:AddLine("/dker minimap", 0.4, 0.8, 1)
    end,
})

function DKER_RefreshMinimapButton()
    if not DKERSettings then return end

    local shouldHide = DKERSettings.hideMinimapButton or false

    if addon.db then
        addon.db.profile.minimap.hide = shouldHide
    end

    if DKERIcon then
        if shouldHide then
            DKERIcon:Hide("DKER")
        else
            DKERIcon:Show("DKER")
        end
    end
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("DKERMinimapPos", {
        profile = { minimap = { hide = false } },
    })

    if DKERSettings then
        self.db.profile.minimap.hide = DKERSettings.hideMinimapButton or false
    end

    DKERIcon:Register("DKER", miniButton, self.db.profile.minimap)
end
