# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Roblox game project using Luau (Roblox's typed Lua variant) with Rojo for filesystem-based development. The project uses Wally for package management.

## Build and Development Commands

```bash
# Install dependencies (run after cloning or updating wally.toml)
wally install

# Generate sourcemap (required for wally-package-types)
rojo sourcemap -o sourcemap.json

# Generate type definitions for Wally packages
wally-package-types --sourcemap sourcemap.json Packages/

# Build place file
rojo build -o rbgames.rbxlx

# Start development server (live sync with Roblox Studio)
rojo serve

# Lint Luau code
selene src/
```

**Setup workflow**: After cloning or adding new dependencies:
1. `wally install` - Install packages
2. `rojo sourcemap -o sourcemap.json` - Generate sourcemap
3. `wally-package-types --sourcemap sourcemap.json Packages/` - Generate type definitions

**Important**: `wally-package-types` modifies link files and cannot run twice on the same files. If you need to regenerate, delete Packages/ServerPackages folders and run `wally install` again first.

**Development workflow**: Run `rojo serve`, then in Roblox Studio use the Rojo plugin to connect and sync changes in real-time.

## Architecture

**Client-Server Model** with FilteringEnabled (mandatory Roblox security):
- `src/client/` → Client-side scripts (runs on player's machine)
- `src/server/` → Server-side scripts (authoritative game logic)
- `src/shared/` → Modules accessible by both client and server

**Rojo Mapping** (defined in `default.project.json`):
- `src/shared` → `ReplicatedStorage/Shared`
- `src/server` → `ServerScriptService/Server`
- `src/client` → `StarterPlayer/StarterPlayerScripts/Client`
- `Packages` → `ReplicatedStorage/Packages` (shared dependencies)
- `ServerPackages` → `ServerScriptService/ServerPackages` (server-only dependencies)

## Dependencies (Wally)

Managed via `wally.toml`:
- **Promise** (evaera/promise) - Async/await pattern for Luau
- **Networker** (leifstout/networker) - Client-server communication
- **ProfileService** (server-only) - Player data persistence

Run `wally install` to fetch packages into `Packages/` and `ServerPackages/`.

## Toolchain

Two toolchain managers are configured (use either):
- **Aftman** (`aftman.toml`): Rojo 7.7.0-rc.1
- **Rokit** (`rokit.toml`): Rojo 7.6.1, Wally 0.3.2, wally-package-types

## Code Standards

- **Language**: Luau with Roblox standard library
- **Linting**: Selene configured for Roblox (`selene.toml`)
- **File extensions**: `.luau` for modules, `.client.luau` for client scripts, `.server.luau` for server scripts

## Requiring Modules

From client or server scripts, require shared modules via ReplicatedStorage:
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local MyModule = require(ReplicatedStorage.Shared.MyModule)
```

Server-only packages are accessed via ServerScriptService:
```luau
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
```
