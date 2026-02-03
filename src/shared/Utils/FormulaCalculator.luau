--!strict
-- FormulaCalculator.luau
-- All game balance formulas in one place

local FormulaCalculator = {}

-- Experience required for next level
function FormulaCalculator.GetExperienceForLevel(level: number): number
	return math.floor(100 * (level ^ 1.5))
end

-- Damage calculation
function FormulaCalculator.CalculateDamage(
	strength: number,
	rebirthLevel: number,
	petMultipliers: number,
	isCrit: boolean,
	critMultiplier: number,
	weaponMultiplier: number?
): number
	local baseDamage = strength
	local rebirthMultiplier = 1 + (rebirthLevel * 0.1) -- +10% per rebirth
	local totalMultiplier = rebirthMultiplier * petMultipliers * (weaponMultiplier or 1.0)

	local damage = baseDamage * totalMultiplier

	if isCrit then
		damage = damage * critMultiplier
	end

	return math.floor(damage)
end

-- XP reward from killing a mob
function FormulaCalculator.CalculateXPReward(
	mobLevel: number,
	zoneMultiplier: number,
	petXPMultiplier: number,
	rebirthLevel: number
): number
	local baseXP = 10 + (mobLevel * 5)
	local rebirthMultiplier = 1 + (rebirthLevel * 0.15) -- +15% per rebirth
	local totalMultiplier = zoneMultiplier * petXPMultiplier * rebirthMultiplier

	return math.floor(baseXP * totalMultiplier)
end

-- Coin reward from killing a mob
function FormulaCalculator.CalculateCoinReward(
	mobLevel: number,
	zoneMultiplier: number,
	petCoinMultiplier: number,
	rebirthLevel: number
): number
	local baseCoins = 5 + (mobLevel * 3)
	local rebirthMultiplier = 1 + (rebirthLevel * 0.1) -- +10% per rebirth
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
