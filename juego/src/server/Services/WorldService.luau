--[[
	WorldService — construye el mapa base al iniciar el servidor.

	El mapa se genera con código para que todo el proyecto viva en texto (Git).
	Es un mapa funcional y provisional: la Cuenta B puede reemplazar las piezas
	visuales por modelos definitivos mientras conserve los nombres de las
	estaciones y sus ProximityPrompt.

	Estaciones:
	  workshop → Taller (fabricar relojes)
	  shop     → Tienda (vender relojes y comprar mejoras)
	  museum   → Museo (exhibir relojes para ingreso pasivo)
]]

local Workspace = game:GetService("Workspace")

local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)

local WorldService = {}

WorldService.Folder = nil
WorldService.Stations = {} -- [stationId] = BasePart
-- Rectángulo donde aparecen las cajas de piezas (en el plano XZ)
WorldService.CollectArea = { minX = -90, maxX = 90, minZ = 20, maxZ = 110 }

local STATIONS = {
	{
		id = "workshop",
		title = "Taller",
		action = "Fabricar relojes",
		position = Vector3.new(-45, 0, -30),
		color = Color3.fromRGB(196, 134, 72),
	},
	{
		id = "shop",
		title = "Tienda",
		action = "Vender y mejorar",
		position = Vector3.new(45, 0, -30),
		color = Color3.fromRGB(74, 160, 96),
	},
	{
		id = "museum",
		title = "Museo",
		action = "Exhibir relojes",
		position = Vector3.new(0, 0, -70),
		color = Color3.fromRGB(92, 120, 200),
	},
}

local function makePart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		part[key] = value
	end
	return part
end

local function makeSign(parent, title, subtitle, height)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Cartel"
	billboard.Size = UDim2.fromOffset(220, 70)
	billboard.StudsOffset = Vector3.new(0, height, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 140
	billboard.Parent = parent

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextStrokeTransparency = 0.4
	titleLabel.Text = title
	titleLabel.Parent = billboard

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.fromScale(1, 0.4)
	subtitleLabel.Position = UDim2.fromScale(0, 0.6)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
	subtitleLabel.TextStrokeTransparency = 0.5
	subtitleLabel.Text = subtitle
	subtitleLabel.Parent = billboard
end

local function buildStation(folder, info)
	local model = Instance.new("Model")
	model.Name = info.title

	local base = makePart({
		Name = "Mostrador",
		Size = Vector3.new(14, 5, 8),
		Position = info.position + Vector3.new(0, 2.5, 0),
		Color = info.color,
		Material = Enum.Material.WoodPlanks,
	})
	base:SetAttribute("StationId", info.id)
	base.Parent = model

	local roof = makePart({
		Name = "Techo",
		Size = Vector3.new(18, 1, 12),
		Position = info.position + Vector3.new(0, 11, 0),
		Color = info.color:Lerp(Color3.new(0, 0, 0), 0.3),
		Material = Enum.Material.SmoothPlastic,
	})
	roof.Parent = model

	for _, offset in { Vector3.new(-8, 0, -5), Vector3.new(8, 0, -5), Vector3.new(-8, 0, 5), Vector3.new(8, 0, 5) } do
		local pillar = makePart({
			Name = "Columna",
			Size = Vector3.new(1, 10.5, 1),
			Position = info.position + offset + Vector3.new(0, 5.25, 0),
			Color = Color3.fromRGB(230, 225, 210),
			Material = Enum.Material.SmoothPlastic,
		})
		pillar.Parent = model
	end

	makeSign(base, info.title, info.action, 10)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Abrir"
	prompt.ActionText = info.action
	prompt.ObjectText = info.title
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = base

	prompt.Triggered:Connect(function(player)
		if DataService.get(player) then
			Net.OpenPanel:FireClient(player, info.id)
		else
			Net.notify(player, "Tus datos aún se están cargando…", "info")
		end
	end)

	model.PrimaryPart = base
	model.Parent = folder
	WorldService.Stations[info.id] = base
end

function WorldService.init()
	local folder = Instance.new("Folder")
	folder.Name = "Mapa"

	-- Si la place ya trae una Baseplate, se deja como está y se construye encima.
	makePart({
		Name = "Suelo",
		Size = Vector3.new(320, 2, 320),
		Position = Vector3.new(0, -0.9, 0), -- 0.1 sobre una Baseplate estándar para evitar parpadeo
		Color = Color3.fromRGB(106, 168, 79),
		Material = Enum.Material.Grass,
	}).Parent = folder

	local area = WorldService.CollectArea
	makePart({
		Name = "ZonaDeRecoleccion",
		Size = Vector3.new(area.maxX - area.minX + 10, 0.2, area.maxZ - area.minZ + 10),
		Position = Vector3.new((area.minX + area.maxX) / 2, 0.2, (area.minZ + area.maxZ) / 2),
		Color = Color3.fromRGB(181, 155, 110),
		Material = Enum.Material.Sand,
		CanCollide = false,
	}).Parent = folder

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Aparicion"
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 0.5, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(240, 200, 80)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Parent = folder

	for _, info in STATIONS do
		buildStation(folder, info)
	end

	folder.Parent = Workspace
	WorldService.Folder = folder
end

-- ¿Está el personaje del jugador cerca de la estación?
function WorldService.isNearStation(player, stationId, maxDistance)
	local station = WorldService.Stations[stationId]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not station or not root then
		return false
	end
	return (root.Position - station.Position).Magnitude <= maxDistance
end

return WorldService
