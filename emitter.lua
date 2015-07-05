

local emitter = {}
emitter.__index = emitter

function emitter:new(x, y)
  local self = {}
  self.x = x or 0
  self.y = y or 0
  self.particles = {}
  self.delay = 0
  self.lifetime = 0.1
  setmetatable(self, emitter)
  return self
end


function emitter:addParticle(text, x, y)
  local p = {}
  p.text = "+"..text
  p.x = x
  p.y = y
  p.red = 255
  p.green = 255
  p.blue = 255
  p.alpha = 200
  p.time = 0
  p.yVelocity = 25
  p.lifetime = self.lifetime*text
  p.fadeSpeed = 400
  p.destroyed = false
  
  p.destroy = function(self)
    self.destroyed = true
  end
  
  p.move = function(self, dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
  end
  
  p.setColor = function(self, r, g, b, a)
    self.red = r or self.red
    self.green = g or self.green
    self.blue = b or self.blue
    self.alpha = a or self.alpha
  end
  
  p.update = function(self, dt)
    self:move(0, -self.yVelocity*dt)
    self.time = self.time + dt
    if self.time > self.lifetime then
      self.alpha = self.alpha - self.fadeSpeed * dt
      if self.alpha <= 1 then
        self.alpha = 0
        self:destroy()
      end
    end
  end
  
  p.draw = function(self)
    love.graphics.setColor(self.red, self.green, self.blue, self.alpha)
    love.graphics.print(self.text, self.x, self.y)
    love.graphics.setColor(255, 255, 255, 255)
  end

  table.insert(self.particles, p)
  return p
end


function emitter:update(dt)
  for k, particle in ipairs(self.particles) do
    if not particle.destroyed then particle:update(dt)
    else table.remove(self.particles, k) end
  end
end


function emitter:draw()
  for k, particle in ipairs(self.particles) do
    particle:draw()
  end
end

return emitter