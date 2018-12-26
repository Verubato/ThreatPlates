local ADDON_NAME, Addon = ...

---------------------------------------------------------------------------------------------------
-- Element: Warning Glow for Threat
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Imported functions and constants
---------------------------------------------------------------------------------------------------

-- Lua APIs

-- WoW APIs
local CreateFrame = CreateFrame

-- ThreatPlates APIs

local OFFSET_THREAT = 7.5
local ART_PATH = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Artwork\\"

local Element = Addon.Elements.NewElement("ThreatGlow")

-- Called in processing event: NAME_PLATE_CREATED
function Element.Created(tp_frame)
  local element_frame = CreateFrame("Frame", nil, tp_frame)

  element_frame:SetFrameLevel(tp_frame:GetFrameLevel())

  element_frame:SetPoint("TOPLEFT", tp_frame, "TOPLEFT", - OFFSET_THREAT, OFFSET_THREAT)
  element_frame:SetPoint("BOTTOMRIGHT", tp_frame, "BOTTOMRIGHT", OFFSET_THREAT, - OFFSET_THREAT)
  element_frame:SetBackdrop({
    edgeFile = ART_PATH .. "TP_Threat",
    edgeSize = 12,
    --insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })

  element_frame:SetBackdropBorderColor(0, 0, 0, 0) -- Transparent color as default

  tp_frame.visual.ThreatGlow = element_frame
end

-- Called in processing event: NAME_PLATE_UNIT_ADDED
function Element.UnitAdded(tp_frame)
end

-- Called in processing event: NAME_PLATE_UNIT_REMOVED
function Element.UnitRemoved(tp_frame)
  tp_frame.visual.ThreatGlow:Hide()
end

function Element.UpdateStyle(tp_frame, style)
end


function Element.ThreatUpdate(tp_frame, unit)
  print ("ThreatGlow: ThreatUpdate - Threat update for unit ", unit.unitid)

  local threatglow = tp_frame.visual.ThreatGlow
  if unit.ThreatStatus and tp_frame.style.threatborder.show then
    print ("unit.ThreatLevel ", unit.ThreatLevel)
    print ("Showing: ", Addon:SetThreatColor(unit))
    threatglow:SetBackdropBorderColor(Addon:SetThreatColor(unit))
    threatglow:Show()
  else
    print ("Hiding")
    threatglow:Hide()
  end
end

Addon.EventService.Subscribe(Element, "ThreatUpdate", Element.ThreatUpdate)