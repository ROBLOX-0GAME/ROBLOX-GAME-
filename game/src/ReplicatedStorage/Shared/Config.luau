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
	BASE_BACKPACK = 60, -- DEC-027: piezas que caben (guardadas + botín); fija, solo crece con el pase
	BASE_CARRY = 1, -- objetos robados que puedes llevar por viaje (DEV-013; hasta 4 con 3 mejoras)
	BASE_WALKSPEED = 16,
	-- Velocidad (DEC-024): la «Velocidad» es una estadística (75, 1M, 99,9T…). La
	-- velocidad física sale de SPEED_CURVE y nunca pasa de MAX_WALKSPEED.
	START_SPEED = 75, -- velocidad (estadística) con la que empieza todo jugador
	MAX_WALKSPEED = 150, -- tope físico en las zonas (más rápido falla la física)
	LOBBY_MAX_WALKSPEED = 50, -- tope en la base; el jugador elige su velocidad con la barra del HUD
	HOUSE_WALKSPEED = 40, -- tope dentro de las casas, para buscar piezas con comodidad
	-- Curva por tramos en escala logarítmica: { estadística, velocidad física }
	SPEED_CURVE = { { 75, 30 }, { 1e6, 85 }, { 9.99e13, 150 } },
	SPEED_CONTEXT_SECONDS = 0.25, -- cada cuánto se ajusta la velocidad según dónde estás
	BASE_JUMPHEIGHT = 7.2,
	BASE_MUSEUM_SLOTS = 4, -- DEC-027: vitrinas iniciales del plot (hasta 12 con 8 mejoras)
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
	OWNER_REACTION_SECONDS = 1.2, -- el dueño tarda esto en levantarse tras despertar
	OWNER_WAKE_SECONDS = 15, -- DEC-024: el dueño duerme; despierta si pasas esto dentro de su casa
	OWNER_HOUSE_SPEED = 12, -- velocidad del dueño dentro de su casa (lento)
	OWNER_SPEED_FACTOR = 0.92, -- fuera de casa corre como la velocidad que exige su zona × esto
	CHASE_MAX_SECONDS = 40, -- el dueño se rinde después de este tiempo
	CHASE_LOSE_DISTANCE = 160, -- el dueño se rinde si te alejas tanto
	CATCH_DISTANCE = 4.5, -- distancia a la que el dueño te atrapa

	-- VIP y ganancia offline (DEC-030)
	VIP_PLAYTIME_FACTOR = 0.7, -- el VIP cumple los premios por tiempo en un 30 % menos de tiempo
	OFFLINE_MAX_SECONDS = 4 * 3600, -- ganancia offline del plot sin VIP: hasta 4 h
	OFFLINE_MAX_SECONDS_VIP = 8 * 3600, -- con VIP: hasta 8 h
	OFFLINE_RATE = 0.5, -- se paga el 50 % del ingreso del plot
	OFFLINE_MIN_SECONDS = 60, -- menos de esto fuera no cuenta

	-- Reinicio de la zona de carreras (DEC-029)
	RACE_RESET_SECONDS = 300, -- cada cuánto se cierra la zona y se renuevan las piezas
	RACE_WARNING_SECONDS = 30, -- cuenta atrás antes del cierre
	RACE_CLOSED_SECONDS = 10, -- tiempo cerrada antes de volver a abrir
	ANNOUNCE_MIN_RARITY = 6, -- aviso a todo el servidor desde esta rareza (6 = Mítico)
	ANNOUNCE_SECONDS = 6, -- tiempo que se ve el aviso arriba

	-- Zonas (DEC-024): cada una es un 35 % más larga que la anterior
	ZONE_BASE_DEPTH = 130, -- largo de la zona 1
	ZONE_DEPTH_GROWTH = 1.35,
	ZONE_GAP = 10, -- espacio entre zonas (ahí va la puerta de velocidad)

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
	-- DEC-027: las mascotas equipadas también dan monedas y suerte
	PET_COIN_SHARE = 0.25, -- +monedas = ¼ de la suma de sus bonus de velocidad
	PET_LUCK_SHARE = 0.1, -- +probabilidad de robar 2 piezas = 1/10 de esa suma (propuesta de Claude)

	-- Plot personal (DEV-008)
	PLOT_COUNT = 6, -- uno por jugador: servidores de 6 (DEV-010; Max Players se fija en Game Settings)
	MAX_PLOT_LUCK = 0.15, -- tope de suerte que dan los relojes exhibidos
	MAX_EXTRA_PART_CHANCE = 0.6, -- tope total de probabilidad de robar 2 piezas

	-- Entrenamiento de velocidad en caminadoras (DEV-006)
	TRAIN_RATE = 0.5, -- velocidad ganada por segundo con multiplicador ×1 (DEC-024)
	MAX_TRAINED = 1e15, -- tope de seguridad (el mundo nuevo empezará en 100T)
	TRAIN_TICK_SECONDS = 1,
	TREADMILL_DISTANCE = 8, -- si te alejas más, dejas de entrenar

	-- Pases y productos con Robux (DEV-006). 0 = todavía no creado en Roblox
	-- (se muestra «Próximamente»). Los IDs reales se copian del Creator Hub
	-- al publicar la experiencia.
	GAMEPASS_IDS = {
		supremePet = 2092457041,
		turboTreadmill = 2092301001,
		runner = 2092654993,
		vip = 2092324975,
		bigBackpack = 2094136992,
		petSlot = 2093488974,
		moneyX2 = 2096725041, -- DEC-030: Dinero ×2
		-- Multiplicadores de ganancia de velocidad al entrenar (DEC-023)
		speedX2 = 2096772933,
		speedX4 = 2092372988,
		speedX8 = 2093243114,
		speedX16 = 2093285040,
		speedX32 = 2094532948,
		speedX64 = 2093458984,
		speedX128 = 2092535040,
		speedX256 = 2096658962,
		speedX512 = 2096658963,
	},
	PRODUCT_IDS = {
		coinsSmall = 3734054833,
		coinsMedium = 3734054876,
		coinsLarge = 3734054880,
		instantTraining = 3734054885,
		goldEgg = 3734054893,
		cosmicCapsule = 3734054900,
		extraSpin = 3734054905,
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
		Announce = "Announce", -- RemoteEvent servidor → todos: aviso arriba de pieza muy rara (DEC-029)
	},

	-- Arte (DEV-014): IDs de Roblox de los sonidos (art/audio/export/sfx_*.ogg) y de los
	-- iconos (art/texturas/export/ico_*.png) tras subirlos con el Asset Manager.
	-- 0 = todavía no subido: no suena o no se muestra (el juego funciona igual).
	SOUND_IDS = {
		robar = 136358381895007,
		alarma_dueno = 101439249349776,
		atrapado = 121771660127526,
		guardar_botin = 102296286128091,
		comprar = 127864647773254,
		abrir_capsula = 119271899636402,
		ruleta = 137255558095184,
		subir_nivel = 85030530372481,
		entrenar = 99286256408690,
		boton = 83644407334698,
	},
	ICON_IDS = {
		monedas = 110143721253053,
		velocidad = 85592491428255,
		mochila = 72587806417673,
		premios = 107634380113502,
		ruleta = 135014274216635,
		robux = 130773426233365,
		ajustes = 115724324517779,
		carga = 84558382393109,
	},
	-- Iconos de los carteles de estación (ART-015, propuesta DEC-025). 0 = cartel sin icono.
	STATION_ICON_IDS = {
		shop = 126558654621046, -- ico_est_tienda
		robux = 130773426233365, -- ico_robux
		pets = 98778607906214, -- ico_est_criadero
		boss = 105138495197610, -- ico_est_cronometro
		carry = 84558382393109, -- ico_carga
		workshop = 137123513210346, -- ico_est_taller
		museum = 90393594479879, -- ico_est_museo
	},
}

return Config
