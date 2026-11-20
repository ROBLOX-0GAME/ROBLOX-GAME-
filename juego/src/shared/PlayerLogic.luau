--[[
	PlayerLogic — reglas puras del juego sobre la tabla de datos de un jugador.

	No usa servicios de Roblox ni hace llamadas de red, para poder probarse
	de forma aislada (ver ServerScriptService.Server.Tests). El servidor es el
	único que llama a las funciones que modifican datos; el cliente solo usa
	las de lectura para mostrar información.

	Las funciones que modifican devuelven (ok: boolean, mensaje: string, ...).
]]

local Config = require(script.Parent.Config)
local GameData = require(script.Parent.GameData)

local PlayerLogic = {}

-- ---------------------------------------------------------------------------
-- Estructura de datos
-- ---------------------------------------------------------------------------

function PlayerLogic.newData()
	return {
		version = Config.DATA_VERSION,
		coins = Config.START_COINS,
		xp = 0,
		parts = {}, -- [partId] = cantidad guardada (segura)
		carried = {}, -- [partId] = botín robado que llevas encima; se pierde si te atrapan
		watches = {}, -- [watchId] = cantidad en inventario
		museum = {}, -- [watchId] = cantidad exhibida
		upgrades = {}, -- [upgradeId] = nivel
		stats = { collected = 0, crafted = 0, sold = 0, earned = 0 },
		tutorial = 1, -- paso actual del tutorial; #GameData.Tutorial + 1 = terminado
	}
end

local function cleanCounts(map, catalog)
	local out = {}
	if type(map) == "table" then
		for id, amount in map do
			if catalog[id] and type(amount) == "number" and amount >= 1 then
				out[id] = math.floor(amount)
			end
		end
	end
	return out
end

local function nonNegativeInt(value)
	if type(value) ~= "number" or value ~= value or value < 0 then
		return 0
	end
	return math.floor(value)
end

-- Completa campos ausentes y descarta valores inválidos o ids desconocidos.
-- Se usa al cargar datos guardados, para que versiones antiguas sigan funcionando.
function PlayerLogic.reconcile(data)
	local template = PlayerLogic.newData()
	if type(data) ~= "table" then
		return template
	end

	data.coins = nonNegativeInt(data.coins)
	data.xp = nonNegativeInt(data.xp)
	data.parts = cleanCounts(data.parts, GameData.Parts)
	-- El botín no guardado en la base se pierde al salir del juego.
	data.carried = {}
	data.watches = cleanCounts(data.watches, GameData.Watches)
	data.museum = cleanCounts(data.museum, GameData.Watches)

	local upgrades = {}
	if type(data.upgrades) == "table" then
		for id, level in data.upgrades do
			local upgrade = GameData.Upgrades[id]
			if upgrade and type(level) == "number" then
				upgrades[id] = math.clamp(math.floor(level), 0, upgrade.maxLevel)
			end
		end
	end
	data.upgrades = upgrades

	local stats = {}
	local oldStats = data.stats
	if type(oldStats) ~= "table" then
		oldStats = {}
	end
	for key in template.stats do
		stats[key] = nonNegativeInt(oldStats[key])
	end
	data.stats = stats

	-- Datos guardados antes de DEV-002 no tienen tutorial: empiezan en el paso 1
	-- y los pasos ya cumplidos se completan solos al cargar.
	data.tutorial = math.clamp(nonNegativeInt(data.tutorial), 1, #GameData.Tutorial + 1)

	data.version = Config.DATA_VERSION
	return data
end

-- ---------------------------------------------------------------------------
-- Lecturas
-- ---------------------------------------------------------------------------

local function sumCounts(map)
	local total = 0
	for _, amount in map do
		total += amount
	end
	return total
end

function PlayerLogic.upgradeLevel(data, upgradeId)
	return data.upgrades[upgradeId] or 0
end

function PlayerLogic.backpackCapacity(data)
	return Config.BASE_BACKPACK + PlayerLogic.upgradeLevel(data, "backpack") * GameData.Upgrades.backpack.step
end

function PlayerLogic.partCount(data)
	return sumCounts(data.parts)
end

function PlayerLogic.carriedCount(data)
	return sumCounts(data.carried)
end

-- Espacio libre en la mochila: capacidad - piezas guardadas - botín encima.
function PlayerLogic.freeSpace(data)
	return math.max(0, PlayerLogic.backpackCapacity(data) - PlayerLogic.partCount(data) - PlayerLogic.carriedCount(data))
end

function PlayerLogic.walkSpeed(data)
	local base = Config.BASE_WALKSPEED + PlayerLogic.upgradeLevel(data, "speed") * GameData.Upgrades.speed.step
	return math.min(Config.MAX_WALKSPEED, base)
end

-- ¿Tiene la velocidad necesaria para cruzar la puerta y robar en la zona?
function PlayerLogic.canEnterZone(data, zoneIndex)
	local zone = GameData.Zones[zoneIndex]
	if not zone then
		return false
	end
	return PlayerLogic.walkSpeed(data) >= zone.minSpeed
end

-- Zona más lejana a la que puede entrar.
function PlayerLogic.highestZone(data)
	local highest = 1
	for index in GameData.Zones do
		if PlayerLogic.canEnterZone(data, index) and index > highest then
			highest = index
		end
	end
	return highest
end

function PlayerLogic.jumpHeight(data)
	return Config.BASE_JUMPHEIGHT + PlayerLogic.upgradeLevel(data, "jump") * GameData.Upgrades.jump.step
end

-- Probabilidad (0-1) de robar 2 piezas en vez de 1.
function PlayerLogic.extraPartChance(data)
	return PlayerLogic.upgradeLevel(data, "luck") * GameData.Upgrades.luck.step
end

function PlayerLogic.museumSlots(data)
	return Config.BASE_MUSEUM_SLOTS + PlayerLogic.upgradeLevel(data, "museum") * GameData.Upgrades.museum.step
end

function PlayerLogic.museumCount(data)
	return sumCounts(data.museum)
end

function PlayerLogic.museumIncome(data)
	local total = 0
	for watchId, amount in data.museum do
		total += GameData.Watches[watchId].income * amount
	end
	return total
end

-- Devuelve nivel, XP dentro del nivel actual y XP necesaria para el siguiente (0 en el máximo).
function PlayerLogic.levelInfo(xp)
	local level = 1
	local remaining = xp
	while level < Config.MAX_LEVEL and remaining >= level * Config.XP_PER_LEVEL_STEP do
		remaining -= level * Config.XP_PER_LEVEL_STEP
		level += 1
	end
	local needed = 0
	if level < Config.MAX_LEVEL then
		needed = level * Config.XP_PER_LEVEL_STEP
	end
	return level, remaining, needed
end

function PlayerLogic.level(data)
	local level = PlayerLogic.levelInfo(data.xp)
	return level
end

-- Precio del siguiente nivel de una mejora, o nil si ya está al máximo.
function PlayerLogic.upgradeCost(data, upgradeId)
	local upgrade = GameData.Upgrades[upgradeId]
	if not upgrade then
		return nil
	end
	local current = PlayerLogic.upgradeLevel(data, upgradeId)
	if current >= upgrade.maxLevel then
		return nil
	end
	return math.floor(upgrade.baseCost * upgrade.growth ^ current)
end

-- Comprueba si se puede fabricar un reloj. Devuelve ok y el motivo si no se puede.
function PlayerLogic.canCraft(data, watchId)
	local watch = GameData.Watches[watchId]
	if not watch then
		return false, "Ese reloj no existe."
	end
	if PlayerLogic.level(data) < watch.level then
		return false, string.format("Necesitas nivel %d para fabricar %s.", watch.level, watch.name)
	end
	if (data.watches[watchId] or 0) >= Config.MAX_WATCHES_PER_TYPE then
		return false, "Ya tienes el máximo de ese reloj."
	end
	for partId, needed in watch.cost do
		local have = data.parts[partId] or 0
		if have < needed then
			return false, string.format("Te faltan %d %s.", needed - have, GameData.Parts[partId].name)
		end
	end
	return true, ""
end

-- Elige una pieza al azar. roll es un número en [0, 1).
-- zoneWeights (opcional): tabla [partId] = peso de una zona; si falta, usa el peso base.
-- luckMultiplier multiplica el peso de las piezas que no son comunes.
function PlayerLogic.rollPart(luckMultiplier, roll, zoneWeights)
	local total = 0
	local weights = {}
	for index, partId in GameData.PartOrder do
		local part = GameData.Parts[partId]
		local weight = part.weight
		if zoneWeights then
			weight = zoneWeights[partId] or 0
		end
		if not part.common then
			weight *= luckMultiplier
		end
		weights[index] = weight
		total += weight
	end
	local target = roll * total
	local lastValid = GameData.PartOrder[1]
	for index, partId in GameData.PartOrder do
		if weights[index] > 0 then
			lastValid = partId
			target -= weights[index]
			if target < 0 then
				return partId
			end
		end
	end
	return lastValid
end

-- Valor actual de lo que mide un paso del tutorial.
function PlayerLogic.tutorialValue(data, stat)
	if stat == "museum" then
		return PlayerLogic.museumCount(data)
	elseif stat == "upgrades" then
		return sumCounts(data.upgrades)
	end
	return data.stats[stat] or 0
end

-- Paso actual del tutorial y su progreso, o nil si ya terminó.
function PlayerLogic.tutorialStep(data)
	local step = GameData.Tutorial[data.tutorial]
	if not step then
		return nil, 0
	end
	return step, math.min(PlayerLogic.tutorialValue(data, step.stat), step.target)
end

-- Vista que el servidor envía al cliente (solo lectura en el cliente).
function PlayerLogic.buildView(data)
	local level, levelXp, levelNeed = PlayerLogic.levelInfo(data.xp)
	local upgradeCosts = {}
	for _, upgradeId in GameData.UpgradeOrder do
		upgradeCosts[upgradeId] = PlayerLogic.upgradeCost(data, upgradeId) or false
	end
	local tutorial = false
	local step, progress = PlayerLogic.tutorialStep(data)
	if step then
		tutorial = {
			index = data.tutorial,
			total = #GameData.Tutorial,
			text = step.text,
			progress = progress,
			target = step.target,
			reward = step.reward,
			guide = step.guide,
		}
	end
	return {
		tutorial = tutorial,
		coins = data.coins,
		xp = data.xp,
		level = level,
		levelXp = levelXp,
		levelNeed = levelNeed,
		parts = table.clone(data.parts),
		carried = table.clone(data.carried),
		carriedCount = PlayerLogic.carriedCount(data),
		freeSpace = PlayerLogic.freeSpace(data),
		walkSpeed = PlayerLogic.walkSpeed(data),
		highestZone = PlayerLogic.highestZone(data),
		watches = table.clone(data.watches),
		museum = table.clone(data.museum),
		upgrades = table.clone(data.upgrades),
		upgradeCosts = upgradeCosts,
		capacity = PlayerLogic.backpackCapacity(data),
		partCount = PlayerLogic.partCount(data),
		museumSlots = PlayerLogic.museumSlots(data),
		museumCount = PlayerLogic.museumCount(data),
		museumIncome = PlayerLogic.museumIncome(data),
	}
end

-- ---------------------------------------------------------------------------
-- Modificaciones (solo servidor)
-- ---------------------------------------------------------------------------

local function removeCount(map, id, amount)
	local left = (map[id] or 0) - amount
	if left > 0 then
		map[id] = left
	else
		map[id] = nil
	end
end

-- Cantidad entera entre 1 y Config.MAX_SELL_AMOUNT (rechaza NaN y decimales).
local function validAmount(amount)
	return type(amount) == "number"
		and amount == amount
		and amount >= 1
		and amount % 1 == 0
		and amount <= Config.MAX_SELL_AMOUNT
end

function PlayerLogic.addPart(data, partId)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida."
	end
	if PlayerLogic.freeSpace(data) < 1 then
		return false, "Mochila llena: fabrica relojes, vende piezas en la Tienda o tira piezas desde la Mochila."
	end
	data.parts[partId] = (data.parts[partId] or 0) + 1
	data.stats.collected += 1
	return true, string.format("+1 %s (%s)", part.name, part.rarity)
end

-- Roba una pieza en una casa: va al botín que llevas encima (DEV-003).
-- bonusRoll en [0, 1): si es menor que la suerte, roba 2 (si caben).
-- Devuelve ok, mensaje, cantidad.
function PlayerLogic.stealPart(data, partId, bonusRoll)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida.", 0
	end
	local free = PlayerLogic.freeSpace(data)
	if free < 1 then
		return false, "Mochila llena: vuelve a la base, fabrica relojes o vende piezas.", 0
	end
	local amount = 1
	if free >= 2 and bonusRoll < PlayerLogic.extraPartChance(data) then
		amount = 2
	end
	data.carried[partId] = (data.carried[partId] or 0) + amount
	local message = string.format("Robaste %d %s (%s). ¡Llévalo a la base!", amount, part.name, part.rarity)
	return true, message, amount
end

-- Guarda el botín al llegar a la base. Devuelve cuántas piezas se guardaron.
function PlayerLogic.depositLoot(data)
	local total = 0
	for partId, amount in data.carried do
		data.parts[partId] = (data.parts[partId] or 0) + amount
		total += amount
	end
	data.carried = {}
	data.stats.collected += total
	return total
end

-- El dueño te atrapó (o caíste): se pierde el botín. Devuelve cuántas piezas se perdieron.
function PlayerLogic.loseLoot(data)
	local total = PlayerLogic.carriedCount(data)
	data.carried = {}
	return total
end

-- Devuelve ok, mensaje, subióDeNivel
function PlayerLogic.craft(data, watchId)
	local ok, reason = PlayerLogic.canCraft(data, watchId)
	if not ok then
		return false, reason, false
	end
	local watch = GameData.Watches[watchId]
	local levelBefore = PlayerLogic.level(data)
	for partId, needed in watch.cost do
		removeCount(data.parts, partId, needed)
	end
	data.watches[watchId] = (data.watches[watchId] or 0) + 1
	data.xp += watch.xp
	data.stats.crafted += 1
	local levelAfter = PlayerLogic.level(data)
	local message = string.format("Fabricaste: %s (+%d XP)", watch.name, watch.xp)
	if levelAfter > levelBefore then
		message ..= string.format(" · ¡Subiste a nivel %d!", levelAfter)
	end
	return true, message, levelAfter > levelBefore
end

function PlayerLogic.sell(data, watchId, amount)
	local watch = GameData.Watches[watchId]
	if not watch then
		return false, "Ese reloj no existe."
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida."
	end
	local owned = data.watches[watchId] or 0
	if owned < amount then
		return false, "No tienes suficientes relojes de ese tipo."
	end
	local earned = watch.sell * amount
	removeCount(data.watches, watchId, amount)
	data.coins += earned
	data.stats.sold += amount
	data.stats.earned += earned
	return true, string.format("Vendiste %d × %s por %d monedas.", amount, watch.name, earned)
end

-- Vende piezas sueltas en la Tienda (BUG-001).
function PlayerLogic.sellPart(data, partId, amount)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida."
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida."
	end
	if (data.parts[partId] or 0) < amount then
		return false, "No tienes suficientes piezas de ese tipo."
	end
	local earned = part.sell * amount
	removeCount(data.parts, partId, amount)
	data.coins += earned
	data.stats.earned += earned
	return true, string.format("Vendiste %d × %s por %d monedas.", amount, part.name, earned)
end

-- Tira piezas desde la Mochila, en cualquier lugar y sin pago (BUG-001).
function PlayerLogic.discardPart(data, partId, amount)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida."
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida."
	end
	if (data.parts[partId] or 0) < amount then
		return false, "No tienes suficientes piezas de ese tipo."
	end
	removeCount(data.parts, partId, amount)
	return true, string.format("Tiraste %d × %s.", amount, part.name)
end

function PlayerLogic.buyUpgrade(data, upgradeId)
	local upgrade = GameData.Upgrades[upgradeId]
	if not upgrade then
		return false, "Esa mejora no existe."
	end
	local cost = PlayerLogic.upgradeCost(data, upgradeId)
	if not cost then
		return false, upgrade.name .. " ya está al máximo."
	end
	if data.coins < cost then
		return false, string.format("Te faltan %d monedas.", cost - data.coins)
	end
	data.coins -= cost
	local newLevel = PlayerLogic.upgradeLevel(data, upgradeId) + 1
	data.upgrades[upgradeId] = newLevel
	return true, string.format("%s mejorada a nivel %d.", upgrade.name, newLevel)
end

function PlayerLogic.display(data, watchId)
	local watch = GameData.Watches[watchId]
	if not watch then
		return false, "Ese reloj no existe."
	end
	if (data.watches[watchId] or 0) < 1 then
		return false, "No tienes ese reloj en tu inventario."
	end
	if PlayerLogic.museumCount(data) >= PlayerLogic.museumSlots(data) then
		return false, "No quedan vitrinas libres. Mejora el museo o retira un reloj."
	end
	removeCount(data.watches, watchId, 1)
	data.museum[watchId] = (data.museum[watchId] or 0) + 1
	return true, string.format("%s exhibido en el museo.", watch.name)
end

function PlayerLogic.withdraw(data, watchId)
	local watch = GameData.Watches[watchId]
	if not watch then
		return false, "Ese reloj no existe."
	end
	if (data.museum[watchId] or 0) < 1 then
		return false, "Ese reloj no está exhibido."
	end
	if (data.watches[watchId] or 0) >= Config.MAX_WATCHES_PER_TYPE then
		return false, "Tu inventario de ese reloj está lleno."
	end
	removeCount(data.museum, watchId, 1)
	data.watches[watchId] = (data.watches[watchId] or 0) + 1
	return true, string.format("%s retirado del museo.", watch.name)
end

-- Completa todos los pasos del tutorial ya cumplidos y entrega sus premios.
-- Devuelve la lista de mensajes para mostrar al jugador.
function PlayerLogic.advanceTutorial(data)
	local messages = {}
	while true do
		local step, progress = PlayerLogic.tutorialStep(data)
		if not step or progress < step.target then
			break
		end
		data.coins += step.reward
		data.stats.earned += step.reward
		data.tutorial += 1
		table.insert(messages, string.format("¡Objetivo cumplido! +%d monedas", step.reward))
		if data.tutorial > #GameData.Tutorial then
			table.insert(messages, "¡Tutorial completado! Ahora fabrica relojes mejores y llena tu museo.")
		end
	end
	return messages
end

-- Entrega piezas guardadas al Cronómetro Maestro (DEV-004).
-- Devuelve ok, mensaje, puntos.
function PlayerLogic.contributeParts(data, partId, amount)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida.", 0
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida.", 0
	end
	if (data.parts[partId] or 0) < amount then
		return false, "No tienes suficientes piezas de ese tipo.", 0
	end
	removeCount(data.parts, partId, amount)
	local points = GameData.RepairPoints[part.rarity] * amount
	return true, string.format("Entregaste %d × %s: +%d puntos de reparación.", amount, part.name, points), points
end

-- Devuelve piezas entregadas si la reparación falla (ignora la capacidad:
-- el jugador ya las tenía).
function PlayerLogic.refundParts(data, parts)
	local total = 0
	for partId, amount in parts do
		if GameData.Parts[partId] and amount > 0 then
			data.parts[partId] = (data.parts[partId] or 0) + amount
			total += amount
		end
	end
	return total
end

function PlayerLogic.bossReward(points)
	return math.floor(points * Config.BOSS_COINS_PER_POINT)
end

-- Suma el ingreso pasivo del museo. Devuelve las monedas ganadas.
function PlayerLogic.collectIncome(data)
	local income = PlayerLogic.museumIncome(data)
	if income > 0 then
		data.coins += income
		data.stats.earned += income
	end
	return income
end

return PlayerLogic
