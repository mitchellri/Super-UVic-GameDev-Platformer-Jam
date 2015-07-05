units = {}
units.__index = units

require('AnAL')

function units:player(object)

	--	Board
	local playerSpritesheetBoardIdle = love.graphics.newImage("Images/Player/boardIdle (2).png")
	local playerSpritesheetBoardWalk = love.graphics.newImage("Images/Player/boardWalk (2).png")
	local playerSpritesheetBoardSurf = love.graphics.newImage("Images/Player/boardSurf (2).png")
	--	No board
	local playerSpritesheetIdle = love.graphics.newImage("Images/Player/idle (2).png")
	local playerSpritesheetWalk = love.graphics.newImage("Images/Player/walk (2).png")

	temp = {}
	
	--	Placement
	temp.flip = 1
	temp.health = true
	temp.points = 0
	temp.regularSpeed = 250
	temp.slowSpeed = 100
	temp.speed = temp.regularSpeed
	temp.jump = false
	temp.jumpSpeed = -350
	temp.friction = 25
	temp.board = false
	temp.surf = false
	temp.ground = true
	
	--	Animations
	temp.animation = {}
	temp.animation.board = {}
	temp.animation.board.idle = newAnimation(playerSpritesheetBoardIdle,24,23,0.4,2)
	temp.animation.board.walk = newAnimation(playerSpritesheetBoardWalk,24,23,0.1,4)
	temp.animation.board.surf = newAnimation(playerSpritesheetBoardSurf,37,29,0.1,2)
	temp.animation.idle = newAnimation(playerSpritesheetIdle,24,23,0.4,2)
	temp.animation.walk = newAnimation(playerSpritesheetWalk,24,23,0.4,4)
	temp.animation.current = temp.animation.idle
	
	--Mechanics
	temp.body = love.physics.newBody( object.world, (object.x) or layoutWidth/4, (object.y) or layoutHeight/2, "dynamic" )
	temp.shape = {}
	temp.shape = love.physics.newRectangleShape( temp.animation.board.idle:getWidth( ), temp.animation.board.idle:getHeight( ) )
	temp.fixture = love.physics.newFixture( temp.body, temp.shape, 1 )
	temp.fixture:setRestitution( 0 )
	temp.fixture:setUserData("Player")
	temp.body:setLinearDamping( temp.friction )

	--	Inputs is the table of keys that the player uses, marked T or F depending on pressed or not
	--	Player needs to be the player object
	function temp:move(inputs)
		--	Movement
		--	Left/Right
		if inputs.left and not objects.player.jump and not objects.player.surf then
			self.body:setLinearVelocity(-objects.player.speed, 0)
			self.flip = -1
			if objects.player.board then
				objects.player.animation.current=objects.player.animation.board.walk
			else objects.player.animation.current=objects.player.animation.walk
			end
		elseif inputs.right and not objects.player.jump and not objects.player.surf then
			self.body:setLinearVelocity(objects.player.speed, 0)
			self.flip = 1
			if objects.player.board then
				objects.player.animation.current=objects.player.animation.board.walk
			else objects.player.animation.current=objects.player.animation.walk
			end
		elseif not inputs.right and not inputs.left and not surf then
			if objects.player.board then
				objects.player.animation.current=objects.player.animation.board.idle
			else
				objects.player.animation.current=objects.player.animation.idle
			end
		end
		if inputs.up and not objects.player.jump then
			x,y = objects.player.body:getLinearVelocity()
			self.body:setLinearDamping( 0 )
			self.body:setLinearVelocity(x, objects.player.jumpSpeed)
			objects.player.jump = true
		end
		if inputs.shoot and objects.player.board and not objects.player.surf then
			objects.board.body:setX(objects.player.body:getX()+objects.player.flip*objects.player.animation.current:getWidth())
			objects.board.body:setY(objects.player.body:getY()-objects.player.animation.current:getHeight()/2)
			objects.board.body:setLinearVelocity(objects.player.flip*objects.board.speed,0)
			objects.player.board = false
		end
		condX=(objects.player.body:getX() >= objects.board.body:getX()-objects.board.sprite:getWidth()) and (objects.player.body:getX() <= objects.board.body:getX()+objects.board.sprite:getWidth())
		condY=(objects.player.body:getY()-objects.player.animation.current:getHeight()/2 >= objects.board.body:getY()-objects.board.sprite:getWidth()) and (objects.player.body:getY() <= objects.board.body:getY()+objects.board.sprite:getWidth())
		if inputs.pickup then
			if objects.player.surf then
				objects.player.surf = false
				objects.board.body:setX(objects.player.body:getX()+objects.player.flip*objects.player.animation.current:getWidth())
				objects.board.body:setY(objects.player.body:getY())
				objects.board.body:setLinearVelocity(objects.player.flip*objects.board.speed/4,0)
				objects.player.board = false
				objects.player.body:setLinearDamping(objects.player.friction)
			elseif condX and condY then
				objects.board.body:setY(deleteZone)
				objects.board.body:setX(0)
				objects.player.board = true
				objects.player.body:setLinearDamping(objects.player.friction)
			end
		end
		if inputs.drop and objects.player.board then
			objects.board.body:setX(objects.player.body:getX()+objects.player.flip*objects.player.animation.current:getWidth()*2)
			objects.board.body:setY(objects.player.body:getY())
			objects.player.board = false
			objects.player.body:setLinearDamping(objects.player.friction)
		end
		if inputs.suicide then
			objects.player.health = false
		end
		
		objects.player:bound()
		
		return self
	end
	
	setmetatable(temp, {__index = units})	
	return temp
end

function units:boardBullet(object)

	temp = {}
	temp.sprite = love.graphics.newImage("Images/Player/board.png")
	temp.speed = objects.player.speed + objects.player.speed/2
	temp.delete = false
	temp.eat = false	
	
	temp.body = love.physics.newBody( object.world, (object.x) or 0, (object.y) or deleteZone, "dynamic" )
	temp.body:setBullet()
	temp.shape = {}
	temp.shape = love.physics.newRectangleShape( temp.sprite:getWidth( ), temp.sprite:getHeight( ) )
	temp.fixture = love.physics.newFixture( temp.body, temp.shape, 1 )
	temp.fixture:setUserData("BoardBullet")
	temp.body:setLinearDamping( 0 )
	
	setmetatable(temp, {__index = units})	
	return temp
end

function units:fish(object)
	
	local fishSpritesheetRegular = love.graphics.newImage("Images/fish.png")
	
	temp = {}

	--	Placement
	temp.angle = object.angle or 0
	temp.speed = 80
	temp.speedX = temp.speed
	temp.speedY = temp.speed
	temp.path = {}
	temp.flip = 1
	
	--	Animations
	temp.animation = {}
	temp.animation.regular = newAnimation(fishSpritesheetRegular,10,8,0.2,4)
	temp.animation.current = temp.animation.regular
	
	--	Mechanics
	temp.body = love.physics.newBody( world, (object.x) or 100, (object.y) or 100, "dynamic" )
	temp.shape = love.physics.newRectangleShape( temp.animation.current:getWidth( ), temp.animation.current:getHeight( ) )
	temp.fixture = love.physics.newFixture( temp.body, temp.shape, 1 )
	temp.fixture:setRestitution( 0 )
	temp.fixture:setUserData("Fish")
	temp.body:setLinearDamping( 5 )
	
	--	FollowBox
	temp.followSize = 76*4
	temp.followBox = love.physics.newRectangleShape( temp.body:getX()+temp.animation.current:getWidth()/2+76/2,temp.body:getY(),temp.followSize,temp.followSize,0 )
	temp.path.x = math.random(water.x-water.w/2,layoutWidth-10)
	temp.path.y = temp.body:getY()

	function temp:move()
		--	Movement
		--	Player is in followBox
		if objects.player.body and self.followBox:testPoint( 0, 0, 0, objects.player.body:getX(), objects.player.body:getY() ) and objects.player.health then
				self.angle = angleTo(self.body,objects.player.body)
				love.graphics.setColor(255,0,0)
				love.graphics.print("!",objects.fish.body:getX(),objects.fish.body:getY(),0, 1, 1, -objects.fish.animation.current:getWidth()/3, objects.fish.animation.current:getHeight()*3)
				love.graphics.setColor(255,255,255)
		--	Player is not in followBow
		else
			--	If at destination
			if (self.body:getX()>self.path.x-10 and self.body:getX()<self.path.x+10) and (self.body:getY()>self.path.y-10 and self.body:getY()<self.path.y+10) then
				temp.path.x = math.random(water.x-water.w/2,layoutWidth-10)
				temp.path.y = temp.body:getY()
			end
			self.angle = angleTo(self.body,self.path.x,self.path.y)
		end
		
		--	Adjust flip value
		if self.angle > math.pi/2 and self.angle < 3*math.pi/2 then
			self.flip = -1
		else
			self.flip = 1
		end
		
		self.body:applyForce(self.speedX, self.speedY)
		self:bound(false,true)
		return self
	end
	
	function temp:update()
		temp.followBox = nil
		if temp.flip then
			local r = temp.animation.current:getWidth()/2+76/2
			local x = temp.body:getX()+math.cos(temp.angle)*r
			local y = temp.body:getY()+math.sin(temp.angle)*r
			temp.followBox = love.physics.newRectangleShape( x,y,self.followSize,self.followSize,temp.angle )
		else
			temp.followBox = love.physics.newRectangleShape( temp.body:getX()+temp.animation.current:getWidth()/2+76/2,temp.body:getY(),76,76,temp.angle )
		end
		temp.speedY = math.sin(temp.angle)*temp.speed
		temp.speedX = math.cos(temp.angle)*temp.speed
	end
	
	setmetatable(temp, {__index = units})
	return temp
end

function angleTo(bodyFrom,xOrBody,y)
	--	Coordinates
	if y then
		if xOrBody >= bodyFrom:getX() then
			return math.atan((bodyFrom:getY()-y)/(bodyFrom:getX()-xOrBody))
		else
			return math.atan((y-bodyFrom:getY())/(xOrBody-bodyFrom:getX()))+math.pi
		end
	--	Body
	else
		if xOrBody:getX() >= bodyFrom:getX() then
			return math.atan((bodyFrom:getY()-xOrBody:getY())/(bodyFrom:getX()-xOrBody:getX()))
		else
			return math.atan((xOrBody:getY()-bodyFrom:getY())/(xOrBody:getX()-bodyFrom:getX()))+math.pi
		end
	end
end

function units:bound()
	--	Collision
	--	Left/Right
	if self.body:getX()<0 then
		self.body:setX(0)
		self.body:setLinearVelocity( 0,y )
	end
	if self.animation then
		if self.body:getX()>layoutWidth - self.animation.current:getWidth() then
			self.body:setX(layoutWidth - self.animation.current:getWidth())
			self.body:setLinearVelocity( 0,y )
		end
	else
		if (self.body:getX()>layoutWidth - self.sprite:getWidth()) then
			self.body:setX(layoutWidth - self.sprite:getWidth())
			self.body:setLinearVelocity( 0,y )
		end
	end
end

setmetatable(units, { __call = function(_, ...) return units.new(...) end})