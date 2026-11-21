--[[
	CharacterService — aplica las mejoras de velocidad y salto al personaje.
	El progreso no depende del personaje: morir o reaparecer no pierde nada.

	DEC-025: la velocidad física depende de dónde estés:
	  - en la base: la elegida con la barra del HUD (máximo Config.LOBBY_MAX_WALKSPEED)
	  - dentro de una casa: como máximo Config.HOUSE_WALKSPEED
	  - en las zonas: la de tu velocidad (estadística) según Config.SPEED_CURVE
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local PlayerLogic = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerLogic"))
local DataService = require(script.Parent.DataService)
local WorldService = require(script.Parent.WorldService)

local CharacterService = {}

local HouseService = nil -- se carga al usarlo (evita depender del orden de inicio)

-- Velocidad física que corresponde a la posición del personaje.
local function contextSpeed(data, position)
	if WorldService.isInHub(position) then
		return PlayerLogic.lobbySpeed(data)
	end
	if not HouseService then
		local ok, module = pcall(require, script.Parent.HouseService)
		HouseService = ok and module or false
	end
	if HouseService and HouseService.houseAt and HouseService.houseAt(position) then
		return PlayerLogic.houseSpeed(data)
	end
	return PlayerLogic.walkSpeed(data)
end

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
	local root = character:FindFirstChild("HumanoidRootPart")
	local speed = root and contextSpeed(data, root.Position) or PlayerLogic.lobbySpeed(data)
	if math.abs(humanoid.WalkSpeed - speed) > 0.05 then
		humanoid.WalkSpeed = speed
	end
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
	-- DEC-025: ajusta la velocidad al pasar entre la base, las casas y las zonas.
	task.spawn(function()
		while true do
			task.wait(Config.SPEED_CONTEXT_SECONDS)
			for _, player in Players:GetPlayers() do
				CharacterService.apply(player)
			end
		end
	end)
end

return CharacterService
