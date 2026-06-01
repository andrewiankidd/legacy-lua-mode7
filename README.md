# legacy-lua-mode7
##### _Mode 7_

![logo](assets/logo.png)

## About
**Mode 7** is a retro-style perspective-rendering experiment built with Lua and [LOVE2D](https://love2d.org), originally written around 2011. Pseudo-3D floor rendering with real-time rotation and scaling.

## Features
- Mode 7 perspective transformation on a 2D tile plane
- Real-time camera rotation and zoom
- Texture-mapped floor rendering from tile grids
- Sprite animation framework (AnAL.lua)
- Web build via love.js (WASM)

### Links
<p align="center">
    <a href="https://andrewiankidd.github.io/legacy-lua-mode7/">
        <img src="https://img.shields.io/badge/%F0%9F%8E%AE%20Mode7-darkorange.svg" height="50" target="_blank" />
    </a>
    <br>
    <strong>Play:</strong>
    <br>
    <a href="https://andrewiankidd.github.io/legacy-lua-mode7/Web/index.html">
        <img src="https://img.shields.io/badge/%f0%9f%8c%90%20Browser-darkorange.svg" />
    </a>
    <a href="https://github.com/andrewiankidd/legacy-lua-mode7/releases/download/latest-main/Mode7-love.zip">
        <img src="https://img.shields.io/badge/.love%20File-darkorange.svg" />
    </a>
    <br>
    <strong>Source Code:</strong>
    <br>
    <a href="https://github.com/andrewiankidd/legacy-lua-mode7">
        <img src="https://img.shields.io/badge/GitHub-darkorange.svg?logo=gitHub" />
    </a>
    <br>
    <a href="https://github.com/andrewiankidd/legacy-lua-mode7/actions/workflows/publish.yml">
        <img src="https://github.com/andrewiankidd/legacy-lua-mode7/actions/workflows/publish.yml/badge.svg" />
    </a>
</p>

## Video

Click to play

[![screenshot](assets/screenshot.png)](https://youtu.be/V4twjbADQvI)

## Running locally

    npm run setup      # install npm deps + download LOVE 11.5
    npm start          # launch the game

### Web build

    npm run build      # pack src/ into .love, compile to Web/ via love.js
    npm run serve      # serve Web/ at http://localhost:8080

## Documentation

See the [docs](docs/index.md) for how the rendering works.

## License

MIT License. See `LICENSE` file for details.
