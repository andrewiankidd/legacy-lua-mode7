-- WEE GAMES -- a bootleg multi-cart of wee street games, all on the Mode 7 base.
-- Boots into a standard main menu; Start opens the "5-in-1" grid; each game
-- loads its own copy of the map.
--
--   npm run dev            boot the game
--   love src shot          screenshot the main menu
--   love src shot grid     screenshot the 5-in-1 grid
--   love src shot <key>    screenshot a game on its map (bike/wally/kerby/chappy/scrap)

local Love2D4Me = require("love2d4me")
Input = Love2D4Me.input -- global, used by game/movement.lua
local GameState = Love2D4Me.gamestate
local Menu = require("love2d4me.src.menu")

require("game.movement")
local Base = require("game.base")
local Menus = require("game.menus")
local Minigames = require("game.minigames")
local Scrap = require("game.scrap")
local Chappy = require("game.chappy")
local Kerby = require("game.kerby")

-- Self-contained games that drive their own state (not the Base): { module, over-check }.
local SPECIAL = {
    scrap  = { mod = Scrap,  over = function() return Scrap.is_dead() end },
    chappy = { mod = Chappy, over = function() return Chappy.is_over() end },
    kerby  = { mod = Kerby,  over = function() return Kerby.is_over() end },
}

local _shot = { want = false, t = 0 }
local paused = false

-- In-game overlay: which mode you're in + how to get back.
local function overlay(name)
    local screen_w = love.graphics.getWidth()
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, screen_w, 44)
    love.graphics.setColor(1, 1, 1, 1)
    local title_font = _G.pixelfontlargew or love.graphics.getFont()
    love.graphics.setFont(title_font)
    love.graphics.print(name, math.floor((screen_w - title_font:getWidth(name)) / 2), 6)
    love.graphics.setFont(_G.pixelfont or love.graphics.getFont())
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("esc: back", screen_w - 130, 14)
    love.graphics.setColor(1, 1, 1, 1)
end

local function enter_game(key)
    if SPECIAL[key] then SPECIAL[key].mod.enter(); return end -- self-contained games
    for _, mg in ipairs(Minigames) do
        if mg.key == key then Base.load(mg.map, mg.npcs, { hostile = mg.hostile }) end
    end
end

-- Launch a game from the grid: load its map, switch to its state.
local function play(key)
    enter_game(key)
    GameState.set_state(key)
end

-- Open the main menu (called once init is done). Start pushes the grid submenu.
local function open_main_menu()
    Menu.clear()
    Menu.push(Menus.main(function() Menu.push(Menus.grid(play)) end))
    GameState.set_state("menu")
end

-- Pause handling. Games are custom states, so we drive a standard pause menu here.
local function resume()
    paused = false
    Menu.pop() -- remove the pause menu
end

local function to_main_menu()
    paused = false
    Menu.clear()
    open_main_menu()
end

local function pause_game()
    paused = true
    Menu.push(Menus.pause({ resume = resume, main_menu = to_main_menu }))
end

local function draw_pause_overlay()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    Menu.draw() -- the pause menu, on top of the frozen game
end

local function register_games()
    for _, mg in ipairs(Minigames) do
        local game = mg
        local sp = SPECIAL[game.key]
        if sp then
            -- self-contained game module (scrap rounds, chappy runner, ...)
            GameState.register(game.key, {
                update = function(dt) if not paused then sp.mod.update(dt) end end,
                draw = function()
                    sp.mod.draw()
                    if not sp.over() then overlay(game.name) end
                    if paused then draw_pause_overlay() end
                end,
                keypressed = function(k)
                    if paused then
                        Menu.keypressed(k)
                    elseif sp.over() then
                        if k == "return" or k == "space" then to_main_menu() end
                    elseif k == "escape" or k == "p" then
                        pause_game()
                    end
                end,
            })
        else
            GameState.register(game.key, {
                update = function(dt) if not paused then Base.update(dt) end end,
                draw = function()
                    Base.draw()
                    overlay(game.name)
                    if paused then draw_pause_overlay() end
                end,
                keypressed = function(k)
                    if paused then
                        Menu.keypressed(k)
                    elseif k == "escape" or k == "p" then
                        pause_game()
                    end
                end,
            })
        end
    end
end

function love.load()
    GameState.init({
        -- gameplay state is unused (games are their own states), but the
        -- framework wants the callbacks; point them at the base harmlessly.
        on_gameplay_init = function() Base.load(GameState.get_config().starting_map or "spawn") end,
        on_gameplay_update = function(dt) Base.update(dt) end,
        on_gameplay_draw = function() Base.draw() end,
    })
    register_games()

    -- dev flags + boot target
    local jumpTo, wantGrid, wantPause, wantPhase = nil, false, false, nil
    for _, a in ipairs(arg or {}) do
        if a == "shot" then _shot.want = true
        elseif a == "grid" then wantGrid = true
        elseif a == "pause" then wantPause = true
        elseif a == "win" or a == "dead" or a == "run" then wantPhase = a
        else
            for _, mg in ipairs(Minigames) do
                if a == mg.key then jumpTo = mg.key end
            end
        end
    end

    if jumpTo then
        play(jumpTo) -- straight into a game (dev)
        if wantPause then pause_game() end
        if wantPhase then
            if jumpTo == "scrap" and (wantPhase == "win" or wantPhase == "dead") then
                Scrap.dev(wantPhase, wantPhase == "win" and 3 or 5, wantPhase == "win" and 2 or 4)
            elseif jumpTo == "chappy" and wantPhase == "run" then
                Chappy.dev("running")
            end
        end
    else
        open_main_menu()
        if wantGrid then Menu.push(Menus.grid(play)) end
    end
end

function love.update(dt)
    GameState.update(dt)
    if _shot.want then
        _shot.t = _shot.t + dt
        if _shot.t > 1.0 then
            _shot.want = false
            love.graphics.captureScreenshot(function(img)
                local fd = img:encode("png")
                love.filesystem.write("cartshot.png", fd:getString())
                print("SHOT_SAVED " .. love.filesystem.getSaveDirectory() .. "/cartshot.png")
                love.event.quit()
            end)
        end
    end
end

function love.draw()
    GameState.draw()
end

function love.keypressed(key)
    GameState.keypressed(key)
end

function love.keyreleased(key)
    GameState.keyreleased(key)
end
