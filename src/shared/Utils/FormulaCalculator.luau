--!strict
-- FormulaCalculator.luau
-- All game balance formulas in one place
--
-- BALANCE PHILOSOPHY:
-- Early game (Lv 1-15): Fast progression, player feels powerful
-- Mid game (Lv 16-35): Slowdown, paid upgrades become attractive
-- Late game (Lv 36+): Grind or pay, rebirth incentivized

local FormulaCalculator = {}

-- Experience required for next level
-- Early levels are fast, then exponential scaling kicks in
function FormulaCalculator.GetExperienceForLevel(level: number): number
	if level <= 10 then
		-- Fast early levels: 50, 70, 95, 125, 160...
		return math.floor(50 * (level ^ 1.1))
	elseif level <= 25 then
		-- Medium scaling
		return math.floor(100 * (level ^ 1.4))
	else
		-- Steep scaling for late game
		return math.floor(150 * (level ^ 1.6))
	end
end

-- Damage calculation with early game boost
function FormulaCalculator.CalculateDamage(
	strength: number,
	rebirthLevel: number,
	petMultipliers: number,
	isCrit: boolean,
	critMultiplier: number,
	weaponMultiplier: number?
): number
	-- Early game boost: strength scales better at low values
	-- At strength 10-50: ~1.5x effective damage
	-- At strength 100+: approaches 1x (linear)
	local earlyGameBoost = 1 + (50 / (strength + 50)) -- 1.5x at 50 str, 1.33x at 100, 1.2x at 200
	local baseDamage = strength * earlyGameBoost

	local rebirthMultiplier = 1 + (rebirthLevel * 0.15) -- +15% per rebirth (was 10%)
	local totalMultiplier = rebirthMultiplier * petMultipliers * (weaponMultiplier or 1.0)

	local damage = baseDamage * totalMultiplier

	if isCrit then
		damage = damage * critMultiplier
	end

	return math.floor(damage)
end

-- XP reward from killing a mob
-- Higher base XP for faster early leveling
function FormulaCalculator.CalculateXPReward(
	mobLevel: number,
	zoneMultiplier: number,
	petXPMultiplier: number,
	rebirthLevel: number
): number
	local baseXP = 15 + (mobLevel * 8) -- More XP (was 10 + mobLevel*5)
	local rebirthMultiplier = 1 + (rebirthLevel * 0.20) -- +20% per rebirth (was 15%)
	local totalMultiplier = zoneMultiplier * petXPMultiplier * rebirthMultiplier

	return math.floor(baseXP * totalMultiplier)
end

-- Coin reward from killing a mob
-- Generous coins early to afford first upgrades quickly
function FormulaCalculator.CalculateCoinReward(
	mobLevel: number,
	zoneMultiplier: number,
	petCoinMultiplier: number,
	rebirthLevel: number
): number
	local baseCoins = 10 + (mobLevel * 5) -- More coins (was 5 + mobLevel*3)
	local rebirthMultiplier = 1 + (rebirthLevel * 0.15) -- +15% per rebirth (was 10%)
	local totalMultiplier = zoneMultiplier * petCoinMultiplier * rebirthMultiplier

	return math.floor(baseCoins * totalMultiplier)
end

-- Upgrade cost (exponential scaling)
function FormulaCalculator.CalculateUpgradeCost(baseCost: number, currentLevel: number): number
	return math.floor(baseCost * (1.15 ^ currentLevel))
end

-- Stat increase from upgrade
function FormulaCalculator.CalculateStatIncrease(baseIncrease: number, currentLevel: number): number
	return baseIncrease + (currentLevel * 0.1)
end

-- Check if player can rebirth
function FormulaCalculator.CanRebirth(level: number, requiredLevel: number): boolean
	return level >= requiredLevel
end

-- Rebirth multiplier bonus
function FormulaCalculator.GetRebirthBonus(rebirthLevel: number): number
	return 1 + (rebirthLevel * 0.1) -- +10% per rebirth
end

-- Mob health scaling
function FormulaCalculator.CalculateMobHealth(baseHealth: number, mobLevel: number): number
	return math.floor(baseHealth * (1.2 ^ (mobLevel - 1)))
end

-- Daily reward amount based on streak
function FormulaCalculator.CalculateDailyReward(streakDay: number): { Coins: number, Gems: number }
	local baseCoins = 100
	local baseGems = 5

	return {
		Coins = baseCoins + (streakDay * 50),
		Gems = baseGems + math.floor(streakDay / 7), -- Bonus gem every 7 days
	}
end

-- Check if can claim daily reward (24 hour cooldown)
function FormulaCalculator.CanClaimDailyReward(lastClaimDate: string, currentDate: string): boolean
	if lastClaimDate == "" then
		return true
	end

	-- Parse ISO 8601 dates and check if 24 hours have passed
	local lastClaim = DateTime.fromIsoDate(lastClaimDate)
	local current = DateTime.fromIsoDate(currentDate)

	if not lastClaim or not current then
		return false
	end

	local hoursSince = (current.UnixTimestamp - lastClaim.UnixTimestamp) / 3600
	return hoursSince >= 24
end

-- Check if streak should continue (claimed within 48 hours)
function FormulaCalculator.ShouldContinueStreak(lastClaimDate: string, currentDate: string): boolean
	if lastClaimDate == "" then
		return false
	end

	local lastClaim = DateTime.fromIsoDate(lastClaimDate)
	local current = DateTime.fromIsoDate(currentDate)

	if not lastClaim or not current then
		return false
	end

	local hoursSince = (current.UnixTimestamp - lastClaim.UnixTimestamp) / 3600
	return hoursSince <= 48 -- Allow 48 hour window to maintain streak
end

return table.freeze(FormulaCalculator)
