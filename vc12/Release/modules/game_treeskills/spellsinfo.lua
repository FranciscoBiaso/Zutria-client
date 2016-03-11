tab_vocations = {
  fire_mage = 1,
  eletrician_mage = 2,
  warrior = 3,
  archer = 4,
  druid = 5,
  summoner = 6,
}

tab_arrows = {
  {0 * 32, 0 * 32},  -- 1
  {1 * 32, 0 * 32},  -- 2
  {2 * 32, 0 * 32},  -- 3
  {3 * 32, 0 * 32},  -- 4
  {4 * 32, 0 * 32},  -- 5
}

-- [1]name, [2]level, [3]ImagePosition, [4]previousSpell
-- [5]Position in templateTableTreeSkills, [6]cooldown, 
-- [7] magic type action (1-instant, 2-loadTargetCursor, 3-rune)
tab_spells_information = {
--[[ 1 ]] {"escudo infernal"          ,3, {0 * 32,1 * 32}, "bola de fogo"            ,{-1,-1}, 10, 1},
--[[ 2 ]] {"espiral fogosa"           ,3, {1 * 32,1 * 32}, "bola de fogo"            ,{-1,-1}, 10, 1},
--[[ 3 ]] {"bola de fogo"             ,3, {2 * 32,1 * 32}, "nenhuma"                 ,{-1,-1}, 10, 1},
--[[ 4 ]] {"espiral incendiária"      ,3, {3 * 32,1 * 32}, "espiral fogosa"          ,{-1,-1}, 10, 1},
--[[ 5 ]] {"runa de bolas de fogo"    ,2, {4 * 32,1 * 32}, "bola de fogo"            ,{-1,-1}, 10, 3},
--[[ 6 ]] {"teleporte de chamas"      ,3, {5 * 32,1 * 32}, "runa de bolas de fogo"   ,{-1,-1}, 10, 2},
--[[ 7 ]] {"runa de fogo vivo"        ,3, {6 * 32,1 * 32}, "teleporte de chamas"     ,{-1,-1}, 10, 3},
--[[ 8 ]] {"chuva fogosa de meteoro"  ,2, {7 * 32,1 * 32}, "espiral incendiária"     ,{-1,-1}, 10, 2},
--[[ 9 ]] {"cuspe do dragão"          ,2, {8 * 32,1 * 32}, "rajada fogosa"           ,{-1,-1}, 10, 1},
--[[ 10 ]]{"rajada fogosa"            ,2, {9 * 32,1 * 32}, "escudo infernal"         ,{-1,-1}, 10, 1},
}

function getTableSpells()
  return tab_spells_information
end
-- first element = hidden, spell or arrow panel // second element = for spell -> spell id,, for arrow -> arrow id
tab_spells_model = {
  {{0,0}, {0,0}, {2,3}, {0,0}, {0,0}}, 
  {{0,0}, {1,1}, {1,3}, {1,2}, {0,0}}, 
  {{2,1}, {0,0}, {2,5}, {0,0}, {2,2}}, 
  {{1,3}, {0,0}, {1,3}, {0,0}, {1,3}},
  {{2,10},{0,0}, {2,6}, {0,0}, {2,4}},
  {{1,3}, {0,0}, {1,3}, {0,0}, {1,3}},
  {{2,9}, {0,0}, {2,7}, {0,0}, {2,8}}, 
}