--[[
	DataService — carga, guarda y replica los datos de cada jugador.

	- Formato guardado: { data = <tabla de PlayerLogic>, lock = { job, time } | nil }
	- Bloqueo de sesión: evita que dos servidores escriban los mismos datos a la vez
	  (por ejemplo, al cambiar rápido de servidor). Un bloqueo caduca tras
	  Config.SESSION_LOCK_SECONDS.
	- Si los datos no cargan en un servidor real, se expulsa al jugador para no
	  sobrescribir su progreso con datos vacíos.
	- En Studio sin acceso a API (Game Settings → Security → Enable Studio Access
	  to API Services) se juega con datos temporales que NO se guardan.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local Net = require(script.Parent.Net)

local DataService = {}

local store = nil
local profiles = {} -- [Player] = { data = tabla, canSave = boolean }
local loadedCallbacks = {}

local function keyFor(player)
	return "player_" .. player.UserId
end

local function isLockedByOther(stored, now)
	return type(stored) == "table"
		and type(stored.lock) == "table"
		and stored.lock.job ~= game.JobId
		and now - (tonumber(stored.lock.time) or 0) < Config.SESSION_LOCK_SECONDS
end

-- Devuelve "ok", datos | "locked" | "error", mensaje
local function tryLoad(player)
	local now = os.time()
	local loaded = nil
	local locked = false
	local success, err = pcall(function()
		store:UpdateAsync(keyFor(player), function(stored)
			locked = false
			loaded = nil
			if isLockedByOther(stored, now) then
				locked = true
				return nil -- no escribir
			end
			local raw = nil
			if type(stored) == "table" then
				raw = stored.data
			end
			loaded = PlayerLogic.reconcile(raw)
			return { data = loaded, lock = { job = game.JobId, time = now } }
		end)
	end)
	if not success then
		return "error", tostring(err)
	end
	if locked then
		return "locked"
	end
	return "ok", loaded
end

local function writeProfile(player, profile, release)
	if not store or not profile.canSave then
		return true
	end
	for attempt = 1, Config.SAVE_ATTEMPTS do
		local lostLock = false
		local success, err = pcall(function()
			store:UpdateAsync(keyFor(player), function(stored)
				lostLock = false
				if isLockedByOther(stored, os.time()) then
					lostLock = true
					return nil -- otro servidor tomó la sesión: no sobrescribir
				end
				local lock = nil
				if not release then
					lock = { job = game.JobId, time = os.time() }
				end
				return { data = profile.data, lock = lock }
			end)
		end)
		if success then
			if lostLock then
				warn("[DataService] Otro servidor tiene la sesión de", player.Name, "; no se sobrescribe.")
				profile.canSave = false
			end
			return true
		end
		warn(string.format("[DataService] Error al guardar %s (intento %d): %s", player.Name, attempt, tostring(err)))
		if attempt < Config.SAVE_ATTEMPTS then
			task.wait(2)
		end
	end
	return false
end

local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Monedas"
	coins.Parent = leaderstats
	local level = Instance.new("IntValue")
	level.Name = "Nivel"
	level.Value = 1
	level.Parent = leaderstats
	leaderstats.Parent = player
end

local function onPlayerAdded(player)
	local data = nil
	local canSave = false

	if store then
		local status, result
		for attempt = 1, Config.LOAD_ATTEMPTS do
			status, result = tryLoad(player)
			if status == "ok" then
				break
			end
			if not player.Parent then
				return
			end
			warn(string.format("[DataService] Carga de %s: %s (intento %d) %s", player.Name, status, attempt, tostring(result or "")))
			if status == "error" and RunService:IsStudio() then
				break -- en Studio sin acceso a API no tiene sentido reintentar
			end
			task.wait(Config.LOAD_RETRY_SECONDS)
		end

		if status == "ok" then
			data = result
			canSave = true
		elseif RunService:IsStudio() then
			warn("[DataService] Studio sin acceso a DataStore: se usan datos temporales que NO se guardan.")
		else
			if status == "locked" then
				player:Kick("Tus datos siguen abiertos en otro servidor. Vuelve a entrar en un minuto.")
			else
				player:Kick("No pudimos cargar tus datos. Tu progreso está a salvo; inténtalo de nuevo.")
			end
			return
		end
	end

	if data == nil then
		data = PlayerLogic.newData()
	end

	local profile = { data = data, canSave = canSave }

	-- Si el jugador salió mientras cargaba, liberar el bloqueo y terminar.
	if not player.Parent then
		writeProfile(player, profile, true)
		return
	end

	profiles[player] = profile
	setupLeaderstats(player)
	DataService.replicate(player)

	if not canSave then
		Net.notify(player, "Modo de prueba: tu progreso no se guardará.", "error")
	end

	for _, callback in loadedCallbacks do
		task.spawn(callback, player, data)
	end
end

local function onPlayerRemoving(player)
	local profile = profiles[player]
	if not profile then
		return
	end
	writeProfile(player, profile, true)
	profiles[player] = nil
end

-- API ------------------------------------------------------------------------

function DataService.init()
	local success, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DATASTORE_NAME)
	end)
	if success then
		store = result
	else
		warn("[DataService] DataStore no disponible:", result)
	end
end

function DataService.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	-- Autoguardado periódico (también renueva el bloqueo de sesión).
	task.spawn(function()
		while true do
			task.wait(Config.AUTOSAVE_SECONDS)
			for player, profile in profiles do
				task.spawn(writeProfile, player, profile, false)
			end
		end
	end)

	-- Guardar a todos al cerrar el servidor.
	game:BindToClose(function()
		local pending = 0
		for player, profile in profiles do
			pending += 1
			task.spawn(function()
				writeProfile(player, profile, true)
				pending -= 1
			end)
		end
		local started = os.clock()
		while pending > 0 and os.clock() - started < 25 do
			task.wait(0.2)
		end
	end)
end

-- Llama a callback(player, data) cuando los datos de un jugador están listos.
function DataService.onLoaded(callback)
	table.insert(loadedCallbacks, callback)
	for player, profile in profiles do
		task.spawn(callback, player, profile.data)
	end
end

-- Datos del jugador o nil si todavía no cargaron.
function DataService.get(player)
	local profile = profiles[player]
	if profile then
		return profile.data
	end
	return nil
end

function DataService.forEach(callback)
	for player, profile in profiles do
		callback(player, profile.data)
	end
end

-- Se llama después de cada cambio de datos: completa objetivos del tutorial
-- cumplidos, envía el estado al cliente y actualiza la tabla de clasificación.
function DataService.replicate(player)
	local data = DataService.get(player)
	if not data then
		return
	end
	for _, message in PlayerLogic.advanceTutorial(data) do
		Net.notify(player, message, "ok")
	end
	local view = PlayerLogic.buildView(data)
	Net.State:FireClient(player, view)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Monedas.Value = view.coins
		leaderstats.Nivel.Value = view.level
	end
end

return DataService
