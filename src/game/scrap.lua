-- scrap.lua — wave-survival brawler built on the Base. Round N has N enemies;
-- clear them all → WINNER! → next round with one more. Player hp carries over
-- between rounds, so it gets harder until you die — then a death screen + score.

local Base = require("game.base")

local Scrap = {}

local round, score, phase, phase_t

local WIN_BANNER_TIME = 1.6

local function font(name) return _G[name] or love.graphics.getFont() end

-- Called when entering the scrap game.
function Scrap.enter()
    round = 1
    score = 0 -- rounds cleared
    phase = "fight"
    phase_t = 0
    Base.load("scrap", 1, { hostile = true }) -- round 1: a single enemy
end

function Scrap.update(dt)
    if phase == "fight" then
        Base.update(dt)
        if Base.player_dead() then
            phase, phase_t = "dead", 0
        elseif Base.enemies_alive() == 0 then
            score = round
            phase, phase_t = "win", 0
        end
    elseif phase == "win" then
        phase_t = phase_t + dt
        if phase_t > WIN_BANNER_TIME then
            round = round + 1
            Base.spawn_enemies(round) -- more enemies, hp carries over
            phase, phase_t = "fight", 0
        end
    elseif phase == "dead" then
        phase_t = phase_t + dt
    end
end

local function banner(title, sub, col)
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, h * 0.34, w, h * 0.30)
    love.graphics.setFont(font("pixelfontlargew"))
    love.graphics.setColor(col)
    love.graphics.printf(title, 0, h * 0.40, w, "center")
    love.graphics.setFont(font("pixelfont"))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(sub, 0, h * 0.52, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

local function death_screen()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setFont(font("pixelfontlargew"))
    love.graphics.setColor(0.85, 0.2, 0.2, 1)
    love.graphics.printf("YOU GOT BATTERT", 0, h * 0.30, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("SCORE: " .. (score or 0), 0, h * 0.45, w, "center")
    love.graphics.setFont(font("pixelfont"))
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.printf("rounds survived: " .. (score or 0), 0, h * 0.55, w, "center")
    love.graphics.printf("press SPACE", 0, h * 0.66, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function Scrap.draw()
    Base.draw()

    -- round counter (top-centre, under the title)
    love.graphics.setFont(font("pixelfont"))
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("ROUND " .. (round or 1), 0, 66, love.graphics.getWidth(), "center")
    love.graphics.setColor(1, 1, 1, 1)

    if phase == "win" then
        banner("WINNER!", "Round " .. round .. " cleared", { 0.25, 0.9, 0.35, 1 })
    elseif phase == "dead" then
        death_screen()
    end
end

function Scrap.is_dead()
    return phase == "dead"
end

-- dev: force a phase/round/score for screenshots
function Scrap.dev(p, r, s)
    phase, round, score, phase_t = p, r or round, s or score, 0
end

return Scrap
