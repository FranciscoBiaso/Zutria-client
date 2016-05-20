MAP_SHADERS = {

  { name = 'Default', frag = 'shaders/default.frag',vert = 'shaders/default.vert' },
  --{ name = 'Bloom', frag = 'shaders/bloom.frag'},
 --- { name = 'Sepia', frag ='shaders/sepia.frag' },
 -- { name = 'Grayscale', frag ='shaders/grayscale.frag' },
 -- { name = 'Pulse', frag = 'shaders/pulse.frag' },
 -- { name = 'Old Tv', frag = 'shaders/oldtv.frag' },
 { name = 'ff', vert = 'shaders/default.vert', frag = 'shaders/ff.frag', tex1 = 'images/clouds.png' },
  --{ name = 'Fog2', frag = 'shaders/fog2.frag', tex1 = 'images/clouds3.png' },
 --{ name = 'Party', frag = 'shaders/party.frag',vert = 'shaders/fog.vert' },
--  { name = 'Radial Blur', frag ='shaders/radialblur.frag' },
 -- { name = 'Zomg', frag ='shaders/zomg.frag' },
  --{ name = 'Heat', frag ='shaders/heat.frag' },
--  { name = 'Noise', frag ='shaders/noise.frag' },
}

local lastShader
local areas = {                    
{from = {x = -0, y = -0, z = 7}, to = {x = 0, y = 0, z = 7}, name = 'ff'},
}

function isInRange(position, fromPosition, toPosition)
    return (position.x >= fromPosition.x and position.y >= fromPosition.y and position.z >= fromPosition.z and position.x <= toPosition.x and position.y <= toPosition.y and position.z <= toPosition.z)
end

function init()
   if not g_graphics.canUseShaders() then return end
   for _i,opts in pairs(MAP_SHADERS) do
     local shader = g_shaders.createShader(opts.name, opts.vert, opts.frag)
     if opts.tex1 then
       shader:addMultiTexture(opts.tex1)
     end
     if opts.tex2 then
       shader:addMultiTexture(opts.tex2)
     end
   end

   connect(LocalPlayer, {
     onPositionChange = onPositionChange,
   })
   
   local map = modules.game_interface.getMapPanel()
   map:setMapShader(g_shaders.getShader('Default'))
end

function terminate()

end

function onPositionChange(localPlayer, newPos, oldPosition)
  if not localPlayer then return end
  if not newPos or not oldPosition then return end
  local name = 'Default'  
  for _, TABLE in ipairs(areas) do
      if isInRange(newPos, TABLE.from, TABLE.to) then
         name = TABLE.name
      end
  end
  if lastShader and lastShader == name then return true end
  lastShader = name
  local map = modules.game_interface.getMapPanel()
  map:setMapShader(g_shaders.getShader(name))
  if newPos.x > oldPosition.x then
    g_shaders.setFogOffset(name,1.0,0)
  elseif newPos.x < oldPosition.x then
     g_shaders.setFogOffset(name,0.6,1.0)
  end
end       