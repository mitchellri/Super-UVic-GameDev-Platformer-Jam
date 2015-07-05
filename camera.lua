camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1/3
camera.scaleY = 1/3
camera.rotation = 0
camera.speed = 2
staticM = false

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:move(dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

function camera:setUnstatic()
	self.staticM = false
end

function camera:follow(body,dt)
	
	if body:getX() > layoutWidth then
		self.staticM = true
	end
	if self.staticM then
		return
	end
	
	camera:move(-(camera.x - (body:getX() - love.graphics.getWidth() / (2/camera.scaleX))) * dt * camera.speed)
	camera:move(0,-(camera.y - (body:getY() - love.graphics.getHeight() / (2/camera.scaleY))) * dt * camera.speed)
	
	if camera.x<0 then
		camera.x = 0
	elseif camera.x>layoutWidth-love.graphics.getWidth()/(1/camera.scaleX) then
		camera.x = layoutWidth-love.graphics.getWidth()/(1/camera.scaleX)
	end
	if camera.y<0 then
		camera.y = 0
	elseif camera.y>layoutHeight-love.graphics.getHeight()/(1/camera.scaleY) then
		camera.y = layoutHeight-love.graphics.getHeight()/(1/camera.scaleY)
	end
end