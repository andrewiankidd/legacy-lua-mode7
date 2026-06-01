-- menus.lua â€” the game's menu definitions, built with the framework Menu module.
-- Main menu (standard look: logo/title/options/quit) â†’ Start pushes the grid
-- (the extended `layout = "grid"` view) â†’ selecting a game launches it.

local Menu = require("love2d4me.src.menu")
local Settings = require("love2d4me.src.settings")
local Minigames = require("game.minigames")

local Menus = {}

local function font(name) return _G[name] or love.graphics.getFont() end

-- Settings submenu (vertical â€” the framework's default layout).
function Menus.options()
    local vol = math.floor(love.audio.getVolume() * 100 + 0.5)
    local fs = love.window.getFullscreen()
    return {
        title = "OPTIONS",
        title_font = font("pixelfontlargew"),
        entry_font = font("pixelfontlargew"),
        spacing = 56,
        entries = {
            { label = "Volume: " .. vol .. "%", action = function()
                local volume = love.audio.getVolume()
                volume = (volume >= 0.95) and 0 or math.min(volume + 0.25, 1)
                love.audio.setVolume(volume); Settings.set("volume", volume)
                Menu.pop(); Menu.push(Menus.options())
            end },
            { label = "Fullscreen: " .. (fs and "On" or "Off"), action = function()
                local nf = not fs
                love.window.setFullscreen(nf); Settings.set("fullscreen", nf)
                Menu.pop(); Menu.push(Menus.options())
            end },
            { label = "Back", action = function() Menu.pop() end },
        },
    }
end

-- The "5-in-1" cartridge grid. on_pick(key) launches a game.
function Menus.grid(on_pick)
    local entries = {}
    for _, g in ipairs(Minigames) do
        entries[#entries + 1] = {
            label = g.name,
            color = g.color,
            action = function() on_pick(g.key) end,
        }
    end
    return {
        layout = "grid",
        columns = 2,
        title = "WEE GAMES  5-in-1",
        title_font = font("pixelfontlargew"),
        entry_font = font("pixelfontlargew"),
        hint = "arrows browse     enter play",
        entries = entries,
        -- default on_cancel = Menu.pop -> back to the main menu
    }
end

-- Standard main menu. Start pushes the grid.
function Menus.main(on_start)
    local logo
    if love.filesystem.getInfo("game/pictures/icon.png") then
        logo = love.graphics.newImage("game/pictures/icon.png")
    end
    return {
        title = "WEE GAMES",
        title_font = font("pixelfontlargew"),
        entry_font = font("pixelfontlargew"),
        logo = logo,
        spacing = 56,
        entries = {
            { label = "Start",   action = function() on_start() end },
            { label = "Options", action = function() Menu.push(Menus.options()) end },
            { label = "Quit",    action = function() love.event.quit() end },
        },
        on_cancel = function() love.event.quit() end,
    }
end

-- Standard in-game pause menu. handlers = { resume, main_menu }.
function Menus.pause(handlers)
    return {
        title = "PAUSED",
        title_font = font("pixelfontlargew"),
        entry_font = font("pixelfontlargew"),
        spacing = 56,
        entries = {
            { label = "Resume",    action = function() handlers.resume() end },
            { label = "Options",   action = function() Menu.push(Menus.options()) end },
            { label = "Main Menu", action = function() handlers.main_menu() end },
            { label = "Quit",      action = function() love.event.quit() end },
        },
        on_cancel = function() handlers.resume() end, -- escape resumes
    }
end

return Menus
