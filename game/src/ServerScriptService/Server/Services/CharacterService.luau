--[[
	CharacterService — aplica las mejoras de velocidad y salto al personaje.
	El progreso no depende del personaje: morir o reaparecer no pierde nada.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerLogic = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerLogic"))
local DataService = require(script.Parent.DataService)

local CharacterService = {}

function CharacterService.apply(player)
	local data = DataService.get(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not data or not humanoid then
		return
	end
	humanoid.UseJumpPower = false
	-- Mientras entrena en una caminadora (TrainingService) se queda quieto.
	if player:GetAttribute("Training") then
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		return
	end
	humanoid.WalkSpeed = PlayerLogic.walkSpeed(data)
	humanoid.JumpHeight = PlayerLogic.jumpHeight(data)
end

local function watchPlayer(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid", 10)
		CharacterService.apply(player)
	end)
end

function CharacterService.init()
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	-- El personaje puede aparecer antes de que terminen de cargar los datos.
	DataService.onLoaded(function(player)
		CharacterService.apply(player)
	end)
end

return CharacterService
