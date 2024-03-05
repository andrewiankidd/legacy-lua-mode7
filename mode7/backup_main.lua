require 'mode7'
require 'anim'

function love.load()
	map = {
		tex = love.graphics.newImage('maps/tex.png'),
		data = nil
	}
	love.filesystem.load("maps/data.ini")()
    mode7 = {
        x = 64,
        y = 64,
        tex = map.tex,
        ox = 0,
        oy = 0,
        r = 0,
        s = 0.075/10
    }
    screen = {
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
	player = {
		ss = love.graphics.newImage("protag/protagss.png"),
		anim = newAnimation(love.graphics.newImage("protag/protagss.png"), 50, 50, 0.1, 0),
		south={1,6},
		southeast={7,12},
		east={13,18},
		northeast={19,24},
		north={25,30},
		northwest={31,36},
		west={37,42},
		southwest={43,48},
		grid = {
			x=0,
			y=0,
			num=0
			},
		location = {
			x = screen.w/2,
			y = screen.h/2,
			realx = screen.w/2 + mode7.x - screen.w/2+40,
			realy = screen.w/2 + mode7.y - screen.h/2+70
			}
	}
	
end
function love.update(dt)
	player.location.realx=player.location.x+mode7.x - screen.w/2+40
	player.location.realy=player.location.y+mode7.y - screen.h/2+70
	player.grid.x = math.floor(0+((player.location.realx / 50) ))
	player.grid.y = math.floor(0+((player.location.realy+50 / 50) ))
	if player.grid.x == 0 then
		player.grid.x = 1
	end

	player.grid.num = ((player.grid.y * (mode7.tex:getWidth( )/50)) + player.grid.x)
	
	if love.keyboard.isDown('w') or love.keyboard.isDown('a') or love.keyboard.isDown('s') or love.keyboard.isDown('d') then
		--adnimation control
		player.anim:update(dt)
		pframe=player.anim:getCurrentFrame()
		--map control
		
		if love.keyboard.isDown('w') and love.keyboard.isDown('a') then						--up left
			if pframe < player.northwest[1] or pframe > player.northwest[2] then
				player.anim:seek(player.northwest[1])
			end
			if player.location.y < (screen.h/2)-50 or player.location.x < (screen.w/2)-50 then
				mode7.y=mode7.y - 1/4
				mode7.x=mode7.x - 0.375
				player.location.y=player.location.y-0
			else
				player.location.y=player.location.y-1
				player.location.x=player.location.x-1.5
			end
		elseif love.keyboard.isDown('w') and love.keyboard.isDown('d') then						--up right
			if pframe < player.northeast[1] or pframe > player.northeast[2] then
				player.anim:seek(player.northeast[1])
			end
			if player.location.y < (screen.h/2)-50 or player.location.x < (screen.w/2)-50 then
				mode7.y=mode7.y - 1/4
				mode7.x=mode7.x + 0.375
				player.location.y=player.location.y-0
			else
				player.location.y=player.location.y-1
				player.location.x=player.location.x+1.5
			end	
		elseif love.keyboard.isDown('s') and love.keyboard.isDown('a') then						--down left
			if pframe < player.southwest[1] or pframe > player.southwest[2] then
				player.anim:seek(player.southwest[1])
			end
			if player.location.y < (screen.h/2)-50 or player.location.x < (screen.w/2)-50 then
				mode7.y=mode7.y + 1/4
				mode7.x=mode7.x - 0.375
				player.location.y=player.location.y-0
			else
				player.location.y=player.location.y+1
				player.location.x=player.location.x-1.5
			end	
		elseif love.keyboard.isDown('s') and love.keyboard.isDown('d') then						--down right
			if pframe < player.southeast[1] or pframe > player.southeast[2] then
				player.anim:seek(player.southeast[1])
			end
			if player.location.y < (screen.h/2)-50 or player.location.x < (screen.w/2)-50 then
				mode7.y=mode7.y + 1/4
				mode7.x=mode7.x + 0.375
				player.location.y=player.location.y-0
			else
				player.location.y=player.location.y-1
				player.location.x=player.location.x-1.5
			end	
		elseif love.keyboard.isDown('w') then													--up
			if pframe < player.north[1] or pframe > player.north[2] then
				player.anim:seek(player.north[1])
			end
			if player.location.y+mode7.y > screen.h/2-70 then
				if player.location.y < (screen.h/2)-50 then
					mode7.y=mode7.y - 1/2
				else
					player.location.y=player.location.y-2
				end
			end
		elseif love.keyboard.isDown('a') then 
			if pframe < player.west[1] or pframe > player.west[2] then
				player.anim:seek(player.west[1])
			end
			if player.location.x+mode7.x > screen.w/2-39 then
				if player.location.x < (screen.w/2)-50 then
					mode7.x=mode7.x - 3/4
				else
					player.location.x=player.location.x-3
				end
			else
				
			end
		elseif love.keyboard.isDown('s') then
			if pframe < player.south[1] or pframe > player.south[2] then
				player.anim:seek(player.south[1])
			end
			if player.location.y > (screen.h/2)+50 then
				mode7.y=mode7.y + 1/2
			else
				player.location.y=player.location.y+2
			end
		elseif love.keyboard.isDown('d') then
			if pframe < player.east[1] or pframe > player.east[2] then
				player.anim:seek(player.east[1])
			end
			if player.location.x > (screen.w/2)+50 then
				mode7.x=mode7.x+3/4
			else
				player.location.x=player.location.x+3
			end
		end
	end
end
function love.draw()
    drawMode7(mode7.x, mode7.y, mode7.tex, mode7.ox, mode7.oy, mode7.r, mode7.s)
	player.anim:draw(player.location.x, player.location.y,0,3,3)
	love.graphics.rectangle("line", player.location.x, player.location.y, 150, 150 )
	--dbg
	love.graphics.print( "playerX: " .. player.location.x .. " mode7.x: " .. mode7.x .. " minus: " .. player.location.x-(mode7.x) .. " plus: " .. player.location.x+(mode7.x), 10, 10)
	love.graphics.print( "playery: " .. player.location.y .. " mode7.y: " .. mode7.y .. " minus: " .. player.location.y-(mode7.y) .. " plus: " .. player.location.y+(mode7.y), 10, 30)
	love.graphics.print(player.location.realx,10,50)
	love.graphics.print(player.location.realy,10,70)
	love.graphics.print("x: " .. player.grid.x,10,90)
	love.graphics.print("y: " .. player.grid.y,100,90)
	love.graphics.print("cell: " .. player.grid.num,200,90)
end