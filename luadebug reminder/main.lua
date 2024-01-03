local mod = RegisterMod('Luadebug Reminder', 1)
local game = Game()

-- change this to true to render the text at the bottom of the screen
mod.renderAtBottom = false

-- you can change the text if you want, but you might need to change the font as well depending on the language used
mod.text = '--luadebug is enabled'
mod.font = Font()
mod.font:Load('font/terminus8.fnt')

mod.counter = 0
mod.counterMax = 10 * 60 -- 10 seconds
mod.yOffset = 4 -- from top or bottom
mod.kcolor = KColor(1, 0, 0, 1) -- red

function mod:onGameExit()
  mod.counter = 0
end

-- 60 fps
function mod:onRender()
  if mod.counter < mod.counterMax then
    mod:renderText()
    
    if not game:IsPaused() then
      mod.counter = mod.counter + 1
    end
  end
end

function mod:onMainMenuRender()
  mod:renderText()
end

function mod:renderText()
  local ss = mod:getScreenSize()
  local x = (ss.X / 2) - (mod.font:GetStringWidthUTF8(mod.text) / 2)
  local y = mod.renderAtBottom and ss.Y - mod.font:GetLineHeight() - mod.yOffset or mod.yOffset
  mod.kcolor.Alpha = (mod.counterMax - mod.counter) / mod.counterMax
  mod.font:DrawStringUTF8(mod.text, x, y, mod.kcolor, 0, true)
end

function mod:isLuadebugEnabled()
  if REPENTANCE then
    return _LUADEBUG
  end
  
  -- ab+
  return debug or io or os or package
end

function mod:getScreenSize()
  if REPENTANCE then
    return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
  end
  
  -- ab+ / based off of code from kilburn
  local room = game:GetRoom()
  local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
  
  local rx = pos.X + 60 * 26 / 40
  local ry = pos.Y + 140 * (26 / 40)
  
  return Vector(rx * 2 + 13 * 26, ry * 2 + 7 * 26)
end

if mod:isLuadebugEnabled() then
  mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onGameExit)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
  
  if REPENTOGON then
    mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onMainMenuRender)
  end
end