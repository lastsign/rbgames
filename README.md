# RPG Grind Game

A Roblox RPG game with progression systems, zones, pets, upgrades, rebirths, and daily rewards.

## Features

### Core Systems
- **Combat System**: Server-authoritative combat with damage calculation, critical hits
- **Progression System**: XP-based leveling with stat increases
- **Zone System**: Multiple zones with different mobs and reward multipliers
- **Pet System**: Collectible pets with passive bonuses (gacha system)
- **Upgrade System**: Purchase stat upgrades with coins
- **Rebirth System**: Prestige system with permanent multipliers
- **Daily Rewards**: Login streak system with increasing rewards

### Data Persistence
- ProfileService integration for reliable data saving
- Automatic profile loading/saving
- Session lock protection

### Client-Server Architecture
- Server-authoritative game logic
- Networker-based communication
- Selective data replication
- Input validation and security

## Project Structure

```
src/
├── client/          # Client-side code
│   ├── Controllers/ # UI and input controllers
│   └── Network/     # Client network interface
├── server/          # Server-side code
│   ├── Services/    # Game services (Combat, Progression, etc.)
│   ├── Systems/     # Game systems (MobSpawner, etc.)
│   └── Network/     # Server network interface
└── shared/          # Shared code
    ├── Config/      # Game configuration and balance
    ├── Data/        # Data schemas and defaults
    └── Utils/       # Utility functions and formulas
```

## Setup

1. Install dependencies:
```bash
wally install
```

2. Generate sourcemap and types:
```bash
rojo sourcemap -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
```

3. Start development server:
```bash
rojo serve
```

4. Connect in Roblox Studio using the Rojo plugin

## Configuration

All game balance is controlled via config files in `src/shared/Config/`:

- `GameConfig.luau` - General game settings
- `MobConfig.luau` - Mob definitions and stats
- `ZoneConfig.luau` - Zone unlock requirements and multipliers
- `PetConfig.luau` - Pet stats and drop rates
- `UpgradeConfig.luau` - Upgrade costs and bonuses
- `RebirthConfig.luau` - Rebirth requirements and bonuses
- `DailyRewardConfig.luau` - Daily reward progression

## Game Formulas

All calculations are centralized in `src/shared/Utils/FormulaCalculator.luau`:

- Experience requirements: `100 * (level ^ 1.5)`
- Damage: `strength * rebirthMult * petMult * critMult`
- XP rewards: `(10 + mobLevel * 5) * zoneMult * petMult * rebirthMult`
- Coin rewards: `(5 + mobLevel * 3) * zoneMult * petMult * rebirthMult`
- Upgrade costs: `baseCost * (1.15 ^ currentLevel)`

## Services

### Server Services

- **DataService**: ProfileService wrapper for data persistence
- **CombatService**: Combat calculations and mob management
- **ProgressionService**: Leveling and stat progression
- **UpgradeService**: Stat upgrade purchases
- **PetService**: Pet ownership and equipping
- **RebirthService**: Rebirth/prestige system
- **DailyRewardService**: Daily login rewards
- **ZoneService**: Zone teleportation and unlocking

### Network API

Client can invoke:
- `AttackMob(mobType)` - Attack a mob
- `PurchaseUpgrade(upgradeName)` - Buy stat upgrade
- `EquipPet(petID)` - Equip a pet
- `UnequipPet(petID)` - Unequip a pet
- `PerformRebirth()` - Perform rebirth
- `ClaimDailyReward()` - Claim daily reward
- `TeleportToZone(zoneName)` - Teleport to zone

Server sends events:
- `DataReplicated` - Full data update
- `CombatResult` - Combat outcome
- `LevelUp` - Level up notification
- `ZoneUnlocked` - Zone unlocked
- `PetEquipped` - Pet equip/unequip
- `UpgradePurchased` - Upgrade purchased
- `RebirthCompleted` - Rebirth completed
- `DailyRewardClaimed` - Daily reward claimed

## Implementation Status

### Phase 1: Foundation ✅
- Data schemas and defaults
- ProfileService integration
- Networker setup
- Formula calculator
- Configuration files

### Phase 2: Core Gameplay ✅
- Combat system
- Progression system
- Mob spawning
- Basic client controller

### Phase 3: Expansion Systems ✅
- Zone system
- Upgrade system
- Currency management

### Phase 4: Engagement Features ✅
- Pet system
- Rebirth system
- Daily rewards

### Phase 5: Polish ⏳
- UI implementation
- Visual effects
- Sound effects
- Game balancing

## TODO

### High Priority
- [ ] Create UI screens (HUD, Shop, Pets, Rebirth, Daily Rewards)
- [ ] Add visual effects (damage numbers, hit effects, level up)
- [ ] Implement egg hatching UI
- [ ] Add zone transition effects
- [ ] Create mob models (currently simple cubes)

### Medium Priority
- [ ] Add sound effects
- [ ] Implement pet following system (visuals)
- [ ] Add leaderboards
- [ ] Create tutorial/onboarding
- [ ] Add achievements

### Low Priority
- [ ] Add particle effects
- [ ] Implement animations
- [ ] Add music
- [ ] Create loading screens
- [ ] Add chat commands for testing

## Testing

Manual testing checklist:
1. Join game → verify profile loads
2. Attack mob → verify damage and rewards
3. Level up → verify stat increases
4. Buy upgrade → verify cost deduction and stat boost
5. Unlock zone → verify teleportation works
6. Equip pets → verify bonuses apply
7. Perform rebirth → verify reset and multipliers
8. Claim daily reward → verify streak tracking
9. Leave and rejoin → verify data persists

## License

This is a learning project for Roblox game development.
