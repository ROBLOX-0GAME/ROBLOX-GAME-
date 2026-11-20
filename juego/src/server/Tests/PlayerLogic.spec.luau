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
			upgrades = { backpack = 99, falsa = 1 },
		})
		t.eq(data.coins, 0, "monedas negativas → 0")
		t.eq(data.xp, 0, "xp inválida → 0")
		t.eq(data.parts.gear, 3, "conserva piezas válidas")
		t.eq(data.parts.inventada, nil, "descarta piezas desconocidas")
		t.eq(data.parts.spring, nil, "descarta cantidades negativas")
		t.eq(data.upgrades.backpack, GameData.Upgrades.backpack.maxLevel, "limita nivel de mejora")
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

	t.test("craft consume piezas y da XP", function()
		local data = PlayerLogic.newData()
		local watch = GameData.Watches.pocket
		t.ok(not PlayerLogic.craft(data, "pocket"), "sin piezas no fabrica")
		giveParts(data, watch.cost)
		local ok = PlayerLogic.craft(data, "pocket")
		t.ok(ok, "fabrica con piezas suficientes")
		t.eq(data.watches.pocket, 1, "suma el reloj")
		t.eq(PlayerLogic.partCount(data), 0, "consume todas las piezas")
		t.eq(data.xp, watch.xp, "da XP")
		t.eq(data.parts.gear, nil, "limpia contadores en cero")
	end)

	t.test("craft exige nivel", function()
		local data = PlayerLogic.newData()
		giveParts(data, GameData.Watches.royal.cost)
		local ok, reason = PlayerLogic.craft(data, "royal")
		t.ok(not ok, "nivel 1 no fabrica el reloj real")
		t.ok(string.find(reason, "nivel") ~= nil, "explica que falta nivel")
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

	t.test("vender piezas siempre rinde menos que fabricar", function()
		for _, watchId in GameData.WatchOrder do
			local watch = GameData.Watches[watchId]
			local partsValue = 0
			for partId, amount in watch.cost do
				partsValue += GameData.Parts[partId].sell * amount
			end
			t.ok(watch.sell > partsValue, watch.name .. " vale más que sus piezas")
		end
	end)

	t.test("buyUpgrade cobra y respeta el máximo", function()
		local data = PlayerLogic.newData()
		local upgrade = GameData.Upgrades.jump
		t.ok(not PlayerLogic.buyUpgrade(data, "jump"), "sin monedas no compra")
		data.coins = 10 ^ 7
		for _ = 1, upgrade.maxLevel do
			t.ok(PlayerLogic.buyUpgrade(data, "jump"), "compra un nivel")
		end
		t.ok(not PlayerLogic.buyUpgrade(data, "jump"), "no pasa del máximo")
		t.eq(PlayerLogic.upgradeCost(data, "jump"), nil, "sin precio al máximo")
		t.eq(PlayerLogic.jumpHeight(data), Config.BASE_JUMPHEIGHT + upgrade.maxLevel * upgrade.step, "aplica el salto")
	end)

	t.test("upgradeCost crece por nivel", function()
		local data = PlayerLogic.newData()
		local upgrade = GameData.Upgrades.backpack
		t.eq(PlayerLogic.upgradeCost(data, "backpack"), upgrade.baseCost, "precio inicial")
		data.upgrades.backpack = 2
		t.eq(PlayerLogic.upgradeCost(data, "backpack"), math.floor(upgrade.baseCost * upgrade.growth ^ 2), "precio nivel 2")
		t.eq(PlayerLogic.backpackCapacity(data), Config.BASE_BACKPACK + 2 * upgrade.step, "capacidad mejorada")
	end)

	t.test("museo: exhibir, límite de vitrinas, retirar e ingreso", function()
		local data = PlayerLogic.newData()
		local slots = PlayerLogic.museumSlots(data)
		data.watches.wrist = slots + 1
		for _ = 1, slots do
			t.ok(PlayerLogic.display(data, "wrist"), "exhibe")
		end
		t.ok(not PlayerLogic.display(data, "wrist"), "no supera las vitrinas")
		t.eq(PlayerLogic.museumIncome(data), GameData.Watches.wrist.income * slots, "ingreso correcto")
		local earned = PlayerLogic.collectIncome(data)
		t.eq(earned, GameData.Watches.wrist.income * slots, "cobra el ingreso")
		t.eq(data.coins, earned, "suma monedas")
		t.ok(PlayerLogic.withdraw(data, "wrist"), "retira")
		t.eq(data.watches.wrist, 2, "vuelve al inventario")
		t.ok(not PlayerLogic.withdraw(data, "pocket"), "no retira lo que no está")
	end)

	t.test("rollPart devuelve piezas válidas y la suerte ayuda", function()
		t.eq(PlayerLogic.rollPart(1, 0), GameData.PartOrder[1], "roll 0 = primera pieza")
		t.eq(PlayerLogic.rollPart(1, 0.999999), GameData.PartOrder[#GameData.PartOrder], "roll ~1 = última pieza")
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

	t.test("las recetas solo usan piezas existentes", function()
		for _, watchId in GameData.WatchOrder do
			local watch = GameData.Watches[watchId]
			t.ok(watch ~= nil, "reloj en el orden existe: " .. watchId)
			for partId in watch.cost do
				t.ok(GameData.Parts[partId] ~= nil, watchId .. " usa pieza válida " .. partId)
			end
		end
	end)

	t.test("buildView es coherente", function()
		local data = PlayerLogic.newData()
		data.parts.gear = 4
		local view = PlayerLogic.buildView(data)
		t.eq(view.partCount, 4, "partCount")
		t.eq(view.capacity, Config.BASE_BACKPACK, "capacity")
		t.eq(view.upgradeCosts.backpack, GameData.Upgrades.backpack.baseCost, "costo de mejora")
		view.parts.gear = 99
		t.eq(data.parts.gear, 4, "la vista es una copia")
	end)
end
