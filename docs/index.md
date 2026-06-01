# Mode 7

A retro-style scanline perspective-rendering experiment built with Lua and LOVE2D.

## How It Works

Mode 7 is a pseudo-3D technique from the retro era. A 2D tile map is rendered with perspective transformation -- each scanline is scaled and offset based on its distance from the "camera," creating the illusion of a 3D floor receding into the distance.

The core rendering lives in `src/mode7.lua`.

## Controls

| Key | Action |
|-----|--------|
| Arrow keys / WASD | Move / rotate camera |
| Space | Action |
| Escape | Menu |

## Getting Started

```bash
npm run setup      # install npm deps + download LOVE 11.5
npm start          # launch the experiment
```

### Web build

```bash
npm run build      # pack src/ into .love, compile to Web/ via love.js
npm run serve      # serve Web/ at http://localhost:8080
```
