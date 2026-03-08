# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of browser-based HTML games. Each game is a single self-contained `.html` file with inline CSS and JavaScript — no build tools, no dependencies, no server required. Open any file directly in a browser to play.

## Games

- **`shooter.html`** — Top-down arena shooter (800×600 canvas). 5 levels × 3 waves each, 4 enemy types (Grunt, Fast, Tank, Shooter).
- **`tictactoe.html`** — Two-player Tic Tac Toe with persistent score tracking.

## Architecture: shooter.html

The shooter is structured as numbered sections in a single script block:

1. **Constants** — Canvas size, colors (`C` object), game state enum, physics constants
2. **Utilities** — Pure math helpers (`dist`, `angleTo`, `clamp`, `lerp`, `rnd`, etc.)
3. **Input** — Singleton handling keyboard + mouse; call `Input.flush()` once per frame
4. **Particles** — Object pool of 512 `Particle` instances; `ParticleSystem` manages them
5. **Bullet** — Shared class for both player and enemy projectiles; has a 4-frame trail
6. **Enemy base** — `Enemy` class with HP, hit flash, health bar, and bounds nudging
7. **Enemy types** — `GruntEnemy`, `FastEnemy`, `TankEnemy`, `ShooterEnemy` extend `Enemy`; `ShooterEnemy` owns its own bullet array
8. **Player** — Keyboard movement, mouse aim, shoot cooldown, i-frames on hit
9. **Collision detection** — `handleCollisions()` handles player bullets↔enemies, enemy bullets↔player, and body contact
10. **Level data** — `LEVEL_DATA` array defines waves as `{type, count}` entries; difficulty scales with level index
11. **LevelManager** — Loads waves, trickle-spawns enemies from a shuffled queue (0.35s interval)
12. **Game** — State machine (`MENU → PLAYING → LEVEL_COMPLETE / GAME_OVER / WIN`); owns `ScreenShake`, orchestrates update/render
13. **Bootstrap** — `window.onload` wires up canvas sizing and starts the `requestAnimationFrame` loop

Enemy bullets are only tracked per-`ShooterEnemy` instance; all other collision geometry uses circular radius checks.

## Adding a New Game

Create a new `.html` file following the single-file pattern (inline `<style>` + `<script>`). No framework or tooling needed.

## Git Workflow

Commit and push to GitHub regularly throughout any work session — after each meaningful change, not just at the end. This ensures work is never lost.

- Write clean, descriptive commit messages that explain what changed and why
- Push after every commit: `git push origin master`
- Commit at natural checkpoints: after adding a feature, fixing a bug, or completing a logical unit of work
