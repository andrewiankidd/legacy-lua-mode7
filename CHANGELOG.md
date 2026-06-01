# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- CI/CD pipeline with rolling `latest-main` releases and GitHub Pages deploy
- Project website with play-in-browser, download links, and feature list
- Documentation (`docs/`) covering Mode 7 rendering and controls
- `npm run setup` bootstraps a dev machine (installs deps + downloads LOVE 11.5)
- `npm start` launches the game using the locally-installed LOVE binary
- love.js web build (WASM) -- play in the browser
- Shared module submodule (`src/lib/`) for input, animation, camera, collision, config, storage, settings

### Changed
- Game source moved from `mode7/` to `src/`
- Animation library switched from anim.lua (AnAL) to shared `lib/animation.lua` via compat shim
- Configuration uses shared `lib/conf.lua` with persistent settings support
- README modernized with logo, badges, and standard layout

### Removed
- Committed binaries (love.exe, DLLs, lovedist.exe)
- Legacy build scripts (`_compile.bat`, `_start.bat`)

## 2011 -- Original Release

### Added
- retro-style scanline perspective rendering on a 2D tile plane
- Real-time camera rotation and zoom
- Texture-mapped floor rendering from tile grids
- Sprite animation framework
