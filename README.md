# EECE406_Project

## Overview
This project implements a fully playable ASTEROIDS game in VHDL, designed to run on an FPGA with VGA output. It features:
- A player-controlled spaceship that can move in four directions and shoot missiles.
- Randomly generated asteroids that wrap around the screen.
- An alien sprite that moves automatically or manually via switches.
- An on-screen info section displaying the player’s remaining lives.
- A “Game Over” screen when all lives are lost.

## Video Demo

## Project Structure
- `asteroids_top.vhd`  
  Top-level module that instantiates all graphics and game logic components.
- `spaceship_graph.vhd`  
  Renders the spaceship and handles movement and missile spawn logic.
- `missile_graph.vhd`  
  Renders and updates multiple missiles, including launch and collision detection.
- `alien_1_graph.vhd`  
  Renders the alien sprite and handles its automatic/manual movement.
- `asteroid_game_graph.vhd`  
  Renders asteroids, handles random generation, movement, and collision with the spaceship.
- `info_section_graph.vhd`  
  Displays the HUD with the number of lives remaining.
- `game_over_graph.vhd`  
  Displays the “Game Over” text centered on the screen.
- `character_set.vhd`  
  ROM module defining 8×8 bitmaps for characters 0–9 and a–z.
- `spaceship_missile_graph.vhd` and `alien_missile_graph.vhd`:  
  Implements missile shooting for the spaceship and alien respecttively.

## Requirements
- VHDL 2008 compatible toolchain (ModelSim, GHDL, Vivado, etc.)
- FPGA development board with VGA output support.
- Resolution: 640×480 at 60 Hz.

> **Note:** The files `spaceship_missile_graph.vhd`, `alien_missile_graph.vhd`, and `generate_asteroid.vhd` must be set to use **VHDL 2008** specifically.

## Synthesis and FPGA Implementation
1. Import all VHDL files into your FPGA tool (Vivado, Quartus, etc.) and set the library to VHDL 2008.
2. Assign the FPGA pins for VGA signals (hsync, vsync, RGB) and input controls (buttons, switches), use the xdc constraint files (you can find preset Basys3 and Nexys A7 100T constraint files in the project dir).
3. Generate the bitstream and program your board.
4. Connect a VGA monitor to the FPGA’s VGA output and use the onboard buttons/switches to play.

## Controls
- **Button L/R/U/D**: Move spaceship left, right, up, down.
- **Button C**: Fire missile from spaceship.
- **Switches 15/14**: Manual alien movement left/right.
- **Switch 13**: Fire missile from alien when in manual control mode.
- **Switch 1**: Toggle alien manual (on) / automatic (off) control.