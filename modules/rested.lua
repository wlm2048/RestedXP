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
RestedXP.RXP = {}

---@class RXP
local RXP   = RestedXP.RXP
local Utils = RestedXP.Utils
local Chat  = RestedXP.Chat
local Debug = RestedXP.Debug

function RXP:Init()
  self.guid = UnitGUID("player")
  local _, _, _, _, _, name, _ = GetPlayerInfoByGUID(self.guid)
  Chat:Print(" loaded for " .. name)
  RestedXPDB[self.guid]["name"] = name
end

function RXP:Update(...)
  local event = select(1, ...)
  -- Chat:Print("Update event: " .. event .. " data: " .. ...)
  -- xpToLevel, restedXP, isResting, epoch
  local restedXP = GetXPExhaustion()
  if (not restedXP) then restedXP = 0 end
  RestedXPDB[self.guid]["xpToLevel"] = UnitXPMax("player")
  RestedXPDB[self.guid]["restedXP"]  = restedXP
  if (event ~= "PLAYER_LOGOUT") then
    -- logout seems to always set this to false, so we'll have to trust the last known status
    RestedXPDB[self.guid]["isResting"] = IsResting()
  end
  RestedXPDB[self.guid]["epoch"]     = GetServerTime()
  -- Chat:Print(format("x2l: %d, rxp: %d, ir: %s, epoch: %d", RestedXPDB[self.guid]["xpToLevel"], RestedXPDB[self.guid]["restedXP"], tostring(RestedXPDB[self.guid]["isResting"]), RestedXPDB[self.guid]["epoch"]))
  -- local rxp, stm, eam = Utils:CalculateRXP(RestedXPDB[self.guid])
  -- Chat:Print(format("rxp: %0.4f, stm: %d, eam: %d", rxp, stm, eam))
end

function RXP:Show()
  local red = "|cFFFF0000"
  local yellow = "|cFFFFFF00"
  local green = "|cFF00FF00"
  local sortedKeys = Utils:GetKeysSortedByRestTime(RestedXPDB)
  for _, keyGUID in ipairs(sortedKeys) do
    data = RestedXPDB[keyGUID]
    local itsAMe = ""
    if (keyGUID == RXP.guid) then itsAMe = "* " end
    local restColor = ""
    local restedPct, secondsToMax, epochAtMax = Utils:CalculateRXP(RestedXPDB[keyGUID])
    local restAtLO = " (zzz)"
    if (data["isResting"] == false) then
      restAtLO = ""
      restColor = red
    end
    if (restedPct > 1.25) then
      restColor = green
    end
    local output = format("%s%s%s: %0.2f%% rested, %s to full rest%s|r", itsAMe, restColor, data["name"], restedPct * 100, Utils:DispTime(secondsToMax), restAtLO)
    Chat:Print(output)
    end
end
