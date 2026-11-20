--[[
	RewardService — recompensas diarias y por tiempo jugado (DEV-009).

	- Cada Config.PLAYTIME_TICK_SECONDS suma tiempo jugado del día a cada
	  jugador conectado (se reinicia cada día UTC).
	- Al entrar y al cruzar el día avisa si hay recompensa diaria por reclamar.
	- Reclamar es una acción del cliente (ActionService: claimDaily,
	  claimPlaytime), validada aquí con las reglas de PlayerLogic.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)

local RewardService = {}

local announcedDay = {} -- [Player] = día en que ya se avisó de la recompensa diaria

local function announceDaily(player, data)
	local now = os.time()
	local canClaim, streak = PlayerLogic.dailyStatus(data, now)
	local today = PlayerLogic.dayNumber(now)
	if canClaim and announcedDay[player] ~= today then
		announcedDay[player] = today
		Net.notify(
			player,
			string.format(
				"¡Recompensa diaria disponible (día %d): %s! Ábrela en «Premios».",
				streak,
				PlayerLogic.rewardText(GameData.DailyRewards[streak])
			),
			"ok"
		)
	end
end

-- Mensaje cuando un nivel de tiempo jugado acaba de quedar disponible.
local function announcePlaytime(player, before, after)
	for _, tier in GameData.PlaytimeRewards do
		local needed = tier.minutes * 60
		if before < needed and after >= needed then
			Net.notify(
				player,
				string.format("Premio por %d minutos listo: %s. Ábrelo en «Premios».", tier.minutes, PlayerLogic.rewardText(tier.reward)),
				"ok"
			)
		end
	end
end

function RewardService.init()
	DataService.onLoaded(function(player, data)
		announceDaily(player, data)
	end)

	task.spawn(function()
		while true do
			task.wait(Config.PLAYTIME_TICK_SECONDS)
			local now = os.time()
			DataService.forEach(function(player, data)
				local before = 0
				if data.playtime.day == PlayerLogic.dayNumber(now) then
					before = data.playtime.seconds
				end
				local after = PlayerLogic.addPlaytime(data, now, Config.PLAYTIME_TICK_SECONDS)
				announcePlaytime(player, before, after)
				announceDaily(player, data)
				DataService.replicate(player)
			end)
		end
	end)

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		announcedDay[player] = nil
	end)
end

return RewardService
