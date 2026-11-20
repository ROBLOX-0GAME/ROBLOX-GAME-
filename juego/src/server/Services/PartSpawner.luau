--[[
	PartSpawner — cajas de piezas en la zona de recolección.

	Cada caja es compartida por todos los jugadores del servidor. Al recogerla,
	el servidor elige la pieza usando la suerte de ESE jugador, la añade a su
	mochila y la caja reaparece tras Config.PART_RESPAWN_SECONDS.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)

local PartSpawner = {}

local random = Random.new()
local cratesFolder = nil

local function spawnCrate(position)
	local crate = Instance.new("Part")
	crate.Name = "CajaDePiezas"
	crate.Anchored = true
	crate.CanCollide = false
	crate.Size = Vector3.new(2, 2, 2)
	crate.Position = position + Vector3.new(0, 1.2, 0)
	crate.Orientation = Vector3.new(0, random:NextNumber(0, 360), 0)
	crate.Color = Color3.fromRGB(150, 110, 60)
	crate.Material = Enum.Material.WoodPlanks
	crate.TopSurface = Enum.SurfaceType.Smooth
	crate.BottomSurface = Enum.SurfaceType.Smooth

	local light = Instance.new("PointLight")
	light.Range = 6
	light.Brightness = 0.6
	light.Color = Color3.fromRGB(255, 220, 140)
	light.Parent = crate

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Recoger"
	prompt.ObjectText = "Caja de piezas"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = crate

	local taken = false
	prompt.Triggered:Connect(function(player)
		if taken then
			return
		end
		local data = DataService.get(player)
		if not data then
			return
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - crate.Position).Magnitude > Config.INTERACT_DISTANCE then
			return
		end

		local partId = PlayerLogic.rollPart(PlayerLogic.luckMultiplier(data), random:NextNumber())
		local ok, message = PlayerLogic.addPart(data, partId)
		if not ok then
			Net.notify(player, message, "error")
			return
		end

		taken = true
		crate:Destroy()
		Net.notify(player, message, "ok")
		DataService.replicate(player)
		task.delay(Config.PART_RESPAWN_SECONDS, spawnCrate, position)
	end)

	crate.Parent = cratesFolder
end

local function randomPosition()
	local area = WorldService.CollectArea
	return Vector3.new(random:NextNumber(area.minX, area.maxX), 0, random:NextNumber(area.minZ, area.maxZ))
end

function PartSpawner.init()
	cratesFolder = Instance.new("Folder")
	cratesFolder.Name = "CajasDePiezas"
	cratesFolder.Parent = WorldService.Folder
	for _ = 1, Config.PART_SPAWN_COUNT do
		spawnCrate(randomPosition())
	end
end

return PartSpawner
