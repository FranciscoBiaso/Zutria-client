tab_vocations = {
  fire_mage = 1,
  eletrician_mage = 2,
  warrior = 3,
  archer = 4,
  druid = 5,
  summoner = 6,
}

tab_arrows = {
  {0 * 32, 0 * 32},  -- 1 left bottom
  {1 * 32, 0 * 32},  -- 2 right bottom
  {2 * 32, 0 * 32},  -- 3 bottom
  {3 * 32, 0 * 32},  -- 4 left
  {4 * 32, 0 * 32},  -- 5 right
  {5 * 32, 0 * 32},  -- 6 left top
  {6 * 32, 0 * 32},  -- 7 right top
  {7 * 32, 0 * 32},  -- 8 top   
}

interface_mini_buttons = {
  {8 * 32, 0 * 32},  -- 1 mini-arrow 
  {8 * 32, 1 * 16},  -- 2 information
}

--[1] clip image/ [2] descritpion
spellTypes = {
--[[1]] {{10 * 32, 0 * 32}, "Runas: um tipo de pedra mágica."}, -- rune
--[[2]] {{10 * 32 + 16, 0 * 32}, "Magia instantânea: é executada imediatamente após sua ativação."}, -- instant
--[[3]] {{10 * 32, 1 * 32}, "Feitiço:  ao ser ativado, leva um certo tempo para ser executado."}, -- sorcerer
--[[4]] {{10 * 32, 16}, "Passiva: produz benefícios ao jogador mas não pode ser ativada."}, -- passive
--[[5]] {{10 * 32 + 16, 16}, "Alvo: ao ser ativada, necessita de uma nova ativação para seu uso."}, -- target
--[[6]] {{10 * 32 + 16, 2 * 16}, "Alvo/Feitiço: combinação do tipo alvo mais o tipo feitiço."} -- target and sorcerer
}

function getTableSpells()
  return spells
end

-- [1]name, [2]maxLevel, [3]ImagePosition, [4]previousSpell
-- [5]Position in templateTableTreeSkills, [6]cooldown, 
-- [7] magic type action (1-instant, 2-loadTargetCursor, 3-rune)
spells = {
-- wizard
--[[ 1 ]] {"teleporte inflamável"  ,2, {0 * 32,1 * 32}, "bola de fogo"          },
--[[ 2 ]] {"língua de fogo"        ,2, {1 * 32,1 * 32}, "bola de fogo"          },
--[[ 3 ]] {"bola de fogo"          ,3, {2 * 32,1 * 32}, "nenhuma"               },
--[[ 4 ]] {"onda sísmica"          ,2, {3 * 32,1 * 32}, "espiral fogosa"        },
--[[ 5 ]] {"chuva de meteoros"     ,2, {4 * 32,1 * 32}, "bola de fogo"          },
--[[ 6 ]] {"fogo vivo"             ,2, {5 * 32,1 * 32}, "runa de bolas de fogo" },
--[[ 7 ]] {"descarga elétrica"     ,2, {0 * 32,2 * 32}, "teleporte de chamas"   },
--[[ 8 ]] {"choque fulminante"     ,2, {1 * 32,2 * 32}, "espiral incendiária"   },
--[[ 9 ]] {"onda elétrica"         ,2, {2 * 32,2 * 32}, "rajada fogosa"         },
--[[ 10 ]]{"raio"                  ,2, {3 * 32,2 * 32}, "escudo infernal"       },
--[[ 11 ]]{"ciclone elétrico"      ,2, {4 * 32,2 * 32}, "escudo infernal"       },
--[[ 12 ]]{"potência enérgica"     ,2, {5 * 32,2 * 32}, "escudo infernal"       },
--[[ 13 ]]{"plasma"                ,2, {0 * 32,3 * 32}, "escudo infernal"       },
--[[ 14 ]]{"onda tripla"           ,2, {1 * 32,3 * 32}, "escudo infernal"       },
--[[ 15 ]]{"abalo cibernético"     ,2, {2 * 32,3 * 32}, "escudo infernal"       },

-- druid
--[[ 16 ]]{"cura básica"           ,2, {0 * 32,6 * 32}, ""                      },
--[[ 17 ]]{"cura divina"           ,2, {1 * 32,6 * 32}, ""                      },
--[[ 18 ]]{"cura vitalícia"        ,2, {2 * 32,6 * 32}, ""                      },
--[[ 19 ]]{"veneno"                ,2, {0 * 32,7 * 32}, ""                      },
--[[ 20 ]]{"folhagem tóxica"       ,2, {1 * 32,7 * 32}, ""                      },
--[[ 21 ]]{"barreira de galhos"    ,2, {2 * 32,7 * 32}, ""                      },
--[[ 22 ]]{"vínculo de vida"       ,2, {3 * 32,7 * 32}, ""                      },
--[[ 23 ]]{"explosão de toxina"    ,2, {4 * 32,7 * 32}, ""                      },
--[[ 24 ]]{"toxina mortal"         ,2, {5 * 32,7 * 32}, ""                      },
--[[ 25 ]]{"fumaça tóxica"         ,2, {6 * 32,7 * 32}, ""                      },
--[[ 26 ]]{"onda de luz"           ,2, {3 * 32,6 * 32}, ""                      },
--[[ 27 ]]{"cintilação tóxica"     ,2, {0 * 32,8 * 32}, ""                      },
--[[ 28 ]]{"benção"                ,2, {4 * 32,6 * 32}, ""                      },
--[[ 29 ]]{"paradoxo"              ,2, {1 * 32,8 * 32}, ""                      },
--[[ 30 ]]{"blindagem"             ,2, {5 * 32,6 * 32}, ""                      },

-- paladin
--[[ 31 ]]{"precisão"              ,9, {0 * 32,9 * 32}, ""                      },
--[[ 32 ]]{"concentração máxima"   ,3, {1 * 32,9 * 32}, ""                      },
--[[ 33 ]]{"força suprema"         ,2, {2 * 32,9 * 32}, ""                      },
--[[ 34 ]]{"flechada crítica"      ,2, {3 * 32,9 * 32}, ""                      },
--[[ 35 ]]{"onus místico"          ,2, {4 * 32,9 * 32}, ""                      },
--[[ 36 ]]{"sabedoria"             ,3, {5 * 32,9 * 32}, ""                      },
--[[ 37 ]]{"elevação de carga"     ,3, {6 * 32,9 * 32}, ""                      },
--[[ 38 ]]{""                      ,3, {7 * 32,9 * 32}, ""                      },
--[[ 39 ]]{""                      ,3, {8 * 32,9 * 32}, ""                      },
--[[ 40 ]]{""                      ,3, {9 * 32,9 * 32}, ""                      },
--[[ 41 ]]{""                      ,3, {10 * 32,9 * 32}, ""                     },
--[[ 42 ]]{""                      ,3, {0 * 32,10 * 32}, ""                     },
--[[ 43 ]]{"flecha de veneno"      ,3, {1 * 32,10 * 32}, ""                     },
--[[ 44 ]]{"flecha de veneno"      ,3, {2 * 32,10 * 32}, ""                     },
--[[ 45 ]]{"flecha de veneno"      ,3, {2 * 32,10 * 32}, ""                     },
--[[ 46 ]]{"flecha de veneno"      ,3, {0 * 32,9 * 32}, ""                      },

-- knight
--[[ 47 ]]{"força física"          ,3, {8 * 32,9 * 32},  ""                      },
--[[ 48 ]]{"fúria"                 ,2, {0 * 32,11 * 32}, ""                      },
--[[ 49 ]]{"retaguarda"            ,2, {1 * 32,11 * 32}, ""                      },
--[[ 50 ]]{"aumento de vitalidade" ,2, {2 * 32,11 * 32}, ""                      },
--[[ 51 ]]{"aumento de vitalidade" ,2, {3 * 32,11 * 32}, ""                      },
--[[ 52 ]]{"aumento de vitalidade" ,2, {4 * 32,11 * 32}, ""                      },
--[[ 53 ]]{"grito"                 ,2, {5 * 32,11 * 32}, ""                      },
--[[ 54 ]]{"grito"                 ,2, {6 * 32,11 * 32}, ""                      },
--[[ 55 ]]{"grito"                 ,2, {7 * 32,11 * 32}, ""                      },
--[[ 56 ]]{"grito"                 ,2, {8 * 32,11 * 32}, ""                      },
--[[ 57 ]]{"grito"                 ,2, {9 * 32,11 * 32}, ""                      },
--[[ 58 ]]{"pulo"                  ,2, {10 * 32,11 * 32}, ""                     },
--[[ 59 ]]{"pulo"                  ,2, {2 * 32,11 * 32}, ""                      },
--[[ 60 ]]{"pulo"                  ,2, {2 * 32,9 * 32}, ""                       },

--generic
--[[ 61 ]]{"cura"                  ,2, {0 * 32,4 * 32}, ""                       },
--[[ 62 ]]{"luz"                   ,2, {1 * 32,6 * 32}, ""                       },
--[[ 63 ]]{"speed"                 ,2, {0 * 32,5 * 32}, ""                       },
--[[ 64 ]]{"speed"                 ,2, {1 * 32,5 * 32}, ""                       },
} 

function transformSpellTypeToStr(type)
  if type == 1 then     return 'runa'
  elseif type == 2 then return 'instântanea'
  elseif type == 3 then return 'feitiço'
  elseif type == 4 then return 'passiva'
  elseif type == 5 then return 'ativação' end
end

function getTableDescriptionSpells()
  return spells_description
end

--[1]spellType{1==rune/ 2==instante /3==sorcerer /4==passive /5==activation}
--[2]countOfPoints to buy
spells_description = {
-- wizard
--[[ 1 ]] {5,14,"Teleporta seu personagem para o local selecionado até uma distância máxima" ..
                " de 4 unidades. No nível 2, incrementa a distância máxima para 6 unidades."},
--[[ 2 ]] {2,20,"É uma onda de fogo frontal. Tem uma distância máxima de 5 unidades." ..
                " Criaturas atingidas recebem danos por queimadura baseado no ataque mágico do lançador." ..
                " No nível 2, incrementa o dano por queimadura e aumenta a área da magia."},
--[[ 3 ]] {2,12,"Necessita de um alvo para ser lançada. Ao lançar, causa dano por queimadura " ..
                " baseado no ataque mágico do lançador. No nível 2 e 3, incrementa o dano por queimadura."},
--[[ 4 ]] {2,23,"Gera uma explosão em volta do lançador. Atinge uma área máxima de 6 unidades." ..
               " Criaturas atingidas recebem danos por queimadura baseado no ataque mágico do lançador." ..
               " No nível 2, incrementa o dano por queimadura e aumenta a área máxima da magia."},
--[[ 5 ]] {1,20,"Gera uma explosão em volta e no local atingido. A explosão causa maior dano na " ..
               "proporação linear do centro para fora. O dano é beaseado no ataque mágico do lançador. " ..
               "No nível 2, aumenta a área atingida e o dano gerado."},
--[[ 6 ]] {1,25," Cria chamas mágicas em volta e no local atingido. Tem uma distância máxima de 4 unidades." ..
                " Criaturas atingidas recebem danos por queimadura baseado no ataque mágico do lançador." ..
                " Os efeitos do fogo vivo são cumulativos." ..
                " No nível 2, aumenta a área da magia."},
--[[ 7 ]] {2,14," Necessita de um alvo para ser lançada. A criatura atingida recebe um dano baseado" ..
                " no ataque mágico do lançador. Perfura a defesa mágica em 3%. No nível 2, incrementa o dano da magia."},
--[[ 8 ]] {1,20," Gera uma mini explosão de ondas elétricas. Criaturas atingidas recebem dano" ..
                " baseado no ataque mágico do lançador. Perfura a defesa mágica em 6%. No nível 2, incrementa o dano da magia." },
--[[ 9 ]] {2,20," É uma onda frontal. Tem uma distância máxima de 6 unidades. Perfura a defesa mágica em 8%" ..
               " Criaturas atingidas recebem dano baseado no ataque mágico do lançador." ..
               " No nível 2, incrementa o dano e a área da magia."},
--[[ 10 ]] {1,26,"Necessita de um alvo para ser lançada. A criatura atingida recebe um dano baseado" ..
                " no ataque mágico do lançador. Perfura a defesa mágica em 12%. No nível 2, incrementa o dano da magia."},
--[[ 11 ]] {2,2," São três tornados que permanecem por 5 segundos, vagando aleatóriamente. Cada um deles" ..
                " perfura a defesa mágica em 6% e causa danos por eletricidade baseado no ataque mágico do lançador." ..
                " No nível 2, eles permanece por 8 segundos, é incrementado o dano e são produzidos quatro tornados."},
--[[ 12 ]] {1,24," Necessita de um alvo para ser lançada. Aumenta a velocidade do personagem em 8. No" ..
                 " nível 2, aumenta a velocidade em 12."},
--[[ 13 ]] {5,14," Necessita de um alvo para ser lançada. Criaturas atingidas recebem danos por queimadura baseado no ataque mágico do lançador e" ..
                 " tem perfuração de defesa mágica em 4%. No nível 2, incrementa o dano por queimadura e a perfuração mágica."},
--[[ 14 ]] {3,24," Gera uma explosão em volta do lançador. Atinge uma área máxima de 6 unidades. Demora " ..
                 " dois segundos para ser lançada. Causa um dano por queimadura e perfura a armadura."},
--[[ 15 ]] {3,30," Gera uma explosão em volta do lançador. Atinge uma área máxima de 6 unidades. Demora " ..
                 " dois segundos para ser lançada. Causa um dano por queimadura e perfura a armadura."},

-- druid
--[[ 16 ]] {1,2,""},
--[[ 17 ]] {5,2,""},
--[[ 18 ]] {1,2,""},
--[[ 19 ]] {2,2,""},
--[[ 20 ]] {2,2,""},
--[[ 21 ]] {1,2,""},
--[[ 22 ]] {5,2,""},
--[[ 23 ]] {2,2,""},
--[[ 24 ]] {1,2,""},
--[[ 25 ]] {1,2,""},
--[[ 26 ]] {2,2,""},
--[[ 27 ]] {3,2,""},
--[[ 28 ]] {2,2,""},
--[[ 29 ]] {3,2,""},
--[[ 30 ]] {1,2,""},

-- paladin
--[[ 31 ]] {2,20,"+ ml dura mais tempo a magia. Aumenta a precisão do arqueiro em 5% no nível 1, em 4% no nível 2, em 3% no nível 3 e em 3% no nível 4."},
--[[ 32 ]] {2,20,"dano criquanto mais distan maior o danoAumenta a precisão do arqueiro de 10% à 25% no nível 1, de 15% à 30% no nível 2 e de 20% a 35% no nível 3." ..
                 " Este efeito tem durabilidade de 15 segundos."},
--[[ 33 ]] {2,20,"Aumenta o ataque físico(- ataq speed) do arqueiro em 6 no nível 1 e em 8 no nível 2." ..
                 " Este efeito permanece ativo por 25 segundos."},
--[[ 34 ]] {6,20,"atordoa Dispara uma flecha mágica no local escolhido, após três segundos, no nível 1. Caso a flecha atinga" ..
                 " alguma criatura, esta tomará um dano crítico incrementado de 25% à 30%. No nível 2, o tempo de disparo" ..
                 " da flecha é de dois segundos e o incremento do dano crítico é de 35% à 45%."},   
--[[ 35 ]] {4,20,"Incrementa a velociade de ataque e/ou a esquiva em 4 pontos de atributos aleatoriamente no nível 1." ..
                 " No nível 2, incrementa em 3 pontos."},    
--[[ 36 ]] {2,20,"Aperfeiçoa até 10 flechas incrementando o ataque em 1, no nível 1. No nível 2, aperfeiçoa até 11 flechas" ..
                 " incrementando o ataque em 2. No nível 3, aperfeiçoa até 12 flechas incrementando o ataque em 3."},                    
--[[ 37 ]] {4,20,"Aumenta a capacidade de flechas na aljava para mais 20, no nível 1. No nível 2, aumenta a capacidade para mais 15. No nível 3 para mais 12."},                    

--[[ 38 ]] {2,20,"Aumenta a velocidade de ata(diminui a precisao e ataque fisico)"}, 
--[[ 39 ]] {4,20,"auemnta força fisica"},   
--[[ 40 ]] {2,20,"incrementa a area de ataque (range)"},        
--[[ 41 ]] {4,20,"incrementa o ataq speed"},                   
--[[ 42 ]] {6,20,"chuva de flechas"},                          
--[[ 43 ]] {2,20,"diminui o peso das flechas"},                 
--[[ 44 ]] {2,20,"diminui o peso das flechas"},                  
--[[ 45 ]] {4,20,"diminui o peso das flechas"},                   
--[[ 46 ]] {4,20,"diminui o peso das flechas"},      

--knight              
--[[ 47 ]] {4,20,"Aumenta o ataque físico e a defesa física em 1 ponto cada, no nível 1. No nível 2" ..
            ", aumenta em 2 pontos cada."},  
--[[ 48 ]] {2,20,"Causa 15% de dano a si mesmo e incrementa o ataque físico em 10 pontos. Aumenta a velocidade" ..
            " em 3 pontos. Reduz a defesa física em 5.Pode-se gerar danos críticos de 10% a 15% do ataque, no nível 1. No nível 2, causa 20%" ..
            " de dano a si mesmo e incrementa o ataque físico em 20. Aumenta a velocidade em 5 pontos. Reduz a " ..
            " defesa física em 10. Pode-se gerar danos críticos de 15% a 20% do ataque."},
--[[ 49 ]] {2,20,"Reduz a velocidade de ataque em 5 pontos. Aumenta a defesa física em 12 pontos, no nível 1. " ..
                 "No nível 2, reduz a velocidade de ataque em 4 pontos e aumenta a defesa física em 15 pontos."},            
--[[ 50 ]] {3,20,"Aumenta os pontos de vida em 18%/25%. Reduz vel mov."}, 
--[[ 51 ]] {2,20,"Ataca os 3 sqm frontais com 10%/15%/20% de bonus damage."},      
--[[ 52 ]] {2,20,"incrementa o número de criaturas de bloqueio para 3/4."},                       
--[[ 53 ]] {2,20,"chama a criatura alvo."},                   
--[[ 54 ]] {2,20,"chama a criatura alvo."},                  
--[[ 55 ]] {2,20,"chama a criatura alvo."},                  
--[[ 56 ]] {3,20,"chama a criatura alvo."},                  
--[[ 57 ]] {2,20,"chama a criatura alvo."},                
--[[ 58 ]] {2,20,"chama a criatura alvo. atordoa"},        
--[[ 59 ]] {4,20,"chama a criatura alvo. atordoa"},   
--[[ 60 ]] {2,20,"chama a criatura alvo. atordoa"},   
--[[ 61 ]] {2,20,"chama a criatura alvo. atordoa"},   
--[[ 62 ]] {2,20,"chama a criatura alvo. atordoa"},   
--[[ 63 ]] {2,20,"chama a criatura alvo. atordoa"},   
--[[ 64 ]] {5,20,"chama a criatura alvo. atordoa"}, 
}

-- first element = hidden, spell or arrow panel // second element = for spell -> spell id, for arrow -> arrow id
wizard_spells = {
  {{2,1}, {1,4}, {2,3}, {1,5}, {2,13}, {1,4}, {2,7}, {1,5},  {2,12}}, 
  {{0,0}, {1,1}, {1,3}, {0,0}, {0,0},  {0,0}, {1,3},  {1,2},  {0,0}}, 
  {{2,5}, {0,0}, {2,2}, {1,5}, {2,14}, {1,4}, {2,9},  {0,0},  {2,8}}, 
  {{1,3}, {0,0}, {1,3}, {0,0}, {1,3},  {0,0}, {1,3},  {0,0},  {1,3}},
  {{2,6}, {0,0}, {2,4}, {0,0}, {2,15}, {0,0}, {2,11}, {0,0},  {2,10}},
}

druid_spells = {
  {{2,21}, {1,4}, {2,19}, {1,5}, {2,22}, {1,4}, {2,16}, {1,5},  {2,17}}, 
  {{0,0}, {1,1}, {1,3}, {0,0}, {0,0},  {0,0}, {1,3},  {1,2},  {0,0}}, 
  {{2,25}, {0,0}, {2,20}, {1,5}, {2,27}, {1,4}, {2,26},  {0,0},  {2,18}}, 
  {{1,3}, {0,0}, {1,3}, {0,0}, {0,0},  {0,0}, {1,3},  {0,0},  {1,3}},
  {{2,24}, {0,0}, {2,23}, {1,5}, {2,29}, {1,4}, {2,28}, {0,0},  {2,30}},
}

paladin_spells = {
  {{2,37}, {0,0},{2,46}, {0 ,0}, {2,45}, {0,0},{2,39}, {0,0}, {2,41},  }, 
  {{0,0}, {0,0},{1,3},  {0,0},  {1,3},{0,0},{1,3},  {0,0}, {1,3},    }, 
  {{2,43}, {0,0},{2,31}, {0,0},  {2,44},{0,0},{2,33}, {0,0}, {2,38},},   
  {{1,3},{0,0},{1,3},  {1,1},  {1,3},{1,1},{1,3},  {0,0}, {1,3},   }, 
  {{2,36},{0,0},{2,32}, {0,0},  {2,34},{0,0},{2,40}, {0,0}, {2,42},  }, 
}

knight_spells = {
  {{2,53}, {0,0}, {2,51}, {0,0}, {2,47}, {0,0}, {2,59}, {0,0},  {2,49}}, 
  {{0,0}, {0,0}, {1,3}, {0,0}, {1,3},  {0,0}, {1,3},  {0,0},  {1,3}}, 
  {{2,58}, {0,0}, {2,55}, {0,0}, {2,60}, {0,0}, {2,57},  {0,0},  {2,54}}, 
  {{0,0}, {0,0}, {1,3}, {0,0}, {1,3},  {0,0}, {1,3},  {0,0},  {1,3}},
  {{0,0}, {0,0}, {2,56}, {0,0}, {2,48}, {0,0}, {2,50}, {0,0},  {2,52}},
}

generic_spells = {
  {{2,62}, {0,0}, {2,63}, {0,0}, {2,64},}, 
  {{1,3}, {0,0}, {0,0}, {0,0},}, 
  {{2,61}, {0,0}, {0,0}, {0,0},},
}


function getTableVocationSpells(type)
  if type == 1 then
    return wizard_spells
  elseif type == 2 then
   return paladin_spells
  elseif type == 3 then
  elseif type == 4 then
    return knight_spells
  elseif type == 5 then
    return generic_spells
  elseif type == 6 then
    return druid_spells
  end  
end
-- first element = xPositionOfImage, second element = yPositionOfImage
-- if first element == -1 then hidden image(space)
start_interface_model = {
  {{8 * 32 + 16, 0}, {8 * 32 + 16, 3 * 16}},
  {{8 * 32 + 16, 6 * 16}, {8 * 32 + 16, 9 * 16}},
  {{8 * 32 + 16, 12 * 16}, {8 * 32 + 16, 15 * 16}},
}

function getStartModelInterface()
  return start_interface_model
end