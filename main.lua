-- Set up our set upy things
function rollUpPlayer()
	dex_score = rollDice(3,6)
	str_score = rollDice(3,6)
	con_score = rollDice(3,6)
	player = {dex=dex_score, str=str_score, con=con_score}
	return player
end

function drawExitMenu()
	showExitMenu = true
end

function clearMenus()
	showExitMenu = false
end

function rollUpOrc()
	dex_score = rollDice(2,6)
	str_score = rollDice(5,6)
	con_score = rollDice(5,6)
	orc = {dex=dex_score, str=str_score, con=con_score}
	return orc
end

function rollDice(number,sides)
	rolls = {}
	total = 0
	for i=1, number, 1 do
		table.insert(rolls,math.random(1,sides))
	end
	for k,v in pairs(rolls) do
		total = v+total
	end
	return total
end

function revealTiles(x,y)
	local space = getSpace(x,y)
	walls[space-1].seen = 'yes'
	walls[space+1].seen = 'yes'
	walls[space+map_width].seen = 'yes'
	walls[space+(map_width)-1].seen = 'yes'
	walls[space+(map_width)+1].seen = 'yes'
	walls[space-map_width].seen = 'yes'
	walls[space-(map_width)-1].seen = 'yes'
	walls[space-(map_width)+1].seen = 'yes'
end

function load()
	love.graphics.setBackgroundColor(10,10,10)
	mode = love.graphics.setMode(750, 700, false, true, 4)
	window_height = love.graphics.getHeight()
	window_width = love.graphics.getWidth()
	extreme_color = love.graphics.newColor( 100, 0, 0 )
	fog_of_war = love.graphics.newColor( 255, 255, 255, 60 )
	currentTime = love.timer.getTime()
	menuFont = love.graphics.newFont(love.default_font, 20) 
	uiFont = love.graphics.newFont(love.default_font, 13) 
	math.randomseed(os.time())
	math.random(); math.random(); math.random();
	player = rollUpPlayer()
	orc = rollUpOrc()
	menuShown = false
	numberCharacters = 2
	map_height = 13
	map_width = 15
	grid_size = 50
	totalMoves = 0
	numberRooms = 0
	message_x = 250
	message_y = 625
	message_angle = 0
	totalTiles = (map_height) * (map_width)
	remainingTiles = totalTiles - numberCharacters
	grid_state = 'on'
	lastkey =  'nothing'
	musicState = 'playing'
	pie_status = 'is being carried by the orc'
	last_message = ''
	orc_space = ''
	player_space = ''
	orc_sees_player = 'no'
	orc_carrying_pie = 'yes'
	orc_limbs = {l_arm='fine',r_arm='fine',l_leg='fine',r_leg='fine',neck='fine',chest='fine',str=2}
	player_limbs = {l_arm='fine',r_arm='fine',l_leg='fine',r_leg='fine',neck='fine',chest='fine'}
	combat_message = ''
	orc_visible = 'no'

	orcs = {speed=1}
	walls = {}
	impassable = {}
	rooms = {}
	
	function getSpace(x,y)
		space = (y-1) * (map_width) + (x)
		return space
	end
	
	function findPath(x1, y1, x2, y2)
		openList = {}
		closedList = {}
		for k,v in pairs(walls) do
			space = getSpace(v.x,v.y)
			if v.type == 'wall' then
				table.insert(closedList,space)
			else
				table.insert(openList,space)
			end
		end
		
		x1 = player_x
		x2 = orc_x
		y1 = player_y
		y2 = orc_y
		
		--last_message = 's:' .. start_space .. 'e: ' .. end_space
		
	end
	
	function canSeePlayer(x,y)
		orc_player_x_diff = x - player_x
		orc_player_y_diff = y - player_y
		if orc_player_x_diff >= -2 then
			if orc_player_x_diff <= 2 then
				if orc_player_y_diff >= -2 then
					if orc_player_y_diff <= 2 then
						orc_sees_player = 'yes'
						orc_visible = 'yes'
						if orc_carrying_pie == 'yes' then
							setDownPie(x*grid_size-(grid_size/2),y*grid_size-(grid_size/2))
						end
					end
				end
			end
		else
			orc_sees_player = 'no'
			orc_visible = 'no'
		end
	end
	
	function canAttackPlayer(x,y)
		orc_player_x_diff = x - player_x
		orc_player_y_diff = y - player_y
		orcCanAttack ='no'
		if orc_player_x_diff >= -1 then
			if orc_player_x_diff <= 1 then
				if orc_player_y_diff >= -1 then
					if orc_player_y_diff <= 1 then
					--	combat_message = 'yes'
						orcCanAttack = 'yes'
					end
				end
			end
		end
	end
	
	function setDownPie(x,y)
		pie_x = x
		pie_y = y
		orc_carrying_pie = 'no'
		pie_status = 'was set down gently'
	end
	
	function playerGetPie()
		pie_x = player_x_pixels
		pie_y = player_y_pixels
		orc_carrying_pie = 'no'
		pie_status = 'is being carried by you!'
		player_carrying_pie = 'yes'
	end
	
	function attackPlayer(source)
		combat_message = 'orc attacked'
	end

	function moveOrc()
		combat_message = ''
		canSeePlayer(orc_x,orc_y)
		canAttackPlayer(orc_x,orc_y)

		goodSpot = 'no'
		
		if orc_sees_player == 'yes' then
			if orcCanAttack == 'yes' then
				attackPlayer('orc')
			else
				possible_next_move = findPath(orc_space, player_space)	
			end
			last_message = 'orc sees you! shit!'
			orc_sprite = love.graphics.newImage("red_orc.png")
		else
			orc_sprite = love.graphics.newImage("orc.png")
			x_table = {0,1,-1}
			y_table = {0,1,-1}
			repeat
				possible_orc_x = x_table[math.random(1,3)]
				possible_orc_y = y_table[math.random(1,3)]

				space = ((orc_y + possible_orc_y)-1) * (map_width) + (orc_x + possible_orc_x)
				if walls[space].type == 'wall' then
					goodSpot = 'no'
				else
					goodSpot = 'yes'
					orc_x_pixels = orc_x_pixels + (possible_orc_x * grid_size)
					orc_y_pixels = orc_y_pixels + (possible_orc_y * grid_size)
					orc_x = orc_x + possible_orc_x
					orc_y = orc_y + possible_orc_y
					if orc_carrying_pie == 'yes' then
						pie_x = orc_x_pixels-10
						pie_y = orc_y_pixels-10
					end
					if orc_y == 1 then
						orc_space = orc_x 
					else
						orc_space = (orc_y-1) * (map_width) + (orc_x)
					end
				
					-- Face the orc in some direction
				
					if possible_orc_x == -1 then
						if possible_orc_y == -1 then
							new_orc_facing = 225
						end
						if possible_orc_y == 0 then
							new_orc_facing = 180
						end
						if possible_orc_y == 1 then
							new_orc_facing = 135
						end
					end
					if possible_orc_x == 0 then
						if possible_orc_y == -1 then
							new_orc_facing = 180
						end
						if possible_orc_y == 0 then
							new_orc_facing = orc_facing
						end
						if possible_orc_y == 1 then
							new_orc_facing = 90
						end
					end
					if possible_orc_x == 1 then
						if possible_orc_y == -1 then
							new_orc_facing = 315
						end
						if possible_orc_y == 0 then
							new_orc_facing = 0
						end
						if possible_orc_y == 1 then
							new_orc_facing = 45
						end
					end
					orc_facing = new_orc_facing
				end
			until goodSpot == 'yes'
		end
		--last_message = 'x:' .. orc_player_x_diff .. 'y: ' .. orc_player_y_diff
		
		orc_sees_player = 'no'
	end

	function facePlayer(dir)
		player_facing = dir
	end

	function movePlayer(dir)
		if dir == 'punch' then
			possible_player_x = 0
			possible_player_y = 0
			playerMoved = 'yes'
		end
		if dir == 'up_left' then
			possible_player_x = -1
			possible_player_y = -1
			playerMoved = 'yes'
		end
		if dir == 'up_right' then
			possible_player_x = 1
			possible_player_y = -1
			playerMoved = 'yes'
		end
		if dir == 'down_left' then
			possible_player_x = -1
			possible_player_y = 1
			playerMoved = 'yes'
		end
		if dir == 'down_right' then
			possible_player_x = 1
			possible_player_y = 1
			playerMoved = 'yes'
		end
		if dir == 'left' then
			possible_player_x = -1
			possible_player_y = 0
			playerMoved = 'yes'
		end
		if dir == 'down' then
			possible_player_y = 1
			possible_player_x = 0
			playerMoved = 'yes'
		end
		if dir == 'right' then
			possible_player_x = 1
			possible_player_y = 0
			playerMoved = 'yes'
		end
		if dir == 'up' then
			possible_player_y = -1
			possible_player_x = 0
			playerMoved = 'yes'
		end

		space = ((player_y + possible_player_y)-1) * (map_width) + (player_x + possible_player_x)

		if walls[space].type == 'wall' then
			playerMoved = 'no'
			last_message = '*bump*'
			message_angle = 0
		else
			playerMoved = 'yes'
			last_message = ''
		end

		if playerMoved == 'yes' then
			player_x_pixels = player_x_pixels + (possible_player_x * grid_size)
			player_y_pixels = player_y_pixels + (possible_player_y * grid_size)
			player_x = player_x + possible_player_x
			player_y = player_y + possible_player_y
			if player_y == 1 then
				player_space = player_x 
			else
				player_space = (player_y-1) * (map_width) + (player_x)
			end
			if player_x_pixels == pie_x then
				if player_y_pixels == pie_y then
					if player_carrying_pie ~= 'yes' then
						playerGetPie()
					end
				end
			end
			if player_carrying_pie == 'yes' then
				pie_x = player_x_pixels
				pie_y = player_y_pixels
			end
			revealTiles(player_x,player_y)
			moveOrc()
			totalMoves = totalMoves+1
			clearMenus()
			if player_space == stairs_space then
				drawExitMenu()
			end
		end

		playerMoved = 'no'
	end
	
	-- Generate room walls around border
	i = 0
	for j=1, map_height, 1 do
		for k=1, map_width, 1 do
			i = i + 1
			x = k
			y = j
			walls[i] = {x=x,y=y,type='empty',seen='no'}
		end
	end
	
	for k,v in pairs(walls) do
		if v.y == 1 then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
		if v.x == 1 then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
		if v.x == math.ceil(map_width/2) then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
		if v.y == map_height then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
		if v.x == map_width then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
		if v.y == math.ceil(map_height/2) then
			walls[k] = {x=v.x,y=v.y,type='wall',seen='no'}
		end
	end
	-- end wall generation
	
	-- Room generation
	
	for k,v in pairs(walls) do
		if v.type == 'wall' then
			remainingTiles = remainingTiles - 1
		end
	end
	
	rooms[1] = {x=2,y=2}
	rooms[2] = {x=math.ceil(map_width/2)+1,y=2}
	rooms[3] = {x=2,y=math.ceil(map_height/2)+1}
	rooms[4] = {x=math.ceil(map_width/2)+1,y=math.ceil(map_height/2)+1}
	
	goodSpot = 'no'
	repeat
		random_x = math.random(2,math.ceil(map_width/2)-1)
		possible_door = getSpace(random_x,math.ceil(map_height/2))
		x = walls[possible_door].x
		y = walls[possible_door].y
		if x ~= math.ceil(map_width/2) then
			goodSpot = 'yes'
			walls[possible_door] = {x=x,y=y,type='empty',seen='no'}
		end
	until goodSpot == 'yes'
	
	goodSpot = 'no'
	repeat
		random_x = math.random((math.ceil(map_width/2)+1),(math.ceil(map_width)-1))
		possible_door = getSpace(random_x,math.ceil(map_height/2))
		x = walls[possible_door].x
		y = walls[possible_door].y
		if x ~= math.ceil(map_width/2) then
			goodSpot = 'yes'
			walls[possible_door] = {x=x,y=y,type='empty',seen='no'}
		end
	until goodSpot == 'yes'
	
	goodSpot = 'no'
	repeat
		random_y = math.random(2,(math.ceil(map_height / 2)-1))
		possible_door = getSpace(math.ceil(map_width/2), random_y)
		x = walls[possible_door].x
		y = walls[possible_door].y
		if x ~= math.ceil(map_height/2) then
			goodSpot = 'yes'
			walls[possible_door] = {x=x,y=y,type='empty',seen='no'}
		end
	until goodSpot == 'yes'
	
	goodSpot = 'no'
	repeat
		random_y = math.random((math.ceil(map_height/2)+1),(math.ceil(map_height)-1))
		possible_door = getSpace(math.ceil(map_width/2),random_y)
		x = walls[possible_door].x
		y = walls[possible_door].y
		if x ~= math.ceil(map_height/2) then
			goodSpot = 'yes'
			walls[possible_door] = {x=x,y=y,type='empty',seen='no'}
		end
	until goodSpot == 'yes'

	
	-- Load graphics
	love.graphics.setCaption("Orc & Pie")
	grid = love.graphics.newImage("grid.png")
	
	orc_sprite = love.graphics.newImage("orc.png")
	
	player_sprite = love.graphics.newImage("player.png")
	stairs = love.graphics.newImage("up_stairs.png")
	arrow = love.graphics.newImage("arrow.png")
	pie = love.graphics.newImage("pie.png")
	brown_wall = love.graphics.newImage("brown_wall.png")
	stone_wall = love.graphics.newImage("stone_wall.png")
	green_grass = love.graphics.newImage("green_grass.png")
	darkened = love.graphics.newImage("darkened.png")

	-- Plop down the orc(s)
	goodSpot = 'no'
	repeat
		repeat
			possible_orc_x = math.random(2,map_height-1)
			possible_orc_y = math.random(2,map_width-1)
			space = getSpace(possible_orc_x,possible_orc_y)
		until type(space) == 'number'
		theSpace = walls[space].type
		if theSpace == 'empty' then
			goodSpot = 'yes'
			orc_x = possible_orc_x
			orc_y = possible_orc_y
			orc_x_pixels = possible_orc_x * grid_size - (grid_size/2)
			orc_y_pixels = possible_orc_y * grid_size - (grid_size/2)
			orc_space = space
			orc_facing = 0
		else
			goodSpot = 'no'
		end
	until goodSpot == 'yes'
	
	-- Gently set down our pie(s)
	pie_x = orc_x_pixels-10
	pie_y = orc_y_pixels-10
	
	-- plop down the player
	goodSpot = 'no'
	repeat
		repeat
			possible_player_x = math.random(2,map_height-1)
			possible_player_y = math.random(2,map_width-1)
			space = getSpace(possible_player_x,possible_player_y)
		until type(space) == 'number'
		if walls[space].type == 'empty' then
			goodSpot = 'yes'
			player_x = possible_player_x
			player_y = possible_player_y
			player_x_pixels = possible_player_x * grid_size - (grid_size/2)
			player_y_pixels = possible_player_y * grid_size - (grid_size/2)
			player_space = space
			revealTiles(player_x,player_y)
		else
			goodSpot = 'no'
		end
	until goodSpot == 'yes'
	player_facing = 0
	goodSpot = 'no'
	-- Drop the stairs
	repeat
		possible_stairs_x = math.random(2,map_height-1)
		possible_stairs_y = math.random(2,map_width-1)
		space = getSpace(possible_stairs_x,possible_stairs_y)
		if walls[space].type == 'empty' then
			if walls[space] ~= player_space then
				goodSpot = 'yes'
				up_stairs_x = possible_stairs_x
				up_stairs_y = possible_stairs_y
				up_stairs_x_pixels = possible_stairs_x * grid_size - (grid_size/2)
				up_stairs_y_pixels = possible_stairs_y * grid_size - (grid_size/2)
				stairs_space = space
				walls[space].type = 'stairs'
			end
		else
			goodSpot = 'no'
		end
	until goodSpot == 'yes'
	
end

function update(dt)
	currentTime = math.floor(love.timer.getTime())
end

function draw()
	-- Draw the grid
	row=0
	while row<map_height do
		column=0
		while column<16 do
			
			love.graphics.draw(grid,column*grid_size+(grid_size / 2),row*grid_size+(grid_size / 2))
			--love.graphics.draw(green_grass,column*grid_size+(grid_size / 2),row*grid_size+(grid_size / 2))
			column = column+1
		end
		row = row+1
	end
	g = 0
	for k,v in pairs(walls) do
		if v.type == 'wall' then
			if v.seen == 'no' then
				--love.graphics.draw(darkened, v.x*grid_size-(grid_size/2), v.y*grid_size-(grid_size/2))
			else
				love.graphics.draw(brown_wall, v.x*grid_size-(grid_size/2), v.y*grid_size-(grid_size/2))
			end
		end
		if v.type == 'stairs' then
			if v.seen == 'no' then
				--love.graphics.draw(darkened, v.x*grid_size-(grid_size/2), v.y*grid_size-(grid_size/2))
			else
				love.graphics.draw(stairs, up_stairs_x_pixels, up_stairs_y_pixels)
			end
		end
		g = g + 40
	end

	
	love.graphics.draw(orc_sprite, orc_x_pixels, orc_y_pixels)
	--love.graphics.draw(arrow, orc_x_pixels, orc_y_pixels, orc_facing)
	love.graphics.draw(player_sprite, player_x_pixels, player_y_pixels, player_facing)
	love.graphics.draw(arrow, player_x_pixels, player_y_pixels,player_facing)
	love.graphics.draw(pie, pie_x, pie_y)
	
	-- "Fog of war"
	for k,v in pairs(walls) do
		x_diff = v.x - player_x
		y_diff = v.y - player_y
		love.graphics.setColor(0,0,0,100)
		if(x_diff < -1) then
			love.graphics.rectangle(2, (v.x*grid_size-grid_size), (v.y*grid_size-grid_size),grid_size,grid_size)
		elseif(x_diff > 1) then
			love.graphics.rectangle(2, (v.x*grid_size-grid_size), (v.y*grid_size-grid_size),grid_size,grid_size)
		elseif(y_diff > 1) then
			love.graphics.rectangle(2, (v.x*grid_size-grid_size), (v.y*grid_size-grid_size),grid_size,grid_size)
		elseif(y_diff < -1) then
			love.graphics.rectangle(2, (v.x*grid_size-grid_size), (v.y*grid_size-grid_size),grid_size,grid_size)
		end
	end
	
	love.graphics.setColor(255,255,255)
	--love.graphics.draw("player position: " .. player_x .. ", " .. player_y .. " : " .. player_space, 0, 620)
	love.graphics.draw("you: str " .. player.str .. ", con " .. player.con .. ", dex " .. player.dex, 0, 620)
	--love.graphics.draw("orc position: " .. orc_x .. ", " .. orc_y .. " : " .. orc_space, 0, 635)
	love.graphics.draw("orc: str " .. orc.str .. ", con " .. orc.con .. ", dex " .. orc.dex, 0, 635)
	--love.graphics.draw("pie position: " .. pie_x .. ", " .. pie_y, 0, 650)
	love.graphics.draw("pie " .. pie_status, 0, 650)
	o = 0
	for k,v in pairs(rooms) do
		love.graphics.draw("room " .. k .. " is " .. v.x + math.ceil(map_width/2)-4 .. " by " .. v.x + math.ceil(map_height/2)-4,o,675)
		o = o + 120
	end
	
	love.graphics.draw(last_message, message_x, message_y,message_angle)
	love.graphics.draw(combat_message, 250, 635)
	
	
	love.graphics.draw("moves " .. totalMoves, 600, 700)
	--
	-- "see player" debugging
	
	--love.graphics.line(player_x_pixels, player_y_pixels, orc_x_pixels, orc_y_pixels )
	--love.graphics.rectangle(1, orc_x_pixels-(grid_size*2)-(grid_size/2), orc_y_pixels-(grid_size*2)-(grid_size/2),(grid_size*5),(grid_size*5))
	if menuShown == true then
	--	love.graphics.setFont(menuFont)
	else
		love.graphics.setFont(uiFont)
	end
	
	if showExitMenu == true then
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( 1, (window_width/2)-200, (window_height/2)-200, 400, 200 )
		love.graphics.setColor( 10, 10, 255 )
		love.graphics.rectangle( 2, (window_width/2)-199, (window_height/2)-199, 399, 199 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw("(Spacebar) to exit, move to stay", (window_height/2)-100, 250)
		menuShown = true
	end
end


function keypressed(key) 
	playerMoved = 'no'
	 
	if key == love.key_p then 
		if musicState == 'playing' then
			love.audio.stop()
			muiscState = 'paused';
		end
		
		if musicState == 'paused' then
			love.audio.play()
			muiscState = 'playing';
		end
	end
	
	if key == love.key_f then
		fulltog = love.graphics.toggleFullscreen()
	end
	
	if key == love.key_g then
		if grid_state == 'on' then
			grid = love.graphics.newImage("blank.png")
			grid_state = 'off'
		else
			grid = love.graphics.newImage("grid.png")
			grid_state = 'on'
		end
	end
	
	if key == love.key_left then
		if player_facing == 180 then
			movePlayer('left')
		else
			facePlayer(180)
		end
	end
	if key == love.key_a then
		if player_facing == 180 then
			movePlayer('left')
		else
			facePlayer(180)
		end
	end
	if key == love.key_right then
		if player_facing == 0 then
			movePlayer('right')
		else
			facePlayer(0)
		end
	end
	if key == love.key_d then
		if player_facing == 0 then
			movePlayer('right')
		else
			facePlayer(0)
		end
	end
	if key == love.key_up then
		if player_facing == 270 then
			movePlayer('up')
		else
			facePlayer(270)
		end
	end
	if key == love.key_w then
		if player_facing == 270 then
			movePlayer('up')
		else
			facePlayer(270)
		end
	end
	if key == love.key_down then
		if player_facing == 90 then
			movePlayer('down')
		else
			facePlayer(90)
		end
	end
	if key == love.key_s then
		if player_facing == 90 then
			movePlayer('down')
		else
			facePlayer(90)
		end
	end
	if key == love.key_q then
		if player_facing == 215 then
			movePlayer('up_left')
		else
			facePlayer(215)
		end
	end
	if key == love.key_e then
		if player_facing == 315 then
			movePlayer('up_right')
		else
			facePlayer(315)
		end
	end
	if key == love.key_z then
		if player_facing == 135 then
			movePlayer('down_left')
		else
			facePlayer(135)
		end
	end
	if key == love.key_c then
		if player_facing == 45 then
			movePlayer('down_right')
		else
			facePlayer(45)
		end
	end
	if key == love.key_space then
		movePlayer('punch')
	end
	
	lastkey = key .. " pressed"
	
end
