--[[
	Intro — cinemática inicial y pieza del legado (DEV-011).

	Solo se ejecuta mientras el servidor diga introDone = false (primera vez):
	  1. Pantalla negra con la historia (GameData.IntroStory), con botón «Saltar».
	  2. La cámara baja desde el cielo hasta el jugador, en la plaza.
	  3. Aparece una pieza muy luminosa en el suelo. Al recogerla, el servidor
	     (acción claimLegacy) entrega la pieza del legado y empieza el tutorial.

	Es funcional y provisional: textos, cámara y efectos los pulirá la Cuenta B
	y la fase de arte, conservando Intro.init / Intro.onState.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameData"))

local player = Players.LocalPlayer

local Intro = {}

local requestAction = nil -- función(acción, id) de la interfaz
local started = false
local piece = nil

local function getControls()
	local ok, controls = pcall(function()
		local module = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
		return require(module):GetControls()
	end)
	if ok then
		return controls
	end
	return nil
end

local function getRoot()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart", 10)
end

local function tween(instance, seconds, goal)
	local animation = TweenService:Create(instance, TweenInfo.new(seconds, Enum.EasingStyle.Sine), goal)
	animation:Play()
	return animation
end

-- Pieza luminosa en el suelo, delante del jugador (solo visible para él).
local function spawnPiece()
	local root = getRoot()
	if not root or piece then
		return
	end
	local ahead = root.Position + root.CFrame.LookVector * 8
	piece = Instance.new("Part")
	piece.Name = "PiezaDelLegado"
	piece.Shape = Enum.PartType.Ball
	piece.Size = Vector3.new(1.4, 1.4, 1.4)
	piece.Anchored = true
	piece.CanCollide = false
	piece.Material = Enum.Material.Neon
	piece.Color = GameData.RarityColors["Herencia"]
	piece.Position = Vector3.new(ahead.X, root.Position.Y - 1.6, ahead.Z)

	local light = Instance.new("PointLight")
	light.Range = 16
	light.Brightness = 3
	light.Color = piece.Color
	light.Parent = piece

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Recoger"
	prompt.ObjectText = "Pieza muy luminosa"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = piece
	prompt.Triggered:Connect(function()
		if requestAction then
			requestAction("claimLegacy", "legacy")
		end
	end)

	piece.Parent = Workspace
	local current = piece
	task.spawn(function()
		local base = current.Position
		local t = 0
		while current.Parent do
			t += 0.03
			current.CFrame = CFrame.new(base + Vector3.new(0, math.sin(t * 2) * 0.3, 0)) * CFrame.Angles(0, t * 1.5, 0)
			task.wait(0.03)
		end
	end)
end

local function playStory()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Introduccion"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	gui.ResetOnSpawn = false

	local black = Instance.new("Frame")
	black.Size = UDim2.fromScale(1, 1)
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BorderSizePixel = 0
	black.Parent = gui

	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0.5)
	text.Position = UDim2.fromScale(0.5, 0.5)
	text.Size = UDim2.fromScale(0.8, 0.3)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 28
	text.TextWrapped = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextTransparency = 1
	text.Text = ""
	text.Parent = gui

	local skipped = false
	local skip = Instance.new("TextButton")
	skip.AnchorPoint = Vector2.new(1, 1)
	skip.Position = UDim2.new(1, -20, 1, -20)
	skip.Size = UDim2.fromOffset(120, 44)
	skip.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	skip.Font = Enum.Font.GothamBold
	skip.TextSize = 18
	skip.TextColor3 = Color3.new(1, 1, 1)
	skip.Text = "Saltar"
	skip.Parent = gui
	skip.Activated:Connect(function()
		skipped = true
	end)

	gui.Parent = player:WaitForChild("PlayerGui")
	local controls = getControls()
	if controls then
		controls:Disable()
	end

	local function waitOrSkip(seconds)
		local elapsed = 0
		while elapsed < seconds and not skipped do
			elapsed += task.wait(0.1)
		end
	end

	for _, line in GameData.IntroStory do
		if skipped then
			break
		end
		text.Text = line
		tween(text, 0.8, { TextTransparency = 0 })
		waitOrSkip(3)
		tween(text, 0.6, { TextTransparency = 1 })
		waitOrSkip(0.7)
	end

	-- La cámara baja desde el cielo hasta el jugador en la plaza.
	local camera = Workspace.CurrentCamera
	local root = getRoot()
	if root then
		local focus = root.Position
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.lookAt(focus + Vector3.new(0, 90, 90), focus)
		text.Text = "…y en el suelo, algo brilla."
		text.TextTransparency = 0
		tween(black, 1.5, { BackgroundTransparency = 1 })
		local duration = 5
		if skipped then
			duration = 1
		end
		tween(camera, duration, { CFrame = CFrame.lookAt(focus + Vector3.new(0, 8, 14), focus) }).Completed:Wait()
		camera.CameraType = Enum.CameraType.Custom
	end

	if controls then
		controls:Enable()
	end
	tween(text, 1, { TextTransparency = 1 }).Completed:Wait()
	gui:Destroy()
end

-- API ------------------------------------------------------------------------

function Intro.init(request)
	requestAction = request
end

-- Llamado con cada estado del servidor.
function Intro.onState(state)
	if state.introDone then
		if piece then
			piece:Destroy()
			piece = nil
		end
		return
	end
	if started then
		return
	end
	started = true
	task.spawn(function()
		playStory()
		spawnPiece()
	end)
end

return Intro
