-- [1] name of npc / [2] list of sellable itens

npcs = 
{
--[[1]]  {"Ferreiro",{}},  
}

function getSellableItens(npcId)
  return npcs[npcId][2]
end