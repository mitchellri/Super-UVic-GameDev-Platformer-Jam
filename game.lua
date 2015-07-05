local game = {}

require('units')
require('camera')
require('stack')
local emitter = require('emitter')
local emitter = emitter:new()

font = love.graphics.newFont("Fonts/small2.ttf",16)
love.graphics.setFont(font)
layoutWidth = 8*20*6*2	--	960
layoutHeight = 5*20*6	--	600
background = love.graphics.newImage('Images/bg.png')
scaleX = 1/camera.scaleX
scaleY = 1/camera.scaleY
gravity = 999

--	Key variables
keys={right="right", left="left", up="up", down="down", shoot="z", pickup="x", drop="c",suicide="="}
inputs={}

--	LOAD	--
--	Called when state loads
function game.load( )
	--	World
	world = love.physics.newWorld( 0, gravity, true )
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	objects = {}
	objects.player = units:player({world=world})
	objects.player.body:setMass(.1)
	testV="None"
	
	--	System variables
	timer=0
	deathTimer = 0
	deleteZone = layoutHeight+50
	
	--	Platforms
	base = {}
	base.w = layoutWidth/2
	base.h = layoutWidth
	base.body = love.physics.newBody( world, objects.player.body:getX()-5, objects.player.body:getY()+layoutWidth/2, "static" )
	base.shape = love.physics.newRectangleShape( base.w, base.h )
	base.fixture = love.physics.newFixture( base.body, base.shape, 1 )
	base.fixture:setUserData("Ground")
	--[[box = {}
	box.w = 15
	box.h = 15
	box.body = love.physics.newBody( world, objects.player.body:getX(), objects.player.body:getY()-50, "dynamic" )
	box.shape = love.physics.newRectangleShape( box.w, box.h )
	box.fixture = love.physics.newFixture( box.body, box.shape, 1 )]]
	water = {}
	water.h=layoutWidth
	water.w=layoutWidth
	water.x=base.body:getX()+base.w/2+water.w/2
	water.y=base.body:getY()-base.h/2+water.h/2
	water.box = love.physics.newRectangleShape( water.x,water.y,water.h,water.w,0 )
	spike = {}
	spike.h=3
	spike.w=150/2
	spike[0] = {}
	spike[0].body = love.physics.newBody( world, objects.player.body:getX()+150, objects.player.body:getY(), "static" )
	spike[0].shape = love.physics.newRectangleShape( spike.w, spike.h )
	spike[0].fixture = love.physics.newFixture( spike[0].body, spike[0].shape, 1 )
	spike[0].fixture:setUserData("Spike")
	spike[1] = {}
	spike[1].body = love.physics.newBody( world, objects.player.body:getX()+275, objects.player.body:getY(), "static" )
	spike[1].shape = love.physics.newRectangleShape( spike.w, spike.h )
	spike[1].fixture = love.physics.newFixture( spike[1].body, spike[1].shape, 1 )
	spike[1].fixture:setUserData("Spike")
	plat1 = {}
	plat1.w = 100
	plat1.h = 100
	plat1.body = love.physics.newBody( world, spike[1].body:getX()+spike.w+plat1.w/2, objects.player.body:getY(), "static" )
	plat1.shape = love.physics.newRectangleShape( plat1.w, plat1.h )
	plat1.fixture = love.physics.newFixture( plat1.body, plat1.shape, 1 )
	plat1.fixture:setUserData("Ground")
	plat2 = {}
	plat2.w = 100
	plat2.h = 50
	plat2.body = love.physics.newBody( world, spike[1].body:getX()-100, objects.player.body:getY()-100, "static" )
	plat2.shape = love.physics.newRectangleShape( plat2.w, plat2.h )
	plat2.fixture = love.physics.newFixture( plat2.body, plat2.shape, 1 )
	plat2.fixture:setUserData("Ground")
	
	--	Coin
	objects.coin = {}
	objects.coin.delete = false
	objects.coin.w = 3
	objects.coin.h = 5
	objects.coin.body = love.physics.newBody( world, layoutWidth-30, objects.player.body:getY()-30, "static" )
	objects.coin.shape = love.physics.newRectangleShape( objects.coin.w, objects.coin.h )
	objects.coin.fixture = love.physics.newFixture( objects.coin.body, objects.coin.shape, 1 )
	objects.coin.fixture:setUserData("Coin")
	
	--	Board
	objects.board = units:boardBullet({world=world,x=plat2.body:getX(),y=plat2.body:getY()-plat2.h/2-10})
	objects.board.body:setMass(.1)
	
	--	Fish
	objects.fish = units:fish({world=world, x=water.x-water.w/2+10,y=objects.player.body:getY()})
	objects.fish.body:setMass(.1)
	
	--	Reset camera
	camera:setUnstatic()
	cameraFollow = objects.player.body
end
	
--	UPDATE	--
--	Updates every change in time/frame
function game.update( dt )
	
	--	Update variables
	timer = timer + love.timer.getDelta()
	
	if objects.board.eat then
		objects.board.body:setX(objects.player.body:getX())
		objects.board.body:setY(objects.player.body:getY())
		objects.board.eat = false
	end
	
	--	Player is alive
	if objects.player.health then
		
		if (objects.player.body:getX()<300) and (objects.player.points ~= 0) then
			love.graphics.print("You have won",camera.x+100,camera.y+100,0,scaleX,scaleY)
		end
		
		--	Player movement
		x,y=objects.player.body:getLinearVelocity()
		if y>=-1 and y<=1 and not objects.player.jump then
			y=0
			objects.player.body:setLinearDamping(objects.player.friction)
		end
		objects.player.body:setLinearVelocity(x,y)
		objects.player:move(inputs)
		
		--	Player jumped on board
		if objects.board.delete then
			--[[objects.player.body:setX(objects.board.body:getX())
			objects.player.body:setY(objects.board.body:getY())]]
			objects.board.body:setY(deleteZone)
			objects.board.body:setX(0)
			objects.board.delete = false
			objects.player.surf = true
			objects.player.body:setLinearDamping(0)
		end
		if objects.coin.delete then
			objects.coin.body:setY(deleteZone)
			objects.coin.body:setX(0)
			objects.coin.delete = false
		end
		
		--	Player in water
		if water.box:testPoint( 0, 0, 0, objects.player.body:getX(), objects.player.body:getY() ) then
			objects.player.ground = false
			objects.player.jump = false
			objects.player.body:setLinearDamping(objects.player.friction)
			objects.player.body:applyForce(0, -gravity/2)
		--	Player over water and not surfing
		elseif ((objects.player.body:getX()>=water.x-water.w/2) and (objects.player.body:getX()<=layoutWidth)) and not objects.player.surf then
			objects.player.speed=objects.player.slowSpeed
		else objects.player.speed=objects.player.regularSpeed
		end
		x,y=objects.player.body:getLinearVelocity()
		--	Player is surfing
		if objects.player.surf then
			objects.player.animation.current=objects.player.animation.board.surf
			if not objects.player.ground then
				objects.player.body:setLinearVelocity(objects.player.speed*objects.player.flip,y)
			end
		end
		--	Camera movement
		camera:follow(cameraFollow,dt)
		
	--	Player is dead
	else
		--	Player life status
		if objects.player.body then
			objects.player.body:destroy()
			objects.player.body = nil
		end
		
		--	Update variables
		deathTimer = deathTimer + love.timer.getDelta()
		
		--	Reset world on button pressed
		if inputs.any and deathTimer >= 1 then
			game.load()
		end
	end
	
	--	Global
	if inputs.five then
		game.load()
	end
	bx,by=objects.board.body:getLinearVelocity()
	--	Board in water
	if water.box:testPoint( 0, 0, 0, objects.board.body:getX(), objects.board.body:getY() ) then
		objects.board.body:applyForce(0, -gravity/2)
		bx=bx/1.1
	end
	objects.board.body:setLinearVelocity(bx,by)
	--	Fish in water
	if water.box:testPoint( 0, 0, 0, objects.fish.body:getX(), objects.fish.body:getY() ) then
		objects.fish.body:applyForce(0, -gravity/7)
	end
	--	Move fish
	objects.fish:move()
	
	--	Update properties
	objects.board:bound()
	objects.player.animation.current:update(dt)
	objects.fish.animation.current:update(dt)
	objects.fish:update()
	world:update(dt)
end

--	DRAW	--
--	Draws things, called every frame after update
function game.draw()
	
	--	Camera push
	camera:set()
	
	--	Background
	love.graphics.draw(background,0,20)
	love.graphics.draw(background,background:getWidth(),20)
	love.graphics.polygon("line",water.box:getPoints())
	
	--	Global
	love.graphics.setColor(100,200,100)
	love.graphics.rectangle( "fill", base.body:getX()-base.w/2, base.body:getY()-base.h/2, base.w, base.h )
	love.graphics.rectangle( "fill", plat1.body:getX()-plat1.w/2, plat1.body:getY()-plat1.h/2, plat1.w, plat1.h )
	love.graphics.rectangle( "fill", plat2.body:getX()-plat2.w/2, plat2.body:getY()-plat2.h/2, plat2.w, plat2.h )
	love.graphics.setColor(255,0,0)
	--love.graphics.rectangle( "fill", box.body:getX()-box.w/2, box.body:getY()-box.h/2, box.w, box.h )
	love.graphics.rectangle( "fill", spike[0].body:getX()-spike.w/2, spike[0].body:getY()-spike.h/2, spike.w, spike.h )
	love.graphics.rectangle( "fill", spike[1].body:getX()-spike.w/2, spike[1].body:getY()-spike.h/2, spike.w, spike.h )
	love.graphics.setColor(255,255,0)
	love.graphics.rectangle( "fill", objects.coin.body:getX()-objects.coin.w/2, objects.coin.body:getY()-objects.coin.h/2, objects.coin.w, objects.coin.h )
	love.graphics.setColor(255,255,255)
	love.graphics.draw(objects.board.sprite,objects.board.body:getX()-objects.board.sprite:getWidth()/2,objects.board.body:getY()+objects.board.sprite:getHeight()/2)
	-- 	Fish
	objects.fish.animation.current:draw(objects.fish.body:getX(), objects.fish.body:getY(),objects.fish.angle,1,objects.fish.flip)
	if objects.player.body and objects.fish.followBox:testPoint( 0, 0, 0, objects.player.body:getX(), objects.player.body:getY() ) and objects.player.health then
		love.graphics.setColor(255,0,0)
		love.graphics.print("!",objects.fish.body:getX(),objects.fish.body:getY(),0, 1, 1, -objects.fish.animation.current:getWidth()/3, objects.fish.animation.current:getHeight()*3)
		love.graphics.setColor(255,255,255)
	end
	
	--	Player is alive
	if objects.player.health then
		--	Flip offset
		if objects.player.flip==1 then
			objects.player.animation.current:draw(objects.player.body:getX()-objects.player.animation.current:getWidth()/2, objects.player.body:getY()-objects.player.animation.current:getHeight()/2,0,objects.player.flip,1)
		else
			objects.player.animation.current:draw(objects.player.body:getX()-objects.player.animation.current:getWidth()/2, objects.player.body:getY()-objects.player.animation.current:getHeight()/2,0,objects.player.flip,1,objects.player.animation.current:getWidth(),0)
		end
	--	Player is dead
	else
		love.graphics.setColor(255,0,0)
		love.graphics.print("You have died.",camera.x+100,camera.y+100,0,scaleX,scaleY)
		if deathTimer>=1 then
			love.graphics.print("press any button to retry.",camera.x+100,camera.y+130)
		end
	end
	
	love.graphics.setColor(0,0,0)
	love.graphics.print("Go get your surfboard!\nz:\tThrow your surfboard\nx:\tUnmount surfboard when mounted \nx:\tPick up surfboard when unmounted\nc:\tDrop your surfboard\n5:\tRestart\nequals:\tSuicide",300,150)
	love.graphics.print("There is a coin on the right side of the map\nCollect the coin and return to the left side of the map to win\nYou must be surfing to recieve the coin",plat2.body:getX()+150,150)
	love.graphics.setColor(255,255,255)
	
	--	Camera pop
	camera:unset()
	
	love.graphics.print("FPS: "..love.timer.getFPS(),0,0,0,scaleX,scaleY)
	love.graphics.print("Time: "..math.floor(timer),0,6*scaleY,0,scaleX,scaleY)
	love.graphics.setColor(255,0,0)
	--love.graphics.print("TestV: "..tostring(testV),0,12*scaleY,0,scaleX,scaleY)
	love.graphics.setColor(255,255,255)
end

function beginContact(a, b, coll)
	if (a:getUserData() == "Player" or b:getUserData() == "Player") and objects.player.health then
		--objects.player.body:setLinearDamping( objects.player.friction )
		if y>0 then
			objects.player.jump = false
		end
		if a:getUserData() == "BoardBullet" or b:getUserData() == "BoardBullet" then
			if objects.player.body:getY() < objects.board.body:getY() then
				objects.board.delete=true
			end
		elseif a:getUserData() == "Ground" or b:getUserData() == "Ground" then
			objects.player.ground = true
			if a:getUserData() == "Ground" and a:getBody():getY()<b:getBody():getY() then
				objects.player.ground = true
			elseif b:getUserData() == "Ground" and b:getBody():getY()<a:getBody():getY() then
				objects.player.ground = true
			end
		elseif a:getUserData() == "Fish" or b:getUserData() == "Fish" then
			if objects.player.surf or objects.player.board then
				objects.board.eat = true
			end
			objects.player.health=false
		elseif a:getUserData() == "Spike" or b:getUserData() == "Spike" then
			testV=true
			objects.player.health = false
		elseif a:getUserData() == "Coin" or b:getUserData() == "Coin" and objects.player.surf then
			objects.coin.delete = true
			objects.player.points=objects.player.points+1
		end
	end
end

--	KEYPRESSED	--
--
function game.keypressed( key, isrepeat )
	inputs.left = love.keyboard.isDown(keys.left)
	inputs.right = love.keyboard.isDown(keys.right)
	inputs.up = love.keyboard.isDown(keys.up)
	inputs.five = love.keyboard.isDown(5)
	inputs.shoot = love.keyboard.isDown(keys.shoot)
	inputs.pickup = love.keyboard.isDown(keys.pickup)
	inputs.drop = love.keyboard.isDown(keys.drop)
	inputs.suicide = love.keyboard.isDown(keys.suicide)
	inputs.any = love.keyboard.isDown(key)
end

--	KEYRELEASED	--
--
function game.keyreleased( key )
	inputs.left = love.keyboard.isDown(keys.left)
	inputs.right = love.keyboard.isDown(keys.right)
	inputs.up = love.keyboard.isDown(keys.up)
	inputs.five = love.keyboard.isDown(5)
	inputs.shoot = love.keyboard.isDown(keys.shoot)
	inputs.pickup = love.keyboard.isDown(keys.pickup)
	inputs.suicide = love.keyboard.isDown(keys.suicide)
	if key ~= nil then
		inputs.any = love.keyboard.isDown(key)
	else
		inputs.any = false
	end
end

--	MOUSEPRESSED	--
--
function game.mousepressed( x, y, button )

end

--	MOUSERELEASED	--
--
function game.mousereleased( x, y, button )

end

return game