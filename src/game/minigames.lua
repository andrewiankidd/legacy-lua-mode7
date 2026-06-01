-- minigames.lua — the five wee games. Each is data: a name, a key, a tile colour,
-- and the map it loads (its own copy of the base map). Mechanics get layered on
-- per game later; for now selecting one drops the guy onto that mode's map.

-- npcs = how many runtime-controlled protag copies to spawn alongside the player.
return {
    { name = "BIKE RACE", key = "bike",   color = { 0.80, 0.25, 0.20 }, map = "bike",   npcs = 2 },
    { name = "WALLY",     key = "wally",  color = { 0.25, 0.45, 0.80 }, map = "wally",  npcs = 1 },
    { name = "KERBY",     key = "kerby",  color = { 0.30, 0.62, 0.34 }, map = "kerby",  npcs = 1 },
    { name = "CHAPPY",    key = "chappy", color = { 0.55, 0.38, 0.22 }, map = "chappy", npcs = 0 },
    { name = "SCRAP",     key = "scrap",  color = { 0.55, 0.30, 0.62 }, map = "scrap",  npcs = 4, hostile = true },
}
