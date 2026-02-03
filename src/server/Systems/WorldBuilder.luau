--!strict
-- WorldBuilder.luau
-- Creates the game world with zones and terrain

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)

local WorldBuilder = {}

-- Zone visual configurations
local ZoneVisuals = {
	StarterZone = {
		GroundColor = Color3.fromRGB(100, 180, 100), -- Green grass
		GroundMaterial = Enum.Material.Grass,
		AccentColor = Color3.fromRGB(139, 90, 43), -- Brown dirt
		TreeColor = Color3.fromRGB(34, 139, 34),
	},
	ForestZone = {
		GroundColor = Color3.fromRGB(50, 80, 50), -- Dark green
		GroundMaterial = Enum.Material.LeafyGrass,
		AccentColor = Color3.fromRGB(60, 40, 20), -- Dark brown
		TreeColor = Color3.fromRGB(20, 60, 20),
	},
	MountainZone = {
		GroundColor = Color3.fromRGB(120, 120, 130), -- Gray rock
		GroundMaterial = Enum.Material.Slate,
		AccentColor = Color3.fromRGB(90, 90, 100),
		TreeColor = Color3.fromRGB(60, 60, 70),
	},
	VolcanoZone = {
		GroundColor = Color3.fromRGB(40, 30, 30), -- Dark volcanic
		GroundMaterial = Enum.Material.CrackedLava,
		AccentColor = Color3.fromRGB(200, 80, 20), -- Lava orange
		TreeColor = Color3.fromRGB(30, 20, 20),
	},
}

-- Create a simple tree
local function CreateTree(position: Vector3, color: Color3): Model
	local tree = Instance.new("Model")
	tree.Name = "Tree"

	-- Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(2, 8, 2)
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Anchored = true
	trunk.BrickColor = BrickColor.new("Reddish brown")
	trunk.Material = Enum.Material.Wood
	trunk.Parent = tree

	-- Foliage
	local foliage = Instance.new("Part")
	foliage.Name = "Foliage"
	foliage.Shape = Enum.PartType.Ball
	foliage.Size = Vector3.new(8, 8, 8)
	foliage.Position = position + Vector3.new(0, 10, 0)
	foliage.Anchored = true
	foliage.Color = color
	foliage.Material = Enum.Material.Grass
	foliage.Parent = tree

	tree.PrimaryPart = trunk
	return tree
end

-- Create a rock
local function CreateRock(position: Vector3, size: number, color: Color3): Part
	local rock = Instance.new("Part")
	rock.Name = "Rock"
	rock.Size = Vector3.new(size, size * 0.6, size)
	rock.Position = position + Vector3.new(0, size * 0.3, 0)
	rock.Anchored = true
	rock.Color = color
	rock.Material = Enum.Material.Slate
	return rock
end

-- Create zone sign
local function CreateZoneSign(zoneName: string, displayName: string, position: Vector3): Model
	local sign = Instance.new("Model")
	sign.Name = zoneName .. "_Sign"

	-- Post
	local post = Instance.new("Part")
	post.Name = "Post"
	post.Size = Vector3.new(1, 12, 1)
	post.Position = position + Vector3.new(0, 6, 0)
	post.Anchored = true
	post.BrickColor = BrickColor.new("Reddish brown")
	post.Material = Enum.Material.Wood
	post.Parent = sign

	-- Sign board
	local board = Instance.new("Part")
	board.Name = "Board"
	board.Size = Vector3.new(12, 4, 0.5)
	board.Position = position + Vector3.new(0, 13, 0)
	board.Anchored = true
	board.BrickColor = BrickColor.new("Dark orange")
	board.Material = Enum.Material.Wood
	board.Parent = sign

	-- Text on sign
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = board

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = displayName
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0
	textLabel.Parent = surfaceGui

	-- Back text
	local surfaceGuiBack = Instance.new("SurfaceGui")
	surfaceGuiBack.Face = Enum.NormalId.Back
	surfaceGuiBack.Parent = board

	local textLabelBack = Instance.new("TextLabel")
	textLabelBack.Size = UDim2.new(1, 0, 1, 0)
	textLabelBack.BackgroundTransparency = 1
	textLabelBack.Text = displayName
	textLabelBack.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabelBack.TextScaled = true
	textLabelBack.Font = Enum.Font.GothamBold
	textLabelBack.TextStrokeTransparency = 0
	textLabelBack.Parent = surfaceGuiBack

	sign.PrimaryPart = post
	return sign
end

-- Create lava pool for volcano zone
local function CreateLavaPool(position: Vector3, size: number): Part
	local lava = Instance.new("Part")
	lava.Name = "LavaPool"
	lava.Size = Vector3.new(size, 1, size)
	lava.Position = position
	lava.Anchored = true
	lava.Color = Color3.fromRGB(255, 100, 0)
	lava.Material = Enum.Material.Neon
	lava.CanCollide = false
	return lava
end

-- Build a single zone
local function BuildZone(zoneName: string, zoneData: any, worldFolder: Folder)
	local visuals = ZoneVisuals[zoneName]
	if not visuals then
		warn(`No visuals defined for zone: {zoneName}`)
		return
	end

	local spawnLocation = zoneData.SpawnLocation or Vector3.new(0, 5, 0)
	local zoneFolder = Instance.new("Folder")
	zoneFolder.Name = zoneName
	zoneFolder.Parent = worldFolder

	-- Create ground platform (100x100 studs)
	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(100, 4, 100)
	ground.Position = spawnLocation + Vector3.new(0, -2, 0)
	ground.Anchored = true
	ground.Color = visuals.GroundColor
	ground.Material = visuals.GroundMaterial
	ground.Parent = zoneFolder

	-- Create zone sign at entrance
	local signPosition = spawnLocation + Vector3.new(-40, 0, -40)
	local sign = CreateZoneSign(zoneName, zoneData.DisplayName, signPosition)
	sign.Parent = zoneFolder

	-- Add decorations based on zone type
	if zoneName == "StarterZone" then
		-- Trees around the zone
		for i = 1, 8 do
			local angle = (i / 8) * math.pi * 2
			local distance = 35
			local treePos = spawnLocation + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
			local tree = CreateTree(treePos, visuals.TreeColor)
			tree.Parent = zoneFolder
		end

		-- Some rocks
		for i = 1, 4 do
			local rockPos = spawnLocation + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
			local rock = CreateRock(rockPos, math.random(3, 6), visuals.AccentColor)
			rock.Parent = zoneFolder
		end

	elseif zoneName == "ForestZone" then
		-- Dense forest - many trees
		for i = 1, 20 do
			local treePos = spawnLocation + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
			-- Don't place too close to center
			if (treePos - spawnLocation).Magnitude > 15 then
				local tree = CreateTree(treePos, visuals.TreeColor)
				tree.Parent = zoneFolder
			end
		end

	elseif zoneName == "MountainZone" then
		-- Rocky terrain
		for i = 1, 15 do
			local rockPos = spawnLocation + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
			local rock = CreateRock(rockPos, math.random(4, 10), visuals.GroundColor)
			rock.Parent = zoneFolder
		end

		-- Create mountain peaks (tall rocks)
		for i = 1, 4 do
			local peakPos = spawnLocation + Vector3.new(math.random(-35, 35), 0, math.random(-35, 35))
			local peak = Instance.new("Part")
			peak.Name = "MountainPeak"
			peak.Size = Vector3.new(15, 30, 15)
			peak.Position = peakPos + Vector3.new(0, 15, 0)
			peak.Anchored = true
			peak.Color = visuals.GroundColor
			peak.Material = Enum.Material.Rock
			peak.Parent = zoneFolder
		end

	elseif zoneName == "VolcanoZone" then
		-- Volcanic rocks
		for i = 1, 10 do
			local rockPos = spawnLocation + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
			local rock = CreateRock(rockPos, math.random(3, 8), visuals.GroundColor)
			rock.Parent = zoneFolder
		end

		-- Lava pools
		for i = 1, 5 do
			local lavaPos = spawnLocation + Vector3.new(math.random(-35, 35), -1.5, math.random(-35, 35))
			local lava = CreateLavaPool(lavaPos, math.random(5, 12))
			lava.Parent = zoneFolder
		end

		-- Central volcano
		local volcano = Instance.new("Part")
		volcano.Name = "Volcano"
		volcano.Size = Vector3.new(30, 25, 30)
		volcano.Position = spawnLocation + Vector3.new(0, 12.5, 30)
		volcano.Anchored = true
		volcano.Color = Color3.fromRGB(60, 40, 40)
		volcano.Material = Enum.Material.Rock
		volcano.Parent = zoneFolder

		-- Volcano crater (lava)
		local crater = Instance.new("Part")
		crater.Name = "Crater"
		crater.Shape = Enum.PartType.Cylinder
		crater.Size = Vector3.new(5, 15, 15)
		crater.Position = spawnLocation + Vector3.new(0, 27, 30)
		crater.Orientation = Vector3.new(0, 0, 90)
		crater.Anchored = true
		crater.Color = Color3.fromRGB(255, 100, 0)
		crater.Material = Enum.Material.Neon
		crater.Parent = zoneFolder
	end

	print(`[WorldBuilder] Built zone: {zoneData.DisplayName}`)
end

-- Create a staircase between two heights
local function CreateStairs(startPos: Vector3, endPos: Vector3, width: number, color: Color3, parent: Instance)
	local heightDiff = endPos.Y - startPos.Y
	local horizontalDist = ((endPos - startPos) * Vector3.new(1, 0, 1)).Magnitude
	local direction = ((endPos - startPos) * Vector3.new(1, 0, 1)).Unit

	-- Step height of 0.75 studs allows characters to walk up without jumping
	local stepHeight = 0.75
	local numSteps = math.ceil(math.abs(heightDiff) / stepHeight)
	local stepDepth = horizontalDist / numSteps

	for i = 0, numSteps - 1 do
		local step = Instance.new("Part")
		step.Name = "Step_" .. i
		step.Size = Vector3.new(width, stepHeight, stepDepth + 0.5)
		step.Position = startPos + direction * (i * stepDepth + stepDepth / 2) + Vector3.new(0, i * stepHeight + stepHeight / 2, 0)
		step.Anchored = true
		step.Color = color
		step.Material = Enum.Material.Cobblestone
		step.Parent = parent
	end
end

-- Create paths between zones
local function CreatePaths(worldFolder: Folder)
	local pathsFolder = Instance.new("Folder")
	pathsFolder.Name = "Paths"
	pathsFolder.Parent = worldFolder

	-- Path from Starter to Forest (flat)
	local path1 = Instance.new("Part")
	path1.Name = "Path_Starter_Forest"
	path1.Size = Vector3.new(200, 2, 20)
	path1.Position = Vector3.new(100, 0, 0)
	path1.Anchored = true
	path1.Color = Color3.fromRGB(139, 90, 43)
	path1.Material = Enum.Material.Cobblestone
	path1.Parent = pathsFolder

	-- Stairs from Forest to Mountain (height difference: 5 to 50)
	CreateStairs(
		Vector3.new(200, 3, 0),  -- Start at forest edge
		Vector3.new(400, 48, 0), -- End at mountain
		20,
		Color3.fromRGB(100, 100, 110),
		pathsFolder
	)

	-- Path on mountain plateau
	local path2flat = Instance.new("Part")
	path2flat.Name = "Path_Mountain_Plateau"
	path2flat.Size = Vector3.new(50, 2, 20)
	path2flat.Position = Vector3.new(425, 48, 0)
	path2flat.Anchored = true
	path2flat.Color = Color3.fromRGB(100, 100, 110)
	path2flat.Material = Enum.Material.Cobblestone
	path2flat.Parent = pathsFolder

	-- Path from Mountain to Volcano (going down and to the side)
	-- First, stairs going down
	CreateStairs(
		Vector3.new(450, 48, 0),
		Vector3.new(500, 3, 0),
		20,
		Color3.fromRGB(80, 70, 70),
		pathsFolder
	)

	-- Then flat path to volcano
	local path3 = Instance.new("Part")
	path3.Name = "Path_To_Volcano"
	path3.Size = Vector3.new(20, 2, 200)
	path3.Position = Vector3.new(550, 3, 100)
	path3.Anchored = true
	path3.Color = Color3.fromRGB(60, 50, 50)
	path3.Material = Enum.Material.Cobblestone
	path3.Parent = pathsFolder

	-- Final stretch to volcano zone
	local path4 = Instance.new("Part")
	path4.Name = "Path_Volcano_Final"
	path4.Size = Vector3.new(100, 2, 20)
	path4.Position = Vector3.new(550, 3, 200)
	path4.Anchored = true
	path4.Color = Color3.fromRGB(60, 50, 50)
	path4.Material = Enum.Material.Cobblestone
	path4.Parent = pathsFolder

	print("[WorldBuilder] Created paths between zones")
end

-- Create spawn point
local function CreateSpawnPoint(worldFolder: Folder)
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation"
	spawnLocation.Size = Vector3.new(8, 1, 8)
	spawnLocation.Position = Vector3.new(0, 3, -30)
	spawnLocation.Anchored = true
	spawnLocation.CanCollide = false
	spawnLocation.Transparency = 0.5
	spawnLocation.BrickColor = BrickColor.new("Bright green")
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Parent = worldFolder

	print("[WorldBuilder] Created spawn point")
end

-- Initialize world
function WorldBuilder.Initialize()
	-- Create world folder
	local worldFolder = Workspace:FindFirstChild("World")
	if not worldFolder then
		worldFolder = Instance.new("Folder")
		worldFolder.Name = "World"
		worldFolder.Parent = Workspace
	end

	-- Build each zone
	for zoneName, zoneData in ZoneConfig do
		BuildZone(zoneName, zoneData, worldFolder)
	end

	-- Create paths
	CreatePaths(worldFolder)

	-- Create spawn point
	CreateSpawnPoint(worldFolder)

	print("[WorldBuilder] World built successfully!")
end

return WorldBuilder
