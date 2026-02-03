--!strict
-- MobHealthController.luau
-- Updates mob health bars on client

local TweenService = game:GetService("TweenService")
local ClientNetworker = require(script.Parent.Parent.Network.ClientNetworker)

local MobHealthController = {}

-- Listen for combat results and update mob health
function MobHealthController.Initialize()
	ClientNetworker.Events.CombatResult.OnClientEvent:Connect(function(result)
		MobHealthController.UpdateMobHealth(result)
	end)

	print("[MobHealthController] Initialized")
end

-- Update health bar on a specific mob model
function MobHealthController.UpdateMobHealthBar(mobModel: Model, currentHealth: number, maxHealth: number)
	local mobBody = mobModel:FindFirstChild("MobBody")
	if not mobBody then
		return
	end

	local healthDisplay = mobBody:FindFirstChild("HealthDisplay") :: BillboardGui?
	if not healthDisplay then
		return
	end

	-- Update health bar fill
	local healthBarBg = healthDisplay:FindFirstChild("HealthBarBg") :: Frame?
	if healthBarBg then
		local healthBar = healthBarBg:FindFirstChild("HealthBar") :: Frame?
		if healthBar then
			local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)

			-- Animate health bar
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(healthBar, tweenInfo, {
				Size = UDim2.new(healthPercent, 0, 1, 0),
			})
			tween:Play()

			-- Change color based on health
			if healthPercent > 0.5 then
				healthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Green
			elseif healthPercent > 0.25 then
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 50) -- Yellow
			else
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red
			end
		end
	end

	-- Update health text
	local healthText = healthDisplay:FindFirstChild("HealthText") :: TextLabel?
	if healthText then
		healthText.Text = `{math.floor(currentHealth)} / {math.floor(maxHealth)}`
	end
end

-- Kill visual effect for mob
function MobHealthController.ShowMobDeath(mobModel: Model, maxHealth: number)
	local mobBody = mobModel:FindFirstChild("MobBody") :: BasePart?
	if not mobBody then
		return
	end

	-- Hide health bar during death
	local healthDisplay = mobBody:FindFirstChild("HealthDisplay") :: BillboardGui?
	if healthDisplay then
		healthDisplay.Enabled = false
	end

	-- Fade out and shrink effect
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(mobBody, tweenInfo, {
		Transparency = 1,
		Size = Vector3.new(0.1, 0.1, 0.1),
	})

	tween:Play()
	tween.Completed:Connect(function()
		-- Reset mob after delay (server will respawn it)
		task.delay(1, function()
			if mobModel and mobModel.Parent and mobBody then
				-- Reset visual
				mobBody.Transparency = 0
				mobBody.Size = Vector3.new(4, 5, 4)

				-- Reset health bar to full
				if healthDisplay then
					healthDisplay.Enabled = true

					local healthBarBg = healthDisplay:FindFirstChild("HealthBarBg") :: Frame?
					if healthBarBg then
						local healthBar = healthBarBg:FindFirstChild("HealthBar") :: Frame?
						if healthBar then
							healthBar.Size = UDim2.new(1, 0, 1, 0)
							healthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Green (full health)
						end
					end

					local healthText = healthDisplay:FindFirstChild("HealthText") :: TextLabel?
					if healthText then
						healthText.Text = `{math.floor(maxHealth)} / {math.floor(maxHealth)}`
					end
				end
			end
		end)
	end)
end

-- Update mob health display (called from CombatResult event, but we use direct method now)
function MobHealthController.UpdateMobHealth(combatResult: any)
	-- This is called from the event, but actual updates happen via UpdateMobHealthBar
	-- which is called directly from CombatController with the target mob
end

return MobHealthController
