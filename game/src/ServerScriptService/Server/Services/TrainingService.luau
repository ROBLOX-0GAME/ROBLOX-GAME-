--[[
	TrainingService — entrenamiento de velocidad en la caminadora del plot
	(DEV-006, rehecho en DEV-008).

	Cada jugador entrena en la caminadora de SU plot. Pulsa para empezar y otra
	vez para parar; mientras entrena no se mueve. Cada segundo gana
	Config.TRAIN_RATE × multiplicador de su caminadora (mejora «treadmill» y
	pase Caminadora Turbo), hasta Config.MAX_TRAINED. Alejarse, reaparecer o
	salir del juego detiene el entrenamiento.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local CharacterService = require(script.Parent.CharacterService)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local PlotService = require(script.Parent.PlotService)

local TrainingService = {}

local training = {} -- [Player] = true

local function getRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function TrainingService.stop(player, message)
	if not training[player] then
		return
	end
	training[player] = nil
	player:SetAttribute("Training", nil)
	CharacterService.apply(player)
	if message then
		Net.notify(player, message, "info")
	end
end

local function start(player)
	local data = DataService.get(player)
	local root = getRoot(player)
	local plot = PlotService.getPlot(player)
	if not data or not root or not plot then
		return
	end
	if data.trained >= Config.MAX_TRAINED then
		Net.notify(player, "Ya entrenaste la velocidad máxima.", "info")
		return
	end
	if PlayerLogic.carriedCount(data) > 0 then
		Net.notify(player, "Guarda tu botín antes de entrenar.", "error")
		return
	end
	training[player] = true
	player:SetAttribute("Training", true)
	root.CFrame = CFrame.new(plot.treadmill.Position + Vector3.new(0, 3.5, 0))
	CharacterService.apply(player)
	Net.notify(
		player,
		string.format(
			"Entrenando: +%s de velocidad por segundo. Pulsa la caminadora otra vez para parar.",
			PlayerLogic.formatBig(Config.TRAIN_RATE * PlayerLogic.treadmillMultiplier(data))
		),
		"ok"
	)
end

function TrainingService.init()
	PlotService.onTreadmill(function(player)
		if training[player] then
			TrainingService.stop(player, "Dejaste de entrenar.")
		else
			start(player)
		end
	end)

	local function watchPlayer(player)
		player.CharacterAdded:Connect(function()
			TrainingService.stop(player)
		end)
	end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		training[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(Config.TRAIN_TICK_SECONDS)
			for player in training do
				local data = DataService.get(player)
				if not data or not PlotService.isNear(player, "treadmill", Config.TREADMILL_DISTANCE) then
					TrainingService.stop(player, "Dejaste de entrenar.")
				else
					if PlayerLogic.trainTick(data, Config.TRAIN_TICK_SECONDS) > 0 then
						DataService.replicate(player)
					end
					if data.trained >= Config.MAX_TRAINED then
						TrainingService.stop(player, "¡Velocidad de entrenamiento al máximo!")
					end
				end
			end
		end
	end)
end

return TrainingService
