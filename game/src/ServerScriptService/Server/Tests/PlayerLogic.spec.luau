--[[
	Pruebas de PlayerLogic (reglas puras del juego).
	Las ejecuta Tests/RunTests al pulsar Play en Studio.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)

return function(t)
	local function giveParts(data, cost)
		for partId, amount in cost do
			data.parts[partId] = (data.parts[partId] or 0) + amount
		end
	end

	t.test("newData empieza vacío", function()
		local data = PlayerLogic.newData()
		t.eq(data.coins, Config.START_COINS, "monedas iniciales")
		t.eq(PlayerLogic.partCount(data), 0, "sin piezas")
		t.eq(PlayerLogic.level(data), 1, "nivel 1")
	end)

	t.test("reconcile repara datos dañados", function()
		local data = PlayerLogic.reconcile({
			coins = -50,
			xp = "mucho",
			parts = { gear = 3, inventada = 9, spring = -2 },
			upgrades = { museum = 99, falsa = 1, backpack = 3 },
		})
		t.eq(data.coins, 0, "monedas negativas → 0")
		t.eq(data.xp, 0, "xp inválida → 0")
		t.eq(data.parts.gear, 3, "conserva piezas válidas")
		t.eq(data.parts.inventada, nil, "descarta piezas desconocidas")
		t.eq(data.parts.spring, nil, "descarta cantidades negativas")
		t.eq(data.upgrades.museum, GameData.Upgrades.museum.maxLevel, "limita nivel de mejora")
		t.eq(data.upgrades.backpack, nil, "DEC-027: descarta mejoras eliminadas")
		t.eq(data.upgrades.falsa, nil, "descarta mejoras desconocidas")
		t.eq(data.stats.crafted, 0, "crea estadísticas")
		t.ok(type(PlayerLogic.reconcile(nil)) == "table", "nil → datos nuevos")
	end)

	t.test("levelInfo calcula niveles", function()
		local step = Config.XP_PER_LEVEL_STEP
		t.eq(PlayerLogic.levelInfo(0), 1, "0 xp = nivel 1")
		t.eq(PlayerLogic.levelInfo(step - 1), 1, "justo antes del nivel 2")
		t.eq(PlayerLogic.levelInfo(step), 2, "nivel 2")
		t.eq(PlayerLogic.levelInfo(step + step * 2), 3, "nivel 3")
		local level = PlayerLogic.levelInfo(10 ^ 9)
		t.eq(level, Config.MAX_LEVEL, "no supera el nivel máximo")
	end)

	t.test("addPart respeta la capacidad de la mochila", function()
		local data = PlayerLogic.newData()
		for _ = 1, Config.BASE_BACKPACK do
			t.ok(PlayerLogic.addPart(data, "gear"), "cabe la pieza")
		end
		local ok = PlayerLogic.addPart(data, "gear")
		t.ok(not ok, "mochila llena rechaza la pieza")
		t.eq(PlayerLogic.partCount(data), Config.BASE_BACKPACK, "no pasa del límite")
		t.ok(not PlayerLogic.addPart(PlayerLogic.newData(), "inventada"), "rechaza piezas desconocidas")
	end)

	-- DEC-028: un juego de 4 piezas del mismo reloj con la misma rareza
	local function pieceSet(watchId, rarity)
		local keys = {}
		for classIndex in GameData.PieceClasses do
			table.insert(keys, PlayerLogic.pieceKey(watchId, classIndex, rarity))
		end
		return keys
	end
	local function givePieces(data, keys)
		for _, key in keys do
			data.pieces[key] = (data.pieces[key] or 0) + 1
		end
	end
	local function craftRequest(watchId, keys)
		return tostring(GameData.WatchIndex[watchId]) .. ":" .. table.concat(keys, ",")
	end

	t.test("DEC-028: armar un reloj con 4 piezas consume las piezas y da XP", function()
		local data = PlayerLogic.newData()
		local keys = pieceSet("pocket", 1)
		t.ok(not PlayerLogic.craft(data, craftRequest("pocket", keys)), "sin piezas no arma")
		givePieces(data, keys)
		local ok, message = PlayerLogic.craft(data, craftRequest("pocket", keys))
		t.ok(ok, "arma con las 4 piezas")
		t.ok(string.find(message, "perfecto") ~= nil, "4 piezas del mismo reloj: reloj perfecto")
		local key = PlayerLogic.watchKey("pocket", 1, 0)
		t.eq(data.watches[key], 1, "suma el reloj con su rareza")
		t.eq(PlayerLogic.partCount(data), 0, "consume las piezas")
		t.ok(data.xp > 0, "da XP")
		t.ok(not PlayerLogic.craft(data, craftRequest("pocket", { keys[2], keys[1], keys[3], keys[4] })), "el orden de los marcos importa")
	end)

	t.test("DEC-028: pieza de otro reloj: −1 rareza y −25 % por pieza; 4 ajenas = Genérico", function()
		local perfect = PlayerLogic.assemblePreview("chrono", pieceSet("chrono", 5))
		t.eq(perfect.rarity, 5, "la media de rarezas sin penalizar")
		t.ok(perfect.perfect, "reloj perfecto")
		local mixed = pieceSet("chrono", 5)
		mixed[3] = PlayerLogic.pieceKey("wrist", 3, 5)
		local one = PlayerLogic.assemblePreview("chrono", mixed)
		t.eq(one.rarity, 4, "1 ajena: −1 rareza")
		t.eq(one.foreign, 1, "cuenta la pieza ajena")
		t.ok(
			math.abs(one.sell - GameData.Watches.chrono.base * Config.RARITY_VALUE_GROWTH ^ 3 * 0.75) < 1,
			"1 ajena: 75 % del valor de su rareza"
		)
		t.ok(one.luck < perfect.luck, "pierde suerte")
		local generic = PlayerLogic.assemblePreview("chrono", pieceSet("wrist", 5))
		t.eq(generic.foreign, 4, "4 ajenas")
		t.ok(string.find(generic.name, "Genérico") ~= nil, "se llama Reloj Genérico")
	end)

	t.test("DEC-028: valores, mejor reloj y relojes antiguos", function()
		t.eq(#GameData.WatchOrder, 18, "18 relojes (6 generales y 12 de lujo, DEV-026)")
		local exclusive = 0
		for _, watchId in GameData.WatchOrder do
			local watch = GameData.Watches[watchId]
			t.ok(watch.base > 0 and watch.caliber ~= nil, watch.name .. " tiene valor y calibre")
			if watch.zone then
				exclusive += 1
				t.ok(watch.zone >= 1 and watch.zone <= 12, watch.name .. ": exclusivo de una zona de 1 a 12")
				t.ok(string.find(watch.name, "&") == nil, watch.name .. ": sin «&» (rompe el texto enriquecido)")
			end
		end
		t.eq(exclusive, 12, "un reloj de lujo exclusivo en cada zona")
		local zones = {}
		for _, watchId in GameData.WatchOrder do
			local zone = GameData.Watches[watchId].zone
			if zone then
				t.ok(not zones[zone], "un solo exclusivo en la zona " .. zone)
				zones[zone] = true
			end
		end
		local best = PlayerLogic.watchInfo(PlayerLogic.watchKey("astronomia", 12, 0))
		t.ok(best.sell >= 1.5e12 and best.sell <= 1.95e12, "el mejor reloj vale entre 1.500T y 1.950T")
		t.ok(PlayerLogic.watchInfo(PlayerLogic.watchKey("rm11", 3, 1)) ~= nil, "lee claves de relojes con dígitos (rm11)")
		local old = PlayerLogic.watchInfo("pocket")
		t.ok(old ~= nil and old.rarity == 1 and old.foreign == 0, "un reloj guardado antes es Común y sin ajenas")
		local data = PlayerLogic.reconcile({ watches = { pocket = 2, ["chrono|3|1"] = 1, ["malo|1|0"] = 4 } })
		t.eq(data.watches.pocket, 2, "conserva relojes antiguos")
		t.eq(data.watches["chrono|3|1"], 1, "conserva relojes con rareza")
		t.eq(data.watches["malo|1|0"], nil, "descarta claves inválidas")
	end)

	t.test("DEC-028: tirada de piezas por zona y exclusivos", function()
		local rng = Random.new(7)
		local function nextNumber()
			return rng:NextNumber()
		end
		local function averageRarity(zoneIndex)
			local sum = 0
			for _ = 1, 2000 do
				local _, _, rarity = PlayerLogic.parsePieceKey(PlayerLogic.rollPiece(zoneIndex, 0, nextNumber))
				sum += rarity
			end
			return sum / 2000
		end
		t.ok(averageRarity(12) > averageRarity(1) + 0.5, "las zonas lejanas dan rarezas más altas")
		local exclusiveSeen, foreignExclusive = false, false
		for _ = 1, 500 do
			local watchId = PlayerLogic.parsePieceKey(PlayerLogic.rollPiece(10, 0, nextNumber))
			if watchId == "tourbillon" then
				exclusiveSeen = true
			elseif GameData.Watches[watchId].zone then
				foreignExclusive = true
			end
		end
		t.ok(exclusiveSeen, "en la zona 10 sale su reloj exclusivo")
		t.ok(not foreignExclusive, "los exclusivos de otras zonas no salen")
		t.ok(PlayerLogic.parsePieceKey("99.1.1") == nil and PlayerLogic.parsePieceKey("1.9.1") == nil, "claves inválidas")
	end)

	t.test("DEC-028: robar piezas de reloj, guardarlas, venderlas y el Reloj del Legado", function()
		local data = PlayerLogic.newData()
		local key = PlayerLogic.pieceKey("royal", 2, 4)
		t.ok(PlayerLogic.stealPiece(data, key, 0.99, 50), "roba la pieza")
		t.eq(PlayerLogic.carriedCount(data), 1, "va al botín")
		local saved, coins = PlayerLogic.depositLoot(data)
		t.eq(saved, 1, "se guarda en la base")
		t.eq(coins, 50, "con sus monedas")
		t.eq(data.pieces[key], 1, "queda en la mochila")
		local value = PlayerLogic.pieceSellValue(key)
		t.ok(PlayerLogic.sellPiece(data, key, 1), "se vende suelta")
		t.eq(data.coins, 50 + value, "paga su valor")
		-- Legado
		local legacy = PlayerLogic.newData()
		PlayerLogic.claimLegacy(legacy, 0)
		local keys = pieceSet("legacy", 2)
		givePieces(legacy, keys)
		t.ok(PlayerLogic.craft(legacy, craftRequest("legacy", keys)), "arma el Reloj del Legado")
		t.eq(legacy.parts.legacy, nil, "usa la pieza del legado")
		givePieces(legacy, keys)
		t.ok(not PlayerLogic.craft(legacy, craftRequest("legacy", keys)), "sin la pieza del legado no arma otro")
	end)

	t.test("sell valida cantidad y paga", function()
		local data = PlayerLogic.newData()
		data.watches.pocket = 3
		t.ok(not PlayerLogic.sell(data, "pocket", 0), "rechaza 0")
		t.ok(not PlayerLogic.sell(data, "pocket", 1.5), "rechaza decimales")
		t.ok(not PlayerLogic.sell(data, "pocket", 4), "rechaza más de lo que tiene")
		t.ok(not PlayerLogic.sell(data, "pocket", 0 / 0), "rechaza NaN")
		t.ok(PlayerLogic.sell(data, "pocket", 2), "vende 2")
		t.eq(data.coins, GameData.Watches.pocket.sell * 2, "paga el precio")
		t.eq(data.watches.pocket, 1, "quedan 1")
	end)

	t.test("BUG-001: vender y tirar piezas libera la mochila", function()
		local data = PlayerLogic.newData()
		for _ = 1, Config.BASE_BACKPACK do
			PlayerLogic.addPart(data, "screw")
		end
		t.ok(not PlayerLogic.addPart(data, "gear"), "mochila llena")
		t.ok(not PlayerLogic.sellPart(data, "screw", Config.BASE_BACKPACK + 1), "no vende más de lo que tiene")
		t.ok(not PlayerLogic.sellPart(data, "screw", 0.5), "rechaza decimales")
		t.ok(PlayerLogic.sellPart(data, "screw", 5), "vende 5")
		t.eq(data.coins, GameData.Parts.screw.sell * 5, "paga las piezas")
		t.ok(PlayerLogic.discardPart(data, "screw", 5), "tira 5")
		t.eq(data.coins, GameData.Parts.screw.sell * 5, "tirar no paga")
		t.eq(PlayerLogic.partCount(data), Config.BASE_BACKPACK - 10, "libera 10 espacios")
		t.ok(PlayerLogic.addPart(data, "gear"), "ya cabe otra pieza")
		t.ok(not PlayerLogic.discardPart(data, "ruby", 1), "no tira lo que no tiene")
	end)

	t.test("buyUpgrade cobra y respeta el máximo", function()
		local data = PlayerLogic.newData()
		local upgrade = GameData.Upgrades.museum
		t.ok(not PlayerLogic.buyUpgrade(data, "museum"), "sin monedas no compra")
		data.coins = 10 ^ 12
		for _ = 1, upgrade.maxLevel do
			t.ok(PlayerLogic.buyUpgrade(data, "museum"), "compra un nivel")
		end
		t.ok(not PlayerLogic.buyUpgrade(data, "museum"), "no pasa del máximo")
		t.eq(PlayerLogic.upgradeCost(data, "museum"), nil, "sin precio al máximo")
		t.eq(PlayerLogic.museumSlots(data), 12, "DEC-027: de 4 a 12 vitrinas")
		t.eq(PlayerLogic.jumpHeight(data), Config.BASE_JUMPHEIGHT, "DEC-027: el salto no se mejora")
	end)

	t.test("upgradeCost crece por nivel", function()
		local data = PlayerLogic.newData()
		local upgrade = GameData.Upgrades.museum
		t.eq(PlayerLogic.upgradeCost(data, "museum"), upgrade.baseCost, "precio inicial")
		data.upgrades.museum = 2
		t.eq(PlayerLogic.upgradeCost(data, "museum"), math.floor(upgrade.baseCost * upgrade.growth ^ 2), "precio nivel 2")
		t.eq(PlayerLogic.backpackCapacity(data), 60, "DEC-027: la mochila es fija en 60")
	end)

	t.test("DEC-027: solo vitrinas, caminadora y carga; precio por nivel", function()
		local ids = {}
		for upgradeId in GameData.Upgrades do
			table.insert(ids, upgradeId)
		end
		table.sort(ids)
		t.eq(table.concat(ids, ","), "carry,museum,treadmill", "solo tres mejoras")
		t.eq(GameData.Upgrades.museum.maxLevel, 8, "8 vitrinas más")
		t.eq(GameData.Upgrades.carry.maxLevel, 3, "3 mejoras de carga")
		t.eq(GameData.Upgrades.treadmill.maxLevel, 30, "30 niveles de caminadora")
		local data = PlayerLogic.newData()
		t.eq(PlayerLogic.museumSlots(data), 4, "el plot empieza con 4 vitrinas")
		t.eq(PlayerLogic.upgradeCost(data, "museum"), 100, "la primera vitrina cuesta 100")
		data.upgrades.museum = 7
		t.eq(PlayerLogic.upgradeCost(data, "museum"), 1e9, "la última vitrina cuesta 1B (×10)")
		data.upgrades.carry = 3
		t.eq(PlayerLogic.carryCapacity(data), 4, "carga máxima: 4 objetos por viaje")
		data.upgrades.treadmill = 29
		local last = PlayerLogic.upgradeCost(data, "treadmill")
		t.ok(last > 1e12 and last < 2e12, "el nivel 30 de la caminadora cuesta ~1,6T")
		t.eq(#GameData.UpgradeOrder, 0, "la Tienda no vende mejoras")
		-- Mascotas: ¼ de su bonus en monedas
		local petData = PlayerLogic.newData()
		petData.pets.dragon = 1
		petData.equipped.dragon = 1
		t.ok(
			math.abs(PlayerLogic.coinMultiplier(petData) - (1 + GameData.Pets.dragon.bonus * Config.PET_COIN_SHARE)) < 1e-9,
			"el dragón da +15% de monedas"
		)
		t.ok(PlayerLogic.extraPartChance(petData) > 0, "las mascotas dan suerte")
	end)

	t.test("DEC-028/029: 12 rarezas en orden, colores y avisos desde Mítico", function()
		local names = {}
		for _, rarity in GameData.Rarities do
			table.insert(names, rarity.name)
			t.ok(typeof(rarity.color) == "Color3", rarity.name .. " tiene color")
		end
		t.eq(
			table.concat(names, ","),
			"Común,Poco común,Raro,Épico,Legendario,Mítico,Divino,Celestial,Cósmico,Eterno,Ancestral,Atemporal",
			"las 12 rarezas en orden"
		)
		t.eq(GameData.RarityIndex["Mítico"], Config.ANNOUNCE_MIN_RARITY, "el aviso empieza en Mítico")
		for index = Config.ANNOUNCE_MIN_RARITY, #GameData.Rarities do
			t.ok(type(GameData.Rarities[index].message) == "string", GameData.Rarities[index].name .. " tiene mensaje")
		end
		t.ok(GameData.Rarities[12].rainbow == true, "Atemporal es arcoíris")
		for _, part in GameData.Parts do
			t.ok(GameData.RarityColors[part.rarity] ~= nil, part.name .. " tiene color de rareza")
		end
		t.ok(Config.RACE_RESET_SECONDS == 300 and Config.RACE_WARNING_SECONDS == 30, "reinicio cada 5 min con 30 s de aviso")
	end)

	t.test("DEC-030: Dinero ×2, VIP y ganancia offline", function()
		local data = PlayerLogic.newData()
		PlayerLogic.setPasses(data, { moneyX2 = true })
		t.eq(PlayerLogic.coinMultiplier(data), 2, "Dinero ×2 duplica las monedas")
		PlayerLogic.setPasses(data, { moneyX2 = true, vip = true })
		t.ok(math.abs(PlayerLogic.coinMultiplier(data) - 2 * GameData.GamePasses.vip.coinMultiplier) < 1e-9, "se combina con el VIP")
		t.ok(math.abs(PlayerLogic.playtimeRate(data) - 1 / Config.VIP_PLAYTIME_FACTOR) < 1e-9, "VIP: el tiempo de premios cuenta más rápido")
		t.ok(Config.GAMEPASS_IDS.moneyX2 ~= nil and Config.GAMEPASS_IDS.moneyX2 ~= 0, "Dinero ×2 creado en Roblox")
		-- Ganancia offline
		local plot = PlayerLogic.newData()
		plot.museum.pocket = 1
		local perMinute = PlayerLogic.museumIncomePerMinute(plot)
		t.eq(PlayerLogic.offlineEarnings(plot, 1000), 0, "sin lastSeen no hay offline")
		plot.lastSeen = 1000
		local coins, seconds = PlayerLogic.offlineEarnings(plot, 1000 + 10 * 3600)
		t.eq(seconds, Config.OFFLINE_MAX_SECONDS, "sin VIP: tope de 4 h")
		t.eq(coins, math.floor(perMinute * seconds / 60 * Config.OFFLINE_RATE), "al 50 % del ingreso")
		PlayerLogic.setPasses(plot, { vip = true })
		local _, vipSeconds = PlayerLogic.offlineEarnings(plot, 1000 + 10 * 3600)
		t.eq(vipSeconds, Config.OFFLINE_MAX_SECONDS_VIP, "con VIP: tope de 8 h")
		t.eq(PlayerLogic.offlineEarnings(plot, 1030), 0, "menos de un minuto fuera no cuenta")
		t.eq(PlayerLogic.reconcile({ lastSeen = -5 }).lastSeen, 0, "repara lastSeen negativo")
	end)

	t.test("museo: exhibir, límite de vitrinas, retirar e ingreso", function()
		local data = PlayerLogic.newData()
		local slots = PlayerLogic.museumSlots(data)
		data.watches.wrist = slots + 1
		for _ = 1, slots do
			t.ok(PlayerLogic.display(data, "wrist"), "exhibe")
		end
		t.ok(not PlayerLogic.display(data, "wrist"), "no supera las vitrinas")
		-- DEV-011: cada ciclo paga PLOT_INCOME_PERCENT del valor repartido en el periodo
		local perTick = GameData.Watches.wrist.sell * slots * Config.PLOT_INCOME_PERCENT
			* Config.MUSEUM_TICK_SECONDS / Config.PLOT_INCOME_PERIOD_SECONDS
		t.ok(math.abs(PlayerLogic.museumIncome(data) - perTick) < 1e-9, "ingreso por ciclo")
		local earned = 0
		for _ = 1, 40 do
			earned += PlayerLogic.collectIncome(data)
		end
		t.eq(earned, math.floor(perTick * 40 + 1e-6), "las fracciones se acumulan sin perderse")
		t.eq(data.coins, earned, "suma monedas")
		t.ok(PlayerLogic.withdraw(data, "wrist"), "retira")
		t.eq(data.watches.wrist, 2, "vuelve al inventario")
		t.ok(not PlayerLogic.withdraw(data, "pocket"), "no retira lo que no está")
	end)

	t.test("rollPart devuelve piezas válidas y la suerte ayuda", function()
		t.eq(PlayerLogic.rollPart(1, 0), GameData.PartOrder[1], "roll 0 = primera pieza")
		local lastWithWeight = nil
		for _, partId in GameData.PartOrder do
			if GameData.Parts[partId].weight > 0 then
				lastWithWeight = partId
			end
		end
		t.eq(PlayerLogic.rollPart(1, 0.999999), lastWithWeight, "roll ~1 = última pieza con peso")
		t.ok(PlayerLogic.rollPart(1, 0.999999) ~= "diamond", "sin tabla de zona no sale diamante")
		local rng = Random.new(1234)
		local rareNormal, rareLucky = 0, 0
		for _ = 1, 4000 do
			local roll = rng:NextNumber()
			if not GameData.Parts[PlayerLogic.rollPart(1, roll)].common then
				rareNormal += 1
			end
			if not GameData.Parts[PlayerLogic.rollPart(1.75, roll)].common then
				rareLucky += 1
			end
		end
		t.ok(rareLucky > rareNormal, "más suerte = más piezas no comunes")
	end)

	t.test("DEV-002/011: el tutorial empieza tras la introducción, va en orden y paga una vez", function()
		local data = PlayerLogic.newData()
		local steps = GameData.Tutorial
		t.eq(data.tutorial, 1, "empieza en el paso 1")
		data.trained = 100 - Config.START_SPEED -- DEC-024: el paso 1 pide 100 de velocidad
		t.eq(#PlayerLogic.advanceTutorial(data), 0, "sin la introducción no avanza")
		t.eq(PlayerLogic.buildView(data).tutorial, false, "la vista no muestra el tutorial aún")
		t.ok(PlayerLogic.claimLegacy(data, 0), "recoge la pieza del legado")
		PlayerLogic.advanceTutorial(data)
		t.eq(data.tutorial, 2, "llegar a 100 de velocidad completa el paso 1")
		t.eq(data.coins, steps[1].reward, "paga el premio del paso 1")
		PlayerLogic.advanceTutorial(data)
		t.eq(data.coins, steps[1].reward, "no paga dos veces")

		-- Cumplir pasos posteriores antes que el 2 no lo salta: se completan en orden.
		data.stats.sold = 1
		data.stats.crafted = 1
		PlayerLogic.advanceTutorial(data)
		t.eq(data.tutorial, 2, "sigue en robar")
		data.stats.collected = 5
		PlayerLogic.advanceTutorial(data)
		t.eq(data.tutorial, 5, "completa robar, fabricar y vender de una vez")
	end)

	t.test("DEV-002: el tutorial termina y los datos antiguos se reparan", function()
		local data = PlayerLogic.newData()
		data.introDone = true
		data.trained = 100 - Config.START_SPEED
		data.stats.collected = 99
		data.stats.crafted = 9
		data.stats.sold = 9
		data.museum.pocket = 1
		data.upgrades.museum = 1
		local messages = PlayerLogic.advanceTutorial(data)
		t.eq(data.tutorial, #GameData.Tutorial + 1, "tutorial terminado")
		t.eq(#messages, #GameData.Tutorial + 1, "un mensaje por paso y otro final")
		t.eq(PlayerLogic.tutorialStep(data), nil, "sin paso actual")
		t.eq(PlayerLogic.buildView(data).tutorial, false, "la vista no muestra tutorial")

		t.eq(PlayerLogic.reconcile({ coins = 5 }).tutorial, 1, "datos sin tutorial empiezan en 1")
		t.eq(PlayerLogic.reconcile({ tutorial = 999 }).tutorial, #GameData.Tutorial + 1, "limita el paso máximo")
	end)

	t.test("DEV-003: robar, guardar en la base y perder el botín", function()
		local data = PlayerLogic.newData()
		t.ok(PlayerLogic.stealPart(data, "ruby", 0.99), "roba un rubí")
		t.eq(PlayerLogic.carriedCount(data), 1, "va al botín")
		t.eq(data.parts.ruby, nil, "todavía no está guardado")
		t.eq(PlayerLogic.freeSpace(data), Config.BASE_BACKPACK - 1, "el botín ocupa espacio")
		t.eq(PlayerLogic.depositLoot(data), 1, "guarda 1 pieza")
		t.eq(data.parts.ruby, 1, "ahora está en la mochila")
		t.eq(data.stats.collected, 1, "cuenta para el tutorial")
		data.upgrades.carry = GameData.Upgrades.carry.maxLevel -- DEV-013: puede cargar varios
		PlayerLogic.stealPart(data, "gear", 0.99)
		PlayerLogic.stealPart(data, "gear", 0.99)
		t.eq(PlayerLogic.loseLoot(data), 2, "atrapado: pierde 2")
		t.eq(PlayerLogic.carriedCount(data), 0, "botín vacío")
		t.eq(data.parts.ruby, 1, "lo guardado no se pierde")
		t.ok(not PlayerLogic.stealPart(data, "inventada", 0), "rechaza piezas desconocidas")
	end)

	t.test("DEV-003: la mochila limita el robo y la suerte da piezas extra", function()
		local data = PlayerLogic.newData()
		data.parts.gear = Config.BASE_BACKPACK - 1 -- mochila casi llena (guardado)
		data.upgrades.carry = GameData.Upgrades.carry.maxLevel
		data.pets.dragon = 3
		data.equipped.dragon = 3 -- DEC-027: la suerte viene de las mascotas
		local _, _, amount = PlayerLogic.stealPart(data, "gear", 0)
		t.eq(amount, 1, "con 1 espacio libre roba solo 1 aunque tenga suerte")
		t.ok(not PlayerLogic.stealPart(data, "gear", 0.99), "mochila llena no roba")

		local lucky = PlayerLogic.newData()
		lucky.pets.dragon = 3
		lucky.equipped.dragon = 3
		lucky.upgrades.carry = GameData.Upgrades.carry.maxLevel
		local _, _, double = PlayerLogic.stealPart(lucky, "gear", 0)
		t.eq(double, 2, "tirada baja con suerte = 2 piezas")
		local _, _, single = PlayerLogic.stealPart(lucky, "gear", 0.99)
		t.eq(single, 1, "tirada alta = 1 pieza")
		t.eq(PlayerLogic.reconcile(lucky).carried.gear, nil, "al cargar datos el botín se descarta")
	end)

	t.test("DEC-024: 12 zonas, velocidad estadística y velocidad física", function()
		local data = PlayerLogic.newData()
		t.eq(#GameData.Zones, 12, "hay 12 zonas")
		t.eq(PlayerLogic.speed(data), Config.START_SPEED, "se empieza con 75 de velocidad")
		t.ok(not PlayerLogic.canEnterZone(data, 1), "la zona 1 pide 100")
		t.eq(PlayerLogic.highestZone(data), 0, "al empezar no hay zona abierta")
		data.trained = 100 - Config.START_SPEED
		t.ok(PlayerLogic.canEnterZone(data, 1), "con 100 se abre la zona 1")
		t.ok(not PlayerLogic.canEnterZone(data, 2), "la zona 2 pide más")
		t.ok(not PlayerLogic.canEnterZone(data, 99), "zona inexistente cerrada")
		t.eq(GameData.Zones[5].minSpeed, 1e6, "la zona 5 pide 1M")
		t.eq(GameData.Zones[12].minSpeed, 9.99e13, "la zona 12 pide 99,9T")
		local previousMin = 0
		for zoneIndex, zone in GameData.Zones do
			t.ok(zone.minSpeed > previousMin, zone.name .. ": pide más velocidad que la anterior")
			t.ok(zone.lootCoins > 0, zone.name .. ": el botín trae monedas")
			for partId in zone.weights do
				t.ok(GameData.Parts[partId] ~= nil, zone.name .. " usa pieza válida " .. partId)
			end
			-- Quien cumple el requisito corre más que el dueño de esa zona
			t.ok(
				PlayerLogic.runSpeed(zone.minSpeed) > PlayerLogic.ownerSpeed(zoneIndex),
				zone.name .. ": el dueño es alcanzable con la velocidad justa"
			)
			previousMin = zone.minSpeed
			t.eq(#zone.owners, 4, zone.name .. " tiene 4 dueños")
		end
		-- Velocidad física: curva con tope (DEC-024)
		t.eq(PlayerLogic.runSpeed(75), 30, "75 corre a 30")
		t.eq(PlayerLogic.runSpeed(1e6), 85, "1M corre a 85")
		t.eq(PlayerLogic.runSpeed(9.99e13), Config.MAX_WALKSPEED, "99,9T corre al tope")
		t.eq(PlayerLogic.runSpeed(1e30), Config.MAX_WALKSPEED, "nunca pasa del tope")
		t.ok(PlayerLogic.runSpeed(1e4) > PlayerLogic.runSpeed(1e3), "más velocidad, más rápido")
		data.trained = 1e12
		t.ok(PlayerLogic.lobbySpeed(data) <= Config.LOBBY_MAX_WALKSPEED, "en la base como máximo 50")
		t.ok(PlayerLogic.houseSpeed(data) <= Config.HOUSE_WALKSPEED, "en las casas como máximo 40")
		PlayerLogic.setSetting(data, "runSpeed", 20)
		t.eq(PlayerLogic.lobbySpeed(data), 20, "la barra elige la velocidad en la base")
		t.ok(not PlayerLogic.setSetting(data, "runSpeed", 51), "la barra no pasa de 50")
		t.eq(PlayerLogic.formatBig(1500), "1,5K", "formato 1,5K")
		t.eq(PlayerLogic.formatBig(9.99e13), "99,9T", "formato 99,9T")
		t.eq(PlayerLogic.formatBig(1.4e7), "14M", "formato 14M")
	end)

	t.test("DEC-024: el botín trae monedas que se cobran en la base", function()
		local data = PlayerLogic.newData()
		PlayerLogic.stealPart(data, "gear", 0.99, 80)
		t.eq(data.carriedCoins, 80, "las monedas van con el botín")
		local saved, coins = PlayerLogic.depositLoot(data)
		t.eq(saved, 1, "guarda la pieza")
		t.eq(coins, 80, "cobra las monedas")
		t.eq(data.coins, 80, "suma a tus monedas")
		data.upgrades.carry = GameData.Upgrades.carry.maxLevel
		PlayerLogic.stealPart(data, "gear", 0.99, 640)
		PlayerLogic.loseLoot(data)
		t.eq(data.carriedCoins, 0, "atrapado: se pierden las monedas del botín")
		t.eq(data.coins, 80, "lo cobrado no se pierde")
	end)

	t.test("DEV-003: zonas ricas dan piezas más raras", function()
		local rng = Random.new(99)
		local function rareShare(zone)
			local rare = 0
			for _ = 1, 3000 do
				if not GameData.Parts[PlayerLogic.rollPart(1, rng:NextNumber(), zone.weights)].common then
					rare += 1
				end
			end
			return rare
		end
		local first = rareShare(GameData.Zones[1])
		local last = rareShare(GameData.Zones[#GameData.Zones])
		t.ok(last > first * 3, "la última zona da muchas más piezas raras")
	end)

	t.test("DEV-004: entregar piezas al Cronómetro y reembolso", function()
		local data = PlayerLogic.newData()
		data.parts.gear = 5
		data.parts.ruby = 2
		local ok, _, points = PlayerLogic.contributeParts(data, "ruby", 2)
		t.ok(ok, "entrega 2 rubíes")
		t.eq(points, GameData.RepairPoints["Raro"] * 2, "puntos por rareza")
		t.eq(data.parts.ruby, nil, "se descuentan")
		t.ok(not PlayerLogic.contributeParts(data, "gear", 6), "no entrega más de lo que tiene")
		t.ok(not PlayerLogic.contributeParts(data, "gear", 0), "rechaza 0")
		t.ok(not PlayerLogic.contributeParts(data, "nada", 1), "rechaza piezas desconocidas")
		t.eq(data.parts.gear, 5, "un rechazo no descuenta nada")
		t.eq(PlayerLogic.refundParts(data, { ruby = 2, nada = 3 }), 2, "devuelve solo piezas válidas")
		t.eq(data.parts.ruby, 2, "reembolso completo")
		t.eq(PlayerLogic.bossReward(10), 10 * Config.BOSS_COINS_PER_POINT, "premio por punto")
	end)

	t.test("DEV-004: todas las rarezas tienen puntos y color", function()
		for _, partId in GameData.PartOrder do
			local rarity = GameData.Parts[partId].rarity
			t.ok(GameData.RepairPoints[rarity] ~= nil, "puntos para " .. rarity)
			t.ok(GameData.RarityColors[rarity] ~= nil, "color para " .. rarity)
		end
	end)

	t.test("DEV-005: abrir huevos cobra y da mascotas válidas", function()
		local data = PlayerLogic.newData()
		local egg = GameData.Eggs.brass
		t.ok(not PlayerLogic.hatchEgg(data, "brass", 0), "sin monedas no abre")
		t.ok(not PlayerLogic.hatchEgg(data, "falso", 0), "huevo inexistente")
		data.coins = egg.cost
		local ok, _, petId = PlayerLogic.hatchEgg(data, "brass", 0)
		t.ok(ok, "abre el huevo")
		t.eq(data.coins, 0, "cobra el precio")
		t.eq(petId, "mouse", "roll 0 = primera mascota del huevo")
		t.eq(data.equipped.mouse, 1, "se equipa sola si hay espacio")
		for _, eggId in GameData.EggOrder do
			for chancePet in GameData.Eggs[eggId].chances do
				t.ok(GameData.Pets[chancePet] ~= nil, eggId .. " contiene mascota válida " .. chancePet)
			end
			t.ok(GameData.Pets[PlayerLogic.rollPet(eggId, 0.999999)] ~= nil, "roll alto da mascota válida")
		end
	end)

	t.test("DEV-005: equipar, límite, multiplicador y liberar", function()
		local data = PlayerLogic.newData()
		data.pets = { mouse = 2, fox = 1, dragon = 2 }
		data.equipped = {}
		t.eq(PlayerLogic.petMultiplier(data), 1, "sin equipar = ×1")
		local baseSpeed = PlayerLogic.walkSpeed(data)
		t.ok(PlayerLogic.equipPet(data, "fox"), "equipa zorro")
		t.ok(not PlayerLogic.equipPet(data, "fox"), "no equipa más de las que tiene")
		t.ok(PlayerLogic.walkSpeed(data) > baseSpeed, "la mascota da velocidad")
		PlayerLogic.equipPet(data, "mouse")
		PlayerLogic.equipPet(data, "mouse")
		t.ok(not PlayerLogic.equipPet(data, "dragon"), "máximo de equipadas")
		t.ok(not PlayerLogic.releasePet(data, "fox"), "no libera una equipada")
		PlayerLogic.equipBest(data)
		t.eq(data.equipped.dragon, 2, "equipar mejores elige dragones")
		t.eq(data.equipped.fox, 1, "y luego el zorro")
		t.eq(PlayerLogic.equippedCount(data), Config.MAX_EQUIPPED_PETS, "llena los espacios")
		local expected = 1 + 2 * GameData.Pets.dragon.bonus + GameData.Pets.fox.bonus
		t.ok(math.abs(PlayerLogic.petMultiplier(data) - expected) < 1e-9, "multiplicador = 1 + suma de bonus")
		t.ok(PlayerLogic.releasePet(data, "mouse"), "libera un ratón sin equipar")
		t.eq(data.pets.mouse, 1, "queda 1 ratón")
		t.ok(PlayerLogic.unequipPet(data, "dragon"), "desequipa")
		t.ok(not PlayerLogic.unequipPet(data, "mouse"), "no desequipa lo que no está equipado")
	end)

	t.test("DEV-005: datos de mascotas dañados se reparan y la velocidad tiene tope", function()
		local data = PlayerLogic.reconcile({
			pets = { dragon = 5, falsa = 2 },
			equipped = { dragon = 9, mouse = 2 },
		})
		t.eq(data.pets.falsa, nil, "descarta mascotas desconocidas")
		t.eq(PlayerLogic.equippedCount(data), Config.MAX_EQUIPPED_PETS, "no más equipadas que el límite")
		t.eq(data.equipped.mouse, nil, "no equipa mascotas que no posee")
		data.trained = 1e15
		t.ok(PlayerLogic.walkSpeed(data) <= Config.MAX_WALKSPEED, "velocidad con tope")
		local fresh = PlayerLogic.newData()
		fresh.trained = 10 -- 85 de velocidad: no llega a la zona 1 (DEC-024)
		t.ok(not PlayerLogic.canEnterZone(fresh, 1), "con 85 no abre la zona 1")
		fresh.pets.fox = 1
		fresh.equipped.fox = 1
		t.ok(PlayerLogic.canEnterZone(fresh, 1), "un zorro (+20%) la abre: 85 × 1,2 = 102")
	end)

	t.test("DEV-008: caminadora del plot, mejoras y pase Turbo", function()
		local data = PlayerLogic.newData()
		local before = PlayerLogic.walkSpeed(data)
		t.eq(PlayerLogic.treadmillMultiplier(data), 1, "nivel 0 entrena ×1")
		local gained = PlayerLogic.trainTick(data, 10)
		t.ok(math.abs(gained - Config.TRAIN_RATE * 10) < 1e-9, "gana TRAIN_RATE por segundo")
		t.ok(PlayerLogic.walkSpeed(data) > before, "entrenar sube la velocidad")
		data.coins = 10 ^ 7
		t.ok(PlayerLogic.buyUpgrade(data, "treadmill"), "mejora la caminadora")
		local step = GameData.Upgrades.treadmill.step
		t.eq(PlayerLogic.treadmillMultiplier(data), step, "DEC-024: cada nivel multiplica por step (×2)")
		PlayerLogic.setPasses(data, { turboTreadmill = true })
		t.eq(PlayerLogic.treadmillMultiplier(data), step * GameData.TURBO_TREADMILL_FACTOR, "el pase Turbo lo multiplica")
		data.upgrades.treadmill = GameData.Upgrades.treadmill.maxLevel
		t.ok(PlayerLogic.treadmillMultiplier(data) >= 2 ^ GameData.Upgrades.treadmill.maxLevel, "cada nivel duplica (DEC-026: 8 niveles)")
		PlayerLogic.trainTick(data, 10 ^ 15)
		t.eq(data.trained, Config.MAX_TRAINED, "tope de seguridad de velocidad entrenada")
		t.ok(PlayerLogic.walkSpeed(data) <= Config.MAX_WALKSPEED, "tope de velocidad física")
		t.eq(PlayerLogic.reconcile({ trained = -5 }).trained, 0, "repara entrenamiento negativo")
		t.eq(PlayerLogic.reconcile({ trained = 1e20 }).trained, Config.MAX_TRAINED, "limita entrenamiento")
	end)

	t.test("DEV-008: datos de caminadoras antiguas se adaptan al plot", function()
		local migrated = PlayerLogic.reconcile({ treadmills = { advanced = true } })
		t.eq(migrated.upgrades.treadmill, 3, "la de Acero equivale al nivel 3")
		t.eq(migrated.treadmills, nil, "se elimina el dato viejo")
		local kept = PlayerLogic.reconcile({ treadmills = { advanced = true }, upgrades = { treadmill = 7 } })
		t.eq(kept.upgrades.treadmill, 7, "no baja un nivel mayor")
		t.eq(PlayerLogic.reconcile({}).upgrades.treadmill, nil, "sin caminadora vieja no regala niveles")
	end)

	t.test("DEV-008: el plot da suerte con tope y las mejoras están separadas", function()
		local data = PlayerLogic.newData()
		t.eq(PlayerLogic.plotLuck(data), 0, "plot vacío sin suerte")
		data.watches.chrono = 1
		PlayerLogic.display(data, "chrono")
		t.ok(math.abs(PlayerLogic.plotLuck(data) - GameData.Watches.chrono.luck) < 1e-9, "suerte del reloj exhibido")
		t.ok(PlayerLogic.extraPartChance(data) > 0, "la suerte del plot ayuda a robar 2 piezas")
		data.museum = { millionaire = 100 }
		t.eq(PlayerLogic.plotLuck(data), Config.MAX_PLOT_LUCK, "tope de suerte del plot")
		data.pets.dragon = 3
		data.equipped.dragon = 3
		t.ok(PlayerLogic.extraPartChance(data) <= Config.MAX_EXTRA_PART_CHANCE, "tope total de suerte")
		for _, watchId in GameData.WatchOrder do
			t.ok(type(GameData.Watches[watchId].luck) == "number", watchId .. " tiene suerte definida")
		end
		for _, upgradeId in GameData.PlotUpgradeOrder do
			t.ok(GameData.Upgrades[upgradeId] ~= nil, "mejora de plot existe: " .. upgradeId)
			t.ok(not table.find(GameData.UpgradeOrder, upgradeId), upgradeId .. " no se vende en la Tienda")
		end
		local view = PlayerLogic.buildView(PlayerLogic.newData())
		t.ok(view.upgradeCosts.treadmill ~= nil and view.upgradeCosts.museum ~= nil, "la vista trae precios del plot")
	end)

	t.test("DEV-008: más vitrinas al mejorar el plot", function()
		local data = PlayerLogic.newData()
		local base = PlayerLogic.museumSlots(data)
		data.coins = 10 ^ 7
		PlayerLogic.buyUpgrade(data, "museum")
		t.eq(PlayerLogic.museumSlots(data), base + GameData.Upgrades.museum.step, "+1 vitrina")
		data.upgrades.museum = GameData.Upgrades.museum.maxLevel
		t.ok(PlayerLogic.museumSlots(data) <= 15, "caben en las 3 filas de 5 vitrinas del plot")
	end)

	t.test("DEV-006: pases de velocidad, monedas, mochila y ranura", function()
		local data = PlayerLogic.newData()
		data.watches.pocket = 2
		local baseSpeed = PlayerLogic.walkSpeed(data)
		local baseCapacity = PlayerLogic.backpackCapacity(data)
		PlayerLogic.setPasses(data, { runner = true, vip = true, bigBackpack = true, petSlot = true, falso = true })
		t.eq(data.passes.falso, nil, "ignora pases desconocidos")
		t.ok(PlayerLogic.walkSpeed(data) > baseSpeed, "Corredor VIP da velocidad")
		t.eq(PlayerLogic.backpackCapacity(data), baseCapacity + GameData.GamePasses.bigBackpack.backpack, "Mochila Gigante")
		t.eq(PlayerLogic.petSlots(data), Config.MAX_EQUIPPED_PETS + 1, "ranura extra")
		PlayerLogic.sell(data, "pocket", 1)
		t.eq(data.coins, math.floor(GameData.Watches.pocket.sell * GameData.GamePasses.vip.coinMultiplier), "VIP +20% al vender")
		t.eq(next(PlayerLogic.reconcile(data).passes), nil, "los pases no se guardan: se consultan al entrar")
	end)

	t.test("DEC-023: pases de entrenamiento (el más alto, combinado con la caminadora)", function()
		local data = PlayerLogic.newData()
		t.eq(PlayerLogic.treadmillMultiplier(data), 1, "sin pases ×1")
		PlayerLogic.setPasses(data, { speedX2 = true, speedX64 = true })
		t.eq(PlayerLogic.treadmillMultiplier(data), 64, "se usa el más alto, no se suman")
		PlayerLogic.setPasses(data, { speedX512 = true, turboTreadmill = true })
		t.eq(PlayerLogic.treadmillMultiplier(data), 512 * GameData.TURBO_TREADMILL_FACTOR, "se combina con la Caminadora Turbo")
		PlayerLogic.setPasses(data, { speedX4 = true })
		data.trained = 0
		local gained = PlayerLogic.trainTick(data, 1)
		t.ok(math.abs(gained - Config.TRAIN_RATE * 4) < 1e-9, "×4 al entrenar")
		t.eq(PlayerLogic.coinMultiplier(data), 1, "no cambia las monedas")
		for _, tier in GameData.SPEED_MULTIPLIER_PASSES do
			local id = "speedX" .. tier.factor
			t.ok(GameData.GamePasses[id] ~= nil and Config.GAMEPASS_IDS[id] ~= nil, id .. " en GameData y Config")
		end
		local priced = true
		for _, key in GameData.GamePassOrder do
			priced = priced and type(GameData.GamePasses[key].robux) == "number"
		end
		for _, key in GameData.ProductOrder do
			priced = priced and type(GameData.Products[key].robux) == "number"
		end
		t.ok(priced, "todos los pases y productos tienen precio")
	end)

	t.test("DEV-006: Mascota Suprema es 20% mejor que tu mejor mascota", function()
		local data = PlayerLogic.newData()
		PlayerLogic.setPasses(data, { supremePet = true })
		t.eq(data.pets.supreme, 1, "el pase da la mascota")
		t.eq(data.equipped.supreme, 1, "se equipa sola")
		t.eq(PlayerLogic.petBonus(data, "supreme"), Config.SUPREME_PET_MIN_BONUS, "sin mascotas usa el mínimo")
		data.pets.dragon = 1
		t.ok(
			math.abs(PlayerLogic.petBonus(data, "supreme") - GameData.Pets.dragon.bonus * Config.SUPREME_PET_FACTOR) < 1e-9,
			"20% más que el dragón"
		)
		t.ok(not PlayerLogic.releasePet(data, "supreme"), "no se puede liberar")
		t.ok(not PlayerLogic.grantPet(data, "supreme"), "no sale de huevos ni regalos")
		PlayerLogic.equipBest(data)
		t.eq(data.equipped.supreme, 1, "equipar mejores la incluye")
		local reloaded = PlayerLogic.reconcile(data)
		t.eq(reloaded.pets.supreme, nil, "al cargar se quita hasta comprobar el pase")
		PlayerLogic.setPasses(reloaded, {})
		t.eq(reloaded.equipped.supreme, nil, "sin pase no queda equipada")
		for _, eggId in GameData.EggOrder do
			t.eq(GameData.Eggs[eggId].chances.supreme, nil, eggId .. " no contiene la Suprema")
		end
	end)

	t.test("DEV-006: perder la ranura extra desequipa la de menor bonus", function()
		local data = PlayerLogic.newData()
		PlayerLogic.setPasses(data, { petSlot = true })
		data.pets = { mouse = 1, dragon = 3 }
		data.equipped = {}
		PlayerLogic.equipBest(data)
		t.eq(PlayerLogic.equippedCount(data), 4, "4 equipadas con el pase")
		PlayerLogic.setPasses(data, {})
		t.eq(PlayerLogic.equippedCount(data), Config.MAX_EQUIPPED_PETS, "vuelve al límite")
		t.eq(data.equipped.mouse, nil, "quita primero la de menor bonus")
	end)

	t.test("DEV-006: productos con Robux y recibos", function()
		local data = PlayerLogic.newData()
		t.ok(PlayerLogic.grantProduct(data, "coinsSmall", 0), "entrega monedas")
		t.eq(data.coins, GameData.Products.coinsSmall.coins, "cantidad correcta")
		t.ok(PlayerLogic.grantProduct(data, "instantTraining", 0), "entrega entrenamiento")
		t.eq(
			data.trained,
			Config.TRAIN_RATE * GameData.Products.instantTraining.trainSeconds,
			"DEC-024: 5 minutos de entrenamiento con tu caminadora"
		)
		t.ok(PlayerLogic.grantProduct(data, "goldEgg", 0), "entrega la cápsula")
		t.eq(data.capsules.gold, 1, "la cápsula comprada va a la Mochila")
		t.ok(not PlayerLogic.grantProduct(data, "falso", 0), "rechaza productos desconocidos")
		t.ok(not PlayerLogic.hasReceipt(data, "abc"), "recibo nuevo")
		PlayerLogic.addReceipt(data, "abc")
		t.ok(PlayerLogic.hasReceipt(data, "abc"), "recuerda el recibo")
		for index = 1, Config.MAX_RECEIPTS + 5 do
			PlayerLogic.addReceipt(data, "r" .. index)
		end
		t.eq(#data.receipts, Config.MAX_RECEIPTS, "guarda solo los últimos")
		for _, key in GameData.ProductOrder do
			t.ok(Config.PRODUCT_IDS[key] ~= nil, "id configurado para " .. key)
		end
		for _, key in GameData.GamePassOrder do
			t.ok(Config.GAMEPASS_IDS[key] ~= nil, "id configurado para " .. key)
		end
	end)

	t.test("DEV-009: cápsulas en la Mochila y Cápsula Cósmica solo con Robux", function()
		local data = PlayerLogic.newData()
		t.ok(not PlayerLogic.openCapsule(data, "brass", 0), "sin cápsulas no abre")
		PlayerLogic.giveReward(data, { capsule = "brass", amount = 2 })
		t.eq(data.capsules.brass, 2, "recompensa guarda 2 cápsulas")
		local ok, _, petId = PlayerLogic.openCapsule(data, "brass", 0)
		t.ok(ok, "abre una cápsula")
		t.eq(petId, "mouse", "roll 0 = primera mascota de la cápsula")
		t.eq(data.capsules.brass, 1, "consume la cápsula")
		data.coins = 10 ^ 7
		t.ok(not PlayerLogic.hatchEgg(data, "cosmic", 0), "la Cósmica no se compra con monedas")
		t.ok(PlayerLogic.grantProduct(data, "cosmicCapsule", 0), "la Cósmica se compra con Robux")
		t.eq(data.capsules.cosmic, 1, "va a la Mochila")
		local _, _, robuxPet = PlayerLogic.openCapsule(data, "cosmic", 0.999999)
		t.ok(GameData.Pets[robuxPet].robux == true, "da una mascota exclusiva de Robux")
		for petId in GameData.Eggs.cosmic.chances do
			t.ok(GameData.Pets[petId].bonus > GameData.Pets.dragon.bonus, petId .. " es más fuerte que el Dragón")
		end
		for _, eggId in { "brass", "silver", "gold" } do
			for petId in GameData.Eggs[eggId].chances do
				t.ok(not GameData.Pets[petId].robux, eggId .. " no da mascotas de Robux")
			end
		end
		data.capsules.gold = 10 ^ 6
		t.eq(PlayerLogic.reconcile(data).capsules.gold, Config.MAX_CAPSULES, "tope de cápsulas")
	end)

	t.test("DEV-009: recompensa diaria con racha de 7 días", function()
		local data = PlayerLogic.newData()
		local day = 20000 * 86400 + 3600 -- un instante cualquiera
		local canClaim, streak = PlayerLogic.dailyStatus(data, day)
		t.ok(canClaim, "el primer día se puede reclamar")
		t.eq(streak, 1, "empieza en el día 1")
		t.ok(PlayerLogic.claimDaily(data, day), "reclama el día 1")
		t.eq(data.coins, GameData.DailyRewards[1].coins, "da la recompensa del día 1")
		t.ok(not PlayerLogic.claimDaily(data, day + 60), "no reclama dos veces el mismo día")
		for index = 2, #GameData.DailyRewards do
			t.ok(PlayerLogic.claimDaily(data, day + (index - 1) * 86400), "reclama el día " .. index)
		end
		t.eq(data.daily.streak, #GameData.DailyRewards, "llega al día 7")
		t.eq(data.capsules.gold, 1, "el día 7 da una Cápsula de Oro")
		PlayerLogic.claimDaily(data, day + 7 * 86400)
		t.eq(data.daily.streak, 1, "tras el día 7 vuelve al día 1")
		PlayerLogic.claimDaily(data, day + 9 * 86400)
		t.eq(data.daily.streak, 1, "saltarse un día reinicia la racha")
		local view = PlayerLogic.buildView(data, day + 9 * 86400 + 10)
		t.ok(not view.daily.canClaim and view.daily.untilTomorrow > 0, "la vista muestra cuándo vuelve")
	end)

	t.test("DEV-009: premios por tiempo jugado, una vez por día", function()
		local data = PlayerLogic.newData()
		local day = 20000 * 86400
		local first = GameData.PlaytimeRewards[1]
		t.ok(not PlayerLogic.claimPlaytime(data, day, 1), "sin tiempo no reclama")
		PlayerLogic.addPlaytime(data, day, first.minutes * 60)
		t.ok(PlayerLogic.claimPlaytime(data, day, "1"), "reclama al cumplir los minutos")
		t.ok(not PlayerLogic.claimPlaytime(data, day, 1), "no reclama dos veces")
		t.ok(not PlayerLogic.claimPlaytime(data, day, 99), "nivel inexistente")
		PlayerLogic.addPlaytime(data, day + 86400, 1)
		t.eq(data.playtime.seconds, 1, "el tiempo se reinicia al cambiar de día")
		t.ok(not PlayerLogic.claimPlaytime(data, day + 86400, 1), "al día siguiente hay que volver a jugar")
		local saved = PlayerLogic.reconcile({ playtime = { day = 5, seconds = -3, claimed = { ["2"] = true, ["99"] = true } } })
		t.eq(saved.playtime.seconds, 0, "repara segundos negativos")
		t.ok(saved.playtime.claimed["2"] == true and saved.playtime.claimed["99"] == nil, "conserva solo niveles válidos")
		for index = 2, #GameData.PlaytimeRewards do
			t.ok(GameData.PlaytimeRewards[index].minutes > GameData.PlaytimeRewards[index - 1].minutes, "niveles en orden")
		end
	end)

	t.test("DEV-011: pieza del legado una sola vez, aleatoria y protegida", function()
		local data = PlayerLogic.newData()
		t.ok(not data.introDone, "empieza sin introducción")
		local ok = PlayerLogic.claimLegacy(data, 0.999)
		t.ok(ok, "recoge la pieza")
		t.eq(data.legacyVariant, GameData.LegacyPieces[#GameData.LegacyPieces].id, "roll alto = última variante")
		t.eq(data.parts.legacy, 1, "la pieza va a la mochila")
		t.eq(PlayerLogic.partCount(data), 0, "la herencia no ocupa espacio de robo")
		t.ok(not PlayerLogic.claimLegacy(data, 0), "no se recoge dos veces")
		t.eq(data.parts.legacy, 1, "sigue habiendo una sola")
		t.ok(not PlayerLogic.sellPart(data, "legacy", 1), "no se vende")
		t.ok(not PlayerLogic.discardPart(data, "legacy", 1), "no se tira")
		t.ok(not PlayerLogic.contributeParts(data, "legacy", 1), "no se entrega al Cronómetro")
		t.eq(PlayerLogic.legacyPiece(data).id, data.legacyVariant, "se puede consultar la variante")
		t.eq(PlayerLogic.reconcile({ legacyVariant = "falsa" }).legacyVariant, nil, "descarta variantes falsas")
		t.eq(GameData.Parts.legacy.weight, 0, "no sale en las casas")
		for _, zone in GameData.Zones do
			t.eq(zone.weights.legacy, nil, zone.name .. " no da piezas del legado")
		end
	end)

	t.test("DEV-011: vender rinde más al momento; exhibir da el 30% por periodo", function()
		for _, watchId in GameData.WatchOrder do
			local perPeriod = PlayerLogic.watchIncomePerMinute(watchId) * Config.PLOT_INCOME_PERIOD_SECONDS / 60
			t.ok(
				math.abs(perPeriod - GameData.Watches[watchId].sell * Config.PLOT_INCOME_PERCENT) < 1e-6,
				watchId .. ": 30% del valor por periodo"
			)
			t.ok(GameData.Watches[watchId].sell > perPeriod, watchId .. ": vender da más que un periodo exhibido")
		end
		local data = PlayerLogic.newData()
		data.museum.pocket = 1
		local before = PlayerLogic.museumIncomePerMinute(data)
		PlayerLogic.setPasses(data, { vip = true })
		t.ok(PlayerLogic.museumIncomePerMinute(data) > before, "el VIP aumenta el ingreso pasivo")
		t.eq(PlayerLogic.reconcile({ incomeRemainder = 5 }).incomeRemainder, 0, "repara fracciones inválidas")
	end)

	t.test("DEV-013: capacidad de carga 1 → 4 con 3 mejoras", function()
		local data = PlayerLogic.newData()
		t.eq(PlayerLogic.carryCapacity(data), 1, "empieza llevando 1 objeto")
		t.ok(PlayerLogic.stealPart(data, "gear", 0.99), "roba 1")
		t.ok(not PlayerLogic.stealPart(data, "gear", 0.99), "no puede llevar 2 sin mejora")
		data.coins = 10 ^ 7
		local previous = 0
		for _ = 1, GameData.Upgrades.carry.maxLevel do
			local cost = PlayerLogic.upgradeCost(data, "carry")
			t.ok(cost > previous, "cada mejora cuesta más")
			previous = cost
			t.ok(PlayerLogic.buyUpgrade(data, "carry"), "compra una mejora de carga")
		end
		t.eq(PlayerLogic.carryCapacity(data), 4, "máximo 4 objetos")
		t.ok(not PlayerLogic.buyUpgrade(data, "carry"), "no pasa de 3 mejoras")
		for _ = 1, 3 do
			t.ok(PlayerLogic.stealPart(data, "gear", 0.99), "roba hasta llenar la carga")
		end
		t.ok(not PlayerLogic.stealPart(data, "gear", 0.99), "carga llena")
		t.ok(not table.find(GameData.UpgradeOrder, "carry"), "no se vende en la Tienda")
		local lucky = PlayerLogic.newData()
		lucky.pets.dragon = 3
		lucky.equipped.dragon = 3
		local _, _, amount = PlayerLogic.stealPart(lucky, "gear", 0)
		t.eq(amount, 1, "la suerte no supera la carga por viaje")
	end)

	t.test("DEV-013: ruleta diaria gratis y giros extra", function()
		local data = PlayerLogic.newData()
		local day = 20000 * 86400
		local free, extra = PlayerLogic.spinStatus(data, day)
		t.ok(free and extra == 0, "un giro gratis al día")
		local ok, _, index = PlayerLogic.spinWheel(data, day, 0)
		t.ok(ok and index == 1, "roll 0 = primer premio")
		t.eq(data.coins, GameData.SpinPrizes[1].reward.coins, "entrega el premio")
		t.ok(not PlayerLogic.spinWheel(data, day + 60, 0), "no gira dos veces gratis el mismo día")
		t.ok(PlayerLogic.grantProduct(data, "extraSpin", 0), "compra un giro extra")
		t.ok(PlayerLogic.spinWheel(data, day + 120, 0.999999), "usa el giro extra")
		t.eq(data.spin.extra, 0, "se gasta el giro extra")
		t.ok(PlayerLogic.spinWheel(data, day + 86400, 0.5), "al día siguiente vuelve el giro gratis")
		t.eq(PlayerLogic.rollSpin(0.999999), #GameData.SpinPrizes, "roll alto = último premio")
		for _, prize in GameData.SpinPrizes do
			t.ok(prize.weight > 0 and prize.reward ~= nil, prize.label .. " es válido")
		end
		local trainedData = PlayerLogic.newData()
		PlayerLogic.giveReward(trainedData, { trained = 1 })
		t.eq(trainedData.trained, 1, "premio de velocidad entrenada")
		PlayerLogic.giveReward(trainedData, { trainSeconds = 60 })
		t.eq(trainedData.trained, 1 + Config.TRAIN_RATE * 60, "DEC-024: premio de 1 minuto de entrenamiento")
		t.eq(PlayerLogic.reconcile({ spin = { extra = 10 ^ 6 } }).spin.extra, Config.MAX_EXTRA_SPINS, "tope de giros extra")
	end)

	t.test("DEV-013: ajustes con valores por defecto y validados", function()
		local data = PlayerLogic.newData()
		t.eq(PlayerLogic.getSetting(data, "guide"), 1, "guía activada por defecto")
		t.eq(PlayerLogic.getSetting(data, "scale"), 2, "tamaño normal por defecto")
		t.ok(PlayerLogic.setSetting(data, "guide", 0), "desactiva la guía")
		t.eq(PlayerLogic.buildView(data).settings.guide, 0, "la vista lo refleja")
		t.ok(not PlayerLogic.setSetting(data, "guide", 5), "rechaza valores fuera de rango")
		t.ok(not PlayerLogic.setSetting(data, "scale", 4), "rechaza opciones inexistentes")
		t.ok(not PlayerLogic.setSetting(data, "falso", 1), "rechaza ajustes desconocidos")
		local saved = PlayerLogic.reconcile({ settings = { guide = 0, scale = 9, falso = 1 } })
		t.eq(saved.settings.guide, 0, "conserva ajustes válidos")
		t.eq(saved.settings.scale, nil, "descarta valores inválidos")
		t.eq(saved.settings.falso, nil, "descarta ajustes desconocidos")
	end)

	t.test("buildView es coherente", function()
		local data = PlayerLogic.newData()
		data.parts.gear = 4
		local view = PlayerLogic.buildView(data)
		t.eq(view.partCount, 4, "partCount")
		t.eq(view.capacity, Config.BASE_BACKPACK, "capacity")
		t.eq(view.upgradeCosts.museum, GameData.Upgrades.museum.baseCost, "costo de mejora")
		view.parts.gear = 99
		t.eq(data.parts.gear, 4, "la vista es una copia")
	end)
end
