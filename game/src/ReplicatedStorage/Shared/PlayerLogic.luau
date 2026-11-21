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
		carriedCoins = 0, -- monedas que trae el botín (DEC-024); se cobran en la base
		pieces = {}, -- [clave de pieza] = cantidad guardada (DEC-028: Caja, Calibre, Esfera, Manecillas)
		carriedPieces = {}, -- [clave de pieza] = piezas de reloj robadas que llevas encima
		watches = {}, -- [watchId] = cantidad en inventario
		museum = {}, -- [watchId] = cantidad exhibida
		upgrades = {}, -- [upgradeId] = nivel
		pets = {}, -- [petId] = cantidad que posee
		equipped = {}, -- [petId] = cantidad equipada (≤ pets[petId])
		stats = { collected = 0, crafted = 0, sold = 0, earned = 0 },
		tutorial = 1, -- paso actual del tutorial; #GameData.Tutorial + 1 = terminado
		trained = 0, -- velocidad permanente ganada en caminadoras (DEV-006)
		passes = {}, -- [passId] = true; SOLO de la sesión: se consulta a Roblox al entrar
		receipts = {}, -- últimas compras con Robux entregadas (evita entregar dos veces)
		capsules = {}, -- [capsuleId] = cápsulas sin abrir en la Mochila (DEV-009)
		introDone = false, -- vio la introducción y recogió la pieza del legado (DEV-011)
		legacyVariant = nil, -- id de GameData.LegacyPieces que le tocó
		incomeRemainder = 0, -- fracción de moneda pendiente del ingreso pasivo
		spin = { lastDay = -1, extra = 0 }, -- ruleta diaria (DEV-013)
		settings = {}, -- [settingId] = valor (DEV-013)
		daily = { streak = 0, lastDay = -1 }, -- racha de recompensa diaria
		playtime = { day = -1, seconds = 0, claimed = {} }, -- tiempo jugado hoy
		lastSeen = 0, -- os.time() de la última vez conectado (DEC-030: ganancia offline)
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
	data.carriedCoins = 0

	-- Mascotas: nunca más equipadas que poseídas ni más del límite.
	data.pets = cleanCounts(data.pets, GameData.Pets)
	-- Las mascotas exclusivas de pases se reponen al comprobar los pases.
	for petId, pet in GameData.Pets do
		if pet.exclusive then
			data.pets[petId] = nil
		end
	end
	data.passes = {}
	local equipped = {}
	local slots = Config.MAX_EQUIPPED_PETS
	for _, petId in GameData.PetOrder do
		local wanted = 0
		if type(data.equipped) == "table" and type(data.equipped[petId]) == "number" then
			wanted = math.floor(data.equipped[petId])
		end
		local amount = math.clamp(wanted, 0, math.min(data.pets[petId] or 0, slots))
		if amount > 0 then
			equipped[petId] = amount
			slots -= amount
		end
	end
	data.equipped = equipped
	-- DEC-028: los relojes se guardan con clave «reloj|rareza|ajenas» (o solo el id, de antes)
	local function cleanWatches(map)
		local clean = {}
		if type(map) == "table" then
			for key, amount in map do
				if type(key) == "string" and PlayerLogic.parseWatchKey(key) then
					local count = nonNegativeInt(amount)
					if count > 0 then
						clean[key] = count
					end
				end
			end
		end
		return clean
	end
	data.watches = cleanWatches(data.watches)
	data.museum = cleanWatches(data.museum)
	local pieces = {}
	if type(data.pieces) == "table" then
		for key, amount in data.pieces do
			if type(key) == "string" and PlayerLogic.parsePieceKey(key) then
				local count = nonNegativeInt(amount)
				if count > 0 then
					pieces[key] = count
				end
			end
		end
	end
	data.pieces = pieces
	data.carriedPieces = {} -- el botín no guardado se pierde al salir

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

	-- Entrenamiento y caminadoras (DEV-006)
	local trained = data.trained
	if type(trained) ~= "number" or trained ~= trained or trained < 0 then
		trained = 0
	end
	data.trained = math.min(trained, Config.MAX_TRAINED)
	-- DEV-008: las caminadoras compartidas pasan a la caminadora del plot.
	-- Quien había desbloqueado la de Acero (×2.5) empieza con su equivalente (nivel 3).
	if type(data.treadmills) == "table" and data.treadmills.advanced == true then
		data.upgrades.treadmill = math.max(data.upgrades.treadmill or 0, 3)
	end
	data.treadmills = nil
	local receipts = {}
	if type(data.receipts) == "table" then
		for _, receipt in data.receipts do
			if type(receipt) == "string" and #receipts < Config.MAX_RECEIPTS then
				table.insert(receipts, receipt)
			end
		end
	end
	data.receipts = receipts

	-- Introducción y pieza del legado (DEV-011)
	data.introDone = data.introDone == true
	data.lastSeen = nonNegativeInt(data.lastSeen) -- DEC-030
	local validVariant = false
	for _, piece in GameData.LegacyPieces do
		if piece.id == data.legacyVariant then
			validVariant = true
		end
	end
	if not validVariant then
		data.legacyVariant = nil
	end
	local remainder = data.incomeRemainder
	if type(remainder) ~= "number" or remainder ~= remainder or remainder < 0 or remainder >= 1 then
		remainder = 0
	end
	data.incomeRemainder = remainder

	-- Ruleta y ajustes (DEV-013)
	local spin = data.spin
	if type(spin) ~= "table" then
		spin = {}
	end
	data.spin = {
		lastDay = (type(spin.lastDay) == "number" and math.floor(spin.lastDay)) or -1,
		extra = math.min(nonNegativeInt(spin.extra), Config.MAX_EXTRA_SPINS),
	}
	local settings = {}
	if type(data.settings) == "table" then
		for _, setting in GameData.Settings do
			local value = data.settings[setting.id]
			if PlayerLogic.validSetting(setting, value) then
				settings[setting.id] = value
			end
		end
	end
	data.settings = settings

	-- Cápsulas y recompensas (DEV-009)
	data.capsules = cleanCounts(data.capsules, GameData.Eggs)
	for capsuleId, amount in data.capsules do
		data.capsules[capsuleId] = math.min(amount, Config.MAX_CAPSULES)
	end
	local daily = data.daily
	if type(daily) ~= "table" then
		daily = {}
	end
	data.daily = {
		streak = math.clamp(nonNegativeInt(daily.streak), 0, #GameData.DailyRewards),
		lastDay = (type(daily.lastDay) == "number" and math.floor(daily.lastDay)) or -1,
	}
	local playtime = data.playtime
	if type(playtime) ~= "table" then
		playtime = {}
	end
	local claimed = {}
	if type(playtime.claimed) == "table" then
		for index, value in playtime.claimed do
			local tier = tonumber(index)
			if value == true and tier and GameData.PlaytimeRewards[tier] then
				claimed[tostring(tier)] = true
			end
		end
	end
	data.playtime = {
		day = (type(playtime.day) == "number" and math.floor(playtime.day)) or -1,
		seconds = nonNegativeInt(playtime.seconds),
		claimed = claimed,
	}

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

-- ¿Tiene el pase de juego? (DEV-006)
function PlayerLogic.hasPass(data, passId)
	return data.passes[passId] == true
end

function PlayerLogic.backpackCapacity(data)
	-- DEC-027: la mochila es fija; solo el pase Mochila Gigante la amplía
	local capacity = Config.BASE_BACKPACK
	if PlayerLogic.hasPass(data, "bigBackpack") then
		capacity += GameData.GamePasses.bigBackpack.backpack
	end
	return capacity
end

function PlayerLogic.partCount(data)
	local total = sumCounts(data.parts) + sumCounts(data.pieces or {}) -- DEC-028: piezas de reloj
	for partId, amount in data.parts do
		if GameData.Parts[partId].protected then
			total -= amount -- las piezas protegidas (herencia) no ocupan espacio
		end
	end
	return total
end

function PlayerLogic.carriedCount(data)
	return sumCounts(data.carried) + sumCounts(data.carriedPieces or {})
end

-- Objetos robados que se pueden llevar por viaje (DEV-013).
function PlayerLogic.carryCapacity(data)
	return Config.BASE_CARRY + PlayerLogic.upgradeLevel(data, "carry") * GameData.Upgrades.carry.step
end

-- Espacio libre en la mochila: capacidad - piezas guardadas - botín encima.
function PlayerLogic.freeSpace(data)
	return math.max(0, PlayerLogic.backpackCapacity(data) - PlayerLogic.partCount(data) - PlayerLogic.carriedCount(data))
end

-- Mascotas que se pueden equipar a la vez (el pase añade una).
function PlayerLogic.petSlots(data)
	local slots = Config.MAX_EQUIPPED_PETS
	if PlayerLogic.hasPass(data, "petSlot") then
		slots += GameData.GamePasses.petSlot.petSlots
	end
	return slots
end

-- Bonus de una mascota. La Mascota Suprema vale 20% más que tu mejor mascota normal.
function PlayerLogic.petBonus(data, petId)
	local pet = GameData.Pets[petId]
	if not pet.exclusive then
		return pet.bonus
	end
	local best = 0
	for ownedId, amount in data.pets do
		local owned = GameData.Pets[ownedId]
		if amount > 0 and not owned.exclusive and owned.bonus > best then
			best = owned.bonus
		end
	end
	return math.max(Config.SUPREME_PET_MIN_BONUS, best * Config.SUPREME_PET_FACTOR)
end

-- Multiplicador de velocidad de las mascotas equipadas (DEV-005).
function PlayerLogic.petMultiplier(data)
	local bonus = 0
	for petId, amount in data.equipped do
		bonus += PlayerLogic.petBonus(data, petId) * amount
	end
	return 1 + bonus
end

-- Multiplicador total: mascotas × pase Corredor VIP (DEC-027: sin mejora de velocidad).
function PlayerLogic.speedMultiplier(data)
	local multiplier = PlayerLogic.petMultiplier(data)
	if PlayerLogic.hasPass(data, "runner") then
		multiplier *= GameData.GamePasses.runner.speedMultiplier
	end
	return multiplier
end

-- Velocidad base (estadística): la inicial + la entrenada (DEC-024).
function PlayerLogic.baseSpeed(data)
	return Config.START_SPEED + data.trained
end

-- Velocidad (estadística) = base × multiplicadores. Es la que abre zonas (DEC-024).
function PlayerLogic.speed(data)
	return PlayerLogic.baseSpeed(data) * PlayerLogic.speedMultiplier(data)
end

-- Velocidad física para una velocidad estadística: curva por tramos en escala
-- logarítmica (Config.SPEED_CURVE) con tope Config.MAX_WALKSPEED (DEC-024).
function PlayerLogic.runSpeed(stat)
	local curve = Config.SPEED_CURVE
	if stat <= curve[1][1] then
		return curve[1][2] * math.max(0, stat) / curve[1][1]
	end
	local physical = curve[#curve][2]
	for index = 1, #curve - 1 do
		local a, b = curve[index], curve[index + 1]
		if stat <= b[1] then
			local t = (math.log10(stat) - math.log10(a[1])) / (math.log10(b[1]) - math.log10(a[1]))
			physical = a[2] + (b[2] - a[2]) * t
			break
		end
	end
	physical = math.max(Config.BASE_WALKSPEED, physical)
	return math.min(Config.MAX_WALKSPEED, math.floor(physical * 10 + 0.5) / 10)
end

-- Velocidad física en las zonas (la más alta que puede alcanzar).
function PlayerLogic.walkSpeed(data)
	return PlayerLogic.runSpeed(PlayerLogic.speed(data))
end

-- Velocidad física en la base: la que el jugador eligió en la barra, con tope (DEC-024).
function PlayerLogic.lobbySpeed(data)
	local chosen = PlayerLogic.getSetting(data, "runSpeed") or Config.LOBBY_MAX_WALKSPEED
	return math.min(PlayerLogic.walkSpeed(data), Config.LOBBY_MAX_WALKSPEED, math.max(Config.BASE_WALKSPEED, chosen))
end

-- Velocidad física dentro de una casa: más lenta para buscar con comodidad (DEC-024).
function PlayerLogic.houseSpeed(data)
	return math.min(PlayerLogic.walkSpeed(data), Config.HOUSE_WALKSPEED)
end

-- Velocidad del dueño de una zona fuera de su casa (DEC-024).
function PlayerLogic.ownerSpeed(zoneIndex)
	local zone = GameData.Zones[zoneIndex]
	if not zone then
		return Config.OWNER_HOUSE_SPEED
	end
	return PlayerLogic.runSpeed(zone.minSpeed) * Config.OWNER_SPEED_FACTOR
end

-- Número grande corto para la interfaz: 950 · 1,5K · 14M · 2,8B · 99,9T (DEC-024).
local BIG_SUFFIXES = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
function PlayerLogic.formatBig(value)
	value = tonumber(value) or 0
	for _, entry in BIG_SUFFIXES do
		if math.abs(value) >= entry[1] then
			local short = value / entry[1]
			local text
			if short >= 100 then
				text = string.format("%d", math.floor(short))
			else
				text = string.format("%.1f", math.floor(short * 10) / 10):gsub("%.0$", "")
			end
			return (text:gsub("%.", ",")) .. entry[2]
		end
	end
	if value % 1 ~= 0 and math.abs(value) < 100 then
		local text = string.format("%.1f", math.floor(value * 10) / 10):gsub("%.0$", "")
		return (text:gsub("%.", ","))
	end
	return tostring(math.floor(value))
end

-- Multiplicador de monedas por ventas, botín y plot: pase VIP × mascotas equipadas
-- (DEC-027: ¼ de la suma de sus bonus de velocidad).
function PlayerLogic.coinMultiplier(data)
	local multiplier = 1 + (PlayerLogic.petMultiplier(data) - 1) * Config.PET_COIN_SHARE
	if PlayerLogic.hasPass(data, "vip") then
		multiplier *= GameData.GamePasses.vip.coinMultiplier
	end
	if PlayerLogic.hasPass(data, "moneyX2") then -- DEC-030
		multiplier *= GameData.GamePasses.moneyX2.coinMultiplier
	end
	return multiplier
end

-- Velocidad a la que cuenta el tiempo jugado para los premios (DEC-030: VIP un 30 % antes).
function PlayerLogic.playtimeRate(data)
	if PlayerLogic.hasPass(data, "vip") then
		return 1 / Config.VIP_PLAYTIME_FACTOR
	end
	return 1
end

-- Ganancia offline del plot (DEC-030): monedas y segundos que cuentan desde
-- data.lastSeen hasta now, con tope de 4 h (8 h con VIP) y al OFFLINE_RATE.
function PlayerLogic.offlineEarnings(data, now)
	if (data.lastSeen or 0) <= 0 then
		return 0, 0
	end
	local cap = Config.OFFLINE_MAX_SECONDS
	if PlayerLogic.hasPass(data, "vip") then
		cap = Config.OFFLINE_MAX_SECONDS_VIP
	end
	local seconds = math.clamp(now - data.lastSeen, 0, cap)
	if seconds < Config.OFFLINE_MIN_SECONDS then
		return 0, 0
	end
	local coins = math.floor(PlayerLogic.museumIncomePerMinute(data) * seconds / 60 * Config.OFFLINE_RATE)
	return coins, seconds
end

-- ¿Tiene la velocidad necesaria para cruzar la puerta y robar en la zona?
function PlayerLogic.canEnterZone(data, zoneIndex)
	local zone = GameData.Zones[zoneIndex]
	if not zone then
		return false
	end
	return PlayerLogic.speed(data) >= zone.minSpeed
end

-- Zona más lejana a la que puede entrar (0 si todavía ninguna).
function PlayerLogic.highestZone(data)
	local highest = 0
	for index in GameData.Zones do
		if PlayerLogic.canEnterZone(data, index) and index > highest then
			highest = index
		end
	end
	return highest
end

function PlayerLogic.jumpHeight(data)
	return Config.BASE_JUMPHEIGHT -- DEC-027: el salto no se mejora
end

-- Suerte que dan los relojes exhibidos en el plot (DEV-008), con tope.
function PlayerLogic.plotLuck(data)
	local luck = 0
	for key, amount in data.museum do
		local info = PlayerLogic.watchInfo(key)
		luck += (info and info.luck or 0) * amount
	end
	return math.min(Config.MAX_PLOT_LUCK, luck)
end

-- Probabilidad (0-1) de robar 2 piezas en vez de 1: mascotas + relojes del plot
-- (DEC-027: la suerte ya no se compra).
function PlayerLogic.extraPartChance(data)
	local petLuck = (PlayerLogic.petMultiplier(data) - 1) * Config.PET_LUCK_SHARE
	local chance = petLuck + PlayerLogic.plotLuck(data)
	return math.min(Config.MAX_EXTRA_PART_CHANCE, chance)
end

-- Multiplicador de entrenamiento de la caminadora del plot (DEV-008).
function PlayerLogic.treadmillMultiplier(data)
	-- DEC-024: cada nivel de la mejora multiplica por step (×2)
	local multiplier = GameData.Upgrades.treadmill.step ^ PlayerLogic.upgradeLevel(data, "treadmill")
	if PlayerLogic.hasPass(data, "turboTreadmill") then
		multiplier *= GameData.TURBO_TREADMILL_FACTOR
	end
	-- Pases de entrenamiento ×2…×512: solo cuenta el más alto (DEC-023)
	local best = 1
	for _, tier in GameData.SPEED_MULTIPLIER_PASSES do
		if tier.factor > best and PlayerLogic.hasPass(data, "speedX" .. tier.factor) then
			best = tier.factor
		end
	end
	return multiplier * best
end

function PlayerLogic.museumSlots(data)
	return Config.BASE_MUSEUM_SLOTS + PlayerLogic.upgradeLevel(data, "museum") * GameData.Upgrades.museum.step
end

function PlayerLogic.museumCount(data)
	return sumCounts(data.museum)
end

-- Monedas por minuto que da un reloj exhibido (DEV-011: 30% de su valor por periodo).
-- key: clave del reloj (DEC-028; también sirve el id de antes)
function PlayerLogic.watchIncomePerMinute(key)
	local info = PlayerLogic.watchInfo(key)
	return (info and info.sell or 0) * Config.PLOT_INCOME_PERCENT * 60 / Config.PLOT_INCOME_PERIOD_SECONDS
end

-- Monedas (con decimales) que da el plot en un ciclo de Config.MUSEUM_TICK_SECONDS.
function PlayerLogic.museumIncome(data)
	local total = 0
	for key, amount in data.museum do
		local info = PlayerLogic.watchInfo(key)
		total += (info and info.sell or 0) * amount
	end
	return total * Config.PLOT_INCOME_PERCENT * Config.MUSEUM_TICK_SECONDS / Config.PLOT_INCOME_PERIOD_SECONDS
end

function PlayerLogic.museumIncomePerMinute(data)
	return PlayerLogic.museumIncome(data) * 60 / Config.MUSEUM_TICK_SECONDS * PlayerLogic.coinMultiplier(data)
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

-- ---------------------------------------------------------------------------
-- Piezas de reloj y relojes con rareza (DEC-028)
-- ---------------------------------------------------------------------------

local function rarityName(index)
	local rarity = GameData.Rarities[index]
	return rarity and rarity.name or "?"
end

-- Clave corta de una pieza: «reloj.clase.rareza» con números (ej.: «3.2.7»).
function PlayerLogic.pieceKey(watchId, classIndex, rarity)
	return string.format("%d.%d.%d", GameData.WatchIndex[watchId] or 0, classIndex, rarity)
end

-- Devuelve watchId, classIndex, rarity o nil si la clave no es válida.
function PlayerLogic.parsePieceKey(key)
	if type(key) ~= "string" then
		return nil
	end
	local w, c, r = key:match("^(%d+)%.(%d+)%.(%d+)$")
	w, c, r = tonumber(w), tonumber(c), tonumber(r)
	local watchId = w and GameData.WatchOrder[w]
	if not watchId or not GameData.PieceClasses[c] or not GameData.Rarities[r] then
		return nil
	end
	return watchId, c, r
end

-- Datos de una pieza para mostrar: nombre, clase, reloj y rareza.
function PlayerLogic.pieceInfo(key)
	local watchId, classIndex, rarity = PlayerLogic.parsePieceKey(key)
	if not watchId then
		return nil
	end
	local watch = GameData.Watches[watchId]
	local class = GameData.PieceClasses[classIndex]
	return {
		key = key,
		watchId = watchId,
		watch = watch,
		classIndex = classIndex,
		className = class.name,
		classId = class.id,
		rarity = rarity,
		rarityName = rarityName(rarity),
		name = string.format("%s de %s", class.name, watch.name),
		holdTime = Config.PIECE_HOLD_BASE + Config.PIECE_HOLD_STEP * (rarity - 1),
	}
end

-- Factor de valor por piezas de otro reloj: −25 % cada una; con las 4, «Genérico» al 10 %.
local function foreignFactor(foreign)
	if foreign >= #GameData.PieceClasses then
		return Config.FOREIGN_GENERIC_FACTOR
	end
	return 1 - Config.FOREIGN_PIECE_PENALTY * foreign
end

-- Valor de un reloj según su base, rareza y piezas ajenas.
local function watchValue(watch, rarity, foreign)
	return math.floor(watch.base * Config.RARITY_VALUE_GROWTH ^ (rarity - 1) * foreignFactor(foreign))
end

-- Monedas que da vender una pieza suelta (DEC-028).
function PlayerLogic.pieceSellValue(key)
	local info = PlayerLogic.pieceInfo(key)
	if not info then
		return 0
	end
	return math.max(1, math.floor(watchValue(info.watch, info.rarity, 0) * Config.PIECE_SELL_FACTOR))
end

-- Probabilidad de subir un escalón de rareza en una zona (DEC-028).
function PlayerLogic.rarityUpChance(zoneIndex, luck)
	local chance = Config.RARITY_UP_BASE + Config.RARITY_UP_PER_ZONE * (math.max(1, zoneIndex) - 1)
	chance += (luck or 0) * Config.RARITY_UP_LUCK
	return math.min(Config.RARITY_UP_MAX, chance)
end

-- Tira una pieza para una casa. rng() devuelve números en [0, 1).
-- Puede salir el reloj exclusivo de la zona (DEV-026: uno en cada zona); si no, uno general.
function PlayerLogic.rollPiece(zoneIndex, luck, rng)
	local exclusive = nil
	for _, watchId in GameData.WatchOrder do
		if GameData.Watches[watchId].zone == zoneIndex then
			exclusive = watchId
		end
	end
	local watchId
	if exclusive and rng() < Config.EXCLUSIVE_PIECE_CHANCE then
		watchId = exclusive
	else
		local total = 0
		for _, id in GameData.WatchOrder do
			total += GameData.Watches[id].weight or 0
		end
		local roll = rng() * total
		for _, id in GameData.WatchOrder do
			roll -= GameData.Watches[id].weight or 0
			if roll < 0 then
				watchId = id
				break
			end
		end
		watchId = watchId or "pocket"
	end
	local classIndex = math.clamp(math.floor(rng() * #GameData.PieceClasses) + 1, 1, #GameData.PieceClasses)
	local rarity = 1
	local up = PlayerLogic.rarityUpChance(zoneIndex, luck)
	while rarity < #GameData.Rarities and rng() < up do
		rarity += 1
	end
	return PlayerLogic.pieceKey(watchId, classIndex, rarity)
end

-- Clave de un reloj armado: «reloj|rareza|piezasAjenas».
function PlayerLogic.watchKey(watchId, rarity, foreign)
	return string.format("%s|%d|%d", watchId, rarity, foreign)
end

-- Devuelve watchId, rarity, foreign. Acepta el id solo (relojes de antes de DEC-028:
-- rareza Común y sin piezas ajenas).
function PlayerLogic.parseWatchKey(key)
	if type(key) ~= "string" then
		return nil
	end
	if GameData.Watches[key] then
		return key, 1, 0
	end
	local id, r, f = key:match("^([%w_]+)|(%d+)|(%d+)$") -- DEV-026: ids con dígitos (rm11)
	r, f = tonumber(r), tonumber(f)
	if not id or not GameData.Watches[id] or not r or not GameData.Rarities[r] or not f or f > #GameData.PieceClasses then
		return nil
	end
	return id, r, f
end

-- Datos de un reloj: nombre con rareza, valor, suerte e ingreso.
function PlayerLogic.watchInfo(key)
	local watchId, rarity, foreign = PlayerLogic.parseWatchKey(key)
	if not watchId then
		return nil
	end
	local watch = GameData.Watches[watchId]
	local name = string.format("%s (%s)", watch.name, rarityName(rarity))
	if foreign >= #GameData.PieceClasses then
		name = string.format("Reloj Genérico (%s)", rarityName(rarity))
	elseif foreign > 0 then
		name ..= string.format(" · %d pieza(s) ajena(s)", foreign)
	end
	return {
		key = key,
		id = watchId,
		watch = watch,
		rarity = rarity,
		rarityName = rarityName(rarity),
		foreign = foreign,
		perfect = foreign == 0,
		name = name,
		sell = watchValue(watch, rarity, foreign),
		luck = (watch.luck or 0) * (1 + Config.RARITY_LUCK_STEP * (rarity - 1)) * foreignFactor(foreign),
		xp = math.floor((watch.xp or 0) * (1 + 0.5 * (rarity - 1))),
	}
end

-- Resultado de armar un reloj con 4 piezas (en orden caja, calibre, esfera, manecillas)
-- para el reloj elegido. Devuelve la info del reloj o nil y el motivo.
-- Rareza: la media de las piezas (hacia abajo), −1 por cada pieza de otro reloj.
function PlayerLogic.assemblePreview(targetId, keys)
	local watch = GameData.Watches[targetId]
	if not watch then
		return nil, "Elige un reloj."
	end
	if type(keys) ~= "table" or #keys ~= #GameData.PieceClasses then
		return nil, "Pon las 4 piezas en los marcos verdes."
	end
	local sum, foreign = 0, 0
	for slot, key in keys do
		local watchId, classIndex, rarity = PlayerLogic.parsePieceKey(key)
		if not watchId then
			return nil, "Pieza no válida."
		end
		if classIndex ~= slot then
			return nil, string.format("El marco %d es para %s.", slot, GameData.PieceClasses[slot].name)
		end
		if watchId ~= targetId then
			foreign += 1
		end
		sum += rarity
	end
	local rarity = math.max(1, math.floor(sum / #keys) - foreign)
	return PlayerLogic.watchInfo(PlayerLogic.watchKey(targetId, rarity, foreign))
end

-- Arma un reloj (DEC-028). request: «indiceReloj:clave1,clave2,clave3,clave4».
-- Devuelve ok, mensaje, subióDeNivel.
function PlayerLogic.craft(data, request)
	if type(request) ~= "string" then
		return false, "Solicitud no válida.", false
	end
	local watchIndex, list = request:match("^(%d+):(.+)$")
	local targetId = GameData.WatchOrder[tonumber(watchIndex or "") or 0]
	if not targetId then
		return false, "Elige un reloj.", false
	end
	local keys = string.split(list, ",")
	local info, reason = PlayerLogic.assemblePreview(targetId, keys)
	if not info then
		return false, reason, false
	end
	local needed = {}
	for _, key in keys do
		needed[key] = (needed[key] or 0) + 1
	end
	for key, amount in needed do
		if (data.pieces[key] or 0) < amount then
			return false, "No tienes esas piezas en tu mochila.", false
		end
	end
	if info.watch.needsLegacy and (data.parts.legacy or 0) < 1 then
		return false, "El Reloj del Legado necesita tu pieza del legado.", false
	end
	if (data.watches[info.key] or 0) >= Config.MAX_WATCHES_PER_TYPE then
		return false, "Ya tienes el máximo de ese reloj.", false
	end
	local levelBefore = PlayerLogic.level(data)
	for key, amount in needed do
		data.pieces[key] -= amount
		if data.pieces[key] <= 0 then
			data.pieces[key] = nil
		end
	end
	if info.watch.needsLegacy then
		data.parts.legacy -= 1
		if data.parts.legacy <= 0 then
			data.parts.legacy = nil
		end
	end
	data.watches[info.key] = (data.watches[info.key] or 0) + 1
	data.xp += info.xp
	data.stats.crafted += 1
	local levelAfter = PlayerLogic.level(data)
	local message = string.format("Armaste: %s (+%d XP)", info.name, info.xp)
	if info.perfect then
		message = string.format("¡Reloj perfecto! %s (+%d XP)", info.name, info.xp)
	end
	if levelAfter > levelBefore then
		message ..= string.format(" · ¡Subiste a nivel %d!", levelAfter)
	end
	return true, message, levelAfter > levelBefore
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
	if stat == "trained10" then
		return math.floor(data.trained * 10 + 1e-6)
	elseif stat == "speed" then
		return math.floor(PlayerLogic.speed(data) + 1e-6) -- DEC-024
	elseif stat == "museum" then
		return PlayerLogic.museumCount(data)
	elseif stat == "upgrades" then
		return sumCounts(data.upgrades)
	end
	return data.stats[stat] or 0
end

-- Paso actual del tutorial y su progreso, o nil si ya terminó.
function PlayerLogic.tutorialStep(data)
	if not data.introDone then
		return nil, 0 -- el tutorial empieza después de la introducción
	end
	local step = GameData.Tutorial[data.tutorial]
	if not step then
		return nil, 0
	end
	return step, math.min(PlayerLogic.tutorialValue(data, step.stat), step.target)
end

-- Vista que el servidor envía al cliente (solo lectura en el cliente).
function PlayerLogic.buildView(data, now)
	now = now or os.time()
	local level, levelXp, levelNeed = PlayerLogic.levelInfo(data.xp)
	local upgradeCosts = {}
	for upgradeId in GameData.Upgrades do
		upgradeCosts[upgradeId] = PlayerLogic.upgradeCost(data, upgradeId) or false
	end
	local petBonuses = {}
	for petId in data.pets do
		petBonuses[petId] = PlayerLogic.petBonus(data, petId)
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
	local canClaimDaily, dailyStreak, untilTomorrow = PlayerLogic.dailyStatus(data, now)
	local canFreeSpin, extraSpins, spinUntil = PlayerLogic.spinStatus(data, now)
	local settingsView = {}
	for _, setting in GameData.Settings do
		settingsView[setting.id] = PlayerLogic.getSetting(data, setting.id)
	end
	local today = PlayerLogic.dayNumber(now)
	local playtimeSeconds, playtimeClaimed = 0, {}
	if data.playtime.day == today then
		playtimeSeconds = data.playtime.seconds
		playtimeClaimed = table.clone(data.playtime.claimed)
	end
	return {
		tutorial = tutorial,
		capsules = table.clone(data.capsules),
		daily = { canClaim = canClaimDaily, streak = dailyStreak, untilTomorrow = untilTomorrow },
		playtime = { seconds = playtimeSeconds, claimed = playtimeClaimed },
		coins = data.coins,
		xp = data.xp,
		level = level,
		levelXp = levelXp,
		levelNeed = levelNeed,
		parts = table.clone(data.parts),
		carried = table.clone(data.carried),
		pieces = table.clone(data.pieces), -- DEC-028
		carriedPieces = table.clone(data.carriedPieces),
		carriedCount = PlayerLogic.carriedCount(data),
		carriedCoins = data.carriedCoins,
		freeSpace = PlayerLogic.freeSpace(data),
		walkSpeed = PlayerLogic.walkSpeed(data),
		speed = PlayerLogic.speed(data), -- estadística que abre zonas (DEC-024)
		lobbySpeed = PlayerLogic.lobbySpeed(data),
		trainPerSecond = Config.TRAIN_RATE * PlayerLogic.treadmillMultiplier(data),
		highestZone = PlayerLogic.highestZone(data),
		watches = table.clone(data.watches),
		museum = table.clone(data.museum),
		upgrades = table.clone(data.upgrades),
		pets = table.clone(data.pets),
		equipped = table.clone(data.equipped),
		petCount = PlayerLogic.petCount(data),
		equippedCount = PlayerLogic.equippedCount(data),
		petMultiplier = PlayerLogic.petMultiplier(data),
		petSlots = PlayerLogic.petSlots(data),
		petBonuses = petBonuses,
		speedMultiplier = PlayerLogic.speedMultiplier(data),
		baseSpeed = PlayerLogic.baseSpeed(data),
		trained = data.trained,
		treadmillMultiplier = PlayerLogic.treadmillMultiplier(data),
		plotLuck = PlayerLogic.plotLuck(data),
		extraPartChance = PlayerLogic.extraPartChance(data),
		passes = table.clone(data.passes),
		coinMultiplier = PlayerLogic.coinMultiplier(data),
		upgradeCosts = upgradeCosts,
		capacity = PlayerLogic.backpackCapacity(data),
		partCount = PlayerLogic.partCount(data),
		museumSlots = PlayerLogic.museumSlots(data),
		museumCount = PlayerLogic.museumCount(data),
		museumIncome = PlayerLogic.museumIncome(data),
		museumIncomePerMinute = PlayerLogic.museumIncomePerMinute(data),
		introDone = data.introDone,
		carryCapacity = PlayerLogic.carryCapacity(data),
		spin = { canFree = canFreeSpin, extra = extraSpins, untilTomorrow = spinUntil },
		settings = settingsView,
		legacyVariant = data.legacyVariant or false,
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
-- lootCoins (opcional): monedas que trae cada pieza en esa zona (DEC-024).
-- Devuelve ok, mensaje, cantidad.
function PlayerLogic.stealPart(data, partId, bonusRoll, lootCoins)
	local part = GameData.Parts[partId]
	if not part then
		return false, "Pieza desconocida.", 0
	end
	local carryRoom = PlayerLogic.carryCapacity(data) - PlayerLogic.carriedCount(data)
	if carryRoom < 1 then
		return false, string.format(
			"Ya llevas %d objeto(s), tu límite por viaje. Vuelve a la base o mejora tu carga en el Puesto de Carga.",
			PlayerLogic.carriedCount(data)
		), 0
	end
	local free = math.min(PlayerLogic.freeSpace(data), carryRoom)
	if PlayerLogic.freeSpace(data) < 1 then
		return false, "Mochila llena: vuelve a la base, fabrica relojes o vende piezas.", 0
	end
	local amount = 1
	if free >= 2 and bonusRoll < PlayerLogic.extraPartChance(data) then
		amount = 2
	end
	data.carried[partId] = (data.carried[partId] or 0) + amount
	local coins = math.max(0, math.floor(lootCoins or 0)) * amount
	data.carriedCoins = (data.carriedCoins or 0) + coins
	local message = string.format("Robaste %d %s (%s). ¡Llévalo a la base!", amount, part.name, part.rarity)
	if coins > 0 then
		message = string.format(
			"Robaste %d %s (%s) y %s monedas. ¡Llévalo a la base!",
			amount,
			part.name,
			part.rarity,
			PlayerLogic.formatBig(math.floor(coins * PlayerLogic.coinMultiplier(data))) -- DEV-027: lo que se cobrará al guardar
		)
	end
	return true, message, amount
end

-- Roba una pieza de reloj en una casa (DEC-028): va al botín con sus monedas.
-- Devuelve ok, mensaje, cantidad.
function PlayerLogic.stealPiece(data, key, bonusRoll, lootCoins)
	local info = PlayerLogic.pieceInfo(key)
	if not info then
		return false, "Pieza desconocida.", 0
	end
	local carryRoom = PlayerLogic.carryCapacity(data) - PlayerLogic.carriedCount(data)
	if carryRoom < 1 then
		return false, string.format(
			"Ya llevas %d objeto(s), tu límite por viaje. Vuelve a la base o mejora tu carga en Mochila y Carga.",
			PlayerLogic.carriedCount(data)
		), 0
	end
	if PlayerLogic.freeSpace(data) < 1 then
		return false, "Mochila llena: vuelve a la base, arma relojes o vende piezas.", 0
	end
	local amount = 1
	if math.min(PlayerLogic.freeSpace(data), carryRoom) >= 2 and bonusRoll < PlayerLogic.extraPartChance(data) then
		amount = 2
	end
	data.carriedPieces[key] = (data.carriedPieces[key] or 0) + amount
	local coins = math.max(0, math.floor(lootCoins or 0)) * amount
	data.carriedCoins = (data.carriedCoins or 0) + coins
	local message = string.format("Robaste %d × %s (%s). ¡Llévalo a la base!", amount, info.name, info.rarityName)
	if coins > 0 then
		message = string.format(
			"Robaste %d × %s (%s) y %s monedas. ¡Llévalo a la base!",
			amount,
			info.name,
			info.rarityName,
			PlayerLogic.formatBig(math.floor(coins * PlayerLogic.coinMultiplier(data))) -- DEV-027: lo que se cobrará al guardar
		)
	end
	return true, message, amount
end

-- «1 pieza» / «N piezas» para los avisos (DEV-027).
function PlayerLogic.piecesText(amount)
	if amount == 1 then
		return "1 pieza"
	end
	return string.format("%d piezas", amount)
end

-- Guarda el botín al llegar a la base. Devuelve las piezas guardadas y las
-- monedas cobradas (con el multiplicador de monedas; DEC-024).
function PlayerLogic.depositLoot(data)
	local total = 0
	for partId, amount in data.carried do
		data.parts[partId] = (data.parts[partId] or 0) + amount
		total += amount
	end
	data.carried = {}
	for key, amount in data.carriedPieces or {} do -- DEC-028
		data.pieces[key] = (data.pieces[key] or 0) + amount
		total += amount
	end
	data.carriedPieces = {}
	data.stats.collected += total
	local coins = math.floor((data.carriedCoins or 0) * PlayerLogic.coinMultiplier(data))
	data.carriedCoins = 0
	if coins > 0 then
		data.coins += coins
		data.stats.earned += coins
	end
	return total, coins
end

-- El dueño te atrapó (o caíste): se pierde el botín. Devuelve cuántas piezas se perdieron.
function PlayerLogic.loseLoot(data)
	local total = PlayerLogic.carriedCount(data)
	data.carried = {}
	data.carriedPieces = {}
	data.carriedCoins = 0
	return total
end

-- Vende relojes (DEC-028: key es la clave del reloj con su rareza).
function PlayerLogic.sell(data, key, amount)
	local info = PlayerLogic.watchInfo(key)
	if not info then
		return false, "Ese reloj no existe."
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida."
	end
	local owned = data.watches[key] or 0
	if owned < amount then
		return false, "No tienes suficientes relojes de ese tipo."
	end
	local earned = math.floor(info.sell * amount * PlayerLogic.coinMultiplier(data))
	removeCount(data.watches, key, amount)
	data.coins += earned
	data.stats.sold += amount
	data.stats.earned += earned
	return true, string.format("Vendiste %d × %s por %s monedas.", amount, info.name, PlayerLogic.formatBig(earned))
end

-- Vende piezas de reloj sueltas (DEC-028): el 5 % del reloj con su rareza.
function PlayerLogic.sellPiece(data, key, amount)
	local info = PlayerLogic.pieceInfo(key)
	if not info then
		return false, "Pieza desconocida."
	end
	if not validAmount(amount) then
		return false, "Cantidad no válida."
	end
	if (data.pieces[key] or 0) < amount then
		return false, "No tienes esas piezas."
	end
	local earned = math.floor(PlayerLogic.pieceSellValue(key) * amount * PlayerLogic.coinMultiplier(data))
	removeCount(data.pieces, key, amount)
	data.coins += earned
	data.stats.earned += earned
	return true, string.format("Vendiste %d × %s (%s) por %s monedas.", amount, info.name, info.rarityName, PlayerLogic.formatBig(earned))
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
	if part.protected then
		return false, part.name .. " no se vende: guárdala o úsala en el Reloj del Legado."
	end
	local earned = math.floor(part.sell * amount * PlayerLogic.coinMultiplier(data))
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
	if part.protected then
		return false, part.name .. " no se puede tirar."
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

function PlayerLogic.display(data, key)
	local info = PlayerLogic.watchInfo(key)
	if not info then
		return false, "Ese reloj no existe."
	end
	if (data.watches[key] or 0) < 1 then
		return false, "No tienes ese reloj en tu inventario."
	end
	if PlayerLogic.museumCount(data) >= PlayerLogic.museumSlots(data) then
		return false, "No quedan vitrinas libres. Mejora tu plot o retira un reloj."
	end
	removeCount(data.watches, key, 1)
	data.museum[key] = (data.museum[key] or 0) + 1
	return true, string.format("%s exhibido en tu plot.", info.name)
end

function PlayerLogic.withdraw(data, key)
	local info = PlayerLogic.watchInfo(key)
	if not info then
		return false, "Ese reloj no existe."
	end
	if (data.museum[key] or 0) < 1 then
		return false, "Ese reloj no está exhibido."
	end
	if (data.watches[key] or 0) >= Config.MAX_WATCHES_PER_TYPE then
		return false, "Tu inventario de ese reloj está lleno."
	end
	removeCount(data.museum, key, 1)
	data.watches[key] = (data.watches[key] or 0) + 1
	return true, string.format("%s retirado de tu plot.", info.name)
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
	if part.protected then
		return false, part.name .. " no se entrega al Cronómetro.", 0
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

-- ---------------------------------------------------------------------------
-- Mascotas (DEV-005)
-- ---------------------------------------------------------------------------

function PlayerLogic.petCount(data)
	return sumCounts(data.pets)
end

function PlayerLogic.equippedCount(data)
	return sumCounts(data.equipped)
end

-- Elige una mascota de un huevo. roll en [0, 1). Devuelve petId o nil.
function PlayerLogic.rollPet(eggId, roll)
	local egg = GameData.Eggs[eggId]
	if not egg then
		return nil
	end
	local total = 0
	for _, petId in GameData.PetOrder do
		total += egg.chances[petId] or 0
	end
	local target = roll * total
	local last = nil
	for _, petId in GameData.PetOrder do
		local weight = egg.chances[petId] or 0
		if weight > 0 then
			last = petId
			target -= weight
			if target < 0 then
				return petId
			end
		end
	end
	return last
end

-- Añade una mascota; se equipa sola si hay espacio. Devuelve ok, mensaje.
function PlayerLogic.grantPet(data, petId)
	local pet = GameData.Pets[petId]
	if not pet or pet.exclusive then
		return false, "Mascota desconocida."
	end
	if PlayerLogic.petCount(data) >= Config.MAX_PETS then
		return false, string.format("Tienes el máximo de %d mascotas. Libera alguna.", Config.MAX_PETS)
	end
	data.pets[petId] = (data.pets[petId] or 0) + 1
	local extra = ""
	if PlayerLogic.equippedCount(data) < PlayerLogic.petSlots(data) then
		data.equipped[petId] = (data.equipped[petId] or 0) + 1
		extra = " (equipada)"
	end
	return true, string.format("¡%s %s! +%d%% de velocidad%s", pet.name, pet.rarity, math.floor(pet.bonus * 100 + 0.5), extra)
end

-- Compra y abre un huevo. Devuelve ok, mensaje, petId.
function PlayerLogic.hatchEgg(data, eggId, roll)
	local egg = GameData.Eggs[eggId]
	if not egg then
		return false, "Esa cápsula no existe.", nil
	end
	if not egg.cost then
		return false, egg.name .. " solo se consigue con Robux.", nil
	end
	if PlayerLogic.petCount(data) >= Config.MAX_PETS then
		return false, string.format("Tienes el máximo de %d mascotas. Libera alguna.", Config.MAX_PETS), nil
	end
	if data.coins < egg.cost then
		return false, string.format("Te faltan %d monedas.", egg.cost - data.coins), nil
	end
	local petId = PlayerLogic.rollPet(eggId, roll)
	data.coins -= egg.cost
	local _, message = PlayerLogic.grantPet(data, petId)
	return true, egg.name .. ": " .. message, petId
end

function PlayerLogic.equipPet(data, petId)
	local pet = GameData.Pets[petId]
	if not pet then
		return false, "Mascota desconocida."
	end
	if (data.pets[petId] or 0) <= (data.equipped[petId] or 0) then
		return false, "No tienes otra " .. pet.name .. " sin equipar."
	end
	if PlayerLogic.equippedCount(data) >= PlayerLogic.petSlots(data) then
		return false, string.format("Solo puedes equipar %d mascotas.", PlayerLogic.petSlots(data))
	end
	data.equipped[petId] = (data.equipped[petId] or 0) + 1
	return true, pet.name .. " equipada."
end

function PlayerLogic.unequipPet(data, petId)
	local pet = GameData.Pets[petId]
	if not pet then
		return false, "Mascota desconocida."
	end
	if (data.equipped[petId] or 0) < 1 then
		return false, pet.name .. " no está equipada."
	end
	removeCount(data.equipped, petId, 1)
	return true, pet.name .. " desequipada."
end

-- Equipa las mascotas con mayor bonus.
function PlayerLogic.equipBest(data)
	data.equipped = {}
	local slots = PlayerLogic.petSlots(data)
	for index = #GameData.PetOrder, 1, -1 do
		local petId = GameData.PetOrder[index]
		local amount = math.min(data.pets[petId] or 0, slots)
		if amount > 0 then
			data.equipped[petId] = amount
			slots -= amount
		end
	end
	return true, string.format("Mejores mascotas equipadas: velocidad ×%.2f", PlayerLogic.petMultiplier(data))
end

-- Libera una mascota que no esté equipada.
function PlayerLogic.releasePet(data, petId)
	local pet = GameData.Pets[petId]
	if not pet then
		return false, "Mascota desconocida."
	end
	if pet.exclusive then
		return false, pet.name .. " es exclusiva de un pase y no se puede liberar."
	end
	if (data.pets[petId] or 0) - (data.equipped[petId] or 0) < 1 then
		return false, "Desequipa esa mascota antes de liberarla."
	end
	removeCount(data.pets, petId, 1)
	return true, pet.name .. " liberada."
end

-- ---------------------------------------------------------------------------
-- Pases, entrenamiento y productos con Robux (DEV-006)
-- ---------------------------------------------------------------------------

-- Aplica los pases que Roblox confirma que posee (tabla [passId] = true).
-- Da o quita la Mascota Suprema y ajusta las mascotas equipadas a las ranuras.
function PlayerLogic.setPasses(data, owned)
	local passes = {}
	for passId, value in owned do
		if GameData.GamePasses[passId] and value == true then
			passes[passId] = true
		end
	end
	data.passes = passes

	if passes.supremePet then
		if (data.pets.supreme or 0) < 1 then
			data.pets.supreme = 1
			if PlayerLogic.equippedCount(data) < PlayerLogic.petSlots(data) then
				data.equipped.supreme = 1
			end
		end
	else
		data.pets.supreme = nil
		data.equipped.supreme = nil
	end

	-- Si perdió ranuras, desequipa empezando por las de menor bonus.
	local index = 1
	while PlayerLogic.equippedCount(data) > PlayerLogic.petSlots(data) and index <= #GameData.PetOrder do
		local petId = GameData.PetOrder[index]
		if (data.equipped[petId] or 0) > 0 then
			removeCount(data.equipped, petId, 1)
		else
			index += 1
		end
	end
end

-- Entrena en la caminadora del plot durante `seconds`. Devuelve la velocidad ganada.
function PlayerLogic.trainTick(data, seconds)
	local before = data.trained
	data.trained = math.min(
		Config.MAX_TRAINED,
		before + Config.TRAIN_RATE * seconds * PlayerLogic.treadmillMultiplier(data)
	)
	return data.trained - before
end

function PlayerLogic.hasReceipt(data, purchaseId)
	return table.find(data.receipts, purchaseId) ~= nil
end

function PlayerLogic.addReceipt(data, purchaseId)
	table.insert(data.receipts, purchaseId)
	while #data.receipts > Config.MAX_RECEIPTS do
		table.remove(data.receipts, 1)
	end
end

-- Entrega un producto comprado con Robux. roll en [0, 1) para huevos.
-- Devuelve ok, mensaje.
function PlayerLogic.grantProduct(data, productId, roll)
	local product = GameData.Products[productId]
	if not product then
		return false, "Producto desconocido."
	end
	if product.coins then
		data.coins += product.coins
		return true, string.format("Compra recibida: +%d monedas.", product.coins)
	end
	if product.trained then
		data.trained = math.min(Config.MAX_TRAINED, data.trained + product.trained)
		return true, string.format("Compra recibida: +%s de velocidad entrenada.", PlayerLogic.formatBig(product.trained))
	end
	if product.trainSeconds then
		-- DEC-024: minutos de entrenamiento al instante, con el multiplicador de tu caminadora
		local gained = PlayerLogic.trainTick(data, product.trainSeconds)
		return true, string.format("Compra recibida: +%s de velocidad entrenada.", PlayerLogic.formatBig(gained))
	end
	if product.spins then
		data.spin.extra = math.min(Config.MAX_EXTRA_SPINS, data.spin.extra + product.spins)
		return true, string.format("Compra recibida: +%d giro(s) de ruleta.", product.spins)
	end
	if product.egg then
		-- La cápsula comprada va a la Mochila: nunca se pierde aunque no quepan mascotas.
		local _, message = PlayerLogic.giveReward(data, { capsule = product.egg, amount = 1 })
		return true, "Compra recibida: " .. message
	end
	return false, "Producto sin contenido."
end

-- ---------------------------------------------------------------------------
-- Cápsulas y recompensas (DEV-009)
-- ---------------------------------------------------------------------------

-- Día (UTC) de un instante en segundos Unix.
function PlayerLogic.dayNumber(now)
	return math.floor(now / 86400)
end

-- Entrega una recompensa { coins = n } o { capsule = id, amount = n }. Devuelve ok, mensaje.
function PlayerLogic.giveReward(data, reward)
	if reward.coins then
		data.coins += reward.coins
		return true, string.format("+%d monedas", reward.coins)
	end
	if reward.trained then
		data.trained = math.min(Config.MAX_TRAINED, data.trained + reward.trained)
		return true, string.format("+%s de velocidad entrenada", PlayerLogic.formatBig(reward.trained))
	end
	if reward.trainSeconds then
		-- DEC-024: tiempo de entrenamiento al instante con el multiplicador de tu caminadora
		local gained = PlayerLogic.trainTick(data, reward.trainSeconds)
		return true, string.format("+%s de velocidad entrenada", PlayerLogic.formatBig(gained))
	end
	local capsule = GameData.Eggs[reward.capsule]
	if capsule then
		local amount = reward.amount or 1
		data.capsules[reward.capsule] = math.min(Config.MAX_CAPSULES, (data.capsules[reward.capsule] or 0) + amount)
		return true, string.format("+%d %s (en tu Mochila)", amount, capsule.name)
	end
	return false, "Recompensa vacía."
end

-- Texto corto de una recompensa para la interfaz.
function PlayerLogic.rewardText(reward)
	if reward.coins then
		return string.format("%d monedas", reward.coins)
	end
	if reward.trained then
		return string.format("+%s de velocidad", PlayerLogic.formatBig(reward.trained))
	end
	if reward.trainSeconds then
		return string.format("%d s de entrenamiento", reward.trainSeconds)
	end
	local capsule = GameData.Eggs[reward.capsule]
	return string.format("%d× %s", reward.amount or 1, capsule and capsule.name or "?")
end

-- Abre una cápsula de la Mochila. Devuelve ok, mensaje, petId.
function PlayerLogic.openCapsule(data, capsuleId, roll)
	local capsule = GameData.Eggs[capsuleId]
	if not capsule then
		return false, "Esa cápsula no existe.", nil
	end
	if (data.capsules[capsuleId] or 0) < 1 then
		return false, "No tienes " .. capsule.name .. ".", nil
	end
	if PlayerLogic.petCount(data) >= Config.MAX_PETS then
		return false, string.format("Tienes el máximo de %d mascotas. Libera alguna.", Config.MAX_PETS), nil
	end
	local petId = PlayerLogic.rollPet(capsuleId, roll)
	removeCount(data.capsules, capsuleId, 1)
	local _, message = PlayerLogic.grantPet(data, petId)
	return true, capsule.name .. ": " .. message, petId
end

-- Estado de la recompensa diaria: puedeReclamar, díaDeLaRacha (1-7), segundosHastaMañana.
function PlayerLogic.dailyStatus(data, now)
	local today = PlayerLogic.dayNumber(now)
	local nextStreak = 1
	if data.daily.lastDay == today - 1 or data.daily.lastDay == today then
		nextStreak = data.daily.streak % #GameData.DailyRewards + 1
	end
	local untilTomorrow = (today + 1) * 86400 - now
	return data.daily.lastDay ~= today, nextStreak, untilTomorrow
end

function PlayerLogic.claimDaily(data, now)
	local canClaim, streak = PlayerLogic.dailyStatus(data, now)
	if not canClaim then
		return false, "Ya reclamaste la recompensa de hoy. Vuelve mañana."
	end
	data.daily.lastDay = PlayerLogic.dayNumber(now)
	data.daily.streak = streak
	local _, message = PlayerLogic.giveReward(data, GameData.DailyRewards[streak])
	return true, string.format("Recompensa diaria (día %d): %s", streak, message)
end

-- Pone a cero el tiempo jugado si cambió el día.
local function syncPlaytimeDay(data, now)
	local today = PlayerLogic.dayNumber(now)
	if data.playtime.day ~= today then
		data.playtime = { day = today, seconds = 0, claimed = {} }
	end
end

function PlayerLogic.addPlaytime(data, now, seconds)
	syncPlaytimeDay(data, now)
	data.playtime.seconds += math.max(0, math.floor(seconds))
	return data.playtime.seconds
end

function PlayerLogic.claimPlaytime(data, now, tierIndex)
	syncPlaytimeDay(data, now)
	local index = tonumber(tierIndex)
	local tier = index and GameData.PlaytimeRewards[index]
	if not tier then
		return false, "Esa recompensa no existe."
	end
	local key = tostring(index)
	if data.playtime.claimed[key] then
		return false, "Ya reclamaste esa recompensa hoy."
	end
	if data.playtime.seconds < tier.minutes * 60 then
		return false, string.format("Juega %d minutos hoy para reclamarla.", tier.minutes)
	end
	data.playtime.claimed[key] = true
	local _, message = PlayerLogic.giveReward(data, tier.reward)
	return true, string.format("Premio por %d minutos: %s", tier.minutes, message)
end

-- ---------------------------------------------------------------------------
-- Introducción y pieza del legado (DEV-011)
-- ---------------------------------------------------------------------------

function PlayerLogic.legacyPiece(data)
	for _, piece in GameData.LegacyPieces do
		if piece.id == data.legacyVariant then
			return piece
		end
	end
	return nil
end

-- Recoge la pieza del legado (una sola vez) y termina la introducción.
-- roll en [0, 1) elige la variante. Devuelve ok, mensaje.
function PlayerLogic.claimLegacy(data, roll)
	if data.introDone or data.legacyVariant then
		return false, "Ya recogiste tu pieza del legado."
	end
	local index = math.clamp(math.floor(roll * #GameData.LegacyPieces) + 1, 1, #GameData.LegacyPieces)
	local piece = GameData.LegacyPieces[index]
	data.legacyVariant = piece.id
	-- No ocupa la mochila de robo: es una herencia.
	data.parts.legacy = (data.parts.legacy or 0) + 1
	data.introDone = true
	return true, string.format("Encontraste: %s. %s Guárdala o úsala en el Reloj del Legado.", piece.name, piece.desc)
end

-- ---------------------------------------------------------------------------
-- Ruleta diaria y ajustes (DEV-013)
-- ---------------------------------------------------------------------------

-- Estado de la ruleta: giroGratisDisponible, girosExtra, segundosHastaMañana.
function PlayerLogic.spinStatus(data, now)
	local today = PlayerLogic.dayNumber(now)
	return data.spin.lastDay ~= today, data.spin.extra, (today + 1) * 86400 - now
end

-- Premio de la ruleta según roll en [0, 1). Devuelve el índice.
function PlayerLogic.rollSpin(roll)
	local total = 0
	for _, prize in GameData.SpinPrizes do
		total += prize.weight
	end
	local target = roll * total
	for index, prize in GameData.SpinPrizes do
		target -= prize.weight
		if target < 0 then
			return index
		end
	end
	return #GameData.SpinPrizes
end

-- Gira la ruleta: usa el giro gratis del día o, si ya se usó, un giro extra.
-- Devuelve ok, mensaje, índiceDelPremio.
function PlayerLogic.spinWheel(data, now, roll)
	local free, extra = PlayerLogic.spinStatus(data, now)
	if free then
		data.spin.lastDay = PlayerLogic.dayNumber(now)
	elseif extra > 0 then
		data.spin.extra -= 1
	else
		return false, "Ya giraste hoy. Vuelve mañana o consigue un giro extra.", nil
	end
	local index = PlayerLogic.rollSpin(roll)
	local prize = GameData.SpinPrizes[index]
	local _, message = PlayerLogic.giveReward(data, prize.reward)
	return true, "Ruleta: " .. message, index
end

function PlayerLogic.validSetting(setting, value)
	if type(value) ~= "number" or value % 1 ~= 0 then
		return false
	end
	if setting.kind == "toggle" then
		return value == 0 or value == 1
	end
	if setting.kind == "range" then
		return value >= setting.min and value <= setting.max -- DEC-024
	end
	return value >= 1 and value <= #setting.options
end

function PlayerLogic.getSetting(data, settingId)
	for _, setting in GameData.Settings do
		if setting.id == settingId then
			local value = data.settings[settingId]
			if value == nil then
				return setting.default
			end
			return value
		end
	end
	return nil
end

function PlayerLogic.setSetting(data, settingId, value)
	for _, setting in GameData.Settings do
		if setting.id == settingId then
			if not PlayerLogic.validSetting(setting, value) then
				return false, "Valor no válido."
			end
			data.settings[settingId] = value
			return true, "Ajuste guardado."
		end
	end
	return false, "Ese ajuste no existe."
end

-- Suma el ingreso pasivo del museo. Devuelve las monedas ganadas.
function PlayerLogic.collectIncome(data)
	-- Las fracciones se acumulan para que los relojes baratos también paguen.
	local exact = PlayerLogic.museumIncome(data) * PlayerLogic.coinMultiplier(data) + data.incomeRemainder
	local income = math.floor(exact)
	data.incomeRemainder = exact - income
	if income > 0 then
		data.coins += income
		data.stats.earned += income
	end
	return income
end

return PlayerLogic
