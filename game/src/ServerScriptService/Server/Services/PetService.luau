--[[
	PetService — Criadero de huevos y mascotas que acompañan al jugador (DEV-005).

	Las mascotas equipadas multiplican la velocidad (PlayerLogic.walkSpeed).
	Aquí solo se crea la estación y la parte visual: esferas con nombre que
	flotan alrededor del personaje. Son provisionales; la Cuenta B puede
	reemplazarlas por modelos conservando PetService.refresh.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameData = require(Shared.GameData)
local AssetLibrary = require(Shared.AssetLibrary)
local DataService = require(script.Parent.DataService)
local WorldService = require(script.Parent.WorldService)

local PetService = {}

-- Posición de cada mascota respecto al personaje (hasta 3 equipadas)
local OFFSETS = {
	Vector3.new(-3, 1.5, 2.5),
	Vector3.new(3, 1.5, 2.5),
	Vector3.new(0, 2.5, 3.5),
}

local function makeFollower(root, petId, offset)
	local pet = GameData.Pets[petId]
	local ball = Instance.new("Part")
	ball.Name = pet.name
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(1.6, 1.6, 1.6)
	ball.Color = GameData.RarityColors[pet.rarity]
	ball.Material = Enum.Material.Neon
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.Massless = true
	ball.CFrame = root.CFrame * CFrame.new(offset)

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(120, 24)
	billboard.StudsOffset = Vector3.new(0, 1.4, 0)
	billboard.MaxDistance = 30 -- ART-015: antes 60 (menos rótulos a la vez)
	billboard.Parent = ball
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.4
	text.Text = string.format("%s +%d%%", pet.name, math.floor(pet.bonus * 100 + 0.5))
	text.Parent = billboard

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = ball
	weld.Parent = ball
	-- Arte (DEV-014): el modelo de la mascota sigue a la esfera soldado
	AssetLibrary.dress(ball, AssetLibrary.PET_ASSETS[petId], { weld = true })
	return ball
end

-- Vuelve a dibujar las mascotas equipadas del jugador.
function PetService.refresh(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local data = DataService.get(player)
	if not root or not data then
		return
	end
	local old = character:FindFirstChild("Mascotas")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Mascotas"
	local index = 0
	for _, petId in GameData.PetOrder do
		for _ = 1, data.equipped[petId] or 0 do
			index += 1
			if OFFSETS[index] then
				makeFollower(root, petId, OFFSETS[index]).Parent = folder
			end
		end
	end
	folder.Parent = character
end

local function watchPlayer(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)
		PetService.refresh(player)
	end)
end

function PetService.init()
	WorldService.buildStation({
		id = "pets",
		title = "Criadero",
		action = "Cápsulas y mascotas",
		position = WorldService.WallSlots.pets, -- pegado al muro frontal (DEV-010)
		color = Color3.fromRGB(220, 150, 60),
	})
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	DataService.onLoaded(function(player)
		PetService.refresh(player)
	end)
end

return PetService
