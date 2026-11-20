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
	BASE_WALKSPEED = 16,
	MAX_WALKSPEED = 60, -- tope de seguridad para la física
	BASE_JUMPHEIGHT = 7.2,
	BASE_MUSEUM_SLOTS = 3,
	MAX_WATCHES_PER_TYPE = 999,

	-- Progresión: subir del nivel n al n+1 cuesta XP_PER_LEVEL_STEP * n
	XP_PER_LEVEL_STEP = 50,
	MAX_LEVEL = 20,

	-- Mundo
	HUB_MAX_Z = 20, -- todo lo que tenga Z menor es la base (zona segura)
	HOUSE_SPOT_RESPAWN_SECONDS = 20, -- una pieza robada reaparece tras este tiempo
	MUSEUM_TICK_SECONDS = 10,

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
	},
}

return Config
