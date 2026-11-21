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
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local AssetLibrary = require(Shared.AssetLibrary)

local WorldService = {}

WorldService.Folder = nil
WorldService.Stations = {} -- [stationId] = BasePart

-- Medidas del mapa
local HALF_WIDTH = 130 -- el mapa va de X = -130 a X = 130 (DEV-010: cabe la media luna)
local ZONE_START = 30 -- Z donde empieza la zona 1
-- DEC-025: cada zona es Config.ZONE_DEPTH_GROWTH veces más larga que la anterior,
-- con Config.ZONE_GAP entre zonas (ahí va la puerta de velocidad).
local ZONE_BOUNDS = {} -- [zona] = { inicio, fin } en Z
do
	local z = ZONE_START
	for index in GameData.Zones do
		local depth = math.floor(Config.ZONE_BASE_DEPTH * Config.ZONE_DEPTH_GROWTH ^ (index - 1))
		ZONE_BOUNDS[index] = { z, z + depth }
		z += depth + Config.ZONE_GAP
	end
end
local MAP_END = ZONE_BOUNDS[#GameData.Zones][2] + 20
local MAP_BACK = -205 -- fondo de la base: detrás de los plots en media luna (DEV-010)
local MAX_PART_LENGTH = 2000 -- Roblox no permite piezas de más de 2048 studs

-- Muro frontal de la base (DEV-010): separa la base de la zona de carrera,
-- con una abertura central para salir a correr. Las estaciones compartidas
-- van pegadas a su cara interior.
local FRONT_WALL_Z = 14 -- centro del muro (la base segura llega hasta Config.HUB_MAX_Z)
local FRONT_OPENING = 14 -- media anchura de la abertura central
local STATION_Z = FRONT_WALL_Z - 6 -- estaciones pegadas al muro, del lado de la base
WorldService.WallSlots = {
	shop = Vector3.new(-80, 0, STATION_Z),
	robux = Vector3.new(-40, 0, STATION_Z),
	pets = Vector3.new(40, 0, STATION_Z),
	boss = Vector3.new(80, 0, STATION_Z),
	carry = Vector3.new(115, 0, STATION_Z), -- Puesto de Carga (DEV-013)
}
-- Centro de la plaza: el arco de plots mira hacia aquí (PlotService)
WorldService.PlazaCenter = Vector3.new(0, 0, -70)

-- Estaciones compartidas creadas aquí. El Jefe (BossService) y el Criadero
-- (PetService) usan también WallSlots. El Taller y el Museo están en cada plot.
local STATIONS = {
	{
		id = "shop",
		title = "Tienda",
		action = "Vender y mejorar",
		position = WorldService.WallSlots.shop,
		color = Color3.fromRGB(74, 160, 96),
	},
	{
		id = "robux",
		title = "Tienda Robux",
		action = "Pases y productos",
		position = WorldService.WallSlots.robux,
		color = Color3.fromRGB(0, 170, 90),
	},
	{
		id = "carry",
		title = "Puesto de Carga",
		action = "Más espacio por viaje",
		position = WorldService.WallSlots.carry,
		color = Color3.fromRGB(200, 160, 60),
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

-- Pieza larga a lo largo de Z, partida en tramos de MAX_PART_LENGTH (DEC-025).
-- props.Size da el ancho (X) y el alto (Y); fromZ/toZ el largo.
local function makeLongPart(parent, props, fromZ, toZ)
	local size = props.Size
	local z = fromZ
	while z < toZ do
		local length = math.min(MAX_PART_LENGTH, toZ - z)
		local chunk = table.clone(props)
		chunk.Size = Vector3.new(size.X, size.Y, length)
		chunk.Position = Vector3.new(props.Position.X, props.Position.Y, z + length / 2)
		makePart(chunk).Parent = parent
		z += length
	end
end
WorldService.makeLongPart = makeLongPart

-- Colores de los carteles (ART-015, propuesta DEC-024: marfil sobre contorno carbón)
local SIGN_TEXT = Color3.fromRGB(242, 240, 234)
local SIGN_SUBTEXT = Color3.fromRGB(242, 193, 78)
local SIGN_STROKE = Color3.fromRGB(30, 31, 38)

-- iconId (opcional, ART-015): imagen a la izquierda del título (0 o nil = sin icono).
local function makeSign(parent, title, subtitle, height, maxDistance, iconId)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Cartel"
	billboard.Size = UDim2.fromOffset(240, 70)
	billboard.StudsOffset = Vector3.new(0, height, 0)
	billboard.MaxDistance = maxDistance or 140
	billboard.LightInfluence = 0 -- se lee igual de día, de noche y con sombras
	billboard.Parent = parent

	local textLeft = 0
	if iconId and iconId ~= 0 then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icono"
		icon.BackgroundTransparency = 1
		icon.Image = "rbxassetid://" .. iconId
		icon.Size = UDim2.fromScale(0.25, 0.85)
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.Parent = billboard
		textLeft = 0.27
	end

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1 - textLeft, 0.6)
	titleLabel.Position = UDim2.fromScale(textLeft, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = SIGN_TEXT
	titleLabel.TextStrokeColor3 = SIGN_STROKE
	titleLabel.TextStrokeTransparency = 0.2
	titleLabel.Text = title
	titleLabel.Parent = billboard

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.fromScale(1 - textLeft, 0.4)
	subtitleLabel.Position = UDim2.fromScale(textLeft, 0.6)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.GothamMedium
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = SIGN_SUBTEXT
	subtitleLabel.TextStrokeColor3 = SIGN_STROKE
	subtitleLabel.TextStrokeTransparency = 0.3
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

	makeSign(base, info.title, info.action, 10, 70, Config.STATION_ICON_IDS[info.id]) -- ART-015: con icono y a menos distancia

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
	-- Arte (DEV-014)
	AssetLibrary.dress(model, AssetLibrary.STATION_ASSETS[info.id])
	return base
end

-- Inicio y fin (en Z) de una zona.
function WorldService.zoneBounds(zoneIndex)
	local bounds = ZONE_BOUNDS[zoneIndex]
	return bounds[1], bounds[2]
end

-- Zona en la que está una posición (nil en la base o fuera de las zonas).
function WorldService.zoneAt(position)
	for index, bounds in ZONE_BOUNDS do
		if position.Z >= bounds[1] - Config.ZONE_GAP and position.Z <= bounds[2] then
			return index
		end
	end
	return nil
end

function WorldService.isInHub(position)
	return position.Z < Config.HUB_MAX_Z
end

local function buildZone(folder, zoneIndex, zone)
	local startZ, endZ = WorldService.zoneBounds(zoneIndex)
	local model = Instance.new("Model")
	model.Name = string.format("Zona%d_%s", zoneIndex, zone.id)

	makeLongPart(model, {
		Name = "Terreno",
		Size = Vector3.new(HALF_WIDTH * 2, 0.2, 1),
		Position = Vector3.new(0, 0.1, 0),
		Color = zone.color:Lerp(Color3.fromRGB(106, 168, 79), 0.55),
		Material = Enum.Material.Grass,
		CanCollide = false,
	}, startZ, endZ)

	-- Cartel de la zona a la entrada del camino
	local signPost = makePart({
		Name = "CartelZona",
		Size = Vector3.new(1, 8, 1),
		Position = Vector3.new(14, 4, startZ + 4),
		Color = Color3.fromRGB(90, 70, 50),
		Material = Enum.Material.Wood,
	})
	-- ART-015: la zona 1 empieza justo en la salida, cuyo cartel ya lo indica; sin rótulo
	-- aquí no se superponen los dos. Las demás, a 120 studs (antes 220).
	if zoneIndex > 1 then
		makeSign(
			signPost,
			zone.name,
			string.format("Zona %d · velocidad %s", zoneIndex, PlayerLogic.formatBig(zone.minSpeed)),
			6,
			120
		)
	end
	signPost.Parent = model

	-- Puerta de velocidad (DEC-025: todas las zonas tienen; la 1 pide 100)
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
		-- Arte (DEV-014): postes en los extremos de la barrera
		for _, side in { -1, 1 } do
			AssetLibrary.place("mdl_puerta_velocidad_poste", Vector3.new(side * (HALF_WIDTH - 2), 0, startZ - 5), nil, gate)
		end
		local label = makePart({
			Name = "Rotulo",
			Size = Vector3.new(1, 1, 1),
			Position = Vector3.new(0, 8, startZ - 5),
			Transparency = 1,
			CanCollide = false,
		})
		makeSign(label, "Velocidad " .. PlayerLogic.formatBig(zone.minSpeed), "Necesaria para entrar a " .. zone.name, 2, 120)
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
	makeLongPart(folder, {
		Name = "Suelo",
		Size = Vector3.new(HALF_WIDTH * 2 + 20, 2, 1),
		Position = Vector3.new(0, -0.9, 0),
		Color = Color3.fromRGB(106, 168, 79),
		Material = Enum.Material.Grass,
	}, MAP_BACK - 10, MAP_END + 10)

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
		-- ART-015: a un lado de la plaza para no tapar la torre de reloj ni la salida
		Position = Vector3.new(-18, 5, WorldService.PlazaCenter.Z + 25),
		Transparency = 1,
		CanCollide = false,
	})
	makeSign(baseSign, "BASE SEGURA", "Aquí el botín se guarda y nadie te persigue", 2, 80)
	baseSign.Parent = folder

	-- Camino central
	makeLongPart(folder, {
		Name = "Camino",
		Size = Vector3.new(22, 0.2, 1),
		Position = Vector3.new(0, 0.25, 0),
		Color = Color3.fromRGB(70, 70, 75),
		Material = Enum.Material.Asphalt,
		CanCollide = false,
	}, Config.HUB_MAX_Z, MAP_END)

	-- Muro frontal con abertura para salir a correr
	local wallLength = HALF_WIDTH - FRONT_OPENING
	for _, side in { -1, 1 } do
		local wallPart = makePart({
			Name = "MuroFrontal",
			Size = Vector3.new(wallLength, 18, 2),
			Position = Vector3.new(side * (FRONT_OPENING + wallLength / 2), 9, FRONT_WALL_Z),
			Color = Color3.fromRGB(150, 140, 125),
			Material = Enum.Material.Brick,
		})
		wallPart.Parent = folder
		AssetLibrary.dress(wallPart, "mdl_muro_frontal")
	end
	-- Arco de la salida (solo visual, si existe el asset)
	local exitArch = AssetLibrary.place("mdl_cartel_salida", Vector3.new(0, 0, FRONT_WALL_Z), Vector3.new(0, 0, -1), folder)
	-- ART-015: con el arco puesto, el rótulo va por encima de él (antes se mezclaba con el modelo)
	local exitHeight = 14
	if exitArch then
		local _, archSize = exitArch:GetBoundingBox()
		exitHeight = archSize.Y + 1
	end
	local exitSign = makePart({
		Name = "CartelSalida",
		Size = Vector3.new(1, 1, 1),
		Position = Vector3.new(0, exitHeight, FRONT_WALL_Z),
		Transparency = 1,
		CanCollide = false,
	})
	makeSign(exitSign, "SALIDA", "¡A correr! Las zonas ricas están adelante", 2, 120)
	exitSign.Parent = folder

	-- Muros invisibles alrededor del mapa
	for _, side in { -1, 1 } do
		makeLongPart(folder, {
			Name = "Limite",
			Size = Vector3.new(2, 80, 1),
			Position = Vector3.new(side * (HALF_WIDTH + 1), 40, 0),
			Transparency = 1,
		}, MAP_BACK - 10, MAP_END + 10)
	end
	for _, wall in {
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
	spawn.Position = WorldService.PlazaCenter + Vector3.new(0, 0.5, 40) -- plaza, frente a la salida
	WorldService.SpawnPosition = spawn.Position -- aquí empieza la historia (DEV-011)
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

	WorldService.placeDecor(folder)
	folder.Parent = Workspace

	for _, info in STATIONS do
		WorldService.buildStation(info)
	end
end

-- Identidad de cada zona (ART-015, propuesta DEC-024). Cada entrada es una lista de
-- alternativas: se usa el primer asset que exista, y el último es el genérico de siempre.
local ZONE_STYLE = {
	{ -- 1 Barrio Humilde
		plants = { { "mdl_arbol" }, { "mdl_arbusto" }, { "mdl_arbol" }, { "mdl_roca" } },
		details = { "mdl_z1_tendedero", "mdl_caja_madera" },
		fence = { "mdl_valla" },
	},
	{ -- 2 Barrio Obrero
		plants = { { "mdl_z2_alamo", "mdl_arbol" }, { "mdl_roca" }, { "mdl_z2_alamo", "mdl_arbol" }, { "mdl_arbusto" } },
		details = { "mdl_z2_barriles", "mdl_caja_madera" },
		fence = { "mdl_valla" },
	},
	{ -- 3 Zona Residencial
		plants = { { "mdl_z3_arbol_redondo", "mdl_arbol" }, { "mdl_arbusto" } },
		details = { "mdl_z3_buzon" },
		fence = { "mdl_z3_seto", "mdl_valla" },
	},
	{ -- 4 Mansiones
		plants = { { "mdl_z4_cipres", "mdl_arbol" }, { "mdl_z4_topiario", "mdl_arbusto" } },
		details = { "mdl_z4_topiario" },
		landmark = "mdl_z4_fuente",
		fence = { "mdl_z3_seto", "mdl_valla" },
	},
	{ -- 5 Colina de los Millonarios
		plants = { { "mdl_z5_palmera", "mdl_arbol" }, { "mdl_z4_topiario", "mdl_arbusto" } },
		details = { "mdl_z5_farol_dorado" },
		landmark = "mdl_z5_estatua_reloj",
		fence = { "mdl_z3_seto", "mdl_valla" },
	},
}

-- Zona a la que pertenece una coordenada Z del camino (1 si está antes de la primera).
-- DEC-025: las zonas tienen largos distintos; las que no tienen estilo propio usan el de la 5.
local function zoneAt(z)
	local index = WorldService.zoneAt(Vector3.new(0, 0, z)) or 1
	return math.min(index, #ZONE_STYLE)
end

-- Coloca el primer asset disponible de la lista; si no hay ninguno, no coloca nada.
local function placeAny(names, position, facing, parent)
	for _, name in names do
		if AssetLibrary.find(name) then
			return AssetLibrary.place(name, position, facing, parent)
		end
	end
	return nil
end

-- Decoración (DEV-014): solo aparece si los assets existen; no afecta al juego.
function WorldService.placeDecor(folder)
	local decor = Instance.new("Folder")
	decor.Name = "Decoracion"
	-- Farolas a ambos lados del camino (DEC-025: más separadas; el mapa mide ~13.000 studs)
	for z = ZONE_START, MAP_END - 20, 60 do
		for _, side in { -1, 1 } do
			AssetLibrary.place("mdl_farola", Vector3.new(side * 14, 0, z), Vector3.new(-side, 0, 0), decor)
		end
	end
	-- Vegetación junto a los muros laterales, propia de cada zona (ART-015, propuesta DEC-024)
	local index = 0
	for z = ZONE_START + 10, MAP_END - 10, 40 do
		local style = ZONE_STYLE[zoneAt(z)] or ZONE_STYLE[1]
		for _, side in { -1, 1 } do
			index += 1
			placeAny(style.plants[index % #style.plants + 1], Vector3.new(side * (HALF_WIDTH - 8), 0, z), nil, decor)
		end
	end
	-- Detalles de cada zona, entre las casas y la vegetación (x = ±100)
	for zoneIndex in GameData.Zones do
		local style = ZONE_STYLE[math.min(zoneIndex, #ZONE_STYLE)]
		local startZ = WorldService.zoneBounds(zoneIndex)
		if style and style.details then
			for i, z in { startZ + 25, startZ + 70, startZ + 115 } do
				local side = (i % 2 == 0) and 1 or -1
				AssetLibrary.place(style.details[(i - 1) % #style.details + 1], Vector3.new(side * 100, 0, z), Vector3.new(-side, 0, 0), decor)
			end
		end
		if style and style.landmark then -- una pieza destacada por zona (fuente, estatua)
			AssetLibrary.place(style.landmark, Vector3.new(-100, 0, startZ + 48), Vector3.new(1, 0, 0), decor)
		end
	end
	-- Torre de reloj: punto focal de la plaza (ART-015)
	-- Mira hacia la aparición y la salida (+Z). Es sólida para que no se atraviese; está
	-- en el centro de la plaza, lejos de la aparición (40 studs) y de los plots (95).
	local tower = AssetLibrary.place("mdl_torre_reloj", WorldService.PlazaCenter, Vector3.new(0, 0, 1), decor)
	if tower then
		for _, part in tower:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
	-- Bancas en la plaza
	local plaza = WorldService.PlazaCenter
	for _, offset in { Vector3.new(-12, 0, 20), Vector3.new(12, 0, 20), Vector3.new(-12, 0, 55), Vector3.new(12, 0, 55) } do
		AssetLibrary.place("mdl_banca", plaza + offset, Vector3.new(-math.sign(offset.X), 0, 0), decor)
	end
	-- Cajas junto al Puesto de Carga
	local carry = WorldService.WallSlots.carry
	for _, offset in { Vector3.new(-10, 0, -2), Vector3.new(-10, 0, -5), Vector3.new(10, 0, -3) } do
		AssetLibrary.place("mdl_caja_madera", carry + offset, nil, decor)
	end
	-- Cartel de cada zona y vallas en sus bordes
	for zoneIndex in GameData.Zones do
		local startZ = WorldService.zoneBounds(zoneIndex)
		AssetLibrary.place("mdl_cartel_zona", Vector3.new(-14, 0, startZ + 4), Vector3.new(0, 0, -1), decor)
		local fence = ZONE_STYLE[math.min(zoneIndex, #ZONE_STYLE)].fence
		for x = -HALF_WIDTH + 8, HALF_WIDTH - 8, 8 do
			if math.abs(x) > 14 then
				placeAny(fence, Vector3.new(x, 0, startZ + 0.5), Vector3.new(0, 0, -1), decor)
			end
		end
	end
	decor.Parent = folder
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
