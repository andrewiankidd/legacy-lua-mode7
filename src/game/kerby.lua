-- kerby.lua -- Kerby (curb ball) game mode.
-- Pong-style: player on left pavement, NPC on right, ball crosses the road.
-- Hit the kerb (curb edge) to score. Fixed mode7 camera, perspective scaling.

local Love2D4Me = require("love2d4me")
local Input = Love2D4Me.input
local Scoring = Love2D4Me.scoring
local HUD = Love2D4Me.hud
local MapLoader = Love2D4Me.maploader

local Kerby = {}

-- Court layout (pixel coords on the 1277x832 background)
local LEFT_PAVEMENT_X = 140
local RIGHT_PAVEMENT_X = 1075
local LEFT_KERB_X = 260
local RIGHT_KERB_X = 940
local COURT_TOP = 420
local COURT_BOTTOM = 760
local COURT_CENTER_Y = (COURT_TOP + COURT_BOTTOM) / 2

-- Background is pre-perspectived (street scene with vanishing point at top).
-- Stretched to fill the viewport; entity depth scaling gives the mode7 feel.
local VANISHING_Y = 265
local ROAD_CENTER_X = (LEFT_PAVEMENT_X + RIGHT_PAVEMENT_X) / 2

-- Gameplay
local PLAYER_SPEED = 3
local BALL_SPEED = 5
local NPC_SPEED = 2.5
local NPC_IDLE_DRIFT = 0.3
local NPC_TRACKING_DEADZONE = 10
local CATCH_RADIUS = 60
local BALL_HOLD_OFFSET = 30
local THROW_AIM_FACTOR = 0.015
local OUT_OF_BOUNDS_MARGIN = 80

-- Timers (seconds)
local SERVE_DELAY = 0.5
local THROW_COOLDOWN = 0.3
local NPC_REACTION_DELAY = 0.8

-- Visual sizes (world units, scaled by depth ratio)
local PLAYER_DRAW_RADIUS = 20
local BALL_DRAW_RADIUS = 12

local tex = nil
local tex_w, tex_h = 0, 0
local ball = nil
local player_x, player_y
local npc_x, npc_y
local throw_timer = 0
local serving = "player"

-- Project world coords to screen. Background is stretched to fill the viewport.
-- X converges toward ROAD_CENTER_X as wy approaches VANISHING_Y, matching the
-- background's built-in perspective. Depth ratio scales entity sizes.
local function project(wx, wy)
    local sw, sh = love.graphics.getDimensions()
    local screen_y = (wy / tex_h) * sh
    local depth_ratio = wy / tex_h
    local perspective_ratio = math.max(0, (wy - VANISHING_Y) / (COURT_BOTTOM - VANISHING_Y))
    local perspective_wx = ROAD_CENTER_X + (wx - ROAD_CENTER_X) * perspective_ratio
    local screen_x = (perspective_wx / tex_w) * sw
    return screen_x, screen_y, depth_ratio
end

local function draw_entity(wx, wy, base_radius, r, g, b)
    local sx, sy, scale = project(wx, wy)
    if not sx then return end
    local radius = math.max(4, base_radius * scale)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", sx, sy + radius * 0.5, radius * 1.2, radius * 0.4)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.circle("fill", sx, sy - radius, radius)
    love.graphics.setColor(1, 1, 1, 1)
end

function Kerby.enter()
    local loaded = MapLoader.load("kerby")
    tex = loaded.background
    tex_w, tex_h = tex:getDimensions()

    Scoring.reset()
    Scoring.set("You", 0)
    Scoring.set("NPC", 0)
    HUD.set_controls({
        "Up/Down: Move",
        "Space: Throw",
    })
    player_x = LEFT_PAVEMENT_X
    player_y = COURT_CENTER_Y
    npc_x = RIGHT_PAVEMENT_X
    npc_y = COURT_CENTER_Y
    throw_timer = 0
    serving = "player"
    ball = nil
    Kerby.serve()
end

function Kerby.serve()
    if serving == "player" then
        ball = { x = player_x + BALL_HOLD_OFFSET, y = player_y, dx = 0, dy = 0, held_by = "player" }
    else
        ball = { x = npc_x - BALL_HOLD_OFFSET, y = npc_y, dx = 0, dy = 0, held_by = "npc" }
    end
    throw_timer = SERVE_DELAY
end

function Kerby.update(dt)
    throw_timer = throw_timer - dt

    -- Player movement (up/down on left pavement)
    if Input.held("move_up") and player_y > COURT_TOP then
        player_y = player_y - PLAYER_SPEED
    end
    if Input.held("move_down") and player_y < COURT_BOTTOM then
        player_y = player_y + PLAYER_SPEED
    end

    -- Player throws
    if ball and ball.held_by == "player" and throw_timer <= 0 then
        if Input.held("confirm") or Input.held("attack") then
            ball.held_by = nil
            ball.dx = BALL_SPEED
            ball.dy = (npc_y - ball.y) * THROW_AIM_FACTOR
            throw_timer = THROW_COOLDOWN
        end
    end

    -- NPC AI
    if ball then
        if ball.held_by == "npc" then
            if throw_timer <= 0 then
                ball.held_by = nil
                ball.dx = -BALL_SPEED
                ball.dy = (player_y - ball.y) * THROW_AIM_FACTOR
                throw_timer = THROW_COOLDOWN
            end
        elseif ball.dx > 0 then
            if npc_y < ball.y - NPC_TRACKING_DEADZONE then npc_y = npc_y + NPC_SPEED end
            if npc_y > ball.y + NPC_TRACKING_DEADZONE then npc_y = npc_y - NPC_SPEED end
        else
            if npc_y < COURT_CENTER_Y then npc_y = npc_y + NPC_SPEED * NPC_IDLE_DRIFT end
            if npc_y > COURT_CENTER_Y then npc_y = npc_y - NPC_SPEED * NPC_IDLE_DRIFT end
        end
    end

    -- Ball follows holder
    if ball and ball.held_by == "player" then
        ball.x = player_x + BALL_HOLD_OFFSET
        ball.y = player_y
    elseif ball and ball.held_by == "npc" then
        ball.x = npc_x - BALL_HOLD_OFFSET
        ball.y = npc_y
    end

    -- Ball flight
    if ball and not ball.held_by then
        ball.x = ball.x + ball.dx
        ball.y = ball.y + ball.dy

        -- Kerb hit = score
        if ball.dx > 0 and ball.x >= RIGHT_KERB_X then
            Scoring.add("You", 1)
            serving = "npc"
            Kerby.serve()
            return
        end
        if ball.dx < 0 and ball.x <= LEFT_KERB_X then
            Scoring.add("NPC", 1)
            serving = "player"
            Kerby.serve()
            return
        end

        -- NPC catches
        if ball.dx > 0 and ball.x > RIGHT_KERB_X then
            local dist = math.sqrt((ball.x - npc_x) ^ 2 + (ball.y - npc_y) ^ 2)
            if dist < CATCH_RADIUS then
                ball.held_by = "npc"
                ball.dx = 0
                ball.dy = 0
                throw_timer = NPC_REACTION_DELAY
            end
        end

        -- Player catches
        if ball.dx < 0 and ball.x < LEFT_KERB_X then
            local dist = math.sqrt((ball.x - player_x) ^ 2 + (ball.y - player_y) ^ 2)
            if dist < CATCH_RADIUS then
                ball.held_by = "player"
                ball.dx = 0
                ball.dy = 0
            end
        end

        -- Out of bounds
        if ball.y < COURT_TOP - OUT_OF_BOUNDS_MARGIN or ball.y > COURT_BOTTOM + OUT_OF_BOUNDS_MARGIN then
            if ball.dx > 0 then serving = "npc" else serving = "player" end
            Kerby.serve()
        end
    end
end

function Kerby.draw()
    if not tex then return end

    local sw, sh = love.graphics.getDimensions()
    love.graphics.draw(tex, 0, 0, 0, sw / tex_w, sh / tex_h)

    draw_entity(player_x, player_y, PLAYER_DRAW_RADIUS, 0.2, 0.5, 1)
    draw_entity(npc_x, npc_y, PLAYER_DRAW_RADIUS, 1, 0.3, 0.3)

    if ball then
        local bsx, bsy, bscale = project(ball.x, ball.y)
        if bsx then
            local radius = math.max(3, BALL_DRAW_RADIUS * bscale)
            love.graphics.setColor(1, 1, 0.2, 1)
            love.graphics.circle("fill", bsx, bsy - radius, radius)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    Scoring.draw("bottom")
    HUD.draw()
end

function Kerby.is_over()
    return false
end

return Kerby
