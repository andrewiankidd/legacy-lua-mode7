-- chappy.lua — side-scrolling endless runner. Chap a door, then leg it right past
-- a looping tenement street, jumping the garden fences. Obstacles deferred.
-- Self-contained (not on the Mode 7 base): flat side view, looping background.

local Chappy = {}

local SPRITE = 50
local DRAW_SCALE = 3
local EAST = { 13, 18 } -- protag east-facing run frames

-- tuning (screen space)
local RUN_SPEED = 380
local JUMP_V = -820
local GRAVITY = 1900
local FENCE_CLEAR = 120 -- how high (px) you must be to clear a fence
local FENCE_HALF = 34   -- half-width of a fence hit zone, in tile px

-- fence positions as fractions of the looping tile (tune to line up with the art)
local FENCE_FRACS = { 0.30, 0.55, 0.80 }

local bg, bgscale, BG_W, anim
local groundY, playerX
local scroll, distance, vy, py, jumping, phase

local function font(n) return _G[n] or love.graphics.getFont() end

function Chappy.enter()
    bg = love.graphics.newImage("game/maps/chappy/background.png")
    bg:setFilter("nearest", "nearest")
    local sw, sh = love.graphics.getDimensions()
    bgscale = sh / bg:getHeight()
    BG_W = bg:getWidth() * bgscale
    anim = newAnimation(love.graphics.newImage("game/npcs/protag/sprite.png"), SPRITE, SPRITE, 0.08, 0)
    anim:seek(EAST[1])
    groundY = sh * 0.95
    playerX = sw * 0.14
    scroll, distance, vy, jumping = 0, 0, 0, false
    py = groundY
    phase = "atdoor"
end

local function fence_hit()
    local tilepos = (scroll + playerX + SPRITE * DRAW_SCALE * 0.5) % BG_W
    for _, f in ipairs(FENCE_FRACS) do
        local fx = f * BG_W
        local d = math.abs(tilepos - fx)
        d = math.min(d, BG_W - d)
        if d < FENCE_HALF and py > groundY - FENCE_CLEAR then
            return true
        end
    end
    return false
end

function Chappy.update(dt)
    if phase ~= "running" then return end
    scroll = scroll + RUN_SPEED * dt
    distance = distance + RUN_SPEED * dt
    if jumping then
        vy = vy + GRAVITY * dt
        py = py + vy * dt
        if py >= groundY then py = groundY; vy = 0; jumping = false end
    end
    anim:update(dt)
    local f = anim:getCurrentFrame()
    if f < EAST[1] or f > EAST[2] then anim:seek(EAST[1]) end
    if fence_hit() then phase = "tripped" end
end

local function draw_bg()
    local off = scroll % BG_W
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(bg, -off, 0, 0, bgscale, bgscale)
    love.graphics.draw(bg, BG_W - off, 0, 0, bgscale, bgscale)
end

function Chappy.draw()
    draw_bg()
    love.graphics.setColor(1, 1, 1, 1)
    anim:draw(playerX, py - SPRITE * DRAW_SCALE, 0, DRAW_SCALE, DRAW_SCALE)

    local sw, sh = love.graphics.getDimensions()
    if phase == "atdoor" then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, sh * 0.40, sw, sh * 0.20)
        love.graphics.setFont(font("pixelfontlargew"))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("CHAP THE DOOR", 0, sh * 0.43, sw, "center")
        love.graphics.setFont(font("pixelfont"))
        love.graphics.printf("press SPACE, then leg it!", 0, sh * 0.52, sw, "center")
    elseif phase == "running" then
        love.graphics.setFont(font("pixelfont"))
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.print(math.floor(distance / 20) .. "m", 16, 12)
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.print("SPACE: jump", 16, 30)
    elseif phase == "tripped" then
        love.graphics.setColor(0, 0, 0, 0.65)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        love.graphics.setFont(font("pixelfontlargew"))
        love.graphics.setColor(0.9, 0.3, 0.2, 1)
        love.graphics.printf("CAUGHT!", 0, sh * 0.30, sw, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("SCORE: " .. math.floor(distance / 20) .. "m", 0, sh * 0.45, sw, "center")
        love.graphics.setFont(font("pixelfont"))
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf("press SPACE", 0, sh * 0.58, sw, "center")
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Chappy.keypressed(k)
    if phase == "atdoor" then
        if k == "space" or k == "return" then phase = "running" end
    elseif phase == "running" then
        if (k == "space" or k == "up" or k == "w") and not jumping then
            jumping = true; vy = JUMP_V
        end
    end
end

function Chappy.is_over() return phase == "tripped" end

-- dev: jump straight to a phase for screenshots
function Chappy.dev(p) phase = p end

return Chappy
