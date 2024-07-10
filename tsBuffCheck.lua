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
print (className.. " has "..buffCount.." Buffs Defined!")

local unit = "player"  -- This can be "player", "target", "partyN", "raidN", etc.
local hasBuff = false

local texture = frame:CreateTexture(nil, "ARTWORK")

local function checkBuff()
  --if UnitClass("player") ~= "Mage" or UnitIsDeadOrGhost(unit) then   -- check the class
  if UnitIsDeadOrGhost(unit) then   -- check dead
    frame:Hide()
    return
  end

  for key,buffName in pairs(classBuff[className]) do
    --local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    texture:SetTexture(buffName)

    local i = 1
    hasBuff = false  -- Initialize hasBuff to false at the start

    while UnitBuff("player", i) do
      local buffIcon = UnitBuff("player", i)
      if buffIcon == buffName then
        hasBuff = true
        -- break
      end
      i = i + 1
    end

    if not hasBuff then
      frame:Show()
    else
      frame:Hide()
    end
  end
end

local flashTimer = 0
local flashState = true

frame:SetScript("OnUpdate", function()
  flashTimer = flashTimer + arg1
  if flashTimer > 0.5 then
    flashTimer = 0
    flashState = not flashState
    if flashState then
      texture:SetAlpha(1)
    else
      texture:SetAlpha(0.5)
    end
  end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_AURA")  -- Might be more reliable than PLAYER_AURAS_CHANGED
eventFrame:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_AURA" and arg1 == "player" then
    checkBuff()
  end
end)

-- Initial check
checkBuff()
