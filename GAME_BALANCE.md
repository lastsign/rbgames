# Game Balance Reference

## Progression Curve

### Level Requirements
| Level | XP Required | Total XP | Time to Level* |
|-------|-------------|----------|----------------|
| 1→2   | 100         | 100      | ~20 kills      |
| 2→3   | 282         | 382      | ~56 kills      |
| 3→4   | 519         | 901      | ~104 kills     |
| 5→6   | 1,118       | 3,108    | ~224 kills     |
| 10→11 | 3,162       | 19,267   | ~632 kills     |
| 20→21 | 8,944       | 110,442  | ~1,789 kills   |
| 30→31 | 15,588      | 281,533  | ~3,118 kills   |
| 49→50 | 34,292      | 1,100,892| ~6,858 kills   |

*Assuming Slime kills (10 XP base), no multipliers

### Stat Growth
Base stats at Level 1:
- Strength: 10
- Speed: 10
- Defense: 5
- Crit Chance: 5%
- Crit Multiplier: 1.5x

Stats per level:
- Strength: +2 per level
- Speed: +2 per level
- Defense: +1 per level

Example at Level 50:
- Strength: 108 (10 + 49×2)
- Speed: 108
- Defense: 54 (5 + 49×1)

## Combat Math

### Damage Calculation
```
Base Damage = Strength
Rebirth Multiplier = 1 + (Rebirth Level × 0.1)
Pet Multiplier = Product of all equipped pet bonuses
Total Damage = Base × Rebirth Mult × Pet Mult

If Critical:
  Total Damage = Total Damage × Crit Multiplier
```

### Example Damage (Level 50, No Rebirth, No Pets)
- Normal hit: 108 damage
- Critical hit: 162 damage (1.5x)

### Example Damage (Level 50, Rebirth 1, Dragon Pet)
- Base: 108
- Rebirth: 1.1x
- Pet: 2.0x
- Normal: 108 × 1.1 × 2.0 = 237 damage
- Critical: 237 × 1.5 = 355 damage

### Mob Health Scaling
```
Health = Base Health × (1.2 ^ (Mob Level - 1))
```

| Mob    | Level | Base HP | Actual HP | Hits to Kill* |
|--------|-------|---------|-----------|---------------|
| Slime  | 1     | 50      | 50        | 1             |
| Goblin | 5     | 120     | 248       | 3             |
| Wolf   | 10    | 250     | 1,289     | 12            |
| Orc    | 15    | 500     | 3,567     | 33            |
| Troll  | 20    | 1,000   | 9,646     | 90            |
| Dragon | 30    | 3,000   | 71,161    | 659           |

*Assuming Level 50 player, no bonuses

## Rewards

### XP Rewards
```
Base XP = 10 + (Mob Level × 5)
Zone Multiplier = 1.0 to 3.0x
Pet Multiplier = 1.0 to 1.8x
Rebirth Multiplier = 1 + (Rebirth Level × 0.15)

Total XP = Base × Zone Mult × Pet Mult × Rebirth Mult
```

| Mob    | Base XP | Starter Zone | Forest (1.5x) | Volcano (3x) |
|--------|---------|--------------|---------------|--------------|
| Slime  | 15      | 15           | 22            | 45           |
| Goblin | 35      | 35           | 52            | 105          |
| Wolf   | 60      | 60           | 90            | 180          |
| Orc    | 85      | 85           | 127           | 255          |
| Troll  | 110     | 110          | 165           | 330          |
| Dragon | 160     | 160          | 240           | 480          |

### Coin Rewards
```
Base Coins = 5 + (Mob Level × 3)
Zone Multiplier = 1.0 to 3.0x
Pet Multiplier = 1.0 to 1.5x
Rebirth Multiplier = 1 + (Rebirth Level × 0.1)

Total Coins = Base × Zone Mult × Pet Mult × Rebirth Mult
```

| Mob    | Base Coins | Starter Zone | Forest (1.5x) | Volcano (3x) |
|--------|------------|--------------|---------------|--------------|
| Slime  | 8          | 8            | 12            | 24           |
| Goblin | 20         | 20           | 30            | 60           |
| Wolf   | 35         | 35           | 52            | 105          |
| Orc    | 50         | 50           | 75            | 150          |
| Troll  | 65         | 65           | 97            | 195          |
| Dragon | 95         | 95           | 142           | 285          |

## Upgrade Costs

### Cost Scaling
```
Cost = Base Cost × (1.15 ^ Current Level)
```

| Upgrade       | Base Cost | Level 1 | Level 5 | Level 10 | Level 20 | Level 50 |
|---------------|-----------|---------|---------|----------|----------|----------|
| Strength      | 100       | 100     | 175     | 404      | 1,637    | 108,366  |
| Speed         | 100       | 100     | 175     | 404      | 1,637    | 108,366  |
| Defense       | 100       | 100     | 175     | 404      | 1,637    | 108,366  |
| Crit Chance   | 200       | 200     | 350     | 809      | 3,273    | 216,732  |
| Crit Mult     | 250       | 250     | 438     | 1,011    | 4,092    | 270,915  |

### Stat Increases
```
Stat Increase = Base Increase + (Current Level × 0.1)
```

| Upgrade       | Base | Level 1 | Level 10 | Level 50 |
|---------------|------|---------|----------|----------|
| Strength      | 5    | 5       | 6        | 10       |
| Speed         | 5    | 5       | 6        | 10       |
| Defense       | 3    | 3       | 4        | 8        |
| Crit Chance   | 0.01 | 0.01    | 0.02     | 0.06     |
| Crit Mult     | 0.1  | 0.1     | 0.2      | 0.6      |

## Pet System

### Pet Bonuses

**Common (50% drop chance):**
- Dog: +10% damage
- Cat: +15% XP

**Rare (25% drop chance):**
- Hawk: +25% damage, +10% coins
- Bear: +30% damage

**Epic (10% drop chance):**
- Phoenix: +50% damage, +30% XP
- Unicorn: +50% XP, +40% coins

**Legendary (1% drop chance):**
- Dragon: +100% damage, +80% XP, +50% coins

### Egg Costs

| Egg       | Cost      | Pool                      | Best Pet    |
|-----------|-----------|---------------------------|-------------|
| Basic     | 500 coins | Dog, Cat                  | Cat         |
| Rare      | 2k coins  | Common + Rare             | Bear        |
| Epic      | 100 gems  | Rare + Epic               | Phoenix     |
| Legendary | 500 gems  | Epic + Legendary          | Dragon      |

### Max Equipped
- Can equip up to 3 pets simultaneously
- Bonuses stack multiplicatively

**Example: 3 Legendary Dragons equipped**
- Damage: 2.0 × 2.0 × 2.0 = 8x damage!
- XP: 1.8 × 1.8 × 1.8 = 5.83x XP
- Coins: 1.5 × 1.5 × 1.5 = 3.375x coins

## Rebirth System

### Requirements
- Reach Level 50
- Can rebirth multiple times

### Bonuses per Rebirth
- +10% damage (multiplicative)
- +15% XP gain (multiplicative)
- +10% coin gain (multiplicative)

### What Resets
- Level → 1
- Experience → 0
- Stats → base values
- Upgrades → 0

### What Keeps
- Pets (all owned and equipped)
- Rebirth level
- Daily reward streak

### Zone Unlocks
- Rebirth 1: Volcanic Wasteland
- Rebirth 5: Celestial Zone
- Rebirth 10: Void Zone

### Example Power (Rebirth 10)
- Damage multiplier: 1 + (10 × 0.1) = 2x
- XP multiplier: 1 + (10 × 0.15) = 2.5x
- Coin multiplier: 1 + (10 × 0.1) = 2x

Combined with 3 Dragons:
- Damage: 2x × 8x = 16x base damage
- XP: 2.5x × 5.83x = 14.58x base XP
- Coins: 2x × 3.375x = 6.75x base coins

## Daily Rewards

### Streak Progression

| Day  | Coins | Gems | Notes             |
|------|-------|------|-------------------|
| 1    | 100   | 5    |                   |
| 2    | 150   | 5    |                   |
| 3    | 200   | 10   |                   |
| 7    | 500   | 25   | Week Streak Bonus |
| 14   | 1,500 | 50   | Two Week Streak   |
| 15+  | Formula     | | See below         |

### Formula (Day 15+)
```
Coins = 100 + (Streak Day × 50)
Gems = 5 + floor(Streak Day / 7)
```

| Day | Coins | Gems |
|-----|-------|------|
| 15  | 850   | 7    |
| 30  | 1,600 | 9    |
| 60  | 3,100 | 13   |
| 100 | 5,100 | 19   |
| 365 | 18,350| 57   |

### Streak Rules
- 24-hour cooldown between claims
- 48-hour window to maintain streak
- Streak resets to 1 if you miss the window

## Economy Balance

### Coins per Hour (estimates)
Assuming killing Slimes in Starter Zone (8 coins, 1 second per kill):
- Base: 28,800 coins/hour
- With Cat pet: 28,800 coins/hour (no coin bonus)
- With Hawk pet: 31,680 coins/hour (+10% coins)
- With 3 Dragons: 97,200 coins/hour (+237.5%)

### Time to Max Upgrade
Strength upgrade to level 50 costs: 108,366 coins
- Base rate: ~3.8 hours of Slime grinding
- With 3 Dragons: ~1.1 hours

### Gem Economy
Gems are premium currency:
- Daily rewards only source (5-50+ per day)
- Epic Egg: 100 gems (~2-20 days)
- Legendary Egg: 500 gems (~10-100 days)

## Zone Progression Path

### Recommended Route

**Levels 1-10: Starter Plains**
- Kill Slimes (easiest)
- Kill Goblins (better rewards)
- Farm coins for first upgrades
- Buy strength upgrades (combat faster)

**Levels 10-20: Dark Forest**
- Unlocked at level 10
- 1.5x rewards
- Kill Goblins → Wolves → Orcs
- Save for Rare Egg (2,000 coins)

**Levels 20-30: Rocky Mountains**
- Unlocked at level 20
- 2.0x rewards
- Kill Orcs and Trolls
- Continue upgrading

**Levels 30-50: Push to Rebirth**
- Stay in Mountains or return to Forest
- Farm upgrades and pets
- Reach level 50 for first rebirth

**Post-Rebirth: Volcanic Wasteland**
- Unlocked at Rebirth 1
- 3.0x rewards
- Dragons give massive XP/coins
- Power level with rebirth bonuses

## Optimization Tips

### Fastest XP
1. Equip 3 pets with XP bonuses (Unicorns ideal)
2. Get rebirth levels for XP multiplier
3. Fight in highest zone available
4. Focus on mobs you can kill quickly

### Fastest Coins
1. Equip pets with coin bonuses
2. Fight in highest zone available
3. Get rebirth levels
4. Kill mobs rapidly (Strength upgrades)

### Efficient Progression
1. Prioritize Strength upgrades early
2. Get Basic/Rare eggs for early pets
3. Reach Rebirth 1 ASAP for Volcano
4. Then focus on perfect pet team
5. Stack rebirths for exponential growth

## Balance Notes

The game is designed for:
- **Early game** (Levels 1-20): Linear progression, learning systems
- **Mid game** (Levels 20-50): Exponential growth, first rebirth goal
- **End game** (Post-rebirth): Multiplicative bonuses, rapid progression
- **Meta game**: Multiple rebirths, perfect pet collection, min-maxing

Key balancing points:
- XP curve ensures ~2 hours to first rebirth
- Upgrades become expensive, encouraging rebirth
- Pets provide significant power but require luck/gems
- Rebirths multiply all bonuses, creating feedback loop
- Daily rewards provide steady gem income for F2P
