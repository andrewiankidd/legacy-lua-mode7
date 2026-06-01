local CAMERA_SCROLL_THRESHOLD = 50
local PLAYER_OFFSET_X = 40
local PLAYER_OFFSET_Y = 70
local SPRITE_SIZE = 50

local MOVE_SPEED_VERTICAL = 2
local MOVE_SPEED_HORIZONTAL = 3
local MOVE_SPEED_DIAG_VERT = 1
local MOVE_SPEED_DIAG_HORIZ = 1.5
local SCROLL_SPEED_VERTICAL = 0.5
local SCROLL_SPEED_HORIZONTAL = 0.75
local SCROLL_SPEED_DIAG_VERT = 0.25
local SCROLL_SPEED_DIAG_HORIZ = 0.375

local ANIM_FRAMES = {
    south     = {1, 6},
    southeast = {7, 12},
    east      = {13, 18},
    northeast = {19, 24},
    north     = {25, 30},
    northwest = {31, 36},
    west      = {37, 42},
    southwest = {43, 48},
}

local function is_walkable(world_x, world_y)
    if not collision then return true end
    return collision:check(world_x, world_y) ~= "solid"
end

local function set_facing(dir)
    local pframe = player.anim:getCurrentFrame()
    local frames = ANIM_FRAMES[dir]
    if pframe < frames[1] or pframe > frames[2] then
        player.anim:seek(frames[1])
    end
end

function movementcontrols(dt)
    player.location.realx = player.location.x + mode7.x - love.graphics.getWidth() / 2 + PLAYER_OFFSET_X
    player.location.realy = player.location.y + mode7.y - love.graphics.getHeight() / 2 + PLAYER_OFFSET_Y
    player.grid.x = math.floor(player.location.realx / SPRITE_SIZE)
    if player.grid.x == 0 then player.grid.x = 1 end
    player.grid.y = math.floor(player.location.realy / 60)
    if player.grid.y == 0 then player.grid.y = 1 end
    player.grid.num = (player.grid.y * (mode7.tex:getWidth() / SPRITE_SIZE)) + player.grid.x

    local moving = Input.held("move_up") or Input.held("move_left") or Input.held("move_down") or Input.held("move_right")
    if not moving then return end

    player.anim:update(dt)
    local at_edge_y = player.location.y < (love.graphics.getHeight() / 2) - CAMERA_SCROLL_THRESHOLD
    local at_edge_x = player.location.x < (love.graphics.getWidth() / 2) - CAMERA_SCROLL_THRESHOLD

    local function try_scroll(dx, dy)
        local nx = mode7.x + dx
        local ny = mode7.y + dy
        if is_walkable(nx, ny) then
            mode7.x = nx
            mode7.y = ny
        end
    end

    local function try_move(dx, dy)
        local nx = player.location.x + dx
        local ny = player.location.y + dy
        local wx = nx + mode7.x - love.graphics.getWidth() / 2 + PLAYER_OFFSET_X
        local wy = ny + mode7.y - love.graphics.getHeight() / 2 + PLAYER_OFFSET_Y
        if is_walkable(wx, wy) then
            player.location.x = nx
            player.location.y = ny
        end
    end

    if Input.held("move_up") and Input.held("move_left") then
        set_facing("northwest")
        if at_edge_y or at_edge_x then try_scroll(-SCROLL_SPEED_DIAG_HORIZ, -SCROLL_SPEED_DIAG_VERT)
        else try_move(-MOVE_SPEED_DIAG_HORIZ, -MOVE_SPEED_DIAG_VERT) end
    elseif Input.held("move_up") and Input.held("move_right") then
        set_facing("northeast")
        if at_edge_y or at_edge_x then try_scroll(SCROLL_SPEED_DIAG_HORIZ, -SCROLL_SPEED_DIAG_VERT)
        else try_move(MOVE_SPEED_DIAG_HORIZ, -MOVE_SPEED_DIAG_VERT) end
    elseif Input.held("move_down") and Input.held("move_left") then
        set_facing("southwest")
        if at_edge_y or at_edge_x then try_scroll(-SCROLL_SPEED_DIAG_HORIZ, SCROLL_SPEED_DIAG_VERT)
        else try_move(-MOVE_SPEED_DIAG_HORIZ, MOVE_SPEED_DIAG_VERT) end
    elseif Input.held("move_down") and Input.held("move_right") then
        set_facing("southeast")
        if at_edge_y or at_edge_x then try_scroll(SCROLL_SPEED_DIAG_HORIZ, SCROLL_SPEED_DIAG_VERT)
        else try_move(-MOVE_SPEED_DIAG_HORIZ, MOVE_SPEED_DIAG_VERT) end
    elseif Input.held("move_up") then
        set_facing("north")
        if player.location.y + mode7.y > love.graphics.getHeight() / 2 - 60 then
            if at_edge_y then try_scroll(0, -SCROLL_SPEED_VERTICAL)
            else try_move(0, -MOVE_SPEED_VERTICAL) end
        end
    elseif Input.held("move_left") then
        set_facing("west")
        if player.location.x + mode7.x > love.graphics.getWidth() / 2 - 39 then
            if at_edge_x then try_scroll(-SCROLL_SPEED_HORIZONTAL, 0)
            else try_move(-MOVE_SPEED_HORIZONTAL, 0) end
        end
    elseif Input.held("move_down") then
        set_facing("south")
        if player.location.y > (love.graphics.getHeight() / 2) + CAMERA_SCROLL_THRESHOLD then
            try_scroll(0, SCROLL_SPEED_VERTICAL)
        else
            try_move(0, MOVE_SPEED_VERTICAL)
        end
    elseif Input.held("move_right") then
        set_facing("east")
        if player.location.x > (love.graphics.getWidth() / 2) + CAMERA_SCROLL_THRESHOLD then
            try_scroll(SCROLL_SPEED_HORIZONTAL, 0)
        else
            try_move(MOVE_SPEED_HORIZONTAL, 0)
        end
    end
end
