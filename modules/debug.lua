--------------------------------------
-- Imports
--------------------------------------
---@class RestedXP
local RestedXP = select(2, ...)
---@type string
local addonName = select(1, ...)

--------------------------------------
-- Declarations
--------------------------------------
RestedXP.Debug = {}

local Debug = RestedXP.Debug

Debug.Levels = {
  NONE = 0,
  INFO = 1,
  DEBUG = 2,
  TRACE = 3
}

function Debug:SetDebugLevel(level)
  Debug.level = level
  RestedXP["debug"] = tostring(level)
end

Debug.Is = function(level)
  return tonumber(Debug.level) >= tonumber(Debug.Levels[level])
end
