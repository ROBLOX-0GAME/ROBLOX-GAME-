--[[
	HouseService — casas, robo de piezas y persecución (DEV-003).

	Flujo (DEC-024):
	  1. El dueño DUERME. Entras a su casa y mantienes el botón sobre una pieza
	     → va a tu botín (lo llevas encima, todavía no es tuyo) junto con las
	     monedas que trae en esa zona.
	  2. Si pasas más de Config.OWNER_WAKE_SECONDS dentro, el dueño despierta y
	     te persigue: dentro de su casa es lento; fuera corre casi como la
	     velocidad que exige su zona.
	  3. Si llegas a la base segura, el botín se guarda en tu mochila y cobras
	     sus monedas. Si el dueño te atrapa (o caes), pierdes el botín y te echa.
	  4. El dueño se rinde si llegas a la base, si te alejas demasiado o tras
	     Config.CHASE_MAX_SECONDS, y vuelve a dormir.

	Cada zona tiene 4 casas con 3 piezas. Cada pieza es única en el servidor
	(quien la roba primero se la lleva) y no reaparece sola: todas se renuevan
	cuando se reinicia la zona de carreras cada 5 min (RaceService, DEC-029).
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
	-- Presentación (ART-015): el cliente resalta las piezas Raras o mejores (Client/Vfx)
	item:SetAttribute("Rarity", info.rarity)
	CollectionService:AddTag(item, "PiezaRobable")

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
				string.format("Necesitas velocidad %s para robar en %s.", PlayerLogic.formatBig(house.zone.minSpeed), house.zone.name),
				"error"
			)
			return
		end
		local ok, message = PlayerLogic.stealPart(data, partId, random:NextNumber(), house.zone.lootCoins)
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
		-- DEC-029: la pieza no reaparece sola; todas se renuevan al reiniciar la zona
	end)

	item.Parent = house.model
	AssetLibrary.dress(item, AssetLibrary.PART_ASSETS[partId]) -- arte (DEV-014)
	spot.item = item

	-- DEC-029: aviso a todo el servidor si la pieza es Mítica o superior
	local rarityIndex = GameData.RarityIndex[info.rarity] or 0
	if rarityIndex >= Config.ANNOUNCE_MIN_RARITY then
		Net.announce({
			kind = "rarePart",
			rarity = info.rarity,
			part = info.name,
			zone = house.zone.name,
			zoneIndex = house.zoneIndex,
		})
	end
end

-- DEC-029: renueva las piezas de todas las casas (al reiniciar la zona de carreras).
function HouseService.resetAll()
	for _, house in houses do
		house.visitors = {}
		for _, spot in house.spots do
			if spot.item then
				spot.item:Destroy()
				spot.item = nil
			end
			spawnSpot(house, spot)
		end
	end
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
	WorldService.makeSign(door, "Casa de " .. ownerName, zone.name, 7, 60) -- ART-015: antes 120
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
		thieves = {}, -- [Player] = true si robó en esta visita
		visitors = {}, -- [Player] = os.clock() al entrar (DEC-024: el dueño despierta a los 15 s)
		chasing = nil,
	}

	-- Arte (DEV-014): la casa mira hacia el camino (la puerta da a -side en X)
	AssetLibrary.dress(model, zone.houseAsset or ("mdl_casa_z" .. zoneIndex), { facing = Vector3.new(-side, 0, 0) })

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

-- El dueño despertó (DEC-024): persigue al jugador que se quedó demasiado en su casa.
local function chase(house, player)
	house.chasing = player
	local zone = house.zone
	local npc = OwnerNpc.create(
		house.ownerName,
		zone.color:Lerp(Color3.new(0, 0, 0), 0.4),
		house.ownerSpawn,
		npcFolder,
		"npc_dueno_z" .. math.min(house.zoneIndex, 5)
	)
	local outsideSpeed = PlayerLogic.ownerSpeed(house.zoneIndex)
	npc.humanoid.WalkSpeed = Config.OWNER_HOUSE_SPEED
	Net.notify(player, string.format("¡%s se despertó y te busca! Sal y corre a la base.", house.ownerName), "error")
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
		-- Dentro de su casa el dueño es lento; fuera corre como su zona (DEC-024)
		if isInside(house, npc.root.Position) then
			npc.humanoid.WalkSpeed = Config.OWNER_HOUSE_SPEED
		else
			npc.humanoid.WalkSpeed = outsideSpeed
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
		local inside = isInside(house, root.Position)
		if inside or not leftHouse then
			-- Dentro de la casa va directo al jugador; si el jugador ya salió, primero
			-- sale por la puerta para no atascarse en las paredes.
			if inside then
				npc.humanoid:MoveTo(root.Position)
			else
				npc.humanoid:MoveTo(house.doorOutside)
			end
			if not inside and (flatDistance(npc.root.Position, house.doorOutside) < 3 or elapsed > 6) then
				leftHouse = true
			end
		else
			npc.humanoid:MoveTo(root.Position)
		end
		task.wait(0.1)
	end

	if result == "caught" and data then
		local lost = PlayerLogic.loseLoot(data)
		if lost > 0 then
			Net.notify(player, string.format("¡%s te atrapó! Perdiste %d piezas robadas.", house.ownerName, lost), "error")
		else
			Net.notify(player, string.format("¡%s te atrapó y te echó de su casa!", house.ownerName), "error")
		end
		Net.sound(player, "atrapado")
		-- Te echa fuera de su casa
		local character = player.Character
		if character and character.PrimaryPart and isInside(house, character.PrimaryPart.Position) then
			character:PivotTo(CFrame.new(house.doorOutside + Vector3.new(0, 3, 0)))
		end
		DataService.replicate(player)
	elseif result == "escaped" then
		Net.notify(player, string.format("%s dejó de perseguirte y volvió a dormir.", house.ownerName), "info")
	end

	npc.model:Destroy()
	house.visitors[player] = nil
	house.chasing = nil
end

-- ¿En qué casa está una posición? (para la velocidad dentro de las casas, DEC-024)
function HouseService.houseAt(position)
	for _, house in houses do
		if isInside(house, position) then
			return house
		end
	end
	return nil
end

-- Cuenta el tiempo de cada jugador dentro de cada casa, despierta al dueño a los
-- Config.OWNER_WAKE_SECONDS (DEC-024) y guarda el botín al llegar a la base.
local function tick()
	local now = os.clock()
	local roots = {}
	for _, player in Players:GetPlayers() do
		roots[player] = getRoot(player)
	end
	for _, house in houses do
		for player in house.visitors do
			local root = roots[player]
			if not player.Parent or not root or not isInside(house, root.Position) then
				house.visitors[player] = nil
			end
		end
		for player, root in roots do
			if isInside(house, root.Position) and not house.visitors[player] then
				house.visitors[player] = now
			end
		end
		if not house.chasing then
			for player, enteredAt in house.visitors do
				if now - enteredAt >= Config.OWNER_WAKE_SECONDS then
					house.chasing = player
					task.spawn(chase, house, player)
					break
				end
			end
		end
	end

	DataService.forEach(function(player, data)
		if PlayerLogic.carriedCount(data) > 0 then
			local root = roots[player]
			if root and WorldService.isInHub(root.Position) then
				local saved, coins = PlayerLogic.depositLoot(data)
				if coins > 0 then
					Net.notify(
						player,
						string.format("Botín guardado: +%d piezas y +%s monedas.", saved, PlayerLogic.formatBig(coins)),
						"ok"
					)
				else
					Net.notify(player, string.format("Botín guardado: +%d piezas en tu mochila.", saved), "ok")
				end
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
		local startZ, endZ = WorldService.zoneBounds(zoneIndex)
		local zoneModel = WorldService.ZonesFolder:FindFirstChild(string.format("Zona%d_%s", zoneIndex, zone.id))
		local houseIndex = 0
		-- DEC-024: una fila al inicio y otra al fondo de la zona (más lejos cuanto más larga)
		for _, rowZ in { startZ + 35, math.max(startZ + 95, endZ - 35) } do
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
