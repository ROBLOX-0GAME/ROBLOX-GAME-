--[[
	ActionService — única puerta de entrada de las acciones del cliente.

	El cliente llama Remotes.Action:InvokeServer(acción, id, cantidad) y recibe
	{ ok = boolean, message = string }. El servidor nunca confía en el cliente:
	valida tipos, límite de solicitudes, distancia a la estación y reglas del
	juego (PlayerLogic) antes de cambiar datos.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)
local CharacterService = require(script.Parent.CharacterService)

local ActionService = {}

-- acción → estación requerida y función que la ejecuta
local ACTIONS = {
	craft = {
		station = "workshop",
		run = function(data, id)
			local ok, message = PlayerLogic.craft(data, id)
			return ok, message
		end,
	},
	sell = {
		station = "shop",
		run = function(data, id, amount)
			return PlayerLogic.sell(data, id, amount)
		end,
	},
	sellPart = {
		station = "shop",
		run = function(data, id, amount)
			return PlayerLogic.sellPart(data, id, amount)
		end,
	},
	discardPart = {
		station = nil, -- se puede tirar en cualquier lugar (BUG-001)
		run = function(data, id, amount)
			return PlayerLogic.discardPart(data, id, amount)
		end,
	},
	buyUpgrade = {
		station = "shop",
		run = function(data, id)
			return PlayerLogic.buyUpgrade(data, id)
		end,
	},
	display = {
		station = "museum",
		run = function(data, id)
			return PlayerLogic.display(data, id)
		end,
	},
	withdraw = {
		station = "museum",
		run = function(data, id)
			return PlayerLogic.withdraw(data, id)
		end,
	},
}

-- Límite de solicitudes por jugador (ventana de 1 segundo)
local requestLog = {} -- [Player] = { windowStart, count }

local function allowRequest(player)
	local now = os.clock()
	local entry = requestLog[player]
	if not entry or now - entry.windowStart >= 1 then
		requestLog[player] = { windowStart = now, count = 1 }
		return true
	end
	entry.count += 1
	return entry.count <= Config.REQUESTS_PER_SECOND
end

local function reply(ok, message)
	return { ok = ok, message = message }
end

local function handle(player, actionName, id, amount)
	if not allowRequest(player) then
		return reply(false, "Vas demasiado rápido. Espera un momento.")
	end
	if type(actionName) ~= "string" or type(id) ~= "string" or #id > 32 then
		return reply(false, "Solicitud no válida.")
	end
	local action = ACTIONS[actionName]
	if not action then
		return reply(false, "Acción desconocida.")
	end
	if amount ~= nil and type(amount) ~= "number" then
		return reply(false, "Cantidad no válida.")
	end
	local data = DataService.get(player)
	if not data then
		return reply(false, "Tus datos aún se están cargando…")
	end
	if action.station and not WorldService.isNearStation(player, action.station, Config.STATION_DISTANCE) then
		return reply(false, "Acércate a la estación para hacer eso.")
	end

	local ok, message = action.run(data, id, amount or 1)
	if ok then
		DataService.replicate(player)
		if actionName == "buyUpgrade" then
			CharacterService.apply(player)
		end
	end
	return reply(ok, message)
end

function ActionService.init()
	Net.Action.OnServerInvoke = function(player, actionName, id, amount)
		local success, result = pcall(handle, player, actionName, id, amount)
		if success then
			return result
		end
		warn("[ActionService] Error procesando", actionName, "de", player.Name, ":", result)
		return reply(false, "Ocurrió un error. Inténtalo de nuevo.")
	end
	Players.PlayerRemoving:Connect(function(player)
		requestLog[player] = nil
	end)
end

return ActionService
