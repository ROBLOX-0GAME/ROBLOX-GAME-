--[[
	Config — valores técnicos y de balance de BUILD A WATCH!

	IMPORTANTE: todas las cifras de balance (monedas, capacidades, tiempos,
	velocidades) son PROPUESTAS y están pendientes de aprobación del equipo.
	Cambiar un número aquí cambia el juego sin tocar otro código.
]]

local Config = {
	-- Guardado de datos
	DATASTORE_NAME = "BuildAWatch_PlayerData_v1",
	DATA_VERSION = 1,
	AUTOSAVE_SECONDS = 120,
	SESSION_LOCK_SECONDS = 300, -- tras este tiempo un bloqueo de sesión se considera abandonado
	LOAD_ATTEMPTS = 5,
	LOAD_RETRY_SECONDS = 3,
	SAVE_ATTEMPTS = 3,

	-- Jugador (bases antes de mejoras)
	START_COINS = 0,
	BASE_BACKPACK = 20, -- piezas que caben (guardadas + botín que llevas encima)
	BASE_CARRY = 1, -- objetos robados que puedes llevar por viaje (DEV-013; hasta 4 con 3 mejoras)
	BASE_WALKSPEED = 16,
	MAX_WALKSPEED = 80, -- tope de seguridad para la física
	BASE_JUMPHEIGHT = 7.2,
	BASE_MUSEUM_SLOTS = 3, -- vitrinas iniciales del plot
	MAX_WATCHES_PER_TYPE = 999,

	-- Progresión: subir del nivel n al n+1 cuesta XP_PER_LEVEL_STEP * n
	XP_PER_LEVEL_STEP = 50,
	MAX_LEVEL = 20,

	-- Mundo
	HUB_MAX_Z = 20, -- todo lo que tenga Z menor es la base (zona segura)
	HOUSE_SPOT_RESPAWN_SECONDS = 20, -- una pieza robada reaparece tras este tiempo
	MUSEUM_TICK_SECONDS = 10, -- cada cuánto se paga el ingreso pasivo (en fracciones)
	-- Ingreso pasivo de un reloj exhibido (DEV-011): PLOT_INCOME_PERCENT de su valor
	-- de venta cada PLOT_INCOME_PERIOD_SECONDS. Vender da el 100% al momento.
	PLOT_INCOME_PERCENT = 0.30,
	PLOT_INCOME_PERIOD_SECONDS = 30, -- DEV-012: cada 30 s (antes 600)
	LEGACY_CLAIM_DISTANCE = 80, -- distancia máxima a la aparición para recoger la pieza del legado

	-- Robo y persecución (DEV-003)
	OWNER_REACTION_SECONDS = 1.2, -- el dueño tarda esto en salir tras de ti
	CHASE_MAX_SECONDS = 25, -- el dueño se rinde después de este tiempo
	CHASE_LOSE_DISTANCE = 140, -- el dueño se rinde si te alejas tanto
	CATCH_DISTANCE = 4.5, -- distancia a la que el dueño te atrapa

	-- Jefe cooperativo: Cronómetro Maestro (DEV-004)
	BOSS_FIRST_DELAY_SECONDS = 90, -- primera avería tras iniciar el servidor
	BOSS_INTERVAL_SECONDS = 420, -- tiempo entre averías
	BOSS_DURATION_SECONDS = 150, -- tiempo para repararlo
	BOSS_POINTS_PER_PLAYER = 25, -- meta = esto × jugadores conectados
	BOSS_MIN_GOAL = 30,
	BOSS_COINS_PER_POINT = 12, -- premio por punto aportado si se repara
	BOSS_EGG_MIN_POINTS = 20, -- con este aporte también se gana un huevo de mascota
	BOSS_EGG = "brass",

	-- Mascotas (DEV-005) y cápsulas (DEV-009)
	MAX_PETS = 50,
	MAX_CAPSULES = 99, -- por tipo, en la Mochila
	PLAYTIME_TICK_SECONDS = 30, -- cada cuánto se suma el tiempo jugado
	MAX_EXTRA_SPINS = 50, -- giros extra de ruleta guardados (DEV-013)
	MAX_EQUIPPED_PETS = 3,

	-- Plot personal (DEV-008)
	PLOT_COUNT = 6, -- uno por jugador: servidores de 6 (DEV-010; Max Players se fija en Game Settings)
	MAX_PLOT_LUCK = 0.15, -- tope de suerte que dan los relojes exhibidos
	MAX_EXTRA_PART_CHANCE = 0.6, -- tope total de probabilidad de robar 2 piezas

	-- Entrenamiento de velocidad en caminadoras (DEV-006)
	TRAIN_RATE = 0.01, -- velocidad permanente ganada por segundo con multiplicador ×1
	MAX_TRAINED = 30, -- velocidad máxima que se puede ganar entrenando
	TRAIN_TICK_SECONDS = 1,
	TREADMILL_DISTANCE = 8, -- si te alejas más, dejas de entrenar

	-- Pases y productos con Robux (DEV-006). 0 = todavía no creado en Roblox
	-- (se muestra «Próximamente»). Los IDs reales se copian del Creator Hub
	-- al publicar la experiencia.
	GAMEPASS_IDS = {
		supremePet = 0,
		turboTreadmill = 0,
		runner = 0,
		vip = 0,
		bigBackpack = 0,
		petSlot = 0,
	},
	PRODUCT_IDS = {
		coinsSmall = 0,
		coinsMedium = 0,
		coinsLarge = 0,
		instantTraining = 0,
		goldEgg = 0,
		cosmicCapsule = 0,
		extraSpin = 0,
	},
	-- Solo para probar en Studio: da todos los pases durante la sesión (no se guardan).
	STUDIO_GRANT_ALL_PASSES = false,
	SUPREME_PET_FACTOR = 1.2, -- la Mascota Suprema es 20% mejor que tu mejor mascota
	SUPREME_PET_MIN_BONUS = 0.06, -- bonus mínimo si aún no tienes mascotas
	MAX_RECEIPTS = 50, -- compras recordadas para no entregar dos veces

	-- Seguridad
	INTERACT_DISTANCE = 14, -- distancia máxima para robar una pieza
	STATION_DISTANCE = 20, -- distancia máxima a una estación para usar su menú
	REQUESTS_PER_SECOND = 8, -- límite de solicitudes cliente → servidor
	MAX_SELL_AMOUNT = 999,

	-- Desarrollo
	RUN_TESTS_IN_STUDIO = true, -- ejecuta las pruebas al pulsar Play en Studio

	-- Nombres de los remotos (servidor y cliente deben coincidir)
	REMOTES = {
		State = "State", -- RemoteEvent servidor → cliente: estado completo del jugador
		Notify = "Notify", -- RemoteEvent servidor → cliente: mensaje corto
		OpenPanel = "OpenPanel", -- RemoteEvent servidor → cliente: abrir un menú de estación
		Action = "Action", -- RemoteFunction cliente → servidor: pedir una acción
		Sound = "Sound", -- RemoteEvent servidor → cliente: reproducir un efecto (DEV-014)
	},

	-- Arte (DEV-014): IDs de Roblox de los sonidos (art/audio/export/sfx_*.ogg) y de los
	-- iconos (art/texturas/export/ico_*.png) tras subirlos con el Asset Manager.
	-- 0 = todavía no subido: no suena o no se muestra (el juego funciona igual).
	SOUND_IDS = {
		robar = 0,
		alarma_dueno = 0,
		atrapado = 0,
		guardar_botin = 0,
		comprar = 0,
		abrir_capsula = 0,
		ruleta = 0,
		subir_nivel = 0,
		entrenar = 0,
		boton = 0,
	},
	ICON_IDS = {
		monedas = 0,
		velocidad = 0,
		mochila = 0,
		premios = 0,
		ruleta = 0,
		robux = 0,
		ajustes = 0,
		carga = 0,
	},
}

return Config
