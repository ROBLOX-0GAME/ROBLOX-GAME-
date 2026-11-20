--[[
	PlotService — plot personal de cada jugador (DEV-008).

	Hay Config.PLOT_COUNT plots en la base, 5 a cada lado. Al cargar sus datos,
	cada jugador recibe el primer plot libre; al salir se libera.

	Distribución de un plot (de fuera hacia el centro de la base):
	  - Taller (mesa de elaboración) al fondo: fabricar relojes.
	  - Vitrinas en el centro: los relojes exhibidos dan ingreso pasivo y un
	    poco de suerte (funciona como el antiguo Museo). Se gestionan desde el
	    panel del plot, que también vende las mejoras de vitrinas y caminadora.
	  - Caminadora enfrente: entrenar velocidad (TrainingService).

	Solo el dueño puede usar su plot (se valida en el servidor). Las piezas son
	marcadores funcionales; el arte final se hará aparte. Etiquetas: "Station"
	con StationId (workshop / plot) y OwnerUserId; "PlotTreadmill".
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)

local PlotService = {}

local plots = {} -- lista de plots
local plotByPlayer = {} -- [Player] = plot
local treadmillHandler = nil -- función(player) que pone TrainingService

local PLOT_WIDTH = 30 -- eje X
local PLOT_DEPTH = 24 -- eje Z
local PLOT_CENTER_X = 88
local PLOT_Z = { 6, -22, -50, -78, -106 }
local FREE_COLOR = Color3.fromRGB(150, 150, 150)

local function makePrompt(parent, actionText, objectText)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function setSign(plot, title, subtitle)
	local billboard = plot.sign:FindFirstChild("Cartel")
	if billboard then
		billboard:Destroy()
	end
	WorldService.makeSign(plot.sign, title, subtitle, 2, 160)
end

-- Solo el dueño puede usar las partes de su plot.
local function ownerOnly(plot, player)
	if plot.owner == player then
		return true
	end
	if plot.owner then
		Net.notify(player, "Este plot es de " .. plot.owner.DisplayName .. ".", "error")
	else
		Net.notify(player, "Este plot está libre; el tuyo tiene tu nombre en el cartel.", "info")
	end
	return false
end

local function buildPlot(folder, index, side, centerZ)
	local makePart = WorldService.makePart
	local centerX = side * PLOT_CENTER_X
	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	makePart({
		Name = "Suelo",
		Size = Vector3.new(PLOT_WIDTH, 0.4, PLOT_DEPTH),
		Position = Vector3.new(centerX, 0.3, centerZ),
		Color = Color3.fromRGB(120, 110, 100),
		Material = Enum.Material.Concrete,
	}).Parent = model

	-- Taller al fondo (lado exterior)
	local workshop = makePart({
		Name = "Taller",
		Size = Vector3.new(4, 3.5, 12),
		Position = Vector3.new(centerX + side * 12, 2, centerZ),
		Color = Color3.fromRGB(196, 134, 72),
		Material = Enum.Material.WoodPlanks,
	})
	workshop:SetAttribute("StationId", "workshop")
	CollectionService:AddTag(workshop, "Station")
	workshop.Parent = model

	-- Panel del plot en el centro (vitrinas y mejoras)
	local panel = makePart({
		Name = "PanelDelPlot",
		Size = Vector3.new(2, 4, 4),
		Position = Vector3.new(centerX - side * 10, 2.5, centerZ + PLOT_DEPTH / 2 - 3),
		Color = Color3.fromRGB(92, 120, 200),
		Material = Enum.Material.SmoothPlastic,
	})
	panel:SetAttribute("StationId", "plot")
	CollectionService:AddTag(panel, "Station")
	panel.Parent = model

	-- Caminadora enfrente (lado hacia el centro de la base)
	local treadmill = makePart({
		Name = "Caminadora",
		Size = Vector3.new(5, 1, 8),
		Position = Vector3.new(centerX - side * (PLOT_WIDTH / 2 + 4), 0.5, centerZ),
		Color = Color3.fromRGB(60, 60, 70),
		Material = Enum.Material.Metal,
	})
	CollectionService:AddTag(treadmill, "PlotTreadmill")
	treadmill.Parent = model

	-- Cartel con el nombre del dueño
	local sign = makePart({
		Name = "Cartel",
		Size = Vector3.new(1, 1, 1),
		Position = Vector3.new(centerX, 9, centerZ - PLOT_DEPTH / 2 + 1),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	sign.Parent = model

	local displays = Instance.new("Folder")
	displays.Name = "Vitrinas"
	displays.Parent = model

	local plot = {
		index = index,
		side = side,
		center = Vector3.new(centerX, 0, centerZ),
		model = model,
		workshop = workshop,
		panel = panel,
		treadmill = treadmill,
		sign = sign,
		displays = displays,
		owner = nil,
	}

	makePrompt(workshop, "Fabricar relojes", "Taller del plot").Triggered:Connect(function(player)
		if ownerOnly(plot, player) and DataService.get(player) then
			Net.OpenPanel:FireClient(player, "workshop")
		end
	end)
	makePrompt(panel, "Vitrinas y mejoras", "Tu plot").Triggered:Connect(function(player)
		if ownerOnly(plot, player) and DataService.get(player) then
			Net.OpenPanel:FireClient(player, "plot")
		end
	end)
	makePrompt(treadmill, "Entrenar / parar", "Caminadora del plot").Triggered:Connect(function(player)
		if ownerOnly(plot, player) and treadmillHandler then
			treadmillHandler(player)
		end
	end)

	setSign(plot, string.format("Plot %d", index), "Libre")
	model.Parent = folder
	table.insert(plots, plot)
end

-- Dibuja las vitrinas y los relojes exhibidos (marcadores con nombre).
function PlotService.refresh(player)
	local plot = plotByPlayer[player]
	local data = DataService.get(player)
	if not plot or not data then
		return
	end
	plot.displays:ClearAllChildren()
	local watches = {}
	for _, watchId in GameData.WatchOrder do
		for _ = 1, data.museum[watchId] or 0 do
			table.insert(watches, watchId)
		end
	end
	local slots = PlayerLogic.museumSlots(data)
	local columns = 5
	for slot = 1, slots do
		local row = (slot - 1) // columns
		local column = (slot - 1) % columns
		local position = plot.center
			+ Vector3.new(plot.side * (6 - row * 4), 0, -8 + column * 4)
		local pedestal = WorldService.makePart({
			Name = "Vitrina" .. slot,
			Size = Vector3.new(2, 2.5, 2),
			Position = position + Vector3.new(0, 1.65, 0),
			Color = Color3.fromRGB(230, 225, 210),
			Material = Enum.Material.Glass,
			Transparency = 0.2,
		})
		pedestal.Parent = plot.displays
		local watchId = watches[slot]
		if watchId then
			local watch = GameData.Watches[watchId]
			local marker = WorldService.makePart({
				Name = watch.name,
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.4, 1.4, 1.4),
				CFrame = CFrame.new(position + Vector3.new(0, 3.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Color3.fromRGB(255, 210, 90),
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			WorldService.makeSign(marker, watch.name, string.format("+%d monedas", watch.income), 1.5, 50)
			marker.Parent = plot.displays
		end
	end
end

local function assign(player)
	if plotByPlayer[player] then
		return plotByPlayer[player]
	end
	for _, plot in plots do
		if not plot.owner then
			plot.owner = player
			plotByPlayer[player] = plot
			player:SetAttribute("PlotIndex", plot.index)
			plot.workshop:SetAttribute("OwnerUserId", player.UserId)
			plot.panel:SetAttribute("OwnerUserId", player.UserId)
			plot.treadmill:SetAttribute("OwnerUserId", player.UserId)
			setSign(plot, "Plot de " .. player.DisplayName, string.format("Plot %d", plot.index))
			PlotService.refresh(player)
			return plot
		end
	end
	warn("[PlotService] No hay plots libres para", player.Name)
	return nil
end

local function release(player)
	local plot = plotByPlayer[player]
	if not plot then
		return
	end
	plotByPlayer[player] = nil
	plot.owner = nil
	plot.displays:ClearAllChildren()
	for _, part in { plot.workshop, plot.panel, plot.treadmill } do
		part:SetAttribute("OwnerUserId", nil)
	end
	setSign(plot, string.format("Plot %d", plot.index), "Libre")
end

-- Lleva al jugador delante de su plot (al reaparecer).
local function moveToPlot(player)
	local plot = plotByPlayer[player]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if plot and root then
		local front = plot.center + Vector3.new(-plot.side * (PLOT_WIDTH / 2 + 10), 4, 0)
		root.CFrame = CFrame.lookAt(front, plot.center + Vector3.new(0, 4, 0))
	end
end

-- API ------------------------------------------------------------------------

function PlotService.getPlot(player)
	return plotByPlayer[player]
end

-- ¿Está el jugador cerca de una parte de SU plot? kind: "workshop" | "plot" | "treadmill"
function PlotService.isNear(player, kind, maxDistance)
	local plot = plotByPlayer[player]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not plot or not root then
		return false
	end
	local part = plot.panel
	if kind == "workshop" then
		part = plot.workshop
	elseif kind == "treadmill" then
		part = plot.treadmill
	end
	return (root.Position - part.Position).Magnitude <= maxDistance
end

-- TrainingService registra aquí qué hacer al pulsar la caminadora.
function PlotService.onTreadmill(handler)
	treadmillHandler = handler
end

function PlotService.init()
	local folder = Instance.new("Folder")
	folder.Name = "Plots"
	folder.Parent = WorldService.Folder

	local index = 0
	for _, side in { -1, 1 } do
		for _, z in PLOT_Z do
			index += 1
			if index <= Config.PLOT_COUNT then
				buildPlot(folder, index, side, z)
			end
		end
	end

	DataService.onLoaded(function(player)
		if assign(player) then
			Net.notify(player, "Tu plot tiene tu nombre en el cartel: taller al fondo, vitrinas y caminadora.", "info")
			moveToPlot(player)
		else
			Net.notify(player, "No quedan plots libres en este servidor.", "error")
		end
	end)
	local function watchPlayer(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart", 10)
			task.wait(0.1)
			moveToPlot(player)
		end)
	end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	Players.PlayerRemoving:Connect(release)
end

return PlotService
