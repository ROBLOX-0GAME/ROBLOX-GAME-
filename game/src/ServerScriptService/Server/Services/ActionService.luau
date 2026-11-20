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
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)
local CharacterService = require(script.Parent.CharacterService)
local BossService = require(script.Parent.BossService)
local PetService = require(script.Parent.PetService)
local MonetizationService = require(script.Parent.MonetizationService)
local PlotService = require(script.Parent.PlotService)

local random = Random.new()

local ActionService = {}

-- acción → estación requerida y función que la ejecuta
local ACTIONS = {
	-- station: estación compartida · plotPart: parte del plot PROPIO (DEV-008)
	craft = {
		plotPart = "workshop",
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
			if not table.find(GameData.UpgradeOrder, id) then
				return false, "Esa mejora se compra en tu plot."
			end
			return PlayerLogic.buyUpgrade(data, id)
		end,
	},
	hatchEgg = {
		station = "pets",
		affectsCharacter = true,
		run = function(data, id)
			local ok, message = PlayerLogic.hatchEgg(data, id, random:NextNumber())
			return ok, message
		end,
	},
	-- Manejo de mascotas: desde la Mochila, en cualquier lugar.
	equipPet = {
		affectsCharacter = true,
		run = function(data, id)
			return PlayerLogic.equipPet(data, id)
		end,
	},
	unequipPet = {
		affectsCharacter = true,
		run = function(data, id)
			return PlayerLogic.unequipPet(data, id)
		end,
	},
	equipBest = {
		affectsCharacter = true,
		run = function(data)
			return PlayerLogic.equipBest(data)
		end,
	},
	releasePet = {
		run = function(data, id)
			return PlayerLogic.releasePet(data, id)
		end,
	},
	-- Mejoras del plot (vitrinas y caminadora), solo en el plot propio (DEV-008)
	buyPlotUpgrade = {
		plotPart = "plot",
		refreshPlot = true,
		run = function(data, id)
			if not table.find(GameData.PlotUpgradeOrder, id) then
				return false, "Esa mejora no es del plot."
			end
			return PlayerLogic.buyUpgrade(data, id)
		end,
	},
	-- Robux (DEV-006)
	buyPass = {
		run = function(data, id, _, player)
			return MonetizationService.promptPass(player, data, id)
		end,
	},
	buyProduct = {
		run = function(_, id, _, player)
			return MonetizationService.promptProduct(player, id)
		end,
	},
	contribute = {
		station = "boss",
		run = function(data, id, amount, player)
			return BossService.contribute(player, data, id, amount)
		end,
	},
	display = {
		plotPart = "plot",
		refreshPlot = true,
		run = function(data, id)
			return PlayerLogic.display(data, id)
		end,
	},
	withdraw = {
		plotPart = "plot",
		refreshPlot = true,
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
	if action.plotPart and not PlotService.isNear(player, action.plotPart, Config.STATION_DISTANCE) then
		return reply(false, "Acércate a tu plot para hacer eso.")
	end

	local ok, message = action.run(data, id, amount or 1, player)
	if ok then
		DataService.replicate(player)
		if actionName == "buyUpgrade" or action.affectsCharacter then
			CharacterService.apply(player)
		end
		if action.affectsCharacter then
			PetService.refresh(player)
		end
		if action.refreshPlot then
			PlotService.refresh(player)
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
