-- base.lua â€” the shared "guy on a Mode 7 map" gameplay base. Every minigame loads
-- its own map through this; the mechanics get layered on per game later.

local Love2D4Me = require("love2d4me")
local NPC = Love2D4Me.npc
local MapLoader = Love2D4Me.maploader
local CollisionModule = Love2D4Me.collision
local Projection = Love2D4Me.projection
local Equipment = Love2D4Me.equipment
local HUD = Love2D4Me.hud
local Input = Love2D4Me.input
require("game.movement") -- defines global movementcontrols(dt), uses globals mode7/player/collision

local SPRITE_SIZE = 50
local ANIM_FRAME_DURATION = 0.1
local ANIM_START_FRAME = 0
local DRAW_SCALE = 3
local MODE7_SCALE = 0.075 / 10
local MODE7_START_X = 64
local MODE7_START_Y = 64
local PLAYER_OFFSET_X = 40
local PLAYER_OFFSET_Y = 70

-- protag sprite is 8-dir x 6-frame (50x50). Map the 4 cardinals for NPC animation.
local PROTAG_DIR_FRAMES = { north = { 25, 30 }, south = { 1, 6 }, east = { 13, 18 }, west = { 37, 42 } }

local function make_anim(sprite)
    return newAnimation(sprite, SPRITE_SIZE, SPRITE_SIZE, ANIM_FRAME_DURATION, ANIM_START_FRAME)
end

local Base = {}
local npcs = {}
local combat_active = false

function Base.load(map_name, npc_count, opts)
    opts = opts or {}
    local loaded = MapLoader.load(map_name or "spawn")
    local tex = loaded.background

    if loaded.collision then
        collision = CollisionModule.new(loaded.collision, { [0] = "solid", [255] = "walk" })
    else
        collision = nil
    end

    local map_cfg = loaded.config or {}
    local spawn = map_cfg.spawn or {}
    mode7 = {
        x = spawn.x or MODE7_START_X,
        y = spawn.y or MODE7_START_Y,
        tex = tex,
        ox = 0, oy = 0, r = 0,
        s = MODE7_SCALE,
    }

    local protag_data = NPC.load("protag")
    player = {
        anim = newAnimation(protag_data.sprite, SPRITE_SIZE, SPRITE_SIZE, ANIM_FRAME_DURATION, ANIM_START_FRAME),
        grid = { x = 0, y = 0, num = 0 },
        location = {
            x = love.graphics.getWidth() / 2,
            y = love.graphics.getHeight() / 2,
            realx = 0,
            realy = 0,
        },
    }

    -- Spawn NPC copies of the protag, ringed around the player, driven by the
    -- framework NPC runtime (patrol for now; per-game AI comes with each mechanic).
    npcs = {}
    npc_count = npc_count or 0
    local pwx = mode7.x + PLAYER_OFFSET_X
    local pwy = mode7.y + PLAYER_OFFSET_Y
    local dirs = { "down", "left", "up", "right" }
    for i = 1, npc_count do
        local ang = ((i - 1) / npc_count) * math.pi * 2
        local entity = NPC.create_entity({
            character = "antag",
            x = pwx + math.cos(ang) * 240,
            y = pwy + math.sin(ang) * 190,
            behavior = "patrol",
            patrol = { distance = 70, direction = dirs[((i - 1) % 4) + 1] },
            dir_frames = PROTAG_DIR_FRAMES,
            seen_range = opts.hostile and 500 or nil,
            chase_speed = opts.hostile and 2 or 1.5,
            follow_distance = opts.hostile and (60 + i * 20) or 40,
        }, make_anim)
        if opts.hostile then
            NPC.aggro(entity, 9999)
            entity.aggro_decay = 0
        end
        npcs[#npcs + 1] = entity
    end

    combat_active = opts.hostile or false
    if combat_active then
        Input.bind("attack", { keys = {"f", "space"} })
        Equipment.register("fist", { damage = 8, range = 80, cooldown = 0.5, type = "melee" })
        Equipment.equip("fist")
        player.hp = 100
        player.max_hp = 100
        HUD.set_health(100, 100)
        HUD.set_controls({
            "Arrows: Move",
            "F: Punch",
        })
    else
        HUD.set_controls({
            "Arrows: Move",
        })
    end
end

-- Player's current world position (the NPC chase target).
local function player_world()
    return player.location.x + mode7.x - love.graphics.getWidth() / 2 + PLAYER_OFFSET_X,
        player.location.y + mode7.y - love.graphics.getHeight() / 2 + PLAYER_OFFSET_Y
end

-- Respawn `count` hostile antag enemies around the player WITHOUT resetting the
-- player/map (used for wave rounds — combat + hp carry over between rounds).
function Base.spawn_enemies(count)
    npcs = {}
    local pwx, pwy = player_world()
    local dirs = { "down", "left", "up", "right" }
    for i = 1, count do
        local ang = ((i - 1) / count) * math.pi * 2
        local entity = NPC.create_entity({
            character = "antag",
            x = pwx + math.cos(ang) * 180,
            y = pwy + math.sin(ang) * 150,
            behavior = "patrol",
            patrol = { distance = 70, direction = dirs[((i - 1) % 4) + 1] },
            dir_frames = PROTAG_DIR_FRAMES,
            seen_range = 500,
            chase_speed = 2,
            follow_distance = 60 + i * 8,
        }, make_anim)
        NPC.aggro(entity, 9999)
        entity.aggro_decay = 0
        npcs[#npcs + 1] = entity
    end
    combat_active = true
end

function Base.enemies_alive()
    local n = 0
    for _, e in ipairs(npcs) do if e.alive then n = n + 1 end end
    return n
end

function Base.player_dead()
    return player ~= nil and player.hp ~= nil and player.hp <= 0
end

function Base.update(dt)
    movementcontrols(dt)
    local pwx, pwy = player_world()
    for _, entity in ipairs(npcs) do
        NPC.update_entity(entity, dt, pwx, pwy)
    end

    if combat_active then
        Equipment.update(dt)
        HUD.update(dt)

        -- Player attacks NPCs
        if Input.held("attack") and Equipment.can_attack() then
            local hit = Equipment.attack()
            if hit then
                for _, entity in ipairs(npcs) do
                    if entity.alive then
                        local dx = entity.x - pwx
                        local dy = entity.y - pwy
                        if dx * dx + dy * dy < hit.range * hit.range then
                            entity.hp = (entity.hp or 30) - hit.damage
                            entity.max_hp = entity.max_hp or 30
                            entity.hit_flash = 0.15
                            if entity.hp <= 0 then entity.alive = false end
                        end
                    end
                end
            end
        end

        -- Hostile NPCs damage player on proximity
        for _, entity in ipairs(npcs) do
            if entity.alive and NPC.is_aggro(entity) then
                local dx = entity.x - pwx
                local dy = entity.y - pwy
                if dx * dx + dy * dy < 60 * 60 then
                    if not entity._attack_cd or entity._attack_cd <= 0 then
                        player.hp = player.hp - 5
                        HUD.flash_damage()
                        entity._attack_cd = 1.2
                    end
                end
                if entity._attack_cd then entity._attack_cd = entity._attack_cd - dt end
            end
        end

        HUD.set_health(player.hp, player.max_hp)
        HUD.set_weapon(Equipment.get_equipped() and Equipment.get_equipped().name, Equipment.get_cooldown_ratio())
    end
end

function Base.draw()
    Projection.mode7(mode7.x, mode7.y, mode7.tex, { ox = mode7.ox, oy = mode7.oy, r = mode7.r, s = mode7.s })
    -- world -> screen: the player sits at screen centre, world scrolls with mode7.
    local cam_x = love.graphics.getWidth() / 2 - mode7.x - PLAYER_OFFSET_X
    local cam_y = love.graphics.getHeight() / 2 - mode7.y - PLAYER_OFFSET_Y
    for _, entity in ipairs(npcs) do
        if entity.alive and entity.anim then
            entity.anim:draw(entity.x + cam_x, entity.y + cam_y, 0, DRAW_SCALE, DRAW_SCALE)
            if entity.hit_flash and entity.hit_flash > 0 then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.rectangle("fill", entity.x + cam_x, entity.y + cam_y, SPRITE_SIZE * DRAW_SCALE, SPRITE_SIZE * DRAW_SCALE)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end
    player.anim:draw(player.location.x, player.location.y, 0, DRAW_SCALE, DRAW_SCALE)
    HUD.draw()
end

return Base
