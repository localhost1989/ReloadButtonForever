-- One Click Reload: a minimap button that reloads the user interface.
local ru = GetLocale() == "ruRU"
local function T(en, russian) return ru and russian or en end

local ICON = "Interface\\AddOns\\ReloadButtonForever\\Media\\Icon"

local function reload()
    ReloadUI()
end

local button = CreateFrame("Button", "ReloadButtonForeverMinimapButton", Minimap)
button:SetSize(31, 31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
button:RegisterForClicks("LeftButtonUp")
button:RegisterForDrag("LeftButton")
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

-- Classic round minimap button (LibDBIcon geometry): dark disc, icon, golden ring.
local background = button:CreateTexture(nil, "BACKGROUND")
background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
background:SetSize(20, 20)
background:SetPoint("TOPLEFT", 7, -5)
local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetTexture(ICON)
icon:SetSize(17, 17)
icon:SetPoint("TOPLEFT", 7, -6)
local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(53, 53)
border:SetPoint("TOPLEFT")

local function db()
    if type(ReloadButtonForeverDB) ~= "table" then ReloadButtonForeverDB = {} end
    return ReloadButtonForeverDB
end
local function place(angle)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * (Minimap:GetWidth() / 2 + 5),
        math.sin(angle) * (Minimap:GetHeight() / 2 + 5))
end
local function restore()
    place(tonumber(db().angle) or math.rad(200))
end

local dragging
button:SetScript("OnDragStart", function(self)
    dragging = true
    GameTooltip:Hide()
    self:SetScript("OnUpdate", function()
        local cx, cy = Minimap:GetCenter()
        if not cx or not cy then return end
        local x, y = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        local angle = math.atan2(y / scale - cy, x / scale - cx)
        db().angle = angle
        place(angle)
    end)
end)
local function stopDrag(self)
    self:SetScript("OnUpdate", nil)
end
button:SetScript("OnDragStop", stopDrag)
button:SetScript("OnHide", stopDrag)
button:SetScript("OnMouseDown", function() dragging = false; icon:SetPoint("TOPLEFT", 8, -7) end)
button:SetScript("OnMouseUp", function() icon:SetPoint("TOPLEFT", 7, -6) end)
button:SetScript("OnClick", function()
    if dragging then return end
    reload()
end)
button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(T("Reload UI", "Перезагрузить интерфейс"))
    GameTooltip:AddLine(T("Click to reload  —  /rl", "Нажмите, чтобы перезагрузить  •  /rl"), 1, 1, 1)
    GameTooltip:AddLine(T("Drag to move.", "Перетащите, чтобы переместить."))
    GameTooltip:Show()
end)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
    restore()
    Minimap:HookScript("OnSizeChanged", restore)
end)

SLASH_RELOADBUTTONFOREVER1 = "/rl"
SLASH_RELOADBUTTONFOREVER2 = "/reloadbutton"
SlashCmdList.RELOADBUTTONFOREVER = reload
