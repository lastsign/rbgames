# Quick Start Guide

## Development Setup

### 1. Install Dependencies
```bash
wally install
```

This installs:
- ProfileService (data persistence)
- Networker (client-server communication)
- Promise (async patterns)

### 2. Generate Type Definitions
```bash
rojo sourcemap -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
```

### 3. Start Development Server
```bash
rojo serve
```

### 4. Connect in Roblox Studio
1. Open Roblox Studio
2. Install the Rojo plugin if you haven't
3. Click "Connect" in the Rojo plugin
4. Point it to `localhost:34872`

The game will sync automatically as you edit files!

## Testing the Game

### In Roblox Studio

1. **Start the game** (F5 or Play button)
2. **Check output** for initialization messages:
   ```
   [Server] RPG Game initializing...
   [MobSpawner] Mobs spawned in all zones
   [Server] RPG Game initialized!
   ```

3. **On player join** you should see:
   ```
   [Server] Player <name> joining...
   [Server] Profile loaded for <name>
   [Client] RPG Game initializing...
   [Client] Received player data
   ```

### Basic Testing

**Test Combat:**
1. Look for red cube mobs in the workspace
2. Click on a mob to attack it
3. Check output for damage messages
4. Mob should respawn after death

**Test Progression:**
1. Kill mobs to gain XP
2. Watch output for level up messages
3. Check that stats increase

**Test in F9 Console (Client):**
```lua
-- Get networker
local Networker = require(game.ReplicatedStorage.Packages.Networker)
local Net = Networker.new("RPGGame")

-- Attack a mob
local result = Net:GetFunction("AttackMob"):InvokeServer("Slime")
print(result)

-- Purchase upgrade
local result = Net:GetFunction("PurchaseUpgrade"):InvokeServer("Strength")
print(result)

-- Teleport to zone
local result = Net:GetFunction("TeleportToZone"):InvokeServer("ForestZone")
print(result)
```

**Test in F9 Console (Server):**
```lua
-- Get a player's data
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
local data = DataService.GetData(player)
print(data)

-- Manually award XP
local ProgressionService = require(game.ServerScriptService.Server.Services.ProgressionService)
ProgressionService.AwardExperience(player, 1000)

-- Force rebirth
local RebirthService = require(game.ServerScriptService.Server.Services.RebirthService)
RebirthService.PerformRebirth(player)
```

## File Structure Reference

```
src/
├── client/
│   ├── init.client.luau          # Entry point
│   ├── Controllers/
│   │   └── CombatController.luau # Combat UI
│   └── Network/
│       └── ClientNetworker.luau  # Network interface
│
├── server/
│   ├── init.server.luau          # Entry point
│   ├── Services/                 # All game logic
│   │   ├── DataService.luau      # ProfileService wrapper
│   │   ├── CombatService.luau    # Combat calculations
│   │   ├── ProgressionService.luau
│   │   ├── UpgradeService.luau
│   │   ├── PetService.luau
│   │   ├── RebirthService.luau
│   │   ├── DailyRewardService.luau
│   │   └── ZoneService.luau
│   ├── Systems/
│   │   └── MobSpawner.luau       # Spawn mobs
│   └── Network/
│       └── ServerNetworker.luau  # Network endpoints
│
└── shared/
    ├── Config/                   # Game balance
    │   ├── GameConfig.luau
    │   ├── MobConfig.luau
    │   ├── ZoneConfig.luau
    │   ├── PetConfig.luau
    │   ├── UpgradeConfig.luau
    │   ├── RebirthConfig.luau
    │   └── DailyRewardConfig.luau
    ├── Data/
    │   ├── PlayerDataSchema.luau # Data structure
    │   └── DefaultData.luau      # Default values
    ├── Types/
    │   └── SharedTypes.luau      # Type definitions
    └── Utils/
        └── FormulaCalculator.luau # All formulas
```

## Common Tasks

### Adding a New Mob

1. Add to `src/shared/Config/MobConfig.luau`:
```lua
NewMob = {
    Name = "New Mob",
    Level = 25,
    BaseHealth = 2000,
    Zones = { "MountainZone" },
},
```

2. Add mob type to zone in `src/shared/Config/ZoneConfig.luau`:
```lua
MountainZone = {
    -- ...
    MobTypes = { "Orc", "Troll", "NewMob" },
},
```

3. Restart server and mobs will spawn automatically

### Adding a New Zone

1. Add to `src/shared/Config/ZoneConfig.luau`:
```lua
NewZone = {
    Name = "NewZone",
    DisplayName = "New Area",
    UnlockLevel = 40,
    UnlockRebirthLevel = 0,
    XPMultiplier = 2.5,
    CoinMultiplier = 2.5,
    SpawnLocation = Vector3.new(800, 5, 0),
    MobTypes = { "NewMob" },
},
```

2. Zone will unlock automatically when player reaches level 40

### Adding a New Pet

1. Add to `src/shared/Config/PetConfig.luau`:
```lua
Pets = {
    -- ...
    NewPet = {
        ID = "NewPet",
        Name = "NewPet",
        DisplayName = "Amazing Pet",
        Rarity = "Epic",
        Bonuses = {
            DamageMultiplier = 1.4,
            XPMultiplier = 1.2,
        },
        DropChance = 0.1,
    },
}

Eggs = {
    -- ...
    EpicEgg = {
        -- ...
        PetPool = { "Hawk", "Bear", "Phoenix", "Unicorn", "NewPet" },
    },
}
```

2. Pet will be available in egg pool

### Adding a New Upgrade

1. Add to `src/shared/Config/UpgradeConfig.luau`:
```lua
NewStat = {
    Name = "NewStat",
    DisplayName = "New Stat Upgrade",
    Description = "Increase your power",
    BaseCost = 150,
    BaseIncrease = 4,
    StatType = "NewStat",
},
```

2. Add stat to PlayerDataSchema:
```lua
Stats = {
    -- ...
    NewStat: number,
},
Upgrades = {
    -- ...
    NewStat: number,
},
```

3. Add default value to DefaultData

4. Update ProgressionService if stat should increase on level up

### Modifying Game Balance

All formulas are in `src/shared/Utils/FormulaCalculator.luau`

**Example: Make leveling faster**
```lua
-- Change from:
function FormulaCalculator.GetExperienceForLevel(level: number): number
    return math.floor(100 * (level ^ 1.5))
end

-- To:
function FormulaCalculator.GetExperienceForLevel(level: number): number
    return math.floor(50 * (level ^ 1.3)) -- Easier!
end
```

**Example: Increase rebirth bonuses**
```lua
-- In RebirthConfig.luau
DamageMultiplierPerRebirth = 0.2, -- Was 0.1, now +20% instead of +10%
```

## Debugging Tips

### Check Player Data
```lua
-- Server console
local player = game.Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
print(DataService.GetData(player))
```

### Give Resources
```lua
-- Server console
local player = game.Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
DataService.UpdateData(player, function(data)
    data.Currencies.Coins += 10000
    data.Currencies.Gems += 1000
end)
```

### Force Level Up
```lua
-- Server console
local player = game.Players:GetPlayers()[1]
local ProgressionService = require(game.ServerScriptService.Server.Services.ProgressionService)
ProgressionService.AwardExperience(player, 100000)
```

### Reset Player Data
```lua
-- Server console (WARNING: Deletes all progress!)
local player = game.Players:GetPlayers()[1]
local ProfileService = require(game.ServerScriptService.ServerPackages.ProfileService)
local DefaultData = require(game.ReplicatedStorage.Shared.Data.DefaultData)
local ProfileStore = ProfileService.GetProfileStore("PlayerData", DefaultData)

-- Player must rejoin after this
player:Kick("Data reset")
```

### View All Mobs
```lua
-- Client or server console
for _, mob in workspace.Mobs:GetChildren() do
    local mobType = mob:FindFirstChild("MobType")
    if mobType then
        print(mob.Name, mobType.Value, mob.MobBody.Position)
    end
end
```

## Performance Monitoring

### Check Profile Load Times
```lua
-- In DataService.LoadProfileAsync, add timing:
local startTime = tick()
-- ... profile loading code ...
warn(`Profile loaded in {tick() - startTime} seconds`)
```

### Monitor Network Traffic
```lua
-- In ServerNetworker, add logging:
function ServerNetworker.ReplicateData(player: Player, data: any)
    local size = #game:GetService("HttpService"):JSONEncode(data)
    warn(`Replicating {size} bytes to {player.Name}`)
    ServerNetworker.Events.DataReplicated:FireClient(player, data)
end
```

## Next Steps

1. **Create UI** - The biggest missing piece
   - Use the network API from controllers
   - Listen to events for updates
   - Display data from replicated data

2. **Add Visual Effects**
   - Damage numbers using BillboardGuis
   - Particle effects for hits
   - Level up celebrations

3. **Improve Mob Models**
   - Replace cubes with actual models
   - Add animations
   - Better health bars

4. **Test Balance**
   - Play through progression
   - Adjust formulas in configs
   - Get feedback

## Troubleshooting

**"Profile failed to load"**
- Check ProfileService is installed
- Verify ServerPackages exists
- Check for typos in store name

**"Player data not found"**
- Profile may not be loaded yet
- Check server console for errors
- Verify player joined successfully

**"Mobs not spawning"**
- Check MobSpawner.Initialize() is called
- Verify workspace has "Mobs" folder
- Check zone configs have valid mob types

**"Combat not working"**
- Ensure mobs have "MobType" StringValue
- Check CombatController is receiving clicks
- Verify AttackMob network function is set up

**"Data not persisting"**
- Check profile is released on leave
- Verify ProfileStore name is consistent
- Test in actual Roblox, not Studio (Studio has limitations)

## Resources

- [ProfileService Docs](https://madstudioroblox.github.io/ProfileService/)
- [Networker GitHub](https://github.com/leifstout/networker)
- [Rojo Docs](https://rojo.space/docs)
- [Luau Documentation](https://luau-lang.org/)

## Support

If you encounter issues:
1. Check F9 console for errors
2. Review this guide
3. Check IMPLEMENTATION.md for architecture details
4. Verify dependencies are installed
5. Try rebuilding: `rojo build -o rbgames.rbxlx`
