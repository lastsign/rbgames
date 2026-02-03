--!strict
-- DamageNumbers.luau
-- Display floating damage numbers above mobs

local TweenService = game:GetService("TweenService")

local DamageNumbers = {}

-- Show damage number at position
function DamageNumbers.Show(damage: number, position: Vector3, isCrit: boolean)
	-- Create part to attach BillboardGui
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position + Vector3.new(0, 3, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = workspace

	-- Create BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(4, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	-- Create damage label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = tostring(damage)
	label.TextSize = isCrit and 48 or 36
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	-- Set color based on crit
	if isCrit then
		label.TextColor3 = Color3.fromRGB(255, 100, 100)
		label.Text = `{damage} CRIT!`
	else
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	-- Animate damage number
	task.spawn(function()
		-- Float up
		local startPos = part.Position
		local endPos = startPos + Vector3.new(
			math.random(-2, 2),
			5,
			math.random(-2, 2)
		)

		local tweenInfo = TweenInfo.new(
			1.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local tween = TweenService:Create(part, tweenInfo, {
			Position = endPos,
		})
		tween:Play()

		-- Fade out
		task.wait(0.5)
		local fadeTween = TweenService:Create(label, TweenInfo.new(1), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		})
		fadeTween:Play()

		task.wait(1)
		part:Destroy()
	end)
end

return DamageNumbers
