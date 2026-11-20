--[[
	GameData — catálogo de piezas, relojes, mejoras, zonas y tutorial.

	Todo el contenido y sus cifras son PROPUESTA, pendiente de aprobación del
	equipo. Los textos visibles están en español.
]]

local GameData = {}

-- Piezas. Se roban en las casas de cada zona (ver GameData.Zones).
-- weight: probabilidad base (la usa rollPart sin tabla de zona)
-- sell: monedas al vender la pieza suelta en la Tienda (salida de BUG-001; menor que fabricar)
-- holdTime: segundos manteniendo el botón para robarla
GameData.Parts = {
	gear = { id = "gear", name = "Engranaje", rarity = "Común", common = true, weight = 40, sell = 2, holdTime = 0.3 },
	spring = { id = "spring", name = "Resorte", rarity = "Común", common = true, weight = 30, sell = 2, holdTime = 0.3 },
	screw = { id = "screw", name = "Tornillo", rarity = "Común", common = true, weight = 30, sell = 2, holdTime = 0.3 },
	crystal = {
		id = "crystal",
		name = "Cristal",
		rarity = "Poco común",
		common = false,
		weight = 14,
		sell = 6,
		holdTime = 0.6,
	},
	strap = { id = "strap", name = "Correa", rarity = "Poco común", common = false, weight = 12, sell = 6, holdTime = 0.6 },
	ruby = { id = "ruby", name = "Rubí", rarity = "Raro", common = false, weight = 4, sell = 25, holdTime = 1 },
	diamond = {
		id = "diamond",
		name = "Diamante",
		rarity = "Legendario",
		common = false,
		weight = 0, -- solo aparece en zonas ricas
		sell = 80,
		holdTime = 1.5,
	},
}
GameData.PartOrder = { "gear", "spring", "screw", "crystal", "strap", "ruby", "diamond" }

-- Puntos de reparación del Cronómetro Maestro por rareza (DEV-004, PROPUESTA)
GameData.RepairPoints = {
	["Común"] = 1,
	["Poco común"] = 3,
	["Raro"] = 8,
	["Legendario"] = 20,
}

GameData.RarityColors = {
	["Común"] = Color3.fromRGB(170, 170, 180),
	["Poco común"] = Color3.fromRGB(80, 150, 230),
	["Raro"] = Color3.fromRGB(220, 60, 70),
	["Épico"] = Color3.fromRGB(170, 90, 230),
	["Legendario"] = Color3.fromRGB(255, 200, 40),
}

-- Mascotas (DEV-005, PROPUESTA). bonus: velocidad extra (0.10 = +10%).
-- El multiplicador total es 1 + suma de los bonus de las mascotas equipadas.
GameData.Pets = {
	mouse = { id = "mouse", name = "Ratón de Cuerda", rarity = "Común", bonus = 0.05 },
	cat = { id = "cat", name = "Gato Engranaje", rarity = "Poco común", bonus = 0.10 },
	fox = { id = "fox", name = "Zorro Relojero", rarity = "Raro", bonus = 0.20 },
	hawk = { id = "hawk", name = "Halcón de Cuarzo", rarity = "Épico", bonus = 0.35 },
	dragon = { id = "dragon", name = "Dragón del Tiempo", rarity = "Legendario", bonus = 0.60 },
}
GameData.PetOrder = { "mouse", "cat", "fox", "hawk", "dragon" }

-- Huevos del Criadero. chances: probabilidad relativa de cada mascota.
GameData.Eggs = {
	brass = {
		id = "brass",
		name = "Huevo de Latón",
		cost = 500,
		chances = { mouse = 60, cat = 30, fox = 10 },
	},
	silver = {
		id = "silver",
		name = "Huevo de Plata",
		cost = 5000,
		chances = { cat = 50, fox = 35, hawk = 15 },
	},
	gold = {
		id = "gold",
		name = "Huevo de Oro",
		cost = 40000,
		chances = { fox = 50, hawk = 35, dragon = 15 },
	},
}
GameData.EggOrder = { "brass", "silver", "gold" }

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
	millionaire = {
		id = "millionaire",
		name = "Reloj del millonario",
		level = 8,
		xp = 400,
		sell = 5000,
		income = 60,
		cost = { gear = 10, spring = 6, crystal = 6, strap = 4, ruby = 4, diamond = 2 },
	},
}
GameData.WatchOrder = { "pocket", "wrist", "chrono", "royal", "millionaire" }

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
		desc = "+2 de velocidad (abre zonas más ricas)",
		maxLevel = 10,
		baseCost = 150,
		growth = 1.8,
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
		desc = "+7.5% de probabilidad de robar 2 piezas en vez de 1",
		maxLevel = 5,
		baseCost = 250,
		growth = 2.2,
		step = 0.075,
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

-- Zonas de robo (DEV-003, PROPUESTA). Se recorren en línea recta desde la base.
-- minSpeed: velocidad necesaria para cruzar la puerta de la zona y robar en ella
-- ownerSpeed: velocidad del dueño que te persigue (algo menor que minSpeed:
--   quien apenas cumple el mínimo puede escapar si no se deja alcanzar)
-- weights: probabilidad relativa de cada pieza en las casas de la zona
GameData.Zones = {
	{
		id = "humble",
		name = "Barrio Humilde",
		minSpeed = 0,
		ownerSpeed = 14,
		color = Color3.fromRGB(150, 120, 90),
		owners = { "Don Tomás", "Doña Rosa", "Don Pepe", "Doña Lupe" },
		weights = { gear = 40, spring = 30, screw = 30, crystal = 4, strap = 4 },
	},
	{
		id = "worker",
		name = "Barrio Obrero",
		minSpeed = 18,
		ownerSpeed = 17,
		color = Color3.fromRGB(170, 110, 80),
		owners = { "Señor Ramírez", "Señora Ortiz", "Señor Vega", "Señora Luna" },
		weights = { gear = 30, spring = 25, screw = 25, crystal = 12, strap = 10, ruby = 1 },
	},
	{
		id = "residential",
		name = "Zona Residencial",
		minSpeed = 22,
		ownerSpeed = 21,
		color = Color3.fromRGB(200, 200, 205),
		owners = { "Licenciado Mora", "Doctora Paz", "Ingeniero Soto", "Arquitecta Real" },
		weights = { gear = 20, spring = 20, screw = 15, crystal = 20, strap = 18, ruby = 5, diamond = 0.5 },
	},
	{
		id = "mansions",
		name = "Mansiones",
		minSpeed = 28,
		ownerSpeed = 26,
		color = Color3.fromRGB(235, 225, 200),
		owners = { "Magnate Duarte", "Condesa Ibarra", "Barón Salcedo", "Duquesa Alba" },
		weights = { gear = 10, spring = 10, screw = 10, crystal = 25, strap = 25, ruby = 14, diamond = 3 },
	},
	{
		id = "millionaires",
		name = "Colina de los Millonarios",
		minSpeed = 34,
		ownerSpeed = 32,
		color = Color3.fromRGB(240, 200, 90),
		owners = { "Sir Oro", "Lady Platino", "Rey del Tiempo", "Reina del Cuarzo" },
		weights = { gear = 5, spring = 5, screw = 5, crystal = 20, strap = 20, ruby = 30, diamond = 10 },
	},
}

-- Tutorial guiado (DEV-002, PROPUESTA). Los pasos se completan en orden.
-- stat: qué se mide (ver PlayerLogic.tutorialValue) · target: meta
-- reward: monedas al completar · guide: a dónde apunta la guía en el mundo
GameData.Tutorial = {
	{
		id = "collect",
		text = "Roba 5 piezas en una casa y llévalas a la base",
		stat = "collected",
		target = 5,
		reward = 20,
		guide = "house",
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
