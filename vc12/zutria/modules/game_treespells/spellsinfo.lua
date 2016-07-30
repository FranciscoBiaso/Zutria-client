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
--[[1]] {{10 * 32, 0 * 32}, "Runas: um tipo de pedra m�gica."}, -- rune
--[[2]] {{10 * 32 + 16, 0 * 32}, "Magia instant�nea: � executada imediatamente ap�s sua ativa��o."}, -- instant
--[[3]] {{10 * 32, 1 * 32}, "Feiti�o:  ao ser ativado, leva um certo tempo para ser executado."}, -- sorcerer
--[[4]] {{10 * 32, 16}, "Passiva: produz benef�cios ao jogador mas n�o pode ser ativada."}, -- passive
--[[5]] {{10 * 32 + 16, 16}, "Alvo: ao ser ativada, necessita de uma nova ativa��o para seu uso."}, -- target
--[[6]] {{10 * 32 + 16, 2 * 16}, "Alvo/Feiti�o: combina��o do tipo alvo mais o tipo feiti�o."} -- target and sorcerer
}

function getTableSpells()
  return spells
end

-- [1]name, [2]maxLevel, [3]ImagePosition, [4]previousSpell
-- [5]Position in templateTableTreeSkills, [6]cooldown, 
-- [7] magic type action (1-instant, 2-loadTargetCursor, 3-rune)
spells = {
-- wizard
--[[ 1 ]] {"teleporte inflam�vel"  ,2, {0 * 32,1 * 32}, "bola de fogo"          },
--[[ 2 ]] {"l�ngua de fogo"        ,2, {1 * 32,1 * 32}, "bola de fogo"          },
--[[ 3 ]] {"bola de fogo"          ,3, {2 * 32,1 * 32}, "nenhuma"               },
--[[ 4 ]] {"onda s�smica"          ,2, {3 * 32,1 * 32}, "espiral fogosa"        },
--[[ 5 ]] {"chuva de meteoros"     ,2, {4 * 32,1 * 32}, "bola de fogo"          },
--[[ 6 ]] {"fogo vivo"             ,2, {5 * 32,1 * 32}, "runa de bolas de fogo" },
--[[ 7 ]] {"descarga el�trica"     ,2, {0 * 32,2 * 32}, "teleporte de chamas"   },
--[[ 8 ]] {"choque fulminante"     ,2, {1 * 32,2 * 32}, "espiral incendi�ria"   },
--[[ 9 ]] {"onda el�trica"         ,2, {2 * 32,2 * 32}, "rajada fogosa"         },
--[[ 10 ]]{"raio"                  ,2, {3 * 32,2 * 32}, "escudo infernal"       },
--[[ 11 ]]{"ciclone el�trico"      ,2, {4 * 32,2 * 32}, "escudo infernal"       },
--[[ 12 ]]{"pot�ncia en�rgica"     ,2, {5 * 32,2 * 32}, "escudo infernal"       },
--[[ 13 ]]{"plasma"                ,2, {0 * 32,3 * 32}, "escudo infernal"       },
--[[ 14 ]]{"onda tripla"           ,2, {1 * 32,3 * 32}, "escudo infernal"       },
--[[ 15 ]]{"abalo cibern�tico"     ,2, {2 * 32,3 * 32}, "escudo infernal"       },

-- druid
--[[ 16 ]]{"cura b�sica"           ,2, {0 * 32,6 * 32}, ""                      },
--[[ 17 ]]{"cura divina"           ,2, {1 * 32,6 * 32}, ""                      },
--[[ 18 ]]{"cura vital�cia"        ,2, {2 * 32,6 * 32}, ""                      },
--[[ 19 ]]{"veneno"                ,2, {0 * 32,7 * 32}, ""                      },
--[[ 20 ]]{"folhagem t�xica"       ,2, {1 * 32,7 * 32}, ""                      },
--[[ 21 ]]{"barreira de galhos"    ,2, {2 * 32,7 * 32}, ""                      },
--[[ 22 ]]{"v�nculo de vida"       ,2, {3 * 32,7 * 32}, ""                      },
--[[ 23 ]]{"explos�o de toxina"    ,2, {4 * 32,7 * 32}, ""                      },
--[[ 24 ]]{"toxina mortal"         ,2, {5 * 32,7 * 32}, ""                      },
--[[ 25 ]]{"fuma�a t�xica"         ,2, {6 * 32,7 * 32}, ""                      },
--[[ 26 ]]{"onda de luz"           ,2, {3 * 32,6 * 32}, ""                      },
--[[ 27 ]]{"cintila��o t�xica"     ,2, {0 * 32,8 * 32}, ""                      },
--[[ 28 ]]{"ben��o"                ,2, {4 * 32,6 * 32}, ""                      },
--[[ 29 ]]{"paradoxo"              ,2, {1 * 32,8 * 32}, ""                      },
--[[ 30 ]]{"blindagem"             ,2, {5 * 32,6 * 32}, ""                      },

-- paladin
--[[ 31 ]]{"precis�o"              ,9, {0 * 32,9 * 32}, ""                      },
--[[ 32 ]]{"concentra��o m�xima"   ,3, {1 * 32,9 * 32}, ""                      },
--[[ 33 ]]{"for�a suprema"         ,2, {2 * 32,9 * 32}, ""                      },
--[[ 34 ]]{"flechada cr�tica"      ,2, {3 * 32,9 * 32}, ""                      },
--[[ 35 ]]{"onus m�stico"          ,2, {4 * 32,9 * 32}, ""                      },
--[[ 36 ]]{"sabedoria"             ,3, {5 * 32,9 * 32}, ""                      },
--[[ 37 ]]{"eleva��o de carga"     ,3, {6 * 32,9 * 32}, ""                      },
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
--[[ 47 ]]{"for�a f�sica"          ,3, {8 * 32,9 * 32},  ""                      },
--[[ 48 ]]{"f�ria"                 ,2, {0 * 32,11 * 32}, ""                      },
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
  elseif type == 2 then return 'inst�ntanea'
  elseif type == 3 then return 'feiti�o'
  elseif type == 4 then return 'passiva'
  elseif type == 5 then return 'ativa��o' end
end

function getTableDescriptionSpells()
  return spells_description
end

--[1]spellType{1==rune/ 2==instante /3==sorcerer /4==passive /5==activation}
--[2]countOfPoints to buy
spells_description = {
-- wizard
--[[ 1 ]] {5,14,"Teleporta seu personagem para o local selecionado at� uma dist�ncia m�xima" ..
                " de 4 unidades. No n�vel 2, incrementa a dist�ncia m�xima para 6 unidades."},
--[[ 2 ]] {2,20,"� uma onda de fogo frontal. Tem uma dist�ncia m�xima de 5 unidades." ..
                " Criaturas atingidas recebem danos por queimadura baseado no ataque m�gico do lan�ador." ..
                " No n�vel 2, incrementa o dano por queimadura e aumenta a �rea da magia."},
--[[ 3 ]] {2,12,"Necessita de um alvo para ser lan�ada. Ao lan�ar, causa dano por queimadura " ..
                " baseado no ataque m�gico do lan�ador. No n�vel 2 e 3, incrementa o dano por queimadura."},
--[[ 4 ]] {2,23,"Gera uma explos�o em volta do lan�ador. Atinge uma �rea m�xima de 6 unidades." ..
               " Criaturas atingidas recebem danos por queimadura baseado no ataque m�gico do lan�ador." ..
               " No n�vel 2, incrementa o dano por queimadura e aumenta a �rea m�xima da magia."},
--[[ 5 ]] {1,20,"Gera uma explos�o em volta e no local atingido. A explos�o causa maior dano na " ..
               "propora��o linear do centro para fora. O dano � beaseado no ataque m�gico do lan�ador. " ..
               "No n�vel 2, aumenta a �rea atingida e o dano gerado."},
--[[ 6 ]] {1,25," Cria chamas m�gicas em volta e no local atingido. Tem uma dist�ncia m�xima de 4 unidades." ..
                " Criaturas atingidas recebem danos por queimadura baseado no ataque m�gico do lan�ador." ..
                " Os efeitos do fogo vivo s�o cumulativos." ..
                " No n�vel 2, aumenta a �rea da magia."},
--[[ 7 ]] {2,14," Necessita de um alvo para ser lan�ada. A criatura atingida recebe um dano baseado" ..
                " no ataque m�gico do lan�ador. Perfura a defesa m�gica em 3%. No n�vel 2, incrementa o dano da magia."},
--[[ 8 ]] {1,20," Gera uma mini explos�o de ondas el�tricas. Criaturas atingidas recebem dano" ..
                " baseado no ataque m�gico do lan�ador. Perfura a defesa m�gica em 6%. No n�vel 2, incrementa o dano da magia." },
--[[ 9 ]] {2,20," � uma onda frontal. Tem uma dist�ncia m�xima de 6 unidades. Perfura a defesa m�gica em 8%" ..
               " Criaturas atingidas recebem dano baseado no ataque m�gico do lan�ador." ..
               " No n�vel 2, incrementa o dano e a �rea da magia."},
--[[ 10 ]] {1,26,"Necessita de um alvo para ser lan�ada. A criatura atingida recebe um dano baseado" ..
                " no ataque m�gico do lan�ador. Perfura a defesa m�gica em 12%. No n�vel 2, incrementa o dano da magia."},
--[[ 11 ]] {2,2," S�o tr�s tornados que permanecem por 5 segundos, vagando aleat�riamente. Cada um deles" ..
                " perfura a defesa m�gica em 6% e causa danos por eletricidade baseado no ataque m�gico do lan�ador." ..
                " No n�vel 2, eles permanece por 8 segundos, � incrementado o dano e s�o produzidos quatro tornados."},
--[[ 12 ]] {1,24," Necessita de um alvo para ser lan�ada. Aumenta a velocidade do personagem em 8. No" ..
                 " n�vel 2, aumenta a velocidade em 12."},
--[[ 13 ]] {5,14," Necessita de um alvo para ser lan�ada. Criaturas atingidas recebem danos por queimadura baseado no ataque m�gico do lan�ador e" ..
                 " tem perfura��o de defesa m�gica em 4%. No n�vel 2, incrementa o dano por queimadura e a perfura��o m�gica."},
--[[ 14 ]] {3,24," Gera uma explos�o em volta do lan�ador. Atinge uma �rea m�xima de 6 unidades. Demora " ..
                 " dois segundos para ser lan�ada. Causa um dano por queimadura e perfura a armadura."},
--[[ 15 ]] {3,30," Gera uma explos�o em volta do lan�ador. Atinge uma �rea m�xima de 6 unidades. Demora " ..
                 " dois segundos para ser lan�ada. Causa um dano por queimadura e perfura a armadura."},

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
--[[ 31 ]] {2,20,"+ ml dura mais tempo a magia. Aumenta a precis�o do arqueiro em 5% no n�vel 1, em 4% no n�vel 2, em 3% no n�vel 3 e em 3% no n�vel 4."},
--[[ 32 ]] {2,20,"dano criquanto mais distan maior o danoAumenta a precis�o do arqueiro de 10% � 25% no n�vel 1, de 15% � 30% no n�vel 2 e de 20% a 35% no n�vel 3." ..
                 " Este efeito tem durabilidade de 15 segundos."},
--[[ 33 ]] {2,20,"Aumenta o ataque f�sico(- ataq speed) do arqueiro em 6 no n�vel 1 e em 8 no n�vel 2." ..
                 " Este efeito permanece ativo por 25 segundos."},
--[[ 34 ]] {6,20,"atordoa Dispara uma flecha m�gica no local escolhido, ap�s tr�s segundos, no n�vel 1. Caso a flecha atinga" ..
                 " alguma criatura, esta tomar� um dano cr�tico incrementado de 25% � 30%. No n�vel 2, o tempo de disparo" ..
                 " da flecha � de dois segundos e o incremento do dano cr�tico � de 35% � 45%."},   
--[[ 35 ]] {4,20,"Incrementa a velociade de ataque e/ou a esquiva em 4 pontos de atributos aleatoriamente no n�vel 1." ..
                 " No n�vel 2, incrementa em 3 pontos."},    
--[[ 36 ]] {2,20,"Aperfei�oa at� 10 flechas incrementando o ataque em 1, no n�vel 1. No n�vel 2, aperfei�oa at� 11 flechas" ..
                 " incrementando o ataque em 2. No n�vel 3, aperfei�oa at� 12 flechas incrementando o ataque em 3."},                    
--[[ 37 ]] {4,20,"Aumenta a capacidade de flechas na aljava para mais 20, no n�vel 1. No n�vel 2, aumenta a capacidade para mais 15. No n�vel 3 para mais 12."},                    

--[[ 38 ]] {2,20,"Aumenta a velocidade de ata(diminui a precisao e ataque fisico)"}, 
--[[ 39 ]] {4,20,"auemnta for�a fisica"},   
--[[ 40 ]] {2,20,"incrementa a area de ataque (range)"},        
--[[ 41 ]] {4,20,"incrementa o ataq speed"},                   
--[[ 42 ]] {6,20,"chuva de flechas"},                          
--[[ 43 ]] {2,20,"diminui o peso das flechas"},                 
--[[ 44 ]] {2,20,"diminui o peso das flechas"},                  
--[[ 45 ]] {4,20,"diminui o peso das flechas"},                   
--[[ 46 ]] {4,20,"diminui o peso das flechas"},      

--knight              
--[[ 47 ]] {4,20,"Aumenta o ataque f�sico e a defesa f�sica em 1 ponto cada, no n�vel 1. No n�vel 2" ..
            ", aumenta em 2 pontos cada."},  
--[[ 48 ]] {2,20,"Causa 15% de dano a si mesmo e incrementa o ataque f�sico em 10 pontos. Aumenta a velocidade" ..
            " em 3 pontos. Reduz a defesa f�sica em 5.Pode-se gerar danos cr�ticos de 10% a 15% do ataque, no n�vel 1. No n�vel 2, causa 20%" ..
            " de dano a si mesmo e incrementa o ataque f�sico em 20. Aumenta a velocidade em 5 pontos. Reduz a " ..
            " defesa f�sica em 10. Pode-se gerar danos cr�ticos de 15% a 20% do ataque."},
--[[ 49 ]] {2,20,"Reduz a velocidade de ataque em 5 pontos. Aumenta a defesa f�sica em 12 pontos, no n�vel 1. " ..
                 "No n�vel 2, reduz a velocidade de ataque em 4 pontos e aumenta a defesa f�sica em 15 pontos."},            
--[[ 50 ]] {3,20,"Aumenta os pontos de vida em 18%/25%. Reduz vel mov."}, 
--[[ 51 ]] {2,20,"Ataca os 3 sqm frontais com 10%/15%/20% de bonus damage."},      
--[[ 52 ]] {2,20,"incrementa o n�mero de criaturas de bloqueio para 3/4."},                       
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