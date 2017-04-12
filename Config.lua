local ADDON_NAME, NAMESPACE = ...
local ThreatPlates = NAMESPACE.ThreatPlates

---------------------------------------------------------------------------------------------------
-- Stuff for handling the configuration of Threat Plates - ThreatPlatesDB
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Imported functions and constants
---------------------------------------------------------------------------------------------------
local L = ThreatPlates.L
local RGB = ThreatPlates.RGB

---------------------------------------------------------------------------------------------------
-- Color definitions
---------------------------------------------------------------------------------------------------

ThreatPlates.COLOR_TAPPED = RGB(110, 110, 110, 1)	-- grey
ThreatPlates.COLOR_TRANSPARENT = RGB(0, 0, 0, 0, 0) -- opaque
ThreatPlates.COLOR_DC = RGB(128, 128, 128, 1) -- dray, darker than tapped color
ThreatPlates.COLOR_FRIEND = RGB(29, 39, 61) -- Blizzard friend dark blue
ThreatPlates.COLOR_GUILD = RGB(60, 168, 255) -- light blue

---------------------------------------------------------------------------------------------------
-- Global contstants for options
---------------------------------------------------------------------------------------------------

ThreatPlates.ANCHOR_POINT = { TOPLEFT = "Top Left", TOP = "Top", TOPRIGHT = "Top Right", LEFT = "Left", CENTER = "Center", RIGHT = "Right", BOTTOMLEFT = "Bottom Left", BOTTOM = "Bottom ", BOTTOMRIGHT = "Bottom Right" }
ThreatPlates.ANCHOR_POINT_SETPOINT = {
  TOPLEFT = {"TOPLEFT", "BOTTOMLEFT"},
  TOP = {"TOP", "BOTTOM"},
  TOPRIGHT = {"TOPRIGHT", "BOTTOMRIGHT"},
  LEFT = {"LEFT", "RIGHT"},
  CENTER = {"CENTER", "CENTER"},
  RIGHT = {"RIGHT", "LEFT"},
  BOTTOMLEFT = {"BOTTOMLEFT", "TOPLEFT"},
  BOTTOM = {"BOTTOM", "TOP"},
  BOTTOMRIGHT = {"BOTTOMRIGHT", "TOPRIGHT"}
}

ThreatPlates.ENEMY_TEXT_COLOR = {
  CLASS = "By Class",
  CUSTOM = "By Custom Color",
  REACTION = "By Reaction",
  HEALTH = "By Health",
}
-- "By Threat", "By Level Color", "By Normal/Elite/Boss"
ThreatPlates.FRIENDLY_TEXT_COLOR = {
  CLASS = "By Class",
  CUSTOM = "By Custom Color",
  REACTION = "By Reaction",
  HEALTH = "By Health",
}
ThreatPlates.ENEMY_SUBTEXT = {
  NONE = "None",
  HEALTH = "Percent Health",
  ROLE = "NPC Role",
  ROLE_GUILD = "NPC Role, Guild",
  ROLE_GUILD_LEVEL = "NPC Role, Guild, or Level",
  LEVEL = "Level",
  ALL = "Everything"
}
-- NPC Role, Guild, or Quest", "Quest",
ThreatPlates.FRIENDLY_SUBTEXT = {
  NONE = "None",
  HEALTH = "Percent Health",
  ROLE = "NPC Role",
  ROLE_GUILD = "NPC Role, Guild",
  ROLE_GUILD_LEVEL = "NPC Role, Guild, or Level",
  LEVEL = "Level",
  ALL = "Everything"
}
-- "NPC Role, Guild, or Quest", "Quest"

---------------------------------------------------------------------------------------------------
-- Global functions for accessing the configuration
---------------------------------------------------------------------------------------------------

local function GetUnitVisibility(unit_type)
  local unit_visibility = TidyPlatesThreat.db.profile.Visibility[unit_type]

  local show = unit_visibility.Show
  if type(show) ~= "boolean" then
    show = (GetCVar(show) == "1")
  end

  return show, unit_visibility.UseHeadlineView
end

---------------------------------------------------------------------------------------------------
-- Functions for configuration migration
---------------------------------------------------------------------------------------------------
local function UpdateDefaultProfile()
  local db = TidyPlatesThreat.db

  -- change the settings of the default profile
  local current_profile = db:GetCurrentProfile()
  db:SetProfile("Default")

  db.profile.optionRoleDetectionAutomatic = true
  db.profile.debuffWidget.ON = false
  db.profile.ShowThreatGlowOnAttackedUnitsOnly = true
  db.profile.AuraWidget.ON = true
  db.profile.text.amount = false
  db.profile.settings.healthborder.texture = "TP_HealthBarOverlayThin"
  db.profile.settings.healthbar.texture = "Aluminium"
  db.profile.settings.castbar.texture = "Aluminium"
  db.profile.settings.name.typeface = "Friz Quadrata TT"
  db.profile.settings.name.size = 10
  db.profile.settings.name.y = 14
  db.profile.settings.level.typeface = "Friz Quadrata TT"
  db.profile.settings.level.size = 9
  db.profile.settings.level.width = 22
  db.profile.settings.level.x = 48
  db.profile.settings.level.y = 0
  db.profile.settings.level.vertical = "CENTER"
  db.profile.settings.customtext.typeface = "Friz Quadrata TT"
  db.profile.settings.customtext.size = 9
  db.profile.settings.customtext.y = 0
  db.profile.settings.spelltext.typeface = "Friz Quadrata TT"
  db.profile.settings.spelltext.size = 8
  db.profile.settings.spelltext.y = -15
  db.profile.settings.eliteicon.show = false
  db.profile.threat.useScale = false
  db.profile.threat.art.ON = false
  db.profile.questWidget.ON = true
  db.profile.questWidget.ModeHPBar = false

  db:SetProfile(current_profile)

  if current_profile == "Default" then
    ThreatPlates.SetThemes(TidyPlatesThreat)
    TidyPlates:ForceUpdate()
  end
end

--local function UpdateSettingValue(old_setting, key, new_setting, new_key)
--  if not new_key then
--    new_key = key
--  end
--
--  local value = old_setting[key]
--  if value then
--    if type(value) == "table" then
--      new_setting[new_key] = t.CopyTable(value)
--    else
--      new_setting[new_key] = value
--    end
--  end
--end

--local function ConvertHeadlineView(profile)
--  -- convert old entry and save it
--  if not profile.headlineView then
--    profile.headlineView = {}
--  end
--  profile.headlineView.enabled = old_value
--  -- delete old entry
--end
--
---- Entries in the config db that should be migrated and deleted
--local DEPRECATED_DB_ENTRIES = {
--  alphaFeatures = true,
--  optionSpecDetectionAutomatic = true,
--  alphaFeatureHeadlineView = ConvertHeadlineView, -- migrate to headlineView.enabled
--}
--
---- Remove all deprected Entries
---- Called whenever the addon is loaded and a new version number is detected
--local function DeleteDeprecatedEntries()
--  -- determine current addon version and compare it with the DB version
--  local db_global = TidyPlatesThreat.db.global
--
--
--  -- Profiles:
--  if db_global.version ~= tostring(ThreatPlates.Meta("version")) then
--    -- addon version is newer that the db version => check for old entries
--    for profile, profile_table in pairs(TidyPlatesThreat.db.profiles) do
--      -- iterate over all profiles
--      for key, func in pairs(DEPRECATED_DB_ENTRIES) do
--        if profile_table[key] ~= nil then
--          if DEPRECATED_DB_ENTRIES[key] == true then
--            ThreatPlates.Print ("Deleting deprecated DB entry \"" .. tostring(key) .. "\"")
--            profile_table[key] = nil
--          elseif type(DEPRECATED_DB_ENTRIES[key]) == "function" then
--            ThreatPlates.Print ("Converting deprecated DB entry \"" .. tostring(key) .. "\"")
--            DEPRECATED_DB_ENTRIES[key](profile_table)
--          end
--        end
--      end
--    end
--  end
--end

-- convert current aura widget settings to aura widget 2.0
--local function ConvertAuraWidget1(profile_name, profile)
--  local old_setting = profile.debuffWidget
--  ThreatPlates.Print (L["xxxxProfile "] .. profile_name .. L[": Converting settings from aura widget to aura widget 2.0 ..."])
--  if old_setting and not profile.AuraWidget then
--    ThreatPlates.Print (L["Profile "] .. profile_name .. L[": Converting settings from aura widget to aura widget 2.0 ..."])
--    profile.AuraWidget = {}
--    local new_setting = profile.AuraWidget
--    if not new_setting.ModeIcon then
--      new_setting.ModeIcon = {}
--    end
--
--    new_setting.scale = old_setting.scale
--    new_setting.FilterMode = old_setting.style
--    new_setting.FilterMode = old_setting.mode
--    new_setting.ModeIcon.Style = old_setting.style
--    new_setting.ShowTargetOnly = old_setting.targetOnly
--    new_setting.ShowCooldownSpiral = old_setting.cooldownSpiral
--    new_setting.ShowFriendly = old_setting.showFriendly
--    new_setting.ShowEnemy = old_setting.showEnemy
--
--    if old_setting.filter then
--      new_setting.FilterBySpell = ThreatPlates.CopyTable(old_setting.filter)
--    end
--    if old_setting.displays then
--      new_setting.FilterByType = ThreatPlates.CopyTable(old_setting.displays)
--    end
--    old_setting.ON = false
--    print ("debuffWidget: ", profile.debuffWidget.ON)
--  end
--end

--local function MigrateDatabase()
--  -- determine current addon version and compare it with the DB version
--  local db_global = TidyPlatesThreat.db.global
--
--  --  -- addon version is newer that the db version => check for old entries
--  --	if db_global.version ~= tostring(ThreatPlates.Meta("version")) then
--  -- iterate over all profiles
--  local db
--  for name, profile in pairs(TidyPlatesThreat.db.profiles) do
--    ConvertAuraWidget1(name, profile)
--  end
--  --	end
--end

-- Update the configuration file:
--  - convert deprecated settings to their new counterpart
-- Called whenever the addon is loaded and a new version number is detected
local function UpdateConfiguration()
  -- determine current addon version and compare it with the DB version
  local db_global = TidyPlatesThreat.db.global

  --  -- addon version is newer that the db version => check for old entries
  --	if db_global.version ~= tostring(ThreatPlates.Meta("version")) then
  -- iterate over all profiles
  for name, profile in pairs(TidyPlatesThreat.db.profiles) do
    -- ConvertAuraWidget1(name, profile)
  end
  --	end
end

local function TotemNameBySpellID(number)
  local name = GetSpellInfo(number)
  if not name then
    return ""
  end
  return name
end

-----------------------------------------------------
-- External
-----------------------------------------------------

ThreatPlates.UpdateDefaultProfile = UpdateDefaultProfile
ThreatPlates.UpdateConfiguration = UpdateConfiguration
--ThreatPlates.MigrateDatabase = MigrateDatabase
ThreatPlates.TotemNameBySpellID = TotemNameBySpellID

ThreatPlates.GetUnitVisibility = GetUnitVisibility

