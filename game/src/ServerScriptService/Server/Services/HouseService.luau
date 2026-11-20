--[[
	HouseService — casas, robo de piezas y persecución (DEV-003).

	Flujo:
	  1. Entras a una casa y mantienes el botón sobre una pieza → va a tu botín
	     (lo llevas encima, todavía no es tuyo).
	  2. Al SALIR de la casa con botín, el dueño sale tras de ti.
	  3. Si llegas a la base segura, el botín se guarda en tu mochila.
	     Si el dueño te atrapa (o caes), pierdes todo el botín que llevabas.
	  4. El dueño se rinde si llegas a la base, si te alejas demasiado o tras
	     Config.CHASE_MAX_SECONDS.

	Cada zona tiene 4 casas con 3 piezas. Las piezas reaparecen tras
	Config.HOUSE_SPOT_RESPAWN_SECONDS con una rareza nueva según la zona.
	Cada dueño persigue a un ladrón a la vez; los demás esperan en cola.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local AssetLibrary = require(Shared.AssetLibrary)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local OwnerNpc = require(script.Parent.OwnerNpc)
local WorldService = require(script.Parent.WorldService)

local HouseService = {}

local random = Random.new()
local houses = {}
local npcFolder = nil

-- Medidas de una casa
local HOUSE_WIDTH = 26 -- eje X
local HOUSE_DEPTH = 24 -- eje Z
local HOUSE_HEIGHT = 12
local DOOR_WIDTH = 8
local DOOR_HEIGHT = 9
local HOUSE_OFFSET_X = 48 -- distancia del camino al centro de la casa
-- Posición de las 3 piezas: { hacia el fondo, a lo largo de Z }
local SPOT_OFFSETS = { { 7, -7 }, { 7, 7 }, { -3, -8 } }

local function getRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function isInside(house, position)
	return position.X >= house.min.X
		and position.X <= house.max.X
		and position.Z >= house.min.Z
		and position.Z <= house.max.Z
		and position.Y <= house.max.Y
end

local function flatDistance(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

-- ---------------------------------------------------------------------------
-- Piezas dentro de la casa
-- ---------------------------------------------------------------------------

local function spawnSpot(house, spot)
	local partId = PlayerLogic.rollPart(1, random:NextNumber(), house.zone.weights)
	local info = GameData.Parts[partId]

	local item = Instance.new("Part")
	item.Name = info.name
	item.Shape = Enum.PartType.Ball
	item.Size = Vector3.new(1.4, 1.4, 1.4)
	item.Anchored = true
	item.CanCollide = false
	item.Color = GameData.RarityColors[info.rarity]
	item.Material = Enum.Material.SmoothPlastic
	if not info.common then
		item.Material = Enum.Material.Neon
		local light = Instance.new("PointLight")
		light.Range = 8
		light.Color = item.Color
		light.Parent = item
	end
	item.Position = spot.position

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Robar"
	prompt.ObjectText = string.format("%s (%s)", info.name, info.rarity)
	prompt.HoldDuration = info.holdTime
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = item

	local taken = false
	prompt.Triggered:Connect(function(player)
		if taken then
			return
		end
		local data = DataService.get(player)
		local root = getRoot(player)
		if not data or not root or (root.Position - item.Position).Magnitude > Config.INTERACT_DISTANCE then
			return
		end
		-- Defensa en el servidor: la puerta de velocidad se abre en el cliente.
		if not PlayerLogic.canEnterZone(data, house.zoneIndex) then
			Net.notify(
				player,
				string.format("Necesitas velocidad %d para robar en %s.", house.zone.minSpeed, house.zone.name),
				"error"
			)
			return
		end
		local ok, message = PlayerLogic.stealPart(data, partId, random:NextNumber())
		if not ok then
			Net.notify(player, message, "error")
			return
		end
		taken = true
		item:Destroy()
		spot.item = nil
		house.thieves[player] = true
		Net.notify(player, message, "ok")
		Net.sound(player, "robar")
		DataService.replicate(player)
		task.delay(Config.HOUSE_SPOT_RESPAWN_SECONDS, spawnSpot, house, spot)
	end)

	item.Parent = house.model
	AssetLibrary.dress(item, AssetLibrary.PART_ASSETS[partId]) -- arte (DEV-014)
	spot.item = item
end

-- ---------------------------------------------------------------------------
-- Construcción de una casa
-- ---------------------------------------------------------------------------

-- side = -1: casa a la izquierda del camino (puerta mirando a +X); side = 1: a la derecha.
local function buildHouse(parent, zoneIndex, zone, houseIndex, centerZ, side)
	local makePart = WorldService.makePart
	local centerX = side * HOUSE_OFFSET_X
	local frontX = centerX - side * HOUSE_WIDTH / 2
	local backX = centerX + side * HOUSE_WIDTH / 2
	local ownerName = zone.owners[houseIndex] or ("Dueño " .. houseIndex)

	local model = Instance.new("Model")
	model.Name = string.format("Casa%d", houseIndex)

	local wallColor = zone.color
	local function wall(name, size, position)
		makePart({
			Name = name,
			Size = size,
			Position = position,
			Color = wallColor,
			Material = Enum.Material.Brick,
		}).Parent = model
	end

	makePart({
		Name = "Piso",
		Size = Vector3.new(HOUSE_WIDTH, 0.4, HOUSE_DEPTH),
		Position = Vector3.new(centerX, 0.4, centerZ),
		Color = Color3.fromRGB(150, 110, 80),
		Material = Enum.Material.WoodPlanks,
	}).Parent = model

	local halfH = HOUSE_HEIGHT / 2
	wall("ParedFondo", Vector3.new(1, HOUSE_HEIGHT, HOUSE_DEPTH), Vector3.new(backX, halfH, centerZ))
	wall("ParedLado", Vector3.new(HOUSE_WIDTH, HOUSE_HEIGHT, 1), Vector3.new(centerX, halfH, centerZ - HOUSE_DEPTH / 2))
	wall("ParedLado", Vector3.new(HOUSE_WIDTH, HOUSE_HEIGHT, 1), Vector3.new(centerX, halfH, centerZ + HOUSE_DEPTH / 2))
	local segment = (HOUSE_DEPTH - DOOR_WIDTH) / 2
	local segmentOffset = DOOR_WIDTH / 2 + segment / 2
	wall("ParedFrente", Vector3.new(1, HOUSE_HEIGHT, segment), Vector3.new(frontX, halfH, centerZ - segmentOffset))
	wall("ParedFrente", Vector3.new(1, HOUSE_HEIGHT, segment), Vector3.new(frontX, halfH, centerZ + segmentOffset))
	wall(
		"Dintel",
		Vector3.new(1, HOUSE_HEIGHT - DOOR_HEIGHT, DOOR_WIDTH),
		Vector3.new(frontX, DOOR_HEIGHT + (HOUSE_HEIGHT - DOOR_HEIGHT) / 2, centerZ)
	)
	makePart({
		Name = "Techo",
		Size = Vector3.new(HOUSE_WIDTH + 2, 1, HOUSE_DEPTH + 2),
		Position = Vector3.new(centerX, HOUSE_HEIGHT + 0.5, centerZ),
		Color = zone.color:Lerp(Color3.new(0, 0, 0), 0.35),
		Material = Enum.Material.Slate,
	}).Parent = model

	local door = makePart({
		Name = "Puerta",
		Size = Vector3.new(1, DOOR_HEIGHT, DOOR_WIDTH),
		Position = Vector3.new(frontX, DOOR_HEIGHT / 2, centerZ),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	WorldService.makeSign(door, "Casa de " .. ownerName, zone.name, 7, 120)
	door.Parent = model
	if zoneIndex == 1 and houseIndex == 1 then
		CollectionService:AddTag(door, "GuideHouse")
		model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	end

	local house = {
		zoneIndex = zoneIndex,
		zone = zone,
		model = model,
		ownerName = ownerName,
		min = Vector3.new(centerX - HOUSE_WIDTH / 2, -5, centerZ - HOUSE_DEPTH / 2),
		max = Vector3.new(centerX + HOUSE_WIDTH / 2, HOUSE_HEIGHT, centerZ + HOUSE_DEPTH / 2),
		ownerSpawn = Vector3.new(centerX + side * 6, 0, centerZ),
		doorOutside = Vector3.new(frontX - side * 4, 0, centerZ),
		spots = {},
		thieves = {}, -- [Player] = true mientras roba dentro
		queue = {}, -- ladrones que salieron y esperan persecución
		chasing = nil,
	}

	-- Arte (DEV-014): la casa mira hacia el camino (la puerta da a -side en X)
	AssetLibrary.dress(model, "mdl_casa_z" .. zoneIndex, { facing = Vector3.new(-side, 0, 0) })

	for _, offset in SPOT_OFFSETS do
		local position = Vector3.new(centerX + side * offset[1], 0, centerZ + offset[2])
		local pedestal = makePart({
			Name = "Pedestal",
			Size = Vector3.new(2.4, 2, 2.4),
			Position = position + Vector3.new(0, 1, 0),
			Color = Color3.fromRGB(110, 80, 55),
			Material = Enum.Material.Wood,
		})
		pedestal.Parent = model
		AssetLibrary.dress(pedestal, "mdl_pedestal")
		local spot = { position = position + Vector3.new(0, 2.9, 0), item = nil }
		table.insert(house.spots, spot)
		spawnSpot(house, spot)
	end

	model.Parent = parent
	table.insert(houses, house)
end

-- ---------------------------------------------------------------------------
-- Persecución
-- ---------------------------------------------------------------------------

local function chase(house, player)
	house.chasing = player
	local zone = house.zone
	local npc = OwnerNpc.create(
		house.ownerName,
		zone.color:Lerp(Color3.new(0, 0, 0), 0.4),
		house.ownerSpawn,
		npcFolder,
		"npc_dueno_z" .. house.zoneIndex
	)
	npc.humanoid.WalkSpeed = zone.ownerSpeed
	Net.notify(player, string.format("¡%s te vio! Corre a la base con tu botín.", house.ownerName), "error")
	Net.sound(player, "alarma_dueno")

	task.wait(Config.OWNER_REACTION_SECONDS)
	local started = os.clock()
	local leftHouse = false
	local result = "gone"
	local data = nil

	while true do
		data = DataService.get(player)
		local root = getRoot(player)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not player.Parent or not data or not root or not humanoid or humanoid.Health <= 0 then
			result = "gone"
			break
		end
		if PlayerLogic.carriedCount(data) == 0 then
			result = "gone"
			break
		end
		if WorldService.isInHub(root.Position) then
			result = "escaped"
			break
		end
		local distance = (root.Position - npc.root.Position).Magnitude
		if distance <= Config.CATCH_DISTANCE then
			result = "caught"
			break
		end
		local elapsed = os.clock() - started
		if distance > Config.CHASE_LOSE_DISTANCE or elapsed > Config.CHASE_MAX_SECONDS then
			result = "escaped"
			break
		end
		if not leftHouse then
			-- Primero sale por la puerta para no atascarse en las paredes.
			npc.humanoid:MoveTo(house.doorOutside)
			if flatDistance(npc.root.Position, house.doorOutside) < 3 or elapsed > 4 then
				leftHouse = true
			end
		else
			npc.humanoid:MoveTo(root.Position)
		end
		task.wait(0.1)
	end

	if result == "caught" and data then
		local lost = PlayerLogic.loseLoot(data)
		Net.notify(player, string.format("¡%s te atrapó! Perdiste %d piezas robadas.", house.ownerName, lost), "error")
		Net.sound(player, "atrapado")
		DataService.replicate(player)
	elseif result == "escaped" then
		Net.notify(player, string.format("%s dejó de perseguirte.", house.ownerName), "info")
	end

	npc.model:Destroy()
	house.chasing = nil
end

local function startNextChase(house)
	while #house.queue > 0 do
		local player = table.remove(house.queue, 1)
		local data = DataService.get(player)
		local root = getRoot(player)
		if
			player.Parent
			and data
			and root
			and PlayerLogic.carriedCount(data) > 0
			and not WorldService.isInHub(root.Position)
		then
			house.chasing = player
			task.spawn(chase, house, player)
			return
		end
	end
end

-- Revisa salidas de casas, inicia persecuciones y guarda botín en la base.
local function tick()
	for _, house in houses do
		for player in house.thieves do
			local root = getRoot(player)
			if not player.Parent or not root then
				house.thieves[player] = nil
			elseif not isInside(house, root.Position) then
				house.thieves[player] = nil
				local data = DataService.get(player)
				if
					data
					and PlayerLogic.carriedCount(data) > 0
					and house.chasing ~= player
					and not table.find(house.queue, player)
				then
					table.insert(house.queue, player)
				end
			end
		end
		if not house.chasing then
			startNextChase(house)
		end
	end

	DataService.forEach(function(player, data)
		if PlayerLogic.carriedCount(data) > 0 then
			local root = getRoot(player)
			if root and WorldService.isInHub(root.Position) then
				local saved = PlayerLogic.depositLoot(data)
				Net.notify(player, string.format("Botín guardado: +%d piezas en tu mochila.", saved), "ok")
				Net.sound(player, "guardar_botin")
				DataService.replicate(player)
			end
		end
	end)
end

-- Caer o reiniciar con botín encima también lo pierde (evita escapar reiniciando).
local function watchDeaths(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then
			return
		end
		humanoid.Died:Connect(function()
			local data = DataService.get(player)
			if data and PlayerLogic.carriedCount(data) > 0 then
				local lost = PlayerLogic.loseLoot(data)
				Net.notify(player, string.format("Perdiste %d piezas robadas al caer.", lost), "error")
				DataService.replicate(player)
			end
		end)
	end)
end

function HouseService.init()
	npcFolder = Instance.new("Folder")
	npcFolder.Name = "Duenos"
	npcFolder.Parent = WorldService.Folder

	for zoneIndex, zone in GameData.Zones do
		local startZ = WorldService.zoneBounds(zoneIndex)
		local zoneModel = WorldService.ZonesFolder:FindFirstChild(string.format("Zona%d_%s", zoneIndex, zone.id))
		local houseIndex = 0
		for _, rowZ in { startZ + 35, startZ + 95 } do
			for _, side in { -1, 1 } do
				houseIndex += 1
				buildHouse(zoneModel, zoneIndex, zone, houseIndex, rowZ, side)
			end
		end
	end

	Players.PlayerAdded:Connect(watchDeaths)
	for _, player in Players:GetPlayers() do
		watchDeaths(player)
	end

	task.spawn(function()
		while true do
			task.wait(0.2)
			tick()
		end
	end)
end

return HouseService
