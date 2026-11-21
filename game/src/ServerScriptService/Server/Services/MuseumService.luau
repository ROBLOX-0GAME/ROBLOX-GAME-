--[[
	MuseumService — ingreso pasivo de los relojes exhibidos.
	Cada Config.MUSEUM_TICK_SECONDS suma a cada jugador el ingreso de su museo.

	DEC-030: ganancia offline. Al entrar (cuando ya se conocen sus pases) se paga
	el tiempo que estuvo fuera, hasta 4 h (8 h con VIP) al 50 % del ingreso.
	Mientras juega, data.lastSeen se actualiza en cada pago.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)

local MuseumService = {}

local granted = {} -- [Player] = true cuando ya se pagó su ganancia offline en esta sesión

-- Paga la ganancia offline una vez por sesión. La llama MonetizationService tras
-- consultar los pases (el tope depende del VIP).
function MuseumService.grantOffline(player)
	if granted[player] then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end
	granted[player] = true
	local now = os.time()
	local coins, seconds = PlayerLogic.offlineEarnings(data, now)
	data.lastSeen = now
	if coins > 0 then
		data.coins += coins
		data.stats.earned += coins
		Net.notify(
			player,
			string.format(
				"Mientras no estabas, tu plot ganó %s monedas (%d h %d min).",
				PlayerLogic.formatBig(coins),
				seconds // 3600,
				(seconds % 3600) // 60
			),
			"ok"
		)
		DataService.replicate(player)
	end
end

function MuseumService.init()
	task.spawn(function()
		while true do
			task.wait(Config.MUSEUM_TICK_SECONDS)
			local now = os.time()
			DataService.forEach(function(player, data)
				if granted[player] then
					data.lastSeen = now -- DEC-030: solo tras pagar la ganancia offline
				end
				if PlayerLogic.collectIncome(data) > 0 then
					DataService.replicate(player)
				end
			end)
		end
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		granted[player] = nil
	end)
end

return MuseumService
