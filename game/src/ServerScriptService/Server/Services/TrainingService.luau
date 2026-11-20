--[[
	TrainingService — caminadoras para entrenar velocidad permanente (DEV-006).

	Pulsa el botón de una caminadora para empezar a entrenar y otra vez para
	parar. Mientras entrenas el personaje no se mueve y cada segundo ganas
	Config.TRAIN_RATE × multiplicador de la caminadora (hasta Config.MAX_TRAINED).
	Alejarse, reaparecer o salir del juego detiene el entrenamiento.

	Las piezas son marcadores funcionales; el modelo final se hará aparte.
	Etiqueta "Treadmill" con atributo TreadmillId.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local CharacterService = require(script.Parent.CharacterService)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)

local TrainingService = {}

local training = {} -- [Player] = { id = treadmillId, part = BasePart }

local POSITIONS = {
	basic = Vector3.new(-80, 0, 5),
	advanced = Vector3.new(-80, 0, -10),
	turbo = Vector3.new(-80, 0, -25),
}

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

local function start(player, treadmillId, part)
	local data = DataService.get(player)
	local root = getRoot(player)
	if not data or not root then
		return
	end
	local ok, reason = PlayerLogic.canUseTreadmill(data, treadmillId)
	if not ok then
		Net.notify(player, reason, "error")
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
	training[player] = { id = treadmillId, part = part }
	player:SetAttribute("Training", treadmillId)
	root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.5, 0))
	CharacterService.apply(player)
	local treadmill = GameData.Treadmills[treadmillId]
	Net.notify(
		player,
		string.format("Entrenando en la %s (×%s). Pulsa otra vez para parar.", treadmill.name, tostring(treadmill.multiplier)),
		"ok"
	)
end

local function buildTreadmill(folder, treadmill)
	local position = POSITIONS[treadmill.id]
	local part = WorldService.makePart({
		Name = treadmill.name,
		Size = Vector3.new(5, 1, 8),
		Position = position + Vector3.new(0, 0.5, 0),
		Color = Color3.fromRGB(60, 60, 70),
		Material = Enum.Material.Metal,
	})
	part:SetAttribute("TreadmillId", treadmill.id)
	CollectionService:AddTag(part, "Treadmill")
	local subtitle = string.format("Entrena velocidad ×%s", tostring(treadmill.multiplier))
	if treadmill.cost > 0 then
		subtitle ..= string.format(" · %d monedas", treadmill.cost)
	elseif treadmill.pass then
		subtitle ..= " · pase de Robux"
	end
	WorldService.makeSign(part, treadmill.name, subtitle, 5, 100)

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Entrenar / parar"
	prompt.ObjectText = treadmill.name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
	prompt.Triggered:Connect(function(player)
		if training[player] then
			TrainingService.stop(player, "Dejaste de entrenar.")
		else
			start(player, treadmill.id, part)
		end
	end)
	part.Parent = folder
end

function TrainingService.init()
	local folder = Instance.new("Model")
	folder.Name = "Caminadoras"
	folder.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	folder.Parent = WorldService.Folder
	for _, treadmillId in GameData.TreadmillOrder do
		buildTreadmill(folder, GameData.Treadmills[treadmillId])
	end

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
			for player, info in training do
				local data = DataService.get(player)
				local root = getRoot(player)
				if not data or not root or (root.Position - info.part.Position).Magnitude > Config.TREADMILL_DISTANCE then
					TrainingService.stop(player, "Dejaste de entrenar.")
				else
					local gained = PlayerLogic.trainTick(data, info.id, Config.TRAIN_TICK_SECONDS)
					if gained > 0 then
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
