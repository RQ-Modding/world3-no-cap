-- World 3 No Level Cap. In World 3 no recruited character has a level cap, as Rance has none: the
-- game reads each cap as Rance's 999 and shows it as ∞. Nothing is written into the save: back in
-- World 1 or 2, with the box off, or without the mod, the game's caps hold again (the levels stay).
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- The game keeps a character's cap in Ｃ[iic].ＬＶ最大, read by ＣＬＶ最大(iic, -1) wherever a level
-- or EXP stops at it (the fight's EXP, Ｃ経験値追加, レベルアップ処理, the reserve's free level, a
-- quest's end). キャラ_レベル上限なし(number) is true for Rance (and numbers 72 and 92): キャラ_レベル最大
-- then answers 2147483647, which the cards and the status page show as ∞. Rance's data asks for 9999,
-- but ＣＬＶ最大 writes at most 999 outside World 3 (9999 in it), and he is made in World 1: his level
-- stops at 999.

local CAP = "ＣＬＶ最大"
local UNCAPPED = "キャラ_レベル上限なし"
local NO_CAP = 999    -- Rance's cap in a save: where his level stops (a higher cap is left alone)
local WORLD = 3
local ATHENA2 = 27    -- Athena 2.0: the game keeps her at LV 1 (レベルアップ処理)

-- The game's functions that raise a cap: they read the save's cap, so a Forbidden Talent worn or a
-- Morurun in World 3 still raises it, for a return to World 1 or 2. (Read as 999, effect 27 would
-- see no room under 999 and the item would be spent for nothing.)
local RAISERS = {
  ["Ｃ機能適応"] = true,             -- Forbidden Talent (effect 27: 304 +20, 305 +5, 252 +3), effect 73
  ["Ｃ再計算"] = true,               -- skills 346 and 347 (35, 45)
  ["Ｃレベルドレイン"] = true,        -- the Morurun at the cap (+3, +10 from the fifth)
  ["割り込み２／転移後特殊"] = true,  -- item 335 in the party at a warp (+1)
  ["汎用／自殺の名所"] = true,        -- an event (+5, up to 55)
  ["キャラ_レベル最大設定"] = true,   -- a write, read back
}

local settings

local function active()
  return rq.world.current() == WORLD and settings.get("on") == true
end

-- A recruited character (登録状態 1 to 4: the party, the first army, used in this quest, the second
-- army), not Athena 2.0.
local function eligible(iic)
  if iic <= 0 then return false end
  local state = rq.ain.call("Ｃ登録状態", iic, -1)
  if state < 1 or state > 4 then return false end
  return rq.ain.call("Ｃ番号", iic, -1) ~= ATHENA2
end

-- Who read the cap: the first name on the game's stack that is not ＣＬＶ最大 itself.
local function caller()
  for _, name in ipairs(rq.ain.stack(3)) do
    if name ~= CAP then return name end
  end
end

-- A read of the cap (ＣＬＶ最大(iic, -1)) answers 999 in World 3, as Rance's.
rq.ain.hook(CAP, { only = { [2] = -1 }, after = function(h)
  if type(h.result) ~= "number" or h.result >= NO_CAP or not active() then return end
  if not eligible(h.args[1]) or RAISERS[caller()] then return end
  h.result = NO_CAP
end })

-- The cards and the status page: ∞, as Rance's.
rq.ain.hook(UNCAPPED, { after = function(h)
  if h.result or not active() then return end
  local no = h.args[1]
  if no == ATHENA2 then return end
  local iic = rq.ain.call("Ｃ番号取得", no)
  if iic ~= 0 and eligible(iic) then h.result = true end
end })

-- The page in Config's Mods tab, kept in the save: on in a save that never set it.
settings = rq.config.settings{
  id = "world3-no-cap",
  title = "World 3 No Level Cap",
  keep = "save",
  rows = {
    { kind = "checkbox", key = "on", label = "No level cap in World 3", default = true,
      tip = { header = "No level cap in World 3",
        text = "In World 3 every recruited character levels with no cap, as Rance. For this save only." } },
    { kind = "space", h = 6 },
    { kind = "label", dim = true, size = 15,
      text = "In World 3 the cards show no cap, as Rance's. Athena 2.0 stays at LV 1, as in the game." },
    { kind = "label", dim = true, size = 15,
      text = "In World 1 or 2, or with this box off, the game's caps hold again; the levels stay." },
    { kind = "label", dim = true, size = 15,
      text = "Forbidden Talents still raise a character's own cap, for World 1 and 2." },
  },
}

-- For the Lab and other mods.
return {
  -- True while the caps are lifted: World 3, a save loaded, the box on.
  active = active,
  -- Whether the caps are lifted for this character now.
  lifted = function(iic) return active() and eligible(iic) end,
  set = function(key, value) settings.set(key, value) end,
  get = function(key) return settings.get(key) end,
  cap = NO_CAP,
}
