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
RestedXP.Data = {}

local Data = RestedXP.Data
local Chat = RestedXP.Chat

function Data:Init()
  self.guid = UnitGUID("player")
  if (not RestedXPDB) then RestedXPDB = { debug = 0 } end
  if (not RestedXPDB[self.guid]) then RestedXPDB[self.guid] = {} end
end
