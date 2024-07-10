local frame = CreateFrame("Frame", "buffReminder", UIParent)
frame:SetWidth(32)
frame:SetHeight(32)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
frame:Hide()

-- Define class buffs
local classBuff = {
  Hunter = {
    buff1 = "Interface\\Icons\\Spell_Nature_Ravenform",
  },
  Mage = {
    buff1 = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    buff2 = "Interface\\Icons\\Spell_Frost_FrostArmor02",
  },
  Warlock = {
    buff1 = "Interface\\Icons\\Spell_Shadow_RagingScream",
  },
  Warrior = {
    buff1 = "Interface\\Icons\\Spell_ability_warrior_battleshout",
  },
}

local className = UnitClass("player")

-- Function to count the number of buffs for a given class
local function countClassBuffs(class)
  local buffs = classBuff[class]
  if not buffs then
    print(class .. " is not defined in the classBuff table.")
    return 0
  end

  local count = 0
  for _ in pairs(buffs) do
    count = count + 1
  end
  return count
end

local buffCount = countClassBuffs(className)

-- debug
print(className .. " has " .. buffCount .. " Buffs Defined!")

local unit = "player"  -- This can be "player", "target", "partyN", "raidN", etc.
local texture = frame:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints(frame)

local function checkBuff()
  if UnitIsDeadOrGhost(unit) then
    frame:Hide()
    return
  end

  local hasBuff = false

  for _, buffName in pairs(classBuff[className]) do
    local i = 1
    while UnitBuff("player", i) do
      local buffIcon = UnitBuff("player", i)
      if buffIcon == buffName then
        hasBuff = true
        break
      end
      i = i + 1
    end

    if not hasBuff then
      texture:SetTexture(buffName)
      frame:Show()
      return
    end
  end

  frame:Hide()
end

local flashTimer = 0
local flashState = true

frame:SetScript("OnUpdate", function(self, elapsed)
  flashTimer = flashTimer + elapsed
  if flashTimer > 0.5 then
    flashTimer = 0
    flashState = not flashState
    texture:SetAlpha(flashState and 1 or 0.5)
  end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_AURA" and arg1 == "player") then
    checkBuff()
  end
end)

-- Initial check
checkBuff()

--[[
### Key Changes:
1. **Event Handler Parameters**: Added `self`, `event`, and `arg1` as parameters to the event handler function.
2. **UnitBuff Handling**: Adjusted the `UnitBuff` loop to correctly handle the returned values.
3. **Frame Visibility**: Moved the frame visibility logic outside the loop to avoid flickering.
4. **OnUpdate Script**: Corrected the `OnUpdate` script to use `elapsed` instead of `arg1`.

These changes should make your code more robust and compatible with WoW 1.12.
]]--

