local AddonTable = select(2, ...)
local AddonName  = select(1, ...)

local tick = 1
local max_delay = 20

local playerGUID = UnitGUID("player")
local playerName = ""
local isResting = false

function copyDefaults(src, dst)
	if not src then return { } end
	if not dst then dst = { } end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = copyDefaults(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end
	return dst
end

function disp_time(time)
   local days = floor(time/86400)
   local hours = floor(mod(time, 86400)/3600)
   local minutes = floor(mod(time,3600)/60)
   local seconds = floor(mod(time,60))
   return format("%dd:%02d:%02d:%02d",days,hours,minutes,seconds)
end

function RestedXP_OnLoad()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
  frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_LOGOUT")
  frame:RegisterEvent("PLAYER_UPDATE_RESTING")
  frame:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" and ... == AddonName then
			load_player_data(...)
			self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
      load_player_data(...)
			update_resting(...)
      get_rested_data(...)
      print_player_data(...)
		elseif event == "PLAYER_LOGOUT" then
			get_rested_data(...)
		elseif event == "PLAYER_UPDATE_RESTING" then
			update_resting(...)
		end
  end)

  SlashCmdList["RestedXP"] = RestedXP_SlashCmd
  SLASH_RestedXP1 = "/RestedXP"
  SLASH_RestedXP2 = "/rxp"
end

function getPIBG()
  local _, _, _, _, sexID, name, _ = GetPlayerInfoByGUID(playerGUID)
  if name ~= nil then
    local sex = {
       [2] = "His",
       [3] = "Her"
    }
    playerName = name
    return true
  else
    return false
  end
end

function update_player_info(...)
  for i=1,max_delay do
    local ret = getPIBG()
    if ret then return end
  end
  C_Timer.After(tick, update_player_info)
end

function load_player_data(...)
	RestedXP = copyDefaults({}, RestedXP)
  if not RestedXP[playerGUID] then RestedXP[playerGUID] = {} end
  update_player_info(...)
	-- print(AddonName .. " loaded for " .. playerName)
end

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function getKeysSortedByRestTime(...)
  local tbl = ...
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return tbl[a]["secToMax"] < tbl[b]["secToMax"]
  end)

  return keys
end

function print_player_data(...)
  if (tableLength(RestedXP) < 2) then
    print "RestedXP: log some alts on! No data to show"
    return
  end
  local red = "|cFFFF0000"
  local yellow = "|cFFFFFF00"
  local green = "|cFF00FF00"
  print(format("%sR%sested%sXP:|r", red, yellow, red))
	local sorted_keys = getKeysSortedByRestTime(RestedXP)
	for _, storedGUID in ipairs(sorted_keys) do
		data = RestedXP[storedGUID]
		local itsame = ""
    if (storedGUID == playerGUID) then itsame = "* " end
    local restColor = ""
    local restPct = data["restedxp_at_logout"] / data["xptol_at_logout"]
    local restAtLO = " (zzz)"
    if (data["resting_at_logout"] == false) then
      restAtLO = ""
      restColor = red
    end
    if (restPct > 1.25) then
      restColor = green
    end
    local output = format("%s%s%s: %0.0f%% rested, %s to full rest%s|r", itsame, restColor, data["name"], restPct * 100, disp_time(data["secToMax"]), restAtLO)
    print(output)
    end
end

function update_resting(...)
	-- apparently, on PLAYER_LOGOUT this is set to false, so we have to check at other times
	isResting = IsResting()
	get_rested_data()
end

function get_rested_data()
  if not RestedXP[playerGUID]["name"] then update_player_info() end
  local restXP = GetXPExhaustion()
  local currentXP = UnitXP("player")
  local levelXP = UnitXPMax("player")
  local restPct = restXP / levelXP
  local maxRestXP = 1.5
  local toMaxRestXP = maxRestXP - restPct
  -- each 5% rested takes 8 hours (when "resting") else 32 hours
  local restingHours = 8
  if not isResting then restingHours = 32 end
  local secToMax = (toMaxRestXP / 0.05) *  (restingHours * 60 * 60)

  if not RestedXP[playerGUID] then RestedXP[playerGUID] = {} end
  RestedXP[playerGUID] = {
    ["name"] = playerName,
    ["logout_time"] = time(),
    ["resting_at_logout"] = isResting,
    ["restedxp_at_logout"] = restXP,
    ["xp_at_logout"] = currentXP,
    ["xptol_at_logout"] = levelXP,
    ["secToMax"] = secToMax,
    ["epoch_to_max"] = GetServerTime() + secToMax
  }
  -- local dhmsToMax = disp_time(secToMax)
end

function RestedXP_SlashCmd(msg)
  print_player_data()
end
-- print(format("cxp: %d, lxp: %d, rpct: %0.0f%%, toMax: %0.0f%%, ttm: %s, resting: %s", currentXP, levelXP, restPct * 100, toMaxRestXP * 100, dhmsToMax, tostring(isRest)))
--
-- local nownow = GetServerTime()
-- local dm = date("*t", nownow + secToMax)
-- print(format("%02d/%02d/%d %02d:%02d:%02d", dm.month, dm.day, dm.year, dm.hour, dm.min, dm.sec))

RestedXP_OnLoad()
