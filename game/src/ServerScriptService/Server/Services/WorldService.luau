--[[
	WorldService — construye el mapa al iniciar el servidor.

	Estructura (vista desde arriba, el camino avanza hacia +Z):

	  [Base segura: Z < Config.HUB_MAX_Z]  aparición, Taller, Tienda, Museo...
	  [Zona 1: Barrio Humilde]             4 casas, sin puerta de velocidad
	  [Puerta de velocidad 18] [Zona 2]    ...
	  ...
	  [Puerta de velocidad 34] [Zona 5: Colina de los Millonarios]

	Las puertas de velocidad son sólidas en el servidor; cada cliente las vuelve
	atravesables solo para su personaje si tiene la velocidad (ver Ui.luau).
	El servidor además rechaza robos en zonas sin la velocidad necesaria.

	El mapa es funcional y provisional: la Cuenta B puede sustituir lo visual
	conservando etiquetas (CollectionService) y atributos.
	Etiquetas: "Station" (StationId), "SpeedGate" (MinSpeed, ZoneIndex), "GuideHouse".
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)

local WorldService = {}

WorldService.Folder = nil
WorldService.Stations = {} -- [stationId] = BasePart

-- Medidas del mapa
local HALF_WIDTH = 110 -- el mapa va de X = -110 a X = 110
local ZONE_START = 30 -- Z donde empieza la zona 1
local ZONE_LENGTH = 140 -- distancia entre el inicio de dos zonas
local ZONE_DEPTH = 130 -- largo útil de cada zona
local MAP_END = ZONE_START + #GameData.Zones * ZONE_LENGTH
local MAP_BACK = -100

local STATIONS = {
	{
		id = "workshop",
		title = "Taller",
		action = "Fabricar relojes",
		position = Vector3.new(-35, 0, -25),
		color = Color3.fromRGB(196, 134, 72),
	},
	{
		id = "shop",
		title = "Tienda",
		action = "Vender y mejorar",
		position = Vector3.new(35, 0, -25),
		color = Color3.fromRGB(74, 160, 96),
	},
	{
		id = "museum",
		title = "Museo",
		action = "Exhibir relojes",
		position = Vector3.new(0, 0, -65),
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
WorldService.makePart = makePart

local function makeSign(parent, title, subtitle, height, maxDistance)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Cartel"
	billboard.Size = UDim2.fromOffset(240, 70)
	billboard.StudsOffset = Vector3.new(0, height, 0)
	billboard.MaxDistance = maxDistance or 140
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
	return billboard
end
WorldService.makeSign = makeSign

-- Crea una estación con su menú. Otros servicios (jefe, mascotas) también la usan.
function WorldService.buildStation(info)
	local model = Instance.new("Model")
	model.Name = info.title
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	local base = makePart({
		Name = "Mostrador",
		Size = Vector3.new(14, 5, 8),
		Position = info.position + Vector3.new(0, 2.5, 0),
		Color = info.color,
		Material = Enum.Material.WoodPlanks,
	})
	base:SetAttribute("StationId", info.id)
	CollectionService:AddTag(base, "Station")
	base.Parent = model

	makePart({
		Name = "Techo",
		Size = Vector3.new(18, 1, 12),
		Position = info.position + Vector3.new(0, 11, 0),
		Color = info.color:Lerp(Color3.new(0, 0, 0), 0.3),
		Material = Enum.Material.SmoothPlastic,
	}).Parent = model

	for _, offset in { Vector3.new(-8, 0, -5), Vector3.new(8, 0, -5), Vector3.new(-8, 0, 5), Vector3.new(8, 0, 5) } do
		makePart({
			Name = "Columna",
			Size = Vector3.new(1, 10.5, 1),
			Position = info.position + offset + Vector3.new(0, 5.25, 0),
			Color = Color3.fromRGB(230, 225, 210),
			Material = Enum.Material.SmoothPlastic,
		}).Parent = model
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
	model.Parent = WorldService.Folder
	WorldService.Stations[info.id] = base
	return base
end

-- Inicio y fin (en Z) de una zona.
function WorldService.zoneBounds(zoneIndex)
	local startZ = ZONE_START + (zoneIndex - 1) * ZONE_LENGTH
	return startZ, startZ + ZONE_DEPTH
end

function WorldService.isInHub(position)
	return position.Z < Config.HUB_MAX_Z
end

local function buildZone(folder, zoneIndex, zone)
	local startZ, endZ = WorldService.zoneBounds(zoneIndex)
	local model = Instance.new("Model")
	model.Name = string.format("Zona%d_%s", zoneIndex, zone.id)

	makePart({
		Name = "Terreno",
		Size = Vector3.new(HALF_WIDTH * 2, 0.2, endZ - startZ),
		Position = Vector3.new(0, 0.1, (startZ + endZ) / 2),
		Color = zone.color:Lerp(Color3.fromRGB(106, 168, 79), 0.55),
		Material = Enum.Material.Grass,
		CanCollide = false,
	}).Parent = model

	-- Cartel de la zona a la entrada del camino
	local signPost = makePart({
		Name = "CartelZona",
		Size = Vector3.new(1, 8, 1),
		Position = Vector3.new(14, 4, startZ + 4),
		Color = Color3.fromRGB(90, 70, 50),
		Material = Enum.Material.Wood,
	})
	makeSign(
		signPost,
		zone.name,
		string.format("Zona %d · velocidad mínima %d", zoneIndex, zone.minSpeed),
		6,
		220
	)
	signPost.Parent = model

	-- Puerta de velocidad (la zona 1 no tiene)
	if zone.minSpeed > 0 then
		local gate = Instance.new("Model")
		gate.Name = "PuertaDeVelocidad"
		gate.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		local barrier = makePart({
			Name = "Barrera",
			Size = Vector3.new(HALF_WIDTH * 2, 40, 2),
			Position = Vector3.new(0, 20, startZ - 5),
			Color = Color3.fromRGB(230, 70, 70),
			Material = Enum.Material.ForceField,
			Transparency = 0.3,
			CanCollide = true,
		})
		barrier:SetAttribute("MinSpeed", zone.minSpeed)
		barrier:SetAttribute("ZoneIndex", zoneIndex)
		CollectionService:AddTag(barrier, "SpeedGate")
		barrier.Parent = gate
		local label = makePart({
			Name = "Rotulo",
			Size = Vector3.new(1, 1, 1),
			Position = Vector3.new(0, 8, startZ - 5),
			Transparency = 1,
			CanCollide = false,
		})
		makeSign(label, string.format("Velocidad %d", zone.minSpeed), "Necesaria para entrar a " .. zone.name, 2, 220)
		label.Parent = gate
		gate.Parent = model
	end

	model.Parent = folder
	return model
end

function WorldService.init()
	local folder = Instance.new("Folder")
	folder.Name = "Mapa"
	WorldService.Folder = folder

	-- Suelo general (0.1 sobre una Baseplate estándar para evitar parpadeo)
	makePart({
		Name = "Suelo",
		Size = Vector3.new(HALF_WIDTH * 2 + 20, 2, MAP_END - MAP_BACK + 20),
		Position = Vector3.new(0, -0.9, (MAP_END + MAP_BACK) / 2),
		Color = Color3.fromRGB(106, 168, 79),
		Material = Enum.Material.Grass,
	}).Parent = folder

	-- Base segura
	makePart({
		Name = "Base",
		Size = Vector3.new(HALF_WIDTH * 2, 0.2, Config.HUB_MAX_Z - MAP_BACK),
		Position = Vector3.new(0, 0.1, (Config.HUB_MAX_Z + MAP_BACK) / 2),
		Color = Color3.fromRGB(205, 190, 160),
		Material = Enum.Material.Pavement,
		CanCollide = false,
	}).Parent = folder
	local baseSign = makePart({
		Name = "CartelBase",
		Size = Vector3.new(1, 1, 1),
		Position = Vector3.new(0, 6, Config.HUB_MAX_Z - 2),
		Transparency = 1,
		CanCollide = false,
	})
	makeSign(baseSign, "BASE SEGURA", "Aquí el botín se guarda y nadie te persigue", 2, 200)
	baseSign.Parent = folder

	-- Camino central
	makePart({
		Name = "Camino",
		Size = Vector3.new(22, 0.2, MAP_END - Config.HUB_MAX_Z),
		Position = Vector3.new(0, 0.25, (MAP_END + Config.HUB_MAX_Z) / 2),
		Color = Color3.fromRGB(70, 70, 75),
		Material = Enum.Material.Asphalt,
		CanCollide = false,
	}).Parent = folder

	-- Muros invisibles alrededor del mapa
	for _, wall in {
		{ Vector3.new(2, 80, MAP_END - MAP_BACK + 20), Vector3.new(-HALF_WIDTH - 1, 40, (MAP_END + MAP_BACK) / 2) },
		{ Vector3.new(2, 80, MAP_END - MAP_BACK + 20), Vector3.new(HALF_WIDTH + 1, 40, (MAP_END + MAP_BACK) / 2) },
		{ Vector3.new(HALF_WIDTH * 2 + 4, 80, 2), Vector3.new(0, 40, MAP_BACK - 1) },
		{ Vector3.new(HALF_WIDTH * 2 + 4, 80, 2), Vector3.new(0, 40, MAP_END + 1) },
	} do
		makePart({
			Name = "Limite",
			Size = wall[1],
			Position = wall[2],
			Transparency = 1,
		}).Parent = folder
	end

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

	local zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "Zonas"
	zonesFolder.Parent = folder
	WorldService.ZonesFolder = zonesFolder
	for zoneIndex, zone in GameData.Zones do
		buildZone(zonesFolder, zoneIndex, zone)
	end

	folder.Parent = Workspace

	for _, info in STATIONS do
		WorldService.buildStation(info)
	end
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
