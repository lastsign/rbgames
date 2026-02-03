--!strict
-- DailyRewardConfig.luau
-- Configuration for daily login rewards

export type DailyReward = {
	Day: number,
	Coins: number,
	Gems: number,
	Bonus: string?, -- Special bonus description
}

local DailyRewardConfig: { DailyReward } = {
	{ Day = 1, Coins = 100, Gems = 5 },
	{ Day = 2, Coins = 150, Gems = 5 },
	{ Day = 3, Coins = 200, Gems = 10 },
	{ Day = 4, Coins = 250, Gems = 10 },
	{ Day = 5, Coins = 300, Gems = 15 },
	{ Day = 6, Coins = 400, Gems = 15 },
	{ Day = 7, Coins = 500, Gems = 25, Bonus = "Week Streak Bonus!" },
	{ Day = 8, Coins = 600, Gems = 30 },
	{ Day = 9, Coins = 700, Gems = 30 },
	{ Day = 10, Coins = 800, Gems = 35 },
	{ Day = 11, Coins = 900, Gems = 35 },
	{ Day = 12, Coins = 1000, Gems = 40 },
	{ Day = 13, Coins = 1100, Gems = 40 },
	{ Day = 14, Coins = 1500, Gems = 50, Bonus = "Two Week Streak!" },
	-- After day 14, continue with scaling formula
}

local Config = {
	Rewards = table.freeze(DailyRewardConfig),

	-- Maximum days with defined rewards (after this, use formula)
	MaxDefinedDays = 14,

	-- Cooldown in hours
	ClaimCooldownHours = 24,

	-- Streak window (must claim within this many hours to maintain streak)
	StreakWindowHours = 48,
}

return table.freeze(Config)
