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
RestedXP.Utils = {}

local Utils = RestedXP.Utils
local Chat  = RestedXP.Chat

function Utils:DispTime(time)
   local days = floor(time/86400)
   local hours = floor(mod(time, 86400)/3600)
   local minutes = floor(mod(time,3600)/60)
   local seconds = floor(mod(time,60))
   return format("%dd:%02d:%02d:%02d",days,hours,minutes,seconds)
end

function Utils:CalculateRXP(t)
  local maxRestXP = 1.5

  -- each 5% rested takes 8 hours (when "resting") else 32 hours
  local restingHours = 8
  if not t["isResting"] then restingHours = 32 end
  local restingSeconds = restingHours * 60 * 60

  if not (t["restedXP"]) then t["restedXP"] = 0 end
  local restedPct = t["restedXP"] / t["xpToLevel"]

  local now = GetServerTime()
  if (t["epoch"] < now and restedPct < maxRestXP) then
    -- estimate the restedXP based on how long the toon has been offline
    local tdiff = now - t["epoch"]
    local additionalRestedXP = (tdiff / restingSeconds) * (0.05 * t["xpToLevel"])
    restedPct = (t["restedXP"] + additionalRestedXP) / t["xpToLevel"]
  end

  if (restedPct >= maxRestXP) then restedPct = maxRestXP end
  local toMaxRestXP = maxRestXP - restedPct

  local secondsToMax = (toMaxRestXP / 0.05) * restingSeconds
  local epochAtMax = t["epoch"] + secondsToMax

  return restedPct, secondsToMax, epochAtMax
end

-- [11:46:34] RestedXP Ronzi: 123.82% rested, 6d:23:34:35 to full rest (zzz)
-- [12:08:12] RestedXP Ronzi: 126.61% rested, 6d:05:42:55 to full rest (zzz)

function Utils:GetKeysSortedByRestTime(...)
  local tbl = ...
  local keys = {}
  for key in pairs(tbl) do
    if (string.match(key, "^Player.*")) then
      table.insert(keys, key)
    end
  end

  table.sort(keys, function(a, b)
    local a_rp = Utils:CalculateRXP(tbl[a])
    local b_rp = Utils:CalculateRXP(tbl[b])
    return a_rp < b_rp
  end)

  return keys
end
