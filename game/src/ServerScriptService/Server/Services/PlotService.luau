--[[
	PlotService — plot personal de cada jugador (DEV-008; media luna en DEV-010).

	Hay Config.PLOT_COUNT plots (6, uno por jugador) colocados en media luna
	alrededor de la plaza de la base (WorldService.PlazaCenter), abierta hacia
	el muro frontal por donde se sale a correr. Al cargar sus datos, cada
	jugador recibe el primer plot libre; al salir se libera.

	Cada plot mira hacia la plaza. De delante hacia atrás:
	  - Caminadora (fuera del plot, hacia la plaza): entrenar velocidad.
	  - Vitrinas (centro): los relojes exhibidos dan ingreso pasivo y un poco
	    de suerte. Se gestionan desde el panel del plot (esquina delantera),
	    que también vende las mejoras de vitrinas y caminadora.
	  - Taller (al fondo): mesa de elaboración para fabricar relojes.

	Solo el dueño puede usar su plot (se valida en el servidor). Las piezas son
	marcadores funcionales; el arte final se hará aparte. Etiquetas: "Station"
	con StationId (workshop / plot) y OwnerUserId; "PlotTreadmill".
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local AssetLibrary = require(Shared.AssetLibrary)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)

local PlotService = {}

local plots = {} -- lista de plots
local plotByPlayer = {} -- [Player] = plot
local treadmillHandler = nil -- función(player) que pone TrainingService

-- Medidas (en coordenadas locales del plot: -Z mira hacia la plaza)
local PLOT_WIDTH = 34 -- eje X local
local PLOT_DEPTH = 40 -- eje Z local
local ARC_RADIUS = 95 -- distancia del centro de la plaza al centro de cada plot
local ARC_FROM = 200 -- ángulos (grados, plano XZ) del primer y último plot
local ARC_TO = 340
local DISPLAY_COLUMNS = { -10, -5, 0, 5, 10 } -- X local de las vitrinas
local DISPLAY_ROWS = { -10, -4, 2 } -- Z local de las filas (de delante hacia atrás)

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
	WorldService.makeSign(plot.sign, title, subtitle, 2, 90) -- ART-015: antes 160
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

-- Pieza colocada en coordenadas locales del plot.
local function plotPart(plot, props, localCFrame)
	props.CFrame = plot.cframe * localCFrame
	return WorldService.makePart(props)
end

local function buildPlot(folder, index, angle)
	local plaza = WorldService.PlazaCenter
	local position = plaza + Vector3.new(math.cos(angle) * ARC_RADIUS, 0, math.sin(angle) * ARC_RADIUS)
	local plot = {
		index = index,
		cframe = CFrame.lookAt(position, Vector3.new(plaza.X, 0, plaza.Z)), -- -Z local mira a la plaza
		owner = nil,
	}

	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	plot.model = model

	local floor = plotPart(plot, {
		Name = "Suelo",
		Size = Vector3.new(PLOT_WIDTH, 0.4, PLOT_DEPTH),
		Color = Color3.fromRGB(120, 110, 100),
		Material = Enum.Material.Concrete,
	}, CFrame.new(0, 0.3, 0))
	floor.Parent = model
	-- Arte (DEV-014): modelos si existen en ReplicatedStorage/Assets
	AssetLibrary.dress(floor, "mdl_plot_suelo")

	-- Taller al fondo
	local workshop = plotPart(plot, {
		Name = "Taller",
		Size = Vector3.new(14, 3.5, 4),
		Color = Color3.fromRGB(196, 134, 72),
		Material = Enum.Material.WoodPlanks,
	}, CFrame.new(0, 2, PLOT_DEPTH / 2 - 4))
	workshop:SetAttribute("StationId", "workshop")
	CollectionService:AddTag(workshop, "Station")
	workshop.Parent = model
	AssetLibrary.dress(workshop, "mdl_taller")

	-- Panel del plot en la esquina delantera (vitrinas y mejoras)
	local panel = plotPart(plot, {
		Name = "PanelDelPlot",
		Size = Vector3.new(4, 4, 2),
		Color = Color3.fromRGB(92, 120, 200),
		Material = Enum.Material.SmoothPlastic,
	}, CFrame.new(PLOT_WIDTH / 2 - 3, 2.5, -PLOT_DEPTH / 2 + 3))
	panel:SetAttribute("StationId", "plot")
	CollectionService:AddTag(panel, "Station")
	panel.Parent = model
	AssetLibrary.dress(panel, "mdl_panel_plot")

	-- Caminadora delante del plot, hacia la plaza
	local treadmill = plotPart(plot, {
		Name = "Caminadora",
		Size = Vector3.new(5, 1, 8),
		Color = Color3.fromRGB(60, 60, 70),
		Material = Enum.Material.Metal,
	}, CFrame.new(0, 0.5, -PLOT_DEPTH / 2 - 7))
	CollectionService:AddTag(treadmill, "PlotTreadmill")
	treadmill.Parent = model
	AssetLibrary.dress(treadmill, "mdl_caminadora")

	-- Cartel con el nombre del dueño, sobre el borde delantero
	local sign = plotPart(plot, {
		Name = "Cartel",
		Size = Vector3.new(1, 1, 1),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	}, CFrame.new(0, 10, -PLOT_DEPTH / 2 + 1))
	sign.Parent = model

	local displays = Instance.new("Folder")
	displays.Name = "Vitrinas"
	displays.Parent = model

	plot.workshop = workshop
	plot.panel = panel
	plot.treadmill = treadmill
	plot.sign = sign
	plot.displays = displays

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
	-- DEC-028: los relojes exhibidos tienen clave con rareza; los más valiosos primero
	local watches = {}
	for key, amount in data.museum do
		for _ = 1, amount do
			table.insert(watches, key)
		end
	end
	table.sort(watches, function(a, b)
		local infoA, infoB = PlayerLogic.watchInfo(a), PlayerLogic.watchInfo(b)
		return (infoA and infoA.sell or 0) > (infoB and infoB.sell or 0)
	end)
	local slots = math.min(PlayerLogic.museumSlots(data), #DISPLAY_COLUMNS * #DISPLAY_ROWS)
	for slot = 1, slots do
		local row = DISPLAY_ROWS[(slot - 1) // #DISPLAY_COLUMNS + 1]
		local column = DISPLAY_COLUMNS[(slot - 1) % #DISPLAY_COLUMNS + 1]
		local pedestal = plotPart(plot, {
			Name = "Vitrina" .. slot,
			Size = Vector3.new(2, 2.5, 2),
			Color = Color3.fromRGB(230, 225, 210),
			Material = Enum.Material.Glass,
			Transparency = 0.2,
		}, CFrame.new(column, 1.65, row))
		pedestal.Parent = plot.displays
		AssetLibrary.dress(pedestal, "mdl_vitrina")
		local key = watches[slot]
		local info = key and PlayerLogic.watchInfo(key)
		if info then
			local watchId = info.id
			local marker = plotPart(plot, {
				Name = info.name,
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(0.4, 1.4, 1.4),
				Color = GameData.RarityColors[info.rarityName] or Color3.fromRGB(255, 210, 90),
				Material = Enum.Material.Neon,
				CanCollide = false,
			}, CFrame.new(column, 3.6, row) * CFrame.Angles(0, math.rad(90), 0))
			WorldService.makeSign(marker, info.name, "+" .. PlayerLogic.formatBig(PlayerLogic.watchIncomePerMinute(key)) .. " monedas/min", 1.5, 30) -- ART-015: antes 50
			-- Presentación (ART-016): el cliente muestra el cartel solo al dueño y pone el aro de rareza
			marker:SetAttribute("OwnerUserId", player.UserId)
			marker:SetAttribute("Rarity", info.rarityName)
			CollectionService:AddTag(marker, "RelojExhibido")
			marker.Parent = plot.displays
			AssetLibrary.dress(marker, AssetLibrary.WATCH_ASSETS[watchId], { facing = plot.cframe.LookVector })
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

-- Lleva al jugador delante de su plot, mirando hacia él.
function PlotService.moveToPlot(player)
	local plot = plotByPlayer[player]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if plot and root then
		local front = (plot.cframe * CFrame.new(0, 4, -PLOT_DEPTH / 2 - 16)).Position
		root.CFrame = CFrame.lookAt(front, plot.cframe.Position + Vector3.new(0, 4, 0))
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

-- Quien aún no terminó la introducción (DEV-011) se queda en la plaza, donde
-- está su pieza del legado; después aparece siempre delante de su plot.
PlotService.shouldMoveToPlot = function(player)
	local data = DataService.get(player)
	return data ~= nil and data.introDone == true
end

function PlotService.init()
	local folder = Instance.new("Folder")
	folder.Name = "Plots"
	folder.Parent = WorldService.Folder

	for index = 1, Config.PLOT_COUNT do
		local t = 0
		if Config.PLOT_COUNT > 1 then
			t = (index - 1) / (Config.PLOT_COUNT - 1)
		end
		buildPlot(folder, index, math.rad(ARC_FROM + (ARC_TO - ARC_FROM) * t))
	end

	DataService.onLoaded(function(player)
		if assign(player) then
			Net.notify(player, "Tu plot tiene tu nombre en el cartel: caminadora delante, vitrinas y taller al fondo.", "info")
			if PlotService.shouldMoveToPlot(player) then
				PlotService.moveToPlot(player)
			end
		else
			Net.notify(player, "No quedan plots libres en este servidor.", "error")
		end
	end)
	local function watchPlayer(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart", 10)
			task.wait(0.1)
			if PlotService.shouldMoveToPlot(player) then
				PlotService.moveToPlot(player)
			end
		end)
	end
	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	Players.PlayerRemoving:Connect(release)
end

return PlotService
