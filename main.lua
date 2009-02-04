-- Set up our set upy things

currentTime = love.timer.getTime()
math.randomseed(os.time())
math.random(); math.random(); math.random();
numberCharacters = 2
map_height = 12
map_width = 13
grid_size = 50
totalMoves = 0
numberRooms = 0
totalTiles = (map_height) * (map_width)

function keypressed(key) 
	playerMoved = no
	-- I don't want to register spaces. 
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

function xyToPixels(value)
	return pixels
end

function pixelsToXY(value)
	return xy
end

function moveOrc()
	
	x_table = {0,grid_size,-grid_size}
	y_table = {0,grid_size,-grid_size}
	
	repeat
		repeat
			x_direction = math.random(1,3)
			possiblex = x_table[x_direction]
		until orc_x+possiblex <= map_width * grid_size
	until orc_x+possiblex >= 0
	
	repeat
		repeat
			y_direction = math.random(1,3)
			possibley = y_table[y_direction]
		until orc_y+possibley <= map_height * grid_size
	until orc_y+possibley >= 0
	
	orc_x = orc_x+possiblex
	orc_y = orc_y+possibley

	pie_x = orc_x
	pie_y = orc_y

end

function facePlayer(dir)
	player_facing = dir
end

function movePlayer(dir)
	if dir == 'punch' then
		playerMoved = yes
	end
	if dir == 'up_left' then
		player_x = player_x-grid_size
		player_y = player_y-grid_size
		playerMoved = yes
	end
	if dir == 'up_right' then
		player_x = player_x+grid_size
		player_y = player_y-grid_size
		playerMoved = yes
	end
	if dir == 'down_left' then
		player_x = player_x-grid_size
		player_y = player_y+grid_size
		playerMoved = yes
	end
	if dir == 'down_right' then
		player_x = player_x+grid_size
		player_y = player_y+grid_size
		playerMoved = yes
	end
	if dir == 'left' then
		player_x = player_x-grid_size
		playerMoved = yes
	end
	if dir == 'down' then
		player_y = player_y+grid_size
		playerMoved = yes
	end
	if dir == 'right' then
		player_x = player_x+grid_size
		playerMoved = yes
	end
	if dir == 'up' then
		player_y = player_y-grid_size
		playerMoved = yes
	end
	
	if playerMoved == yes then
		moveOrc()
		totalMoves = totalMoves+1
	end
	
	playerMoved = no
end

function load()
	mode = love.graphics.setMode(650, 700, false, true, 4)
	
	lastkey =  'nothing'
	musicState = 'playing'

	remainingTiles = totalTiles - numberCharacters
	tiles = {}
	k = 1
	for i=1, map_width, 1 do
		for j=1, map_height, 1 do
			passable = 'yes'
			if i == 1 then
				passable = 'no'
			end
			if i == 13 then
				passable = 'no'
			end
			if j == 1 then
				passable = 'no'
			end
			if j == 12 then
				passable = 'no'
			end
			tiles[k] = {x=i,y=j,passable=passable}
			k = k + 1
		end
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
	
	-- Load a font 
	local f = love.graphics.newFont(love.default_font, 12) 
	love.graphics.setFont(f)
	
	-- Load music
	love.graphics.setCaption("Orc & Pie")
	grid = love.graphics.newImage("grid.png")
	orc = love.graphics.newImage("orc.png")
	player = love.graphics.newImage("player.png")
	arrow = love.graphics.newImage("arrow.png")
	pie = love.graphics.newImage("pie.png")
	brown_wall = love.graphics.newImage("brown_wall.png")

	orc_x = math.random(1,map_height)
			
	orc_y = math.random(1,map_width)
	
	orc_speed = math.random()
	
	pie_x = orc_x
	pie_y = orc_y
	-- plop down the player
	
	player_x = math.random(1,map_height)
	player_y = math.random(1,map_width)
	player_facing = 0
	
end

function checkTile(x,y)
	
end

function update(dt)
	currentTime = math.floor(love.timer.getTime())
	
end

function draw()

	i = 0
	repeat
		i=i+1
		if i == 1 then
			love.graphics.draw(brown_wall, 25, 25)
		else
			x = i*50-25
			love.graphics.draw(brown_wall, x, 25)
			love.graphics.draw(brown_wall, x, 575)
		end
		
	until i == map_width
	
	i = 0
	repeat
		i=i+1
		y = i*50-25
		love.graphics.draw(brown_wall, 25, y)
		love.graphics.draw(brown_wall, 625, y)
	until i == map_height

	love.graphics.draw(orc, orc_x, orc_y)
	love.graphics.draw(pie, orc_x-10, orc_y-10)
	love.graphics.draw(player, player_x, player_y, player_facing)
	love.graphics.draw(arrow, player_x, player_y,player_facing)
	love.graphics.draw("player position: " .. player_x .. ", " .. player_y, 0, 630)
	love.graphics.draw("orc position: " .. orc_x .. ", " .. orc_y, 0, 645)
	love.graphics.draw("rooms: " .. numberRooms, 0, 615)
	love.graphics.draw("facing " .. player_facing, 520, 620)

	love.graphics.draw("moves " .. totalMoves, 520, 650)
	
	row=0
	while row<12 do
		column=0
		while column<16 do
			love.graphics.draw(grid,column*50+25,row*50+25)
			column = column+1
		end
		row = row+1
	end

end