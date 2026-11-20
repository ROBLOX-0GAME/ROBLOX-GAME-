--[[
	GameData — catálogo de piezas, relojes y mejoras.

	Todo el contenido y sus cifras son PROPUESTA DEV-001, pendiente de
	aprobación del equipo. Los textos visibles están en español.
]]

local GameData = {}

-- Piezas que salen de las cajas del área de recolección.
-- weight: probabilidad relativa. La suerte multiplica el peso de lo que no es común.
-- sell: monedas al vender la pieza suelta en la Tienda (BUG-001: salida si la
-- mochila se llena). Es bajo a propósito: fabricar relojes siempre rinde más.
GameData.Parts = {
	gear = { id = "gear", name = "Engranaje", rarity = "Común", common = true, weight = 40, sell = 2 },
	spring = { id = "spring", name = "Resorte", rarity = "Común", common = true, weight = 30, sell = 2 },
	screw = { id = "screw", name = "Tornillo", rarity = "Común", common = true, weight = 30, sell = 2 },
	crystal = { id = "crystal", name = "Cristal", rarity = "Poco común", common = false, weight = 14, sell = 6 },
	strap = { id = "strap", name = "Correa", rarity = "Poco común", common = false, weight = 12, sell = 6 },
	ruby = { id = "ruby", name = "Rubí", rarity = "Raro", common = false, weight = 4, sell = 25 },
}
GameData.PartOrder = { "gear", "spring", "screw", "crystal", "strap", "ruby" }

-- Relojes que se fabrican en el taller.
-- level: nivel mínimo · xp: experiencia al fabricar · sell: monedas al vender
-- income: monedas por ciclo del museo mientras está exhibido · cost: piezas necesarias
GameData.Watches = {
	pocket = {
		id = "pocket",
		name = "Reloj de bolsillo",
		level = 1,
		xp = 10,
		sell = 60,
		income = 1,
		cost = { gear = 3, spring = 2, screw = 2 },
	},
	wrist = {
		id = "wrist",
		name = "Reloj de pulsera",
		level = 2,
		xp = 25,
		sell = 150,
		income = 3,
		cost = { gear = 4, spring = 2, crystal = 2, strap = 1 },
	},
	chrono = {
		id = "chrono",
		name = "Cronógrafo",
		level = 4,
		xp = 60,
		sell = 400,
		income = 8,
		cost = { gear = 6, spring = 4, screw = 4, crystal = 3, strap = 2 },
	},
	royal = {
		id = "royal",
		name = "Reloj real de rubí",
		level = 6,
		xp = 150,
		sell = 1200,
		income = 25,
		cost = { gear = 8, spring = 4, crystal = 4, strap = 2, ruby = 2 },
	},
}
GameData.WatchOrder = { "pocket", "wrist", "chrono", "royal" }

-- Mejoras compradas con monedas. Precio del siguiente nivel:
-- floor(baseCost * growth ^ nivelActual)
GameData.Upgrades = {
	backpack = {
		id = "backpack",
		name = "Mochila",
		desc = "+10 espacios para piezas",
		maxLevel = 5,
		baseCost = 100,
		growth = 2,
		step = 10,
	},
	speed = {
		id = "speed",
		name = "Velocidad",
		desc = "+2 de velocidad al caminar",
		maxLevel = 5,
		baseCost = 150,
		growth = 2,
		step = 2,
	},
	jump = {
		id = "jump",
		name = "Salto",
		desc = "+1.5 de altura de salto",
		maxLevel = 3,
		baseCost = 200,
		growth = 2,
		step = 1.5,
	},
	luck = {
		id = "luck",
		name = "Suerte",
		desc = "+15% de piezas poco comunes y raras",
		maxLevel = 5,
		baseCost = 250,
		growth = 2.2,
		step = 0.15,
	},
	museum = {
		id = "museum",
		name = "Vitrinas del museo",
		desc = "+1 vitrina para exhibir relojes",
		maxLevel = 5,
		baseCost = 300,
		growth = 2,
		step = 1,
	},
}
GameData.UpgradeOrder = { "backpack", "speed", "jump", "luck", "museum" }

-- Tutorial guiado (DEV-002, PROPUESTA). Los pasos se completan en orden.
-- stat: qué se mide (ver PlayerLogic.tutorialValue) · target: meta
-- reward: monedas al completar · guide: a dónde apunta la guía en el mundo
GameData.Tutorial = {
	{
		id = "collect",
		text = "Recoge 5 cajas de piezas en la zona de arena",
		stat = "collected",
		target = 5,
		reward = 20,
		guide = "collect",
	},
	{
		id = "craft",
		text = "Fabrica un reloj de bolsillo en el Taller",
		stat = "crafted",
		target = 1,
		reward = 30,
		guide = "workshop",
	},
	{
		id = "sell",
		text = "Vende un reloj en la Tienda",
		stat = "sold",
		target = 1,
		reward = 30,
		guide = "shop",
	},
	{
		id = "display",
		text = "Fabrica otro reloj y exhíbelo en el Museo",
		stat = "museum",
		target = 1,
		reward = 40,
		guide = "museum",
	},
	{
		id = "upgrade",
		text = "Compra tu primera mejora en la Tienda",
		stat = "upgrades",
		target = 1,
		reward = 50,
		guide = "shop",
	},
}

return GameData
