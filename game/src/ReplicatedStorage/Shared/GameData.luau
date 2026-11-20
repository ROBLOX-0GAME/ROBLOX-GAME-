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
GameData.Parts.legacy = {
	id = "legacy",
	name = "Pieza del Legado",
	rarity = "Herencia",
	common = false,
	weight = 0, -- no sale en las casas: se recibe una sola vez en la introducción (DEV-011)
	sell = 0,
	holdTime = 0,
	protected = true, -- no se vende, ni se tira, ni se entrega al Cronómetro: se guarda o se usa
}
GameData.PartOrder = { "gear", "spring", "screw", "crystal", "strap", "ruby", "diamond", "legacy" }

-- Variantes de la pieza del legado (ficticias, inspiradas en la alta relojería;
-- no se usan marcas reales). Se elige una al azar para cada jugador.
GameData.LegacyPieces = {
	{ id = "celestial", name = "Espiral Celestial", desc = "Espiral de un calibre de gran complicación, ensamblada a mano." },
	{ id = "sapphire", name = "Corona de Zafiro Real", desc = "Corona tallada en zafiro de una pieza de alta joyería." },
	{ id = "rainbow", name = "Rotor de Diamantes Arcoíris", desc = "Rotor cubierto de diamantes de colores, de un reloj único." },
}

-- Historia de la cinemática inicial (DEV-011; textos propuestos, los revisa la Cuenta B)
GameData.IntroStory = {
	"Cuando eras pequeño, tus padres se fueron sin dejar rastro.",
	"Creciste solo, con una única pasión: los relojes.",
	"El día que cumpliste 18 años, te dejaron en un lugar que nunca habías visto…",
	"…una ciudad donde los relojes valen fortunas.",
}

-- Puntos de reparación del Cronómetro Maestro por rareza (DEV-004, PROPUESTA)
GameData.RepairPoints = {
	["Común"] = 1,
	["Poco común"] = 3,
	["Raro"] = 8,
	["Legendario"] = 20,
	["Herencia"] = 0, -- protegida: no se entrega
}

GameData.RarityColors = {
	["Común"] = Color3.fromRGB(170, 170, 180),
	["Poco común"] = Color3.fromRGB(80, 150, 230),
	["Raro"] = Color3.fromRGB(220, 60, 70),
	["Épico"] = Color3.fromRGB(170, 90, 230),
	["Legendario"] = Color3.fromRGB(255, 200, 40),
	["Mítico"] = Color3.fromRGB(255, 90, 160),
	["Divino"] = Color3.fromRGB(120, 255, 240),
	["Herencia"] = Color3.fromRGB(255, 240, 150),
}

-- Mascotas (DEV-005, PROPUESTA). bonus: velocidad extra (0.10 = +10%).
-- El multiplicador total es 1 + suma de los bonus de las mascotas equipadas.
GameData.Pets = {
	mouse = { id = "mouse", name = "Ratón de Cuerda", rarity = "Común", bonus = 0.05 },
	cat = { id = "cat", name = "Gato Engranaje", rarity = "Poco común", bonus = 0.10 },
	fox = { id = "fox", name = "Zorro Relojero", rarity = "Raro", bonus = 0.20 },
	hawk = { id = "hawk", name = "Halcón de Cuarzo", rarity = "Épico", bonus = 0.35 },
	dragon = { id = "dragon", name = "Dragón del Tiempo", rarity = "Legendario", bonus = 0.60 },
	-- Exclusivas de la Cápsula Cósmica (solo Robux, DEV-009): más poderosas
	phoenix = { id = "phoenix", name = "Fénix Cronal", rarity = "Mítico", bonus = 0.80, robux = true },
	titan = { id = "titan", name = "Titán de Cuarzo", rarity = "Mítico", bonus = 1.00, robux = true },
	chronolord = { id = "chronolord", name = "Señor del Tiempo", rarity = "Divino", bonus = 1.50, robux = true },
	-- Exclusiva del pase «Mascota Suprema»: su bonus se calcula como 20% más
	-- que tu mejor mascota (PlayerLogic.petBonus). No sale de huevos ni se libera.
	supreme = {
		id = "supreme",
		name = "Mascota Suprema",
		rarity = "Legendario",
		bonus = 0,
		exclusive = true,
	},
}
-- Orden de menor a mayor bonus (la Suprema siempre es la mejor)
GameData.PetOrder = { "mouse", "cat", "fox", "hawk", "dragon", "phoenix", "titan", "chronolord", "supreme" }

-- Caminadora personal del plot (DEV-008). Multiplicador de entrenamiento =
-- 1 + nivel de la mejora «treadmill» × 0.5; el pase Caminadora Turbo lo multiplica.
GameData.TURBO_TREADMILL_FACTOR = 2

-- Pases de juego (compra única con Robux, permanentes). DEV-006, PROPUESTA.
-- Por decisión de Jhonn incluyen ventajas fuertes de velocidad.
GameData.GamePasses = {
	supremePet = {
		id = "supremePet",
		name = "Mascota Suprema",
		desc = "Mascota exclusiva 20% mejor que tu mejor mascota (mejora sola cuando consigues mejores)",
	},
	turboTreadmill = {
		id = "turboTreadmill",
		name = "Caminadora Turbo",
		desc = "Tu caminadora del plot entrena ×2 más rápido",
	},
	runner = {
		id = "runner",
		name = "Corredor VIP",
		desc = "+25% de velocidad permanente",
		speedMultiplier = 1.25,
	},
	vip = {
		id = "vip",
		name = "VIP",
		desc = "+20% de monedas al vender y en el museo",
		coinMultiplier = 1.2,
	},
	bigBackpack = {
		id = "bigBackpack",
		name = "Mochila Gigante",
		desc = "+20 espacios para piezas",
		backpack = 20,
	},
	petSlot = {
		id = "petSlot",
		name = "Ranura de Mascota",
		desc = "+1 mascota equipada",
		petSlots = 1,
	},
}
GameData.GamePassOrder = { "supremePet", "turboTreadmill", "runner", "vip", "bigBackpack", "petSlot" }

-- Productos (compra repetible con Robux). DEV-006, PROPUESTA.
GameData.Products = {
	coinsSmall = { id = "coinsSmall", name = "Bolsa de monedas", desc = "+2.500 monedas", coins = 2500 },
	coinsMedium = { id = "coinsMedium", name = "Cofre de monedas", desc = "+15.000 monedas", coins = 15000 },
	coinsLarge = { id = "coinsLarge", name = "Bóveda de monedas", desc = "+75.000 monedas", coins = 75000 },
	instantTraining = {
		id = "instantTraining",
		name = "Entrenamiento instantáneo",
		desc = "+5 de velocidad entrenada",
		trained = 5,
	},
	goldEgg = {
		id = "goldEgg",
		name = "Cápsula de Oro",
		desc = "Una Cápsula de Oro para tu Mochila (probabilidades en el Criadero)",
		egg = "gold",
	},
	cosmicCapsule = {
		id = "cosmicCapsule",
		name = "Cápsula Cósmica",
		desc = "Mascotas exclusivas: Fénix Cronal +80%, Titán de Cuarzo +100%, Señor del Tiempo +150%",
		egg = "cosmic",
	},
}
GameData.ProductOrder = { "coinsSmall", "coinsMedium", "coinsLarge", "instantTraining", "goldEgg", "cosmicCapsule" }

-- Cápsulas de mascota (DEV-009; antes «huevos»; los ids se conservan).
-- cost: monedas en el Criadero (nil = no se vende por monedas)
-- robuxProduct: producto de Robux que la entrega · chances: probabilidad relativa
GameData.Eggs = {
	brass = {
		id = "brass",
		name = "Cápsula de Latón",
		cost = 500,
		chances = { mouse = 60, cat = 30, fox = 10 },
	},
	silver = {
		id = "silver",
		name = "Cápsula de Plata",
		cost = 5000,
		chances = { cat = 50, fox = 35, hawk = 15 },
	},
	gold = {
		id = "gold",
		name = "Cápsula de Oro",
		cost = 40000,
		chances = { fox = 50, hawk = 35, dragon = 15 },
	},
	cosmic = {
		id = "cosmic",
		name = "Cápsula Cósmica",
		cost = nil,
		robuxProduct = "cosmicCapsule",
		chances = { phoenix = 60, titan = 30, chronolord = 10 },
	},
}
GameData.EggOrder = { "brass", "silver", "gold", "cosmic" }

-- Recompensa diaria (DEV-009, PROPUESTA): racha de 7 días; se reclama una vez
-- por día (UTC) y vuelve al día 1 si se salta un día.
GameData.DailyRewards = {
	{ coins = 250 },
	{ capsule = "brass", amount = 1 },
	{ coins = 750 },
	{ capsule = "brass", amount = 2 },
	{ coins = 2000 },
	{ capsule = "silver", amount = 1 },
	{ capsule = "gold", amount = 1 },
}

-- Recompensas por tiempo jugado en el día (DEV-009, PROPUESTA). Cada nivel
-- se reclama una vez por día al acumular esos minutos.
GameData.PlaytimeRewards = {
	{ minutes = 5, reward = { coins = 150 } },
	{ minutes = 15, reward = { capsule = "brass", amount = 1 } },
	{ minutes = 30, reward = { coins = 1000 } },
	{ minutes = 60, reward = { capsule = "silver", amount = 1 } },
	{ minutes = 120, reward = { capsule = "gold", amount = 1 } },
}

-- Relojes que se fabrican en el taller.
-- level: nivel mínimo · xp: experiencia al fabricar · sell: monedas al vender
-- cost: piezas necesarias · luck: suerte mientras está exhibido
-- Ingreso pasivo exhibido: Config.PLOT_INCOME_PERCENT del valor cada periodo (DEV-011)
GameData.Watches = {
	pocket = {
		id = "pocket",
		luck = 0.005, -- suerte extra mientras está exhibido en el plot (DEV-008)
		name = "Reloj de bolsillo",
		level = 1,
		xp = 10,
		sell = 60,
		cost = { gear = 3, spring = 2, screw = 2 },
	},
	wrist = {
		id = "wrist",
		luck = 0.01, -- suerte extra mientras está exhibido en el plot (DEV-008)
		name = "Reloj de pulsera",
		level = 2,
		xp = 25,
		sell = 150,
		cost = { gear = 4, spring = 2, crystal = 2, strap = 1 },
	},
	chrono = {
		id = "chrono",
		luck = 0.02, -- suerte extra mientras está exhibido en el plot (DEV-008)
		name = "Cronógrafo",
		level = 4,
		xp = 60,
		sell = 400,
		cost = { gear = 6, spring = 4, screw = 4, crystal = 3, strap = 2 },
	},
	royal = {
		id = "royal",
		luck = 0.03, -- suerte extra mientras está exhibido en el plot (DEV-008)
		name = "Reloj real de rubí",
		level = 6,
		xp = 150,
		sell = 1200,
		cost = { gear = 8, spring = 4, crystal = 4, strap = 2, ruby = 2 },
	},
	millionaire = {
		id = "millionaire",
		luck = 0.05, -- suerte extra mientras está exhibido en el plot (DEV-008)
		name = "Reloj del millonario",
		level = 8,
		xp = 400,
		sell = 5000,
		cost = { gear = 10, spring = 6, crystal = 6, strap = 4, ruby = 4, diamond = 2 },
	},
}
GameData.Watches.legacy = {
	id = "legacy",
	name = "Reloj del Legado",
	luck = 0.04,
	level = 3,
	xp = 200,
	sell = 3000,
	cost = { legacy = 1, gear = 6, spring = 4, crystal = 2, strap = 1 },
}
GameData.WatchOrder = { "pocket", "wrist", "chrono", "legacy", "royal", "millionaire" }

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
	-- Mejoras del plot personal (DEV-008). El id «museum» se conserva para no
	-- perder datos guardados: ahora son las vitrinas del plot.
	museum = {
		id = "museum",
		name = "Vitrinas del plot",
		desc = "+2 vitrinas en tu plot para exhibir relojes",
		maxLevel = 6,
		baseCost = 300,
		growth = 2,
		step = 2,
	},
	treadmill = {
		id = "treadmill",
		name = "Caminadora del plot",
		desc = "+0.5 al multiplicador de entrenamiento de tu caminadora",
		maxLevel = 10,
		baseCost = 400,
		growth = 1.75,
		step = 0.5,
	},
}
-- Mejoras que se compran en la Tienda
GameData.UpgradeOrder = { "backpack", "speed", "jump", "luck" }
-- Mejoras que se compran en el propio plot
GameData.PlotUpgradeOrder = { "museum", "treadmill" }

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

-- Tutorial guiado (DEV-002; rehecho en DEV-011, PROPUESTA). Empieza después de
-- la cinemática y de recoger la pieza del legado. Los pasos se completan en orden.
-- stat: qué se mide (ver PlayerLogic.tutorialValue) · target: meta
-- reward: monedas al completar · guide: a dónde apunta la guía en el mundo
GameData.Tutorial = {
	{
		id = "train",
		text = "Gana velocidad: entrena en la caminadora delante de tu plot (+0.5)",
		stat = "trained10",
		target = 5,
		reward = 20,
		guide = "treadmill",
	},
	{
		id = "collect",
		text = "Sal por la abertura del muro, roba 5 piezas en una casa y vuelve a la base",
		stat = "collected",
		target = 5,
		reward = 30,
		guide = "house",
	},
	{
		id = "craft",
		text = "Fabrica un reloj de bolsillo en el taller al fondo de tu plot",
		stat = "crafted",
		target = 1,
		reward = 30,
		guide = "workshop",
	},
	{
		id = "sell",
		text = "Vende un reloj en la Tienda: vender da todo su valor al momento",
		stat = "sold",
		target = 1,
		reward = 40,
		guide = "shop",
	},
	{
		id = "display",
		text = "Fabrica otro y exhíbelo en tu plot: da el 30% de su valor cada 30 s",
		stat = "museum",
		target = 1,
		reward = 40,
		guide = "plot",
	},
	{
		id = "upgrade",
		text = "Compra una mejora: más velocidad abre zonas más ricas",
		stat = "upgrades",
		target = 1,
		reward = 60,
		guide = "shop",
	},
}

return GameData
