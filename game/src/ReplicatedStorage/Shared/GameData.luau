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

-- Rarezas (DEC-028, Jhonn 2026-11-21): 12, de menor a mayor. color: color principal;
-- stroke: contorno del texto del aviso (nil = sin contorno); rainbow: color animado;
-- message: título del aviso que ven todos (desde Config.ANNOUNCE_MIN_RARITY).
GameData.Rarities = {
	{ name = "Común", color = Color3.fromRGB(176, 180, 188) },
	{ name = "Poco común", color = Color3.fromRGB(76, 175, 106) },
	{ name = "Raro", color = Color3.fromRGB(61, 139, 253) },
	{ name = "Épico", color = Color3.fromRGB(155, 89, 230) },
	{ name = "Legendario", color = Color3.fromRGB(242, 160, 50) },
	{ name = "Mítico", color = Color3.fromRGB(224, 60, 60), message = "¡PIEZA MÍTICA!" },
	{ name = "Divino", color = Color3.fromRGB(255, 221, 51), stroke = Color3.fromRGB(255, 255, 255), message = "✦ ¡PIEZA DIVINA! ✦" },
	{ name = "Celestial", color = Color3.fromRGB(91, 213, 224), stroke = Color3.fromRGB(255, 255, 255), message = "☾ ¡PIEZA CELESTIAL! ☽" },
	{ name = "Cósmico", color = Color3.fromRGB(214, 92, 230), stroke = Color3.fromRGB(40, 10, 60), message = "✧ ¡PIEZA CÓSMICA! ✧" },
	{ name = "Eterno", color = Color3.fromRGB(255, 255, 255), stroke = Color3.fromRGB(242, 193, 78), message = "∞ ¡PIEZA ETERNA! ∞" },
	{ name = "Ancestral", color = Color3.fromRGB(0, 168, 107), stroke = Color3.fromRGB(0, 0, 0), message = "⚜ ¡PIEZA ANCESTRAL! ⚜" },
	{ name = "Atemporal", color = Color3.fromRGB(255, 255, 255), rainbow = true, message = "⌛ ¡¡PIEZA ATEMPORAL!! ⌛" },
}
-- Posición de cada rareza (1 = Común … 12 = Atemporal)
GameData.RarityIndex = {}
GameData.RarityColors = {}
for index, rarity in GameData.Rarities do
	GameData.RarityIndex[rarity.name] = index
	GameData.RarityColors[rarity.name] = rarity.color
end
GameData.RarityColors["Herencia"] = Color3.fromRGB(255, 240, 150)

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
		robux = 459,
		name = "Mascota Suprema",
		desc = "Mascota exclusiva 20% mejor que tu mejor mascota (mejora sola cuando consigues mejores)",
	},
	turboTreadmill = {
		id = "turboTreadmill",
		robux = 229,
		name = "Caminadora Turbo",
		desc = "Tu caminadora del plot entrena ×2 más rápido",
	},
	runner = {
		id = "runner",
		robux = 289,
		name = "Corredor VIP",
		desc = "+25% de velocidad permanente",
		speedMultiplier = 1.25,
	},
	vip = {
		id = "vip",
		robux = 349,
		name = "VIP",
		desc = "+20% de monedas, premios por tiempo un 30% antes, etiqueta [VIP] en el chat y ganancia offline de 8 h",
		coinMultiplier = 1.2,
	},
	-- DEC-030: monedas ×2 al vender, en el botín y en el plot (se combina con el VIP)
	moneyX2 = {
		id = "moneyX2",
		robux = 249,
		name = "Dinero ×2",
		desc = "Monedas ×2 al vender, en el botín y en tu plot, para siempre",
		coinMultiplier = 2,
	},
	bigBackpack = {
		id = "bigBackpack",
		robux = 119,
		name = "Mochila Gigante",
		desc = "+20 espacios para piezas",
		backpack = 20,
	},
	petSlot = {
		id = "petSlot",
		robux = 179,
		name = "Ranura de Mascota",
		desc = "+1 mascota equipada",
		petSlots = 1,
	},
}
-- Multiplicadores de ganancia de velocidad al entrenar (DEC-023, Jhonn 2026-11-20):
-- ×2 … ×512. Se usa el más alto que tengas (no se suman entre sí) y se combina con
-- la mejora de la caminadora y la Caminadora Turbo.
GameData.SPEED_MULTIPLIER_PASSES = {
	{ factor = 2, robux = 3 },
	{ factor = 4, robux = 5 },
	{ factor = 8, robux = 15 },
	{ factor = 16, robux = 35 },
	{ factor = 32, robux = 75 },
	{ factor = 64, robux = 149 },
	{ factor = 128, robux = 299 },
	{ factor = 256, robux = 599 },
	{ factor = 512, robux = 1199 },
}
GameData.GamePassOrder = { "supremePet", "turboTreadmill", "runner", "vip", "moneyX2", "bigBackpack", "petSlot" }
for _, tier in GameData.SPEED_MULTIPLIER_PASSES do
	local id = "speedX" .. tier.factor
	GameData.GamePasses[id] = {
		id = id,
		name = string.format("Entrenamiento ×%d", tier.factor),
		desc = string.format("Ganas velocidad ×%d más rápido al entrenar, para siempre (se usa el multiplicador más alto que tengas)", tier.factor),
		robux = tier.robux,
		trainFactor = tier.factor,
	}
	table.insert(GameData.GamePassOrder, id)
end

-- Productos (compra repetible con Robux). DEV-006, PROPUESTA.
GameData.Products = {
	coinsSmall = { id = "coinsSmall", robux = 25, name = "Bolsa de monedas", desc = "+2.500 monedas", coins = 2500 },
	coinsMedium = { id = "coinsMedium", robux = 99, name = "Cofre de monedas", desc = "+15.000 monedas", coins = 15000 },
	coinsLarge = { id = "coinsLarge", robux = 399, name = "Bóveda de monedas", desc = "+75.000 monedas", coins = 75000 },
	instantTraining = {
		id = "instantTraining",
		robux = 49,
		name = "Entrenamiento instantáneo",
		desc = "5 minutos de entrenamiento al instante (con el multiplicador de tu caminadora)",
		trainSeconds = 300,
	},
	goldEgg = {
		id = "goldEgg",
		robux = 49,
		name = "Cápsula de Oro",
		desc = "Una Cápsula de Oro para tu Mochila (probabilidades en el Criadero)",
		egg = "gold",
	},
	cosmicCapsule = {
		id = "cosmicCapsule",
		robux = 149,
		name = "Cápsula Cósmica",
		desc = "Mascotas exclusivas: Fénix Cronal +80%, Titán de Cuarzo +100%, Señor del Tiempo +150%",
		egg = "cosmic",
	},
}
GameData.Products.extraSpin = {
	id = "extraSpin",
	robux = 19,
	name = "Giro extra de ruleta",
	desc = "Un giro más de la ruleta diaria (probabilidades en la ruleta)",
	spins = 1,
}
GameData.ProductOrder = { "coinsSmall", "coinsMedium", "coinsLarge", "instantTraining", "goldEgg", "cosmicCapsule", "extraSpin" }

-- Ajustes del jugador (DEV-013). kind = "toggle" (0/1) o "choice" (índice en options).
GameData.Settings = {
	{ id = "guide", name = "Guía del tutorial", kind = "toggle", default = 1 },
	{ id = "toasts", name = "Notificaciones", kind = "toggle", default = 1 },
	{ id = "scale", name = "Tamaño de la interfaz", kind = "choice", options = { "Pequeño", "Normal", "Grande" }, default = 2 },
	-- DEC-024: velocidad al caminar por la base (la barra del botón «Velocidad» del HUD)
	{ id = "runSpeed", name = "Velocidad en la base", kind = "range", min = 16, max = 50, default = 50 },
}

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

-- Relojes (DEC-028, Jhonn 2026-11-21). Se arman con 4 piezas en la mesa del plot:
-- Caja → Calibre → Esfera → Manecillas. La rareza del reloj sale de sus piezas.
-- base: valor de venta con rareza Común; cada rareza multiplica por
--   Config.RARITY_VALUE_GROWTH (el mejor: Ricardo Mil Tourbillon con 4 piezas
--   Atemporales ≈ 1,8T, dentro de lo pedido: 1.500T–1.950T).
-- xp: experiencia al armarlo · luck: suerte exhibido en el plot (con rareza Común)
-- caliber: Cuarzo, Mecánico o Automático (solo visual, R-009)
-- zone: zona donde salen sus piezas en exclusiva (nil = reloj general, sale en cualquier zona)
-- weight: probabilidad relativa entre los relojes generales
-- Nombres interpretados (sin marcas reales); el arte se parece al original sin logos.
-- sell = base (compatibilidad con código anterior)
GameData.Watches = {
	pocket = {
		id = "pocket",
		name = "Reloj de bolsillo",
		inspired = "clásico de bolsillo con tapa",
		base = 60,
		sell = 60,
		xp = 10,
		luck = 0.005,
		caliber = "Mecánico",
		weight = 30,
	},
	wrist = {
		id = "wrist",
		name = "Reloj de pulsera",
		inspired = "pulsera sencilla de diario",
		base = 150,
		sell = 150,
		xp = 20,
		luck = 0.01,
		caliber = "Cuarzo",
		weight = 25,
	},
	chrono = {
		id = "chrono",
		name = "Cronógrafo",
		inspired = "cronógrafo deportivo de 3 subesferas",
		base = 400,
		sell = 400,
		xp = 40,
		luck = 0.015,
		caliber = "Mecánico",
		weight = 18,
	},
	legacy = {
		id = "legacy",
		name = "Reloj del Legado",
		inspired = "reloj único con la pieza del legado",
		base = 1000,
		sell = 1000,
		xp = 80,
		luck = 0.03,
		caliber = "Automático",
		weight = 7,
		needsLegacy = true, -- además de sus 4 piezas, usa la pieza del legado
	},
	royal = {
		id = "royal",
		name = "Reloj real de rubí",
		inspired = "reloj de gala con rubíes",
		base = 1200,
		sell = 1200,
		xp = 100,
		luck = 0.025,
		caliber = "Automático",
		weight = 12,
	},
	millionaire = {
		id = "millionaire",
		name = "Reloj del millonario",
		inspired = "bisel de diamantes y esfera dorada",
		base = 3000,
		sell = 3000,
		xp = 200,
		luck = 0.04,
		caliber = "Automático",
		weight = 8,
	},
	-- DEV-026: 12 relojes de lujo, uno exclusivo por zona (nombres interpretados;
	-- el arte debe parecerse al original, sin marcas). material: el de su zona.
	lunamaster = {
		id = "lunamaster",
		name = "Omigo Lunamaster",
		inspired = "inspirado en Omega Speedmaster",
		material = "acero",
		base = 200,
		sell = 200,
		xp = 25,
		luck = 0.01,
		caliber = "Mecánico",
		zone = 1,
	},
	santo = {
		id = "santo",
		name = "Cartero Santo",
		inspired = "inspirado en Cartier Santos",
		material = "acero cepillado con tornillos vistos",
		base = 300,
		sell = 300,
		xp = 35,
		luck = 0.012,
		caliber = "Automático",
		zone = 2,
	},
	reverso = {
		id = "reverso",
		name = "Jaguar-LeColtre Reversible",
		inspired = "inspirado en Jaeger-LeCoultre Reverso",
		material = "acero y esmalte art déco",
		base = 500,
		sell = 500,
		xp = 50,
		luck = 0.015,
		caliber = "Mecánico",
		zone = 3,
	},
	daytona = {
		id = "daytona",
		name = "Rolando Daytuna",
		inspired = "inspirado en Rolex Daytona",
		material = "oro amarillo",
		base = 800,
		sell = 800,
		xp = 70,
		luck = 0.02,
		caliber = "Automático",
		zone = 4,
	},
	overseas = {
		id = "overseas",
		name = "Vacherón Ultramar",
		inspired = "inspirado en Vacheron Constantin Overseas",
		material = "oro rosa",
		base = 1200,
		sell = 1200,
		xp = 90,
		luck = 0.02,
		caliber = "Automático",
		zone = 5,
	},
	nautil = {
		id = "nautil",
		name = "Philippon Nautil",
		inspired = "inspirado en Patek Philippe Nautilus",
		material = "acero con esfera azul",
		base = 1600,
		sell = 1600,
		xp = 120,
		luck = 0.025,
		caliber = "Automático",
		zone = 6,
	},
	roblereal = {
		id = "roblereal",
		name = "Audemar Roble Real",
		inspired = "inspirado en Audemars Piguet Royal Oak",
		material = "acero y oro blanco",
		base = 2000,
		sell = 2000,
		xp = 150,
		luck = 0.03,
		caliber = "Automático",
		zone = 7,
	},
	bigbang = {
		id = "bigbang",
		name = "Hublón Gran Explosión",
		inspired = "inspirado en Hublot Big Bang",
		material = "cerámica y caucho",
		base = 2500,
		sell = 2500,
		xp = 180,
		luck = 0.03,
		caliber = "Automático",
		zone = 8,
	},
	rm11 = {
		id = "rm11",
		name = "Ricardo Mil RM-11",
		inspired = "inspirado en Richard Mille RM 11",
		material = "carbono y zafiro",
		base = 3000,
		sell = 3000,
		xp = 220,
		luck = 0.035,
		caliber = "Automático",
		zone = 9,
	},
	tourbillon = {
		id = "tourbillon",
		name = "Bregué Clásico Tourbillon",
		inspired = "inspirado en Breguet Classique Tourbillon",
		material = "oro con guilloché",
		base = 3500,
		sell = 3500,
		xp = 260,
		luck = 0.04,
		caliber = "Mecánico",
		zone = 10,
	},
	granmaestro = {
		id = "granmaestro",
		name = "Philippon Gran Maestro Campana",
		inspired = "inspirado en Patek Philippe Grandmaster Chime",
		material = "oro rosa y esmalte",
		base = 4200,
		sell = 4200,
		xp = 300,
		luck = 0.045,
		caliber = "Mecánico",
		zone = 11,
	},
	astronomia = {
		id = "astronomia",
		name = "Jacobo y Cía. Astronomía",
		inspired = "inspirado en Jacob & Co. Astronomia",
		material = "zafiro y gemas",
		base = 5000,
		sell = 5000,
		xp = 400,
		luck = 0.05,
		caliber = "Mecánico",
		zone = 12,
	},
}
GameData.WatchOrder = { "pocket", "wrist", "chrono", "legacy", "royal", "millionaire", "lunamaster", "santo", "reverso", "daytona", "overseas", "nautil", "roblereal", "bigbang", "rm11", "tourbillon", "granmaestro", "astronomia" }
-- Índice numérico de cada reloj (para las claves cortas de las piezas)
GameData.WatchIndex = {}
for index, watchId in GameData.WatchOrder do
	GameData.WatchIndex[watchId] = index
end

-- Clases de pieza, en el orden de los marcos verdes de la mesa (DEC-028)
GameData.PieceClasses = {
	{ id = "case", name = "Caja" },
	{ id = "movement", name = "Calibre" },
	{ id = "dial", name = "Esfera" },
	{ id = "hands", name = "Manecillas" },
}

-- Mejoras (DEC-027, Jhonn 2026-11-21): solo hay tres. El precio sube por nivel y
-- nunca depende de la zona. Precio del siguiente nivel: floor(baseCost × growth ^ nivel).
--   - Vitrinas del plot: de 4 a 12 (+1 por nivel), 100 y ×10.
--   - Carga por viaje: de 1 a 4 objetos (3 niveles), 100 y ×10.
--   - Caminadora: 30 niveles, ×2 de entrenamiento cada uno. growth 2.25: el nivel 30
--     cuesta ~1,6T, lo que vale vender el mejor reloj del juego (1.500T–1.950T, DEC-028).
-- La mochila es fija (Config.BASE_BACKPACK) y solo crece con el pase de Robux.
-- No hay mejoras de velocidad, salto ni suerte.
GameData.Upgrades = {
	-- El id «museum» se conserva para no perder datos guardados: son las vitrinas del plot.
	museum = {
		id = "museum",
		name = "Vitrinas del plot",
		desc = "+1 vitrina en tu plot para exhibir relojes (de 4 a 12)",
		maxLevel = 8,
		baseCost = 100,
		growth = 10,
		step = 1,
	},
	treadmill = {
		id = "treadmill",
		name = "Caminadora del plot",
		desc = "Duplica lo que entrena tu caminadora (×2 por nivel)",
		maxLevel = 30,
		baseCost = 100,
		growth = 2.25,
		step = 2, -- DEC-024: multiplicador step ^ nivel
	},
	carry = {
		id = "carry",
		name = "Capacidad de carga",
		desc = "+1 objeto robado por viaje (máximo 4)",
		maxLevel = 3,
		baseCost = 100,
		growth = 10,
		step = 1,
	},
}
-- Mejoras que se compran en la Tienda (DEC-027: ninguna; la Tienda solo compra)
GameData.UpgradeOrder = {}
-- Mejoras que se compran en el propio plot
GameData.PlotUpgradeOrder = { "museum", "treadmill" }
-- Mejoras que se compran en el Puesto de Mochila y Carga
GameData.CarryUpgradeOrder = { "carry" }

-- Ruleta diaria (DEV-013, PROPUESTA): un giro gratis al día (UTC) y giros extra
-- comprados con Robux. weight: probabilidad relativa (se muestra en la ruleta).
GameData.SpinPrizes = {
	{ label = "200 monedas", weight = 30, reward = { coins = 200 } },
	{ label = "500 monedas", weight = 25, reward = { coins = 500 } },
	{ label = "Cápsula de Latón", weight = 20, reward = { capsule = "brass", amount = 1 } },
	{ label = "1.500 monedas", weight = 12, reward = { coins = 1500 } },
	{ label = "Cápsula de Plata", weight = 8, reward = { capsule = "silver", amount = 1 } },
	{ label = "1 minuto de entrenamiento", weight = 4, reward = { trainSeconds = 60 } },
	{ label = "Cápsula de Oro", weight = 1, reward = { capsule = "gold", amount = 1 } },
}

-- Zonas de robo (DEC-024). Se recorren en línea recta desde la base y cada una es
-- un 35 % más larga que la anterior (Config.ZONE_DEPTH_GROWTH).
-- minSpeed: velocidad (estadística) para cruzar la puerta y robar en la zona
-- lootCoins: monedas que trae cada pieza robada (se cobran al llegar a la base)
-- houseAsset: modelo de casa de ReplicatedStorage/Assets
-- weights: probabilidad relativa de cada pieza en las casas de la zona
-- El dueño corre como la velocidad física de minSpeed × Config.OWNER_SPEED_FACTOR.
-- Con GameData.NEXT_WORLD_SPEED se abrirá un mundo nuevo en una actualización futura.
GameData.NEXT_WORLD_SPEED = 1e14
GameData.Zones = {
	{
		id = "humble",
		name = "Barrio Humilde",
		minSpeed = 100,
		lootCoins = 10,
		houseAsset = "mdl_casa_z1",
		color = Color3.fromRGB(150, 120, 90),
		owners = { "Don Tomás", "Doña Rosa", "Don Pepe", "Doña Lupe" },
		weights = { gear = 40, spring = 30, screw = 30, crystal = 4, strap = 4 },
	},
	{
		id = "worker",
		name = "Barrio Obrero",
		minSpeed = 1e3,
		lootCoins = 80,
		houseAsset = "mdl_casa_z2",
		color = Color3.fromRGB(170, 110, 80),
		owners = { "Señor Ramírez", "Señora Ortiz", "Señor Vega", "Señora Luna" },
		weights = { gear = 30, spring = 25, screw = 25, crystal = 12, strap = 10, ruby = 1 },
	},
	{
		id = "residential",
		name = "Zona Residencial",
		minSpeed = 1e4,
		lootCoins = 640,
		houseAsset = "mdl_casa_z3",
		color = Color3.fromRGB(200, 200, 205),
		owners = { "Licenciado Mora", "Doctora Paz", "Ingeniero Soto", "Arquitecta Real" },
		weights = { gear = 20, spring = 20, screw = 15, crystal = 20, strap = 18, ruby = 5, diamond = 0.5 },
	},
	{
		id = "mansions",
		name = "Mansiones",
		minSpeed = 1e5,
		lootCoins = 5120,
		houseAsset = "mdl_casa_z4",
		color = Color3.fromRGB(235, 225, 200),
		owners = { "Magnate Duarte", "Condesa Ibarra", "Barón Salcedo", "Duquesa Alba" },
		weights = { gear = 10, spring = 10, screw = 10, crystal = 25, strap = 25, ruby = 14, diamond = 3 },
	},
	{
		id = "millionaires",
		name = "Colina de los Millonarios",
		minSpeed = 1e6,
		lootCoins = 40960,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(240, 200, 90),
		owners = { "Sir Oro", "Lady Platino", "Rey del Tiempo", "Reina del Cuarzo" },
		weights = { gear = 5, spring = 5, screw = 5, crystal = 20, strap = 20, ruby = 30, diamond = 10 },
	},
	{
		id = "yachts",
		name = "Puerto de los Yates",
		minSpeed = 1.4e7,
		lootCoins = 327680,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(90, 170, 220),
		owners = { "Capitán Brisa", "Almirante Coral", "Doña Marea", "Don Velero" },
		weights = { gear = 4, spring = 4, screw = 4, crystal = 20, strap = 20, ruby = 32, diamond = 12 },
	},
	{
		id = "financial",
		name = "Distrito Financiero",
		minSpeed = 2e8,
		lootCoins = 2621440,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(120, 130, 150),
		owners = { "Banquero Cifuentes", "Inversora Plata", "Corredor Bolsa", "Directora Valor" },
		weights = { gear = 3, spring = 3, screw = 3, crystal = 18, strap = 18, ruby = 34, diamond = 15 },
	},
	{
		id = "island",
		name = "Isla Privada",
		minSpeed = 2.8e9,
		lootCoins = 20971520,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(80, 190, 150),
		owners = { "Magnate Palmera", "Baronesa Arena", "Señor Laguna", "Dama Coral" },
		weights = { gear = 2, spring = 2, screw = 2, crystal = 16, strap = 16, ruby = 36, diamond = 18 },
	},
	{
		id = "crystalcity",
		name = "Ciudad de Cristal",
		minSpeed = 4e10,
		lootCoins = 167772160,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(170, 220, 240),
		owners = { "Conde Prisma", "Duquesa Vidrio", "Marqués Reflejo", "Lady Cuarzo" },
		weights = { gear = 2, spring = 2, screw = 2, crystal = 14, strap = 14, ruby = 36, diamond = 22 },
	},
	{
		id = "goldenvalley",
		name = "Valle Dorado",
		minSpeed = 5.6e11,
		lootCoins = 1342177280,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(230, 180, 60),
		owners = { "Barón Lingote", "Reina Áurea", "Príncipe Quilate", "Dama Pepita" },
		weights = { gear = 1, spring = 1, screw = 1, crystal = 12, strap = 12, ruby = 36, diamond = 27 },
	},
	{
		id = "imperial",
		name = "Palacio Imperial",
		minSpeed = 7.5e12,
		lootCoins = 10737418240,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(150, 60, 140),
		owners = { "Emperador Segundero", "Emperatriz Minuta", "Gran Visir Hora", "Archiduque Tic" },
		weights = { gear = 1, spring = 1, screw = 1, crystal = 10, strap = 10, ruby = 35, diamond = 32 },
	},
	{
		id = "timecitadel",
		name = "Ciudadela del Tiempo",
		minSpeed = 9.99e13,
		lootCoins = 85899345920,
		houseAsset = "mdl_casa_z5",
		color = Color3.fromRGB(60, 50, 110),
		owners = { "Guardián del Tiempo", "Señora del Reloj", "Maestro Cronos", "Dama Eternidad" },
		weights = { gear = 1, spring = 1, screw = 1, crystal = 8, strap = 8, ruby = 33, diamond = 40 },
	},
}

-- Tutorial guiado (DEV-002; rehecho en DEV-011, PROPUESTA). Empieza después de
-- la cinemática y de recoger la pieza del legado. Los pasos se completan en orden.
-- stat: qué se mide (ver PlayerLogic.tutorialValue) · target: meta
-- reward: monedas al completar · guide: a dónde apunta la guía en el mundo
GameData.Tutorial = {
	{
		id = "train",
		text = "Entrena en la caminadora de tu plot hasta tener 100 de velocidad: abre la zona 1",
		stat = "speed",
		target = 100,
		reward = 20,
		guide = "treadmill",
	},
	{
		id = "collect",
		text = "Sal por la abertura del muro, roba 5 piezas de reloj en las casas y vuelve a la base",
		stat = "collected",
		target = 5,
		reward = 30,
		guide = "house",
	},
	{
		id = "craft",
		text = "Arma un reloj en la mesa de tu plot: caja, calibre, esfera y manecillas",
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
		text = "Arma otro y exhíbelo en tu plot: da el 30% de su valor cada 30 s",
		stat = "museum",
		target = 1,
		reward = 40,
		guide = "plot",
	},
	{
		id = "upgrade",
		text = "Compra una mejora en tu plot: más vitrinas o una caminadora más rápida",
		stat = "upgrades",
		target = 1,
		reward = 60,
		guide = "plot",
	},
}

return GameData
