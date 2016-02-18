tab_vocations = {
  fire_mage = 1,
  eletrician_mage = 2,
  warrior = 3,
  archer = 4,
  druid = 5,
  summoner = 6,
}

tab_arrows = {
  ["45 left arrow"]        = {0 * 32, 0 * 32},
  ["45 right arrow"]       = {1 * 32, 0 * 32},
  ["down arrow"]           = {2 * 32, 0 * 32},
  ["90 left arrow"]        = {3 * 32, 0 * 32},
  ["90 right arrow"]       = {4 * 32, 0 * 32},
}

-- name = [1]level, [2]type, [3]xImagePosion, [4]yImagePosition, [5]spellId
-- [6]previousSpell
tab_spells = {
  ["escudo infernal"]            = {3, 1, 0 * 32,1 * 32, 1, "bola de fogo"},
  ["espiral fogosa"]             = {3, 1, 1 * 32,1 * 32, 2, "bola de fogo"},
  ["bola de fogo"]               = {3, 1, 2 * 32,1 * 32, 3, "nenhuma"},
  ["espiral incendiária"]        = {3, 1, 3 * 32,1 * 32, 4, "espiral fogosa"},
  ["runa de bolas de fogo"]      = {2, 1, 4 * 32,1 * 32, 5, "bola de fogo"},
  ["teleporte de chamas"]        = {3, 1, 5 * 32,1 * 32, 6, "runa de bolas de fogo"},
  ["runa de fogo vivo"]          = {3, 1, 6 * 32,1 * 32, 7, "teleporte de chamas"},
  ["chuva fogosa de meteoro"]    = {2, 1, 7 * 32,1 * 32, 8, "espiral incendiária"},
  ["cuspe do dragão"]            = {2, 1, 8 * 32,1 * 32, 9, "rajada fogosa"},
  ["rajada fogosa"]              = {2, 1, 9 * 32,1 * 32, 10, "escudo infernal"},
}

tab_fire_spell_grid = {
  {0,                   0, "bola de fogo",                  0,                         0}, 
  {0,     "45 left arrow", "down arrow",     "45 right arrow",                         0}, 
  {"escudo infernal",   0, "runa de bolas de fogo",         0,          "espiral fogosa"}, 
  {"down arrow",        0, "down arrow",                    0,              "down arrow"}, 
  {"rajada fogosa",     0, "teleporte de chamas",           0,     "espiral incendiária"}, 
  {"down arrow",        0, "down arrow",                    0,              "down arrow"}, 
  {"cuspe do dragão",   0, "runa de fogo vivo",             0, "chuva fogosa de meteoro"}, 
}
-- 0 empty square
-- string "arrow x" - arrow key  / x = {8 combinations of arrows}
-- string spell name