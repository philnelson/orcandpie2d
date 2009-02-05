-- Set up our set upy things

function load()
	mode = love.graphics.setMode(650, 700, false, true, 4)
	currentTime = love.timer.getTime()
	math.randomseed(os.time())
	math.random(); math.random(); math.random();
	numberCharacters = 2
	map_height = 12
	map_width = 13
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
	orc = {l_arm='fine',r_arm='fine',l_leg='fine',r_leg='fine',neck='fine',chest='fine',str=2}
	player = {l_arm='fine',r_arm='fine',l_leg='fine',r_leg='fine',neck='fine',chest='fine'}
	combat_message = ''

	orcs = {speed=1}
	walls = {}
	impassable = {}

	function in_table ( search, table ) 
	 	for _,v in pairs(table) do
			if (v==search) then return true end
		end
		return false
	end
	
	function getSpace(x,y)
		space = (y-1) * (map_width) + (x)
		return space
	end
	
	function findPath(start_space, end_space)
		openList = {}
		closedList = {}
		x1 = player_x
		x2 = orc_x
		y1 = player_y
		y2 = orc_y
		
		last_message = 's:' .. start_space .. 'e: ' .. end_space
		
	end
	
	function rollUpPlayer()
		dex_score = rollDice(3,6)
		player = {dex=dex_score}
	end
	
	function rollDice(number,sides)
		rolls = {}
		total = 0
		for i=1, number, 1 do
			table.insert(roll,math.random(1,sides))
		end
		for k,v in pairs(rolls) do
			total = v+total
		end
		return total
	end
	
	function canSeePlayer(x,y)
		orc_player_x_diff = x - player_x
		orc_player_y_diff = y - player_y
		if orc_player_x_diff >= -2 then
			if orc_player_x_diff <= 2 then
				if orc_player_y_diff >= -2 then
					if orc_player_y_diff <= 2 then
						orc_sees_player = 'yes'
						if orc_carrying_pie == 'yes' then
							setDownPie(x*grid_size-(grid_size/2),y*grid_size-(grid_size/2))
						end
					end
				end
			end
		else
			orc_sees_player = 'no'
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
			message_angle = 10
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
			moveOrc()
			totalMoves = totalMoves+1
		end

		playerMoved = 'no'
	end
	
	rooms = {}
	while remainingTiles > 12 do
		numberRooms=numberRooms+1
		repeat
			theSize = math.random(12,remainingTiles)
			dimensions = theSize / 4 + 1
		until math.mod(theSize, 4) == 0
		remainingTiles = remainingTiles - theSize
	end
	
	-- Generate room walls around border
	i = 0
	for j=1, map_height, 1 do
		for k=1, map_width, 1 do
			i = i + 1
			x = k
			y = j
			walls[i] = {x=x,y=y,type='empty'}
		end
	end
	
	for k,v in pairs(walls) do
		if v.y == 1 then
			walls[k] = {x=v.x,y=v.y,type='wall'}
		end
		if v.x == 1 then
			walls[k] = {x=v.x,y=v.y,type='wall'}
		end
		if v.y == map_height then
			walls[k] = {x=v.x,y=v.y,type='wall'}
		end
		if v.x == map_width then
			walls[k] = {x=v.x,y=v.y,type='wall'}
		end
	end
	
	-- Load a font 
	local f = love.graphics.newFont(love.default_font, 12) 
	love.graphics.setFont(f)
	
	-- Load music
	love.graphics.setCaption("Orc & Pie")
	grid = love.graphics.newImage("grid.png")
	
	orc_sprite = love.graphics.newImage("orc.png")
	
	player_sprite = love.graphics.newImage("player.png")
	arrow = love.graphics.newImage("arrow.png")
	pie = love.graphics.newImage("pie.png")
	brown_wall = love.graphics.newImage("brown_wall.png")

	-- Plop down the orc(s)
	goodSpot = 'no'
	repeat
		possible_orc_x = math.random(2,map_height-1)
		possible_orc_y = math.random(2,map_width-1)
		space = getSpace(possible_orc_x,possible_orc_y)
		if walls[space].type == 'empty' then
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
		possible_player_x = math.random(2,map_height-1)
		possible_player_y = math.random(2,map_width-1)
		space = math.ceil(possible_player_x * 2) + math.ceil(possible_player_y / 2)
		if walls[space].type == 'empty' then
			goodSpot = 'yes'
			player_x = possible_player_x
			player_y = possible_player_y
			player_x_pixels = possible_player_x * grid_size - (grid_size/2)
			player_y_pixels = possible_player_y * grid_size - (grid_size/2)
			player_space = space
		else
			goodSpot = 'no'
		end
	until goodSpot == 'yes'
	player_facing = 0
	
end

function update(dt)
	currentTime = math.floor(love.timer.getTime())
	
end

function draw()
	-- Draw the grid
	row=0
	while row<12 do
		column=0
		while column<16 do
			love.graphics.draw(grid,column*grid_size+(grid_size / 2),row*grid_size+(grid_size / 2))
			column = column+1
		end
		row = row+1
	end
	
	g = 0
	for k,v in pairs(walls) do
		if v.type == 'wall' then
			love.graphics.draw(brown_wall, v.x*grid_size-(grid_size/2), v.y*grid_size-(grid_size/2))
--			love.graphics.draw("w" .. v.type, g, 610)
		end
		g = g + 40
	end
	
	love.graphics.draw(orc_sprite, orc_x_pixels, orc_y_pixels)
	love.graphics.draw(arrow, orc_x_pixels, orc_y_pixels, orc_facing)
	love.graphics.draw(player_sprite, player_x_pixels, player_y_pixels, player_facing)
	love.graphics.draw(arrow, player_x_pixels, player_y_pixels,player_facing)
	love.graphics.draw(pie, pie_x, pie_y)
	love.graphics.draw("player position: " .. player_x .. ", " .. player_y .. " : " .. player_space, 0, 620)
	love.graphics.draw("orc position: " .. orc_x .. ", " .. orc_y .. " : " .. orc_space, 0, 635)
	love.graphics.draw("pie position: " .. pie_x .. ", " .. pie_y, 0, 650)
	love.graphics.draw("pie " .. pie_status, 0, 665)
	love.graphics.draw("you: ", 0, 680)
	offset = 30
	for k,v in pairs(player) do
		love.graphics.draw(k .. ' ' .. v, offset, 680)
		offset = offset+65
	end
	love.graphics.draw(last_message, message_x, message_y,message_angle)
	love.graphics.draw(combat_message, 250, 635)
	love.graphics.draw("moves " .. totalMoves, 520, 650)
	
	-- "see player" debugging
	
	love.graphics.line(player_x_pixels, player_y_pixels, orc_x_pixels, orc_y_pixels )
	love.graphics.rectangle(1, orc_x_pixels-(grid_size*2)-(grid_size/2), orc_y_pixels-(grid_size*2)-(grid_size/2),(grid_size*5),(grid_size*5))
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
