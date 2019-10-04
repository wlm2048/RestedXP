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
RestedXP.Chat = {}

---@class Chat
local Chat  = RestedXP.Chat
local Debug = RestedXP.Debug
local RXP   = RestedXP.RXP

--------------------------------------
-- Defaults
--------------------------------------
Chat.command = "/rxp"
Chat.commands = {
  ["help"] = function()
    print(" ")
    Chat:Print("List of commands:")
    Chat:Print("/rxp - show rested XP for all your characters")
    print(" ")
  end,
  ["show"] = function()
    if (not RXP) then RXP = RestedXP.RXP end
    RXP:Show()
  end,
  ["debug"] = function(level)
    if (Debug == nil) then Debug = RestedXP.Debug end
    if (string.match(level, "[0-3]")) then
      Debug:SetDebugLevel(level)
      Chat:Print("Debug level set to: " .. level)
    else
      Chat:Print("Unknown debug level: " .. level)
      Chat.commands.help()
    end
  end
}

--------------------------------------
-- Chat functions
--------------------------------------
function Chat:Print(...)
  local prefix = string.format("|cffff0000%s|r", addonName)
  DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function Chat:Init()
  SLASH_RestedXP1 = self.command
  SlashCmdList["RestedXP"] = function(msg)
    local str = msg
    if (#str == 0) then
      str = "show"
    end

    local args = {}
    for _, arg in ipairs({string.split(" ", str)}) do
      if (#arg > 0) then
        table.insert(args, arg)
      end
    end

    local path = Chat.commands -- required for updating found table.

    for id, arg in ipairs(args) do
      if (#arg > 0) then -- if string length is greater than 0.
        arg = arg:lower()
        if (path[arg]) then
          if (type(path[arg]) == "function") then
            -- all remaining args passed to our function!
            path[arg](select(id + 1, unpack(args)))
            return
          elseif (type(path[arg]) == "table") then
            path = path[arg] -- another sub-table found!
          end
        else
          -- does not exist!
          Chat.commands.help()
          return
        end
      end
    end
  end
end
