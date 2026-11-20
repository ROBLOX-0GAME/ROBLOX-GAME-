--[[
	Config — valores técnicos y de balance de BUILD A WATCH!

	IMPORTANTE: todas las cifras de balance (monedas, capacidades, tiempos)
	son PROPUESTAS de la tarea DEV-001 y están pendientes de aprobación del
	equipo. Cambiar un número aquí cambia el juego sin tocar otro código.
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
	BASE_BACKPACK = 20, -- piezas que caben en la mochila
	BASE_WALKSPEED = 16,
	BASE_JUMPHEIGHT = 7.2,
	BASE_MUSEUM_SLOTS = 3,
	MAX_WATCHES_PER_TYPE = 999,

	-- Progresión: subir del nivel n al n+1 cuesta XP_PER_LEVEL_STEP * n
	XP_PER_LEVEL_STEP = 50,
	MAX_LEVEL = 20,

	-- Mundo
	PART_SPAWN_COUNT = 30,
	PART_RESPAWN_SECONDS = 8,
	MUSEUM_TICK_SECONDS = 10,

	-- Seguridad
	INTERACT_DISTANCE = 14, -- distancia máxima para recoger una caja
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
