--[[
	Ui — HUD, notificaciones y menús de las estaciones.

	Controles (teclado, mando y táctil):
	  - Estaciones y cajas: ProximityPrompt (E / botón X del mando / tocar).
	  - Mochila: tecla B, botón Y del mando o el botón "Mochila" en pantalla.
	  - Cerrar menú: botón X del menú, botón B del mando o alejarse de la estación.
	  - Con mando, al abrir un menú se selecciona el primer botón automáticamente.

	La interfaz es provisional y funcional; la Cuenta B puede rediseñarla
	manteniendo las llamadas a Ui.setState / Ui.openPanel / Ui.toast.
]]

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic) -- solo funciones de lectura (textos)

local player = Players.LocalPlayer

local Ui = {}

-- Paleta «taller de relojería fantástico» (ART-015, propuesta DEC-024): carbón, marfil,
-- latón y oro, con cian para el foco. Mismos colores que tex_paleta.
local COLORS = {
	panel = Color3.fromRGB(30, 31, 38), -- carbón
	row = Color3.fromRGB(48, 50, 60),
	text = Color3.fromRGB(242, 240, 234), -- marfil
	muted = Color3.fromRGB(176, 172, 160),
	accent = Color3.fromRGB(242, 193, 78), -- oro
	brass = Color3.fromRGB(194, 123, 58), -- latón (bordes)
	focus = Color3.fromRGB(91, 213, 224), -- cian (selección con mando)
	ok = Color3.fromRGB(76, 175, 106),
	error = Color3.fromRGB(214, 84, 84),
	info = Color3.fromRGB(44, 79, 128),
	button = Color3.fromRGB(44, 79, 128), -- azul oscuro: contraste alto con el marfil
	buttonOff = Color3.fromRGB(80, 82, 92),
}

local PANEL_TITLES = {
	workshop = "Taller de tu plot — Fabricar relojes",
	shop = "Tienda — Vender y mejorar",
	plot = "Tu plot — Vitrinas y mejoras",
	backpack = "Mochila",
	boss = "Cronómetro Maestro — Reparación",
	pets = "Criadero — Cápsulas y mascotas",
	rewards = "Premios — Diario y por tiempo",
	spin = "Ruleta diaria",
	settings = "Ajustes",
	carry = "Puesto de Carga — Capacidad por viaje",
	robux = "Tienda Robux — Pases y productos",
	speed = "Velocidad", -- DEC-025: barra para elegir la velocidad en la base
}

local HUD_PANELS = { backpack = true, robux = true, rewards = true, spin = true, settings = true, speed = true }
local sliderDragging = false -- mientras se arrastra la barra de velocidad no se redibuja el menú
local state = nil
local bossTimerLabel = nil -- etiqueta del menú del jefe que se actualiza cada medio segundo
local lastBossKey = ""
local actionRemote = nil
local actionHandler = nil -- función (action, result) tras una acción correcta (ART-015)
local busy = false
local openPanelId = nil

local gui, panel, panelTitle, panelList
local hud = {}
local toastList

-- ---------------------------------------------------------------------------
-- Ayudas de construcción
-- ---------------------------------------------------------------------------

local function new(className, props, children)
	local instance = Instance.new(className)
	for key, value in props do
		instance[key] = value
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	return instance
end

local function corner(radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function padding(px)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, px),
		PaddingBottom = UDim.new(0, px),
		PaddingLeft = UDim.new(0, px),
		PaddingRight = UDim.new(0, px),
	})
end

local function label(text, size, color, props)
	local item = new("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextSize = size or 16,
		TextColor3 = color or COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		RichText = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	if props then
		for key, value in props do
			item[key] = value
		end
	end
	return item
end

-- ---------------------------------------------------------------------------
-- Sonidos (DEV-014): solo suenan los que tienen ID en Config.SOUND_IDS
-- ---------------------------------------------------------------------------

local SoundService = game:GetService("SoundService")
local soundCache = {}
local trainingSound = nil

local function getSound(key)
	local id = Config.SOUND_IDS[key]
	if not id or id == 0 then
		return nil
	end
	if not soundCache[key] then
		local sound = Instance.new("Sound")
		sound.Name = "sfx_" .. key
		sound.SoundId = "rbxassetid://" .. id
		sound.Parent = SoundService
		soundCache[key] = sound
	end
	return soundCache[key]
end

function Ui.playSound(key)
	local sound = getSound(key)
	if sound then
		SoundService:PlayLocalSound(sound)
	end
end

-- Icono (DEV-014): ImageLabel si hay ID en Config.ICON_IDS
local function iconImage(key, size)
	local id = Config.ICON_IDS[key]
	if not id or id == 0 then
		return nil
	end
	local image = Instance.new("ImageLabel")
	image.Name = "Icono"
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://" .. id
	image.Size = UDim2.fromOffset(size, size)
	return image
end

local function button(text, enabled, onActivated)
	local item = new("TextButton", {
		Size = UDim2.fromOffset(120, 40),
		BackgroundColor3 = COLORS.buttonOff,
		Font = Enum.Font.GothamBold,
		Text = text,
		TextSize = 15,
		TextColor3 = COLORS.text,
		AutoButtonColor = true,
		Selectable = true,
	}, { corner(8) })
	if enabled then
		item.BackgroundColor3 = COLORS.button
	end
	-- Activated funciona con clic, toque y botón A del mando.
	item.Activated:Connect(function(...)
		Ui.playSound("boton")
		onActivated(...)
	end)
	return item
end

local function formatNumber(value)
	-- DEC-025: las cifras crecen hasta billones; desde un millón se abrevian (1,2M · 99,9T)
	if math.abs(value) >= 1e6 then
		return PlayerLogic.formatBig(value)
	end
	local text = string.format("%d", math.floor(value))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1."):reverse()
	if formatted:sub(1, 1) == "." then
		formatted = formatted:sub(2)
	end
	return formatted
end

-- ---------------------------------------------------------------------------
-- Notificaciones
-- ---------------------------------------------------------------------------

function Ui.toast(text, kind)
	if not toastList or type(text) ~= "string" or text == "" then
		return
	end
	if state and state.settings and state.settings.toasts == 0 and kind ~= "error" then
		return
	end
	local item = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLORS[kind] or COLORS.info,
		BackgroundTransparency = 0.1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextSize = 16,
		TextWrapped = true,
		TextColor3 = COLORS.text,
	}, { corner(8), padding(8) })
	item.Parent = toastList
	task.delay(3, function()
		item:Destroy()
	end)
	local items = {}
	for _, child in toastList:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(items, child)
		end
	end
	if #items > 3 then -- ART-015: como mucho 3 a la vez (antes 4)
		items[1]:Destroy()
	end
end

-- ---------------------------------------------------------------------------
-- Acciones al servidor
-- ---------------------------------------------------------------------------

local function request(action, id, amount)
	if busy or not actionRemote then
		return
	end
	busy = true
	local success, result = pcall(function()
		return actionRemote:InvokeServer(action, id, amount)
	end)
	busy = false
	if not success or type(result) ~= "table" then
		Ui.toast("No se pudo contactar con el servidor.", "error")
		return
	end
	local kind = "error"
	if result.ok then
		kind = "ok"
		if actionHandler then -- efectos visuales (Client/Vfx, ART-015); no cambian el resultado
			task.spawn(actionHandler, action, result)
		end
	end
	Ui.toast(result.message, kind)
	return result
end

-- ---------------------------------------------------------------------------
-- Filas de los menús
-- ---------------------------------------------------------------------------

local rowOrder = 0

local function addRow(text, buttons)
	rowOrder += 1
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLORS.row,
		LayoutOrder = rowOrder,
	}, {
		corner(8),
		padding(10),
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	label(text, 16, COLORS.text, { LayoutOrder = 1 }).Parent = row

	if buttons and #buttons > 0 then
		local bar = new("Frame", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		for index, info in buttons do
			local item = button(info.text, info.enabled ~= false, info.onActivated)
			item.LayoutOrder = index
			item.Parent = bar
		end
		bar.Parent = row
	end
	row.Parent = panelList
	return row
end

local function addHeader(text)
	rowOrder += 1
	local item = label("<b>" .. text .. "</b>", 18, COLORS.accent, { LayoutOrder = rowOrder })
	item.Parent = panelList
	return item
end

-- Parte de una estación por id (etiqueta "Station" que pone el servidor).
-- Las estaciones de los plots (DEV-008) llevan OwnerUserId: solo vale la propia.
local function stationById(stationId)
	for _, part in CollectionService:GetTagged("Station") do
		local owner = part:GetAttribute("OwnerUserId")
		if part:GetAttribute("StationId") == stationId and (owner == nil or owner == player.UserId) then
			return part
		end
	end
	return nil
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds >= 3600 then
		return string.format("%dh %02dm", seconds // 3600, (seconds % 3600) // 60)
	end
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function costText(cost)
	local pieces = {}
	for _, partId in GameData.PartOrder do
		local needed = cost[partId]
		if needed then
			local have = state.parts[partId] or 0
			local color = "#7fd38f"
			if have < needed then
				color = "#e57373"
			end
			table.insert(
				pieces,
				string.format('<font color="%s">%d/%d</font> %s', color, have, needed, GameData.Parts[partId].name)
			)
		end
	end
	return table.concat(pieces, " · ")
end

-- ---------------------------------------------------------------------------
-- Contenido de cada menú
-- ---------------------------------------------------------------------------

local function canCraftLocal(watch)
	if state.level < watch.level then
		return false
	end
	for partId, needed in watch.cost do
		if (state.parts[partId] or 0) < needed then
			return false
		end
	end
	return true
end

local function renderWorkshop()
	addHeader(string.format("Nivel %d · Piezas %d/%d", state.level, state.partCount, state.capacity))
	for _, watchId in GameData.WatchOrder do
		local watch = GameData.Watches[watchId]
		local title = string.format(
			"<b>%s</b>  <font color=\"#aaaab9\">(nivel %d · +%d XP · vende %d)</font>\n%s",
			watch.name,
			watch.level,
			watch.xp,
			watch.sell,
			costText(watch.cost)
		)
		addRow(title, {
			{
				text = "Fabricar",
				enabled = canCraftLocal(watch),
				onActivated = function()
					request("craft", watchId)
				end,
			},
		})
	end
end

local function renderShop()
	addHeader("Vender relojes")
	local any = false
	for _, watchId in GameData.WatchOrder do
		local owned = state.watches[watchId] or 0
		if owned > 0 then
			any = true
			local watch = GameData.Watches[watchId]
			addRow(string.format("<b>%s</b> × %d  ·  %d monedas c/u", watch.name, owned, watch.sell), {
				{
					text = "Vender 1",
					onActivated = function()
						request("sell", watchId, 1)
					end,
				},
				{
					text = "Vender todos",
					onActivated = function()
						request("sell", watchId, math.min(owned, Config.MAX_SELL_AMOUNT))
					end,
				},
			})
		end
	end
	if not any then
		addRow("No tienes relojes para vender. Fabrícalos en el Taller.")
	end

	addHeader("Vender piezas sueltas")
	local anyPart = false
	for _, partId in GameData.PartOrder do
		local owned = state.parts[partId] or 0
		if owned > 0 and not GameData.Parts[partId].protected then
			anyPart = true
			local part = GameData.Parts[partId]
			addRow(string.format("<b>%s</b> × %d  ·  %d monedas c/u", part.name, owned, part.sell), {
				{
					text = "Vender 1",
					onActivated = function()
						request("sellPart", partId, 1)
					end,
				},
				{
					text = "Vender todas",
					onActivated = function()
						request("sellPart", partId, math.min(owned, Config.MAX_SELL_AMOUNT))
					end,
				},
			})
		end
	end
	if not anyPart then
		addRow("No tienes piezas sueltas.")
	end

	addHeader("Mejoras")
	addRow("Las vitrinas y la caminadora se mejoran en el panel de tu plot.")
	for _, upgradeId in GameData.UpgradeOrder do
		local upgrade = GameData.Upgrades[upgradeId]
		local level = state.upgrades[upgradeId] or 0
		local cost = state.upgradeCosts[upgradeId]
		local buttonText = "Máximo"
		local enabled = false
		if cost then
			buttonText = "Comprar " .. formatNumber(cost)
			enabled = state.coins >= cost
		end
		addRow(string.format("<b>%s</b>  (nivel %d/%d)\n%s", upgrade.name, level, upgrade.maxLevel, upgrade.desc), {
			{
				text = buttonText,
				enabled = enabled,
				onActivated = function()
					if cost then
						request("buyUpgrade", upgradeId)
					end
				end,
			},
		})
	end
end

local function renderPlotUpgrades()
	addHeader("Mejoras del plot")
	addRow(
		string.format(
			"Caminadora ×%s (+%s/s) · velocidad entrenada %s · suerte del plot +%.1f%%",
			PlayerLogic.formatBig(state.treadmillMultiplier),
			PlayerLogic.formatBig(state.trainPerSecond),
			PlayerLogic.formatBig(state.trained),
			state.plotLuck * 100
		)
	)
	for _, upgradeId in GameData.PlotUpgradeOrder do
		local upgrade = GameData.Upgrades[upgradeId]
		local level = state.upgrades[upgradeId] or 0
		local cost = state.upgradeCosts[upgradeId]
		local buttonText = "Máximo"
		local enabled = false
		if cost then
			buttonText = "Comprar " .. formatNumber(cost)
			enabled = state.coins >= cost
		end
		addRow(string.format("<b>%s</b>  (nivel %d/%d)\n%s", upgrade.name, level, upgrade.maxLevel, upgrade.desc), {
			{
				text = buttonText,
				enabled = enabled,
				onActivated = function()
					if cost then
						request("buyPlotUpgrade", upgradeId)
					end
				end,
			},
		})
	end
end

local function renderMuseum()
	addHeader(
		string.format(
			"Vitrinas %d/%d · Ingreso pasivo +%.1f monedas/min",
			state.museumCount,
			state.museumSlots,
			state.museumIncomePerMinute
		)
	)
	addRow(
		string.format(
			"Vender da el 100%% del valor al momento. Exhibido, un reloj da el %d%% de su valor cada %d s.",
			math.floor(Config.PLOT_INCOME_PERCENT * 100 + 0.5),
			Config.PLOT_INCOME_PERIOD_SECONDS
		)
	)
	local anyDisplayed = false
	for _, watchId in GameData.WatchOrder do
		local displayed = state.museum[watchId] or 0
		if displayed > 0 then
			anyDisplayed = true
			local watch = GameData.Watches[watchId]
			addRow(string.format("<b>%s</b> × %d exhibido  ·  +%.1f/min c/u", watch.name, displayed, PlayerLogic.watchIncomePerMinute(watchId)), {
				{
					text = "Retirar",
					onActivated = function()
						request("withdraw", watchId)
					end,
				},
			})
		end
	end
	if not anyDisplayed then
		addRow("Todavía no exhibes relojes. Cada reloj exhibido da monedas mientras juegas.")
	end

	addHeader("En tu inventario")
	local anyOwned = false
	local hasSpace = state.museumCount < state.museumSlots
	for _, watchId in GameData.WatchOrder do
		local owned = state.watches[watchId] or 0
		if owned > 0 then
			anyOwned = true
			local watch = GameData.Watches[watchId]
			addRow(string.format("<b>%s</b> × %d  ·  vende %d o exhibe por +%.1f/min", watch.name, owned, watch.sell, PlayerLogic.watchIncomePerMinute(watchId)), {
				{
					text = "Exhibir",
					enabled = hasSpace,
					onActivated = function()
						request("display", watchId)
					end,
				},
			})
		end
	end
	if not anyOwned then
		addRow("No tienes relojes en el inventario.")
	end
end

-- Lista de mascotas con botones para equipar, desequipar y liberar (DEV-005).
local function addPetRows()
	addHeader(
		string.format(
			"Mascotas %d/%d · equipadas %d/%d · velocidad ×%.2f",
			state.petCount,
			Config.MAX_PETS,
			state.equippedCount,
			state.petSlots,
			state.petMultiplier
		)
	)
	if state.petCount == 0 then
		addRow("Todavía no tienes mascotas. Consigue cápsulas en el Criadero, en «Premios» o con Robux.")
		return
	end
	addRow("Equipa las mascotas con más bonus para correr más rápido.", {
		{
			text = "Equipar mejores",
			onActivated = function()
				request("equipBest", "best")
			end,
		},
	})
	for index = #GameData.PetOrder, 1, -1 do
		local petId = GameData.PetOrder[index]
		local owned = state.pets[petId] or 0
		if owned > 0 then
			local pet = GameData.Pets[petId]
			local equipped = state.equipped[petId] or 0
			addRow(
				string.format(
					"<b>%s</b> × %d  <font color=\"#aaaab9\">(%s · +%d%% velocidad · %d equipada(s))</font>",
					pet.name,
					owned,
					pet.rarity,
					math.floor((state.petBonuses[petId] or pet.bonus) * 100 + 0.5),
					equipped
				),
				{
					{
						text = "Equipar",
						enabled = owned > equipped and state.equippedCount < state.petSlots,
						onActivated = function()
							request("equipPet", petId)
						end,
					},
					{
						text = "Quitar",
						enabled = equipped > 0,
						onActivated = function()
							request("unequipPet", petId)
						end,
					},
					{
						text = "Liberar",
						enabled = owned > equipped,
						onActivated = function()
							request("releasePet", petId)
						end,
					},
				}
			)
		end
	end
end

local function renderPets()
	addHeader(string.format("Tus monedas: %s", formatNumber(state.coins)))
	for _, eggId in GameData.EggOrder do
		local egg = GameData.Eggs[eggId]
		local total = 0
		for _, chance in egg.chances do
			total += chance
		end
		local odds = {}
		for _, petId in GameData.PetOrder do
			local chance = egg.chances[petId]
			if chance then
				local pet = GameData.Pets[petId]
				table.insert(
					odds,
					string.format(
						"%s %d%% (+%d%%)",
						pet.name,
						math.floor(chance / total * 100 + 0.5),
						math.floor(pet.bonus * 100 + 0.5)
					)
				)
			end
		end
		local price = "solo Robux"
		local buttons = {}
		if egg.cost then
			price = formatNumber(egg.cost) .. " monedas"
			table.insert(buttons, {
				text = "Comprar y abrir",
				enabled = state.coins >= egg.cost,
				onActivated = function()
					request("hatchEgg", eggId)
				end,
			})
		elseif egg.robuxProduct then
			local available = (Config.PRODUCT_IDS[egg.robuxProduct] or 0) ~= 0
			local robuxText = "Próximamente"
			if available then
				robuxText = "Comprar (Robux)"
			end
			table.insert(buttons, {
				text = robuxText,
				enabled = available,
				onActivated = function()
					request("buyProduct", egg.robuxProduct)
				end,
			})
		end
		local stored = state.capsules[eggId] or 0
		if stored > 0 then
			table.insert(buttons, {
				text = string.format("Abrir guardada (%d)", stored),
				onActivated = function()
					request("openCapsule", eggId)
				end,
			})
		end
		addRow(
			string.format("<b>%s</b> — %s\n%s", egg.name, price, table.concat(odds, " · ")),
			buttons
		)
	end
	addPetRows()
end

-- Premios diarios y por tiempo jugado (DEV-009)
local function renderRewards()
	local daily = state.daily
	addHeader(string.format("Recompensa diaria · racha: día %d de %d", daily.streak, #GameData.DailyRewards))
	local days = {}
	for index, reward in GameData.DailyRewards do
		local mark = ""
		if index == daily.streak then
			mark = "<b>➜ </b>"
		end
		table.insert(days, string.format("%sDía %d: %s", mark, index, PlayerLogic.rewardText(reward)))
	end
	local dailyButton = "Reclamar"
	if not daily.canClaim then
		dailyButton = "Vuelve en " .. formatTime(daily.untilTomorrow)
	end
	addRow(table.concat(days, "\n"), {
		{
			text = dailyButton,
			enabled = daily.canClaim,
			onActivated = function()
				request("claimDaily", "daily")
			end,
		},
	})
	addRow("Si saltas un día, la racha vuelve al día 1.")

	local minutes = math.floor(state.playtime.seconds / 60)
	addHeader(string.format("Premios por tiempo jugado hoy · llevas %d min", minutes))
	for index, tier in GameData.PlaytimeRewards do
		local claimed = state.playtime.claimed[tostring(index)] == true
		local ready = state.playtime.seconds >= tier.minutes * 60
		local text = "Reclamar"
		if claimed then
			text = "Reclamado"
		elseif not ready then
			text = string.format("Faltan %d min", math.max(1, tier.minutes - minutes))
		end
		addRow(string.format("<b>%d minutos</b> — %s", tier.minutes, PlayerLogic.rewardText(tier.reward)), {
			{
				text = text,
				enabled = ready and not claimed,
				onActivated = function()
					request("claimPlaytime", tostring(index))
				end,
			},
		})
	end
	addRow("Los premios por tiempo se reinician cada día. Las cápsulas van a tu Mochila.")
end

local function renderBackpack()
	addHeader(string.format("Piezas %d/%d", state.partCount, state.capacity))
	for _, partId in GameData.PartOrder do
		local part = GameData.Parts[partId]
		local owned = state.parts[partId] or 0
		local buttons = nil
		if partId == "legacy" then
			if owned > 0 then
				local variant = nil
				for _, legacyPiece in GameData.LegacyPieces do
					if legacyPiece.id == state.legacyVariant then
						variant = legacyPiece
					end
				end
				addRow(string.format(
					"<b>%s</b> (herencia)\n<font color=\"#aaaab9\">%s Úsala en el Reloj del Legado o guárdala.</font>",
					variant and variant.name or part.name,
					variant and variant.desc or ""
				))
			end
		elseif owned > 0 then
			-- Tirar piezas libera espacio en cualquier lugar (BUG-001).
			buttons = {
				{
					text = "Tirar 1",
					onActivated = function()
						request("discardPart", partId, 1)
					end,
				},
				{
					text = "Tirar todas",
					onActivated = function()
						request("discardPart", partId, math.min(owned, Config.MAX_SELL_AMOUNT))
					end,
				},
			}
		end
		if partId ~= "legacy" then
			addRow(string.format("<b>%s</b> × %d  <font color=\"#aaaab9\">(%s)</font>", part.name, owned, part.rarity), buttons)
		end
	end
	addHeader("Relojes")
	for _, watchId in GameData.WatchOrder do
		local watch = GameData.Watches[watchId]
		addRow(
			string.format(
				"<b>%s</b> × %d  <font color=\"#aaaab9\">(%d en tu plot)</font>",
				watch.name,
				state.watches[watchId] or 0,
				state.museum[watchId] or 0
			)
		)
	end
	if state.carriedCount > 0 then
		addHeader("Botín encima (aún no es tuyo)")
		for _, partId in GameData.PartOrder do
			local amount = state.carried[partId]
			if amount then
				addRow(
					string.format(
						"<b>%s</b> × %d — llévalo a la base para guardarlo",
						GameData.Parts[partId].name,
						amount
					)
				)
			end
		end
	end
	addHeader("Cápsulas sin abrir")
	local anyCapsule = false
	for _, eggId in GameData.EggOrder do
		local amount = state.capsules[eggId] or 0
		if amount > 0 then
			anyCapsule = true
			addRow(string.format("<b>%s</b> × %d", GameData.Eggs[eggId].name, amount), {
				{
					text = "Abrir",
					onActivated = function()
						request("openCapsule", eggId)
					end,
				},
			})
		end
	end
	if not anyCapsule then
		addRow("No tienes cápsulas. Gánalas en «Premios» o cómpralas en el Criadero.")
	end
	addPetRows()
	addRow("Consejo: si la mochila se llena, vende piezas en la Tienda o tira las que no necesites.")
end

-- Estado del jefe leído de los atributos de su estación (DEV-004)
local function bossInfo()
	local station = stationById("boss")
	if not station then
		return nil
	end
	return {
		active = station:GetAttribute("BossActive") == true,
		points = station:GetAttribute("BossPoints") or 0,
		goal = station:GetAttribute("BossGoal") or 0,
		endsAt = station:GetAttribute("BossEndsAt") or 0,
		nextAt = station:GetAttribute("BossNextAt") or 0,
		mine = player:GetAttribute("BossPoints") or 0,
	}
end

local function bossTimerText(info)
	local now = Workspace:GetServerTimeNow()
	if info.active then
		return string.format("⏱ Tiempo restante: %s", formatTime(info.endsAt - now))
	end
	return string.format("Próxima avería en %s", formatTime(info.nextAt - now))
end

local function renderBoss()
	local info = bossInfo()
	if not info then
		addRow("Cargando el Cronómetro Maestro…")
		return
	end
	bossTimerLabel = addHeader(bossTimerText(info))
	if not info.active then
		addRow(
			"El Cronómetro Maestro funciona. Cuando se averíe, todos los jugadores del servidor "
				.. "tendrán poco tiempo para entregarle piezas guardadas. Si llegan a la meta, "
				.. string.format("cada uno gana %d monedas por punto aportado; si no, recuperan sus piezas.", Config.BOSS_COINS_PER_POINT)
		)
		return
	end
	addRow(
		string.format(
			"<b>Reparación: %d / %d puntos</b>\nTu aporte: %d puntos (≈ %d monedas si se repara)",
			info.points,
			info.goal,
			info.mine,
			info.mine * Config.BOSS_COINS_PER_POINT
		)
	)
	addHeader("Entregar piezas guardadas")
	local any = false
	for _, partId in GameData.PartOrder do
		local owned = state.parts[partId] or 0
		if owned > 0 and not GameData.Parts[partId].protected then
			any = true
			local part = GameData.Parts[partId]
			addRow(
				string.format(
					"<b>%s</b> × %d  ·  %d puntos c/u",
					part.name,
					owned,
					GameData.RepairPoints[part.rarity]
				),
				{
					{
						text = "Entregar 1",
						onActivated = function()
							request("contribute", partId, 1)
						end,
					},
					{
						text = "Entregar todas",
						onActivated = function()
							request("contribute", partId, math.min(owned, Config.MAX_SELL_AMOUNT))
						end,
					},
				}
			)
		end
	end
	if not any then
		addRow("No tienes piezas guardadas. Roba en las casas y vuelve rápido.")
	end
end

-- Tienda Robux (DEV-006). Los IDs en 0 se muestran como «Próximamente».
local function renderRobux()
	addHeader("Pases (compra única, para siempre)")
	for _, passKey in GameData.GamePassOrder do
		local pass = GameData.GamePasses[passKey]
		local owned = state.passes[passKey] == true
		local available = (Config.GAMEPASS_IDS[passKey] or 0) ~= 0
		local text = "Comprar"
		if owned then
			text = "Lo tienes"
		elseif not available then
			text = "Próximamente"
		end
		addRow(string.format("<b>%s</b> · %s R$\n%s", pass.name, tostring(pass.robux or "?"), pass.desc), {
			{
				text = text,
				enabled = available and not owned,
				onActivated = function()
					request("buyPass", passKey)
				end,
			},
		})
	end
	addHeader("Productos (se pueden comprar varias veces)")
	for _, productKey in GameData.ProductOrder do
		local product = GameData.Products[productKey]
		local available = (Config.PRODUCT_IDS[productKey] or 0) ~= 0
		local text = "Comprar"
		if not available then
			text = "Próximamente"
		end
		addRow(string.format("<b>%s</b> · %s R$\n%s", product.name, tostring(product.robux or "?"), product.desc), {
			{
				text = text,
				enabled = available,
				onActivated = function()
					request("buyProduct", productKey)
				end,
			},
		})
	end
	addRow("Las compras las procesa Roblox. Las cápsulas muestran sus probabilidades en el Criadero.")
end

-- Ruleta diaria (DEV-013)
local spinLabel = nil
local spinning = false
local lastSpinText = nil -- se conserva aunque el menú se redibuje

local function renderSpin()
	local spin = state.spin
	local status = "¡Giro gratis disponible!"
	if not spin.canFree then
		status = "Próximo giro gratis en " .. formatTime(spin.untilTomorrow)
	end
	addHeader(string.format("%s · giros extra: %d", status, spin.extra))
	rowOrder += 1
	spinLabel = label(lastSpinText or "<b>¿Qué te tocará?</b>", 26, COLORS.accent, {
		LayoutOrder = rowOrder,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	spinLabel.Parent = panelList
	local canSpin = spin.canFree or spin.extra > 0
	local productAvailable = (Config.PRODUCT_IDS.extraSpin or 0) ~= 0
	local extraText = "Giro extra (próximamente)"
	if productAvailable then
		extraText = "Giro extra (Robux)"
	end
	addRow("Gira una vez al día gratis. Los giros extra se compran con Robux.", {
		{
			text = "Girar",
			enabled = canSpin and not spinning,
			onActivated = function()
				if spinning or not canSpin then
					return
				end
				spinning = true
				Ui.playSound("ruleta")
				-- Animación: recorre los premios y se detiene en el que decide el servidor.
				local finished = false
				task.spawn(function()
					local index = 1
					while not finished do
						index = index % #GameData.SpinPrizes + 1
						if spinLabel and spinLabel.Parent then
							spinLabel.Text = "<b>" .. GameData.SpinPrizes[index].label .. "</b>"
						end
						task.wait(0.08)
					end
				end)
				task.wait(1.2)
				local result = request("spinWheel", "spin")
				finished = true
				spinning = false
				if result and result.ok and result.extra and GameData.SpinPrizes[result.extra] then
					lastSpinText = "<b>🎉 " .. GameData.SpinPrizes[result.extra].label .. "</b>"
				else
					lastSpinText = nil
				end
				if spinLabel and spinLabel.Parent then
					spinLabel.Text = lastSpinText or "<b>¿Qué te tocará?</b>"
				end
			end,
		},
		{
			text = extraText,
			enabled = productAvailable,
			onActivated = function()
				request("buyProduct", "extraSpin")
			end,
		},
	})
	addHeader("Premios y probabilidades")
	local total = 0
	for _, prize in GameData.SpinPrizes do
		total += prize.weight
	end
	for _, prize in GameData.SpinPrizes do
		addRow(string.format("%s — <b>%.0f%%</b>", prize.label, prize.weight / total * 100))
	end
end

-- Ajustes (DEV-013)
local replayIntroHandler = nil

local function renderSettings()
	for _, setting in GameData.Settings do
		local value = state.settings[setting.id]
		if setting.kind == "range" then
			-- DEC-025: la velocidad en la base se elige con la barra del botón «Velocidad»
			addRow(string.format("<b>%s</b>: %d", setting.name, value), {
				{
					text = "Cambiar",
					onActivated = function()
						Ui.openPanel("speed")
					end,
				},
			})
		elseif setting.kind == "toggle" then
			local onText = "Activado"
			if value == 0 then
				onText = "Desactivado"
			end
			addRow(string.format("<b>%s</b>: %s", setting.name, onText), {
				{
					text = "Cambiar",
					onActivated = function()
						request("setSetting", setting.id, 1 - value)
					end,
				},
			})
		else
			local buttons = {}
			for index, option in setting.options do
				table.insert(buttons, {
					text = option,
					enabled = index ~= value,
					onActivated = function()
						request("setSetting", setting.id, index)
					end,
				})
			end
			addRow(string.format("<b>%s</b>: %s", setting.name, setting.options[value] or "?"), buttons)
		end
	end
	addRow("<b>Introducción</b>: vuelve a ver la historia del inicio.", {
		{
			text = "Ver historia",
			onActivated = function()
				Ui.closePanel()
				if replayIntroHandler then
					replayIntroHandler()
				end
			end,
		},
	})
	addHeader("Controles")
	addRow("<b>PC:</b> E interactuar · B Mochila · P Premios · R Ruleta · M Robux · O Ajustes")
	addRow("<b>Mando:</b> X interactuar · Y Mochila · Cruceta: ↑ Premios, → Ruleta, ↓ Robux, ← Ajustes · B cerrar")
	addRow("<b>Táctil:</b> botones a la derecha de la pantalla; toca los avisos de las estaciones para usarlas.")
end

-- Puesto de Carga (DEV-013)
local function renderCarry()
	addHeader(string.format("Llevas hasta %d objeto(s) robado(s) por viaje", state.carryCapacity))
	addRow("Cada viaje a una casa puedes cargar este número de objetos antes de volver a la base.")
	for _, upgradeId in GameData.CarryUpgradeOrder do
		local upgrade = GameData.Upgrades[upgradeId]
		local level = state.upgrades[upgradeId] or 0
		local cost = state.upgradeCosts[upgradeId]
		local buttonText = "Máximo"
		local enabled = false
		if cost then
			buttonText = "Comprar " .. formatNumber(cost)
			enabled = state.coins >= cost
		end
		addRow(string.format("<b>%s</b>  (nivel %d/%d)\n%s", upgrade.name, level, upgrade.maxLevel, upgrade.desc), {
			{
				text = buttonText,
				enabled = enabled,
				onActivated = function()
					if cost then
						request("buyCarryUpgrade", upgradeId)
					end
				end,
			},
		})
	end
end

local function bossKey()
	local info = bossInfo()
	if not info then
		return ""
	end
	return string.format("%s|%d|%d|%d", tostring(info.active), info.points, info.goal, info.mine)
end

-- Velocidad (DEC-025): tu velocidad, la de cada lugar y la barra para elegir la de la base.
local function nextZone()
	for index, zone in GameData.Zones do
		if state.speed < zone.minSpeed then
			return index, zone
		end
	end
	return nil, nil
end

local function renderSpeed()
	addHeader(string.format("Tu velocidad: %s", PlayerLogic.formatBig(state.speed)))
	local zoneIndex, zone = nextZone()
	if zone then
		addRow(string.format(
			"Siguiente zona: <b>%d · %s</b> — necesitas <b>%s</b> (te faltan %s).",
			zoneIndex,
			zone.name,
			PlayerLogic.formatBig(zone.minSpeed),
			PlayerLogic.formatBig(zone.minSpeed - state.speed)
		))
	else
		addRow(string.format(
			"¡Abriste las 12 zonas! Con <b>%s</b> se abrirá un mundo nuevo en una próxima actualización.",
			PlayerLogic.formatBig(GameData.NEXT_WORLD_SPEED)
		))
	end
	addRow(string.format(
		"Corres a <b>%.0f</b> en las zonas · <b>%d</b> dentro de las casas · entrenas <b>+%s/s</b> en tu caminadora.",
		state.walkSpeed,
		math.min(state.walkSpeed, Config.HOUSE_WALKSPEED),
		PlayerLogic.formatBig(state.trainPerSecond)
	))

	-- Barra deslizante: velocidad al caminar por la base (16 a 50, o tu máximo si es menor)
	local setting
	for _, item in GameData.Settings do
		if item.id == "runSpeed" then
			setting = item
		end
	end
	local minValue = setting.min
	local maxValue = math.max(minValue, math.min(setting.max, math.floor(state.walkSpeed)))
	local value = math.clamp(state.settings.runSpeed or setting.default, minValue, maxValue)

	local row = addRow(string.format("<b>Velocidad en la base</b> (de %d a %d)", minValue, maxValue))
	local valueLabel = label(string.format("<b>%d</b>", value), 22, COLORS.accent, { LayoutOrder = 2 })
	valueLabel.Parent = row
	local track = new("Frame", {
		Name = "Barra",
		Size = UDim2.new(1, -20, 0, 14),
		BackgroundColor3 = COLORS.buttonOff,
		LayoutOrder = 3,
		Active = true,
	}, { corner(7) })
	local fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = COLORS.accent,
	}, { corner(7) })
	fill.Parent = track
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = COLORS.text,
		ZIndex = 2,
	}, { corner(14) })
	knob.Parent = track
	track.Parent = row

	local function show(newValue)
		value = math.clamp(math.floor(newValue + 0.5), minValue, maxValue)
		local fraction = 0
		if maxValue > minValue then
			fraction = (value - minValue) / (maxValue - minValue)
		end
		fill.Size = UDim2.fromScale(fraction, 1)
		knob.Position = UDim2.fromScale(fraction, 0.5)
		valueLabel.Text = string.format("<b>%d</b>", value)
	end
	local function save()
		if value ~= state.settings.runSpeed then
			request("setSetting", "runSpeed", value)
		end
	end
	local function fromInput(x)
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end
		show(minValue + (maxValue - minValue) * math.clamp((x - track.AbsolutePosition.X) / width, 0, 1))
	end
	show(value)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliderDragging = true
			fromInput(input.Position.X)
		end
	end)
	local moveConnection, endConnection
	moveConnection = UserInputService.InputChanged:Connect(function(input)
		if not track.Parent then
			moveConnection:Disconnect()
			return
		end
		if
			sliderDragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			fromInput(input.Position.X)
		end
	end)
	endConnection = UserInputService.InputEnded:Connect(function(input)
		if not track.Parent then
			endConnection:Disconnect()
			return
		end
		if
			sliderDragging
			and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		then
			sliderDragging = false
			save()
		end
	end)

	-- Botones para mando y para ajustes rápidos
	addRow("Ajuste rápido:", {
		{
			text = "−5",
			onActivated = function()
				show(value - 5)
				save()
			end,
		},
		{
			text = "+5",
			onActivated = function()
				show(value + 5)
				save()
			end,
		},
		{
			text = "Lento (16)",
			onActivated = function()
				show(minValue)
				save()
			end,
		},
		{
			text = "Máximo",
			onActivated = function()
				show(maxValue)
				save()
			end,
		},
	})
	addRow("La barra cambia tu velocidad en la base. En las zonas corres siempre a tu máximo y dentro de las casas a 40 o menos.")
end

local RENDERERS = {
	speed = renderSpeed,
	workshop = renderWorkshop,
	shop = renderShop,
	plot = function()
		renderMuseum()
		renderPlotUpgrades()
	end,
	backpack = renderBackpack,
	boss = renderBoss,
	pets = renderPets,
	robux = renderRobux,
	rewards = renderRewards,
	spin = renderSpin,
	settings = renderSettings,
	carry = renderCarry,
}

-- ---------------------------------------------------------------------------
-- Abrir, cerrar y refrescar menús
-- ---------------------------------------------------------------------------

local function selectFirstButton()
	if not UserInputService.GamepadEnabled then
		return
	end
	local first = nil
	local bestOrder = math.huge
	for _, descendant in panelList:GetDescendants() do
		if descendant:IsA("TextButton") then
			local row = descendant.Parent.Parent
			if row.LayoutOrder < bestOrder then
				bestOrder = row.LayoutOrder
				first = descendant
			end
		end
	end
	GuiService.SelectedObject = first or panel:FindFirstChild("Cerrar", true)
end

local function render(keepSelection)
	for _, child in panelList:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	rowOrder = 0
	if not openPanelId or not state then
		return
	end
	panelTitle.Text = PANEL_TITLES[openPanelId] or ""
	RENDERERS[openPanelId]()
	if not keepSelection then
		selectFirstButton()
	elseif UserInputService.GamepadEnabled and not GuiService.SelectedObject then
		selectFirstButton()
	end
end

function Ui.closePanel()
	openPanelId = nil
	panel.Visible = false
	GuiService.SelectedObject = nil
	ContextActionService:UnbindAction("CerrarMenu")
end

function Ui.openPanel(panelId)
	if not RENDERERS[panelId] or not state then
		return
	end
	openPanelId = panelId
	panel.Visible = true
	render(false)
	ContextActionService:BindAction("CerrarMenu", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			Ui.closePanel()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonB)
end

local function togglePanel(panelId)
	if openPanelId == panelId then
		Ui.closePanel()
	else
		Ui.openPanel(panelId)
	end
end

local function toggleBackpack()
	togglePanel("backpack")
end

-- ---------------------------------------------------------------------------
-- HUD (DEV-013): tarjetas a la izquierda, objetivo arriba al centro y barra
-- de botones a la derecha. Se escala según la pantalla y el ajuste «Tamaño».
-- ---------------------------------------------------------------------------

local SCALE_SETTING = { 0.85, 1, 1.18 }

local function updateScale()
	if not hud.scale then
		return
	end
	local camera = Workspace.CurrentCamera
	local viewport = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
	local base = math.clamp(math.min(viewport.X, viewport.Y) / 720, 0.65, 1.25)
	-- En consola (TV, sin táctil ni teclado) se agranda para leerse a distancia.
	if UserInputService.GamepadEnabled and not UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		base *= 1.15
	end
	local choice = 2
	if state and state.settings then
		choice = state.settings.scale or 2
	end
	hud.scale.Scale = base * (SCALE_SETTING[choice] or 1)
end

local function rewardsPending()
	if not state then
		return false
	end
	if state.daily.canClaim then
		return true
	end
	for index, tier in GameData.PlaytimeRewards do
		if state.playtime.seconds >= tier.minutes * 60 and not state.playtime.claimed[tostring(index)] then
			return true
		end
	end
	return false
end

local function updateHud()
	if not state then
		return
	end
	updateScale()
	hud.coins.Text = string.format("<b>%s</b>", formatNumber(state.coins))
	hud.level.Text = string.format("Nivel <b>%d</b>", state.level)
	local fraction = 1
	if state.levelNeed > 0 then
		fraction = math.clamp(state.levelXp / state.levelNeed, 0, 1)
		hud.xpText.Text = string.format("%d / %d XP", state.levelXp, state.levelNeed)
	else
		hud.xpText.Text = "Nivel máximo"
	end
	hud.xpFill.Size = UDim2.fromScale(fraction, 1)
	-- DEC-025: la velocidad es una estadística; se muestra abreviada y con su velocidad física
	hud.speed.Text = string.format(
		"<b>Velocidad %s</b>  (corres a %.0f)",
		PlayerLogic.formatBig(state.speed),
		state.walkSpeed
	)
	local reached = GameData.Zones[state.highestZone]
	local following = GameData.Zones[state.highestZone + 1]
	if following then
		hud.zone.Text = string.format(
			"Zona máx.: %s · siguiente: %s",
			reached and reached.name or "ninguna",
			PlayerLogic.formatBig(following.minSpeed)
		)
	else
		hud.zone.Text = "Zona máx.: " .. (reached and reached.name or "ninguna")
	end
	hud.carry.Text = string.format(
		"Carga %d/%d · Mochila %d/%d",
		state.carriedCount,
		state.carryCapacity,
		state.partCount + state.carriedCount,
		state.capacity
	)
	if state.carriedCount > 0 then
		hud.loot.Visible = true
		hud.loot.Text = string.format("<b>Botín encima: %d</b> — ¡llévalo a la base!", state.carriedCount)
	else
		hud.loot.Visible = false
	end
	hud.museum.Text = string.format(
		"Plot +%.1f/min · suerte +%.1f%%",
		state.museumIncomePerMinute,
		state.plotLuck * 100
	)

	local tutorial = state.tutorial
	if tutorial then
		hud.objectiveCard.Visible = true
		hud.objective.Text = string.format(
			"<b>Objetivo %d/%d</b> · %s (%d/%d) · <font color=\"#aaaab9\">premio %d</font>",
			tutorial.index,
			tutorial.total,
			tutorial.text,
			tutorial.progress,
			tutorial.target,
			tutorial.reward
		)
	else
		hud.objectiveCard.Visible = false
	end

	hud.badges.rewards.Visible = rewardsPending()
	hud.badges.spin.Visible = state.spin.canFree or state.spin.extra > 0
end

-- ---------------------------------------------------------------------------
-- Guía del tutorial: una línea luminosa del personaje al destino (DEV-002)
-- ---------------------------------------------------------------------------

local guide = { beam = nil, from = nil, to = nil, target = nil }

-- Estación por id (etiqueta "Station"); funciona con streaming porque las
-- estaciones son modelos persistentes.
local findStation = stationById

local function findGuideTarget(guideId)
	if guideId == "treadmill" then
		-- Caminadora del plot propio (DEV-011)
		for _, part in CollectionService:GetTagged("PlotTreadmill") do
			if part:GetAttribute("OwnerUserId") == player.UserId then
				return part
			end
		end
		return nil
	end
	if guideId == "house" then
		return CollectionService:GetTagged("GuideHouse")[1]
	end
	return findStation(guideId)
end

-- Puertas de velocidad: se vuelven atravesables SOLO para este jugador si
-- tiene la velocidad. El servidor igual rechaza robos sin la velocidad.
local function updateGates()
	if not state then
		return
	end
	for _, gate in CollectionService:GetTagged("SpeedGate") do
		local open = state.speed >= (gate:GetAttribute("MinSpeed") or 0) -- DEC-025: estadística
		gate.CanCollide = not open
		if open then
			gate.Color = COLORS.ok
			gate.Transparency = 0.8
		else
			gate.Color = COLORS.error
			gate.Transparency = 0.3
		end
	end
end

local function clearGuide()
	for _, key in { "beam", "from", "to" } do
		if guide[key] then
			guide[key]:Destroy()
			guide[key] = nil
		end
	end
	guide.target = nil
end

local function updateGuide()
	local tutorial = state and state.tutorial
	if state and state.settings and state.settings.guide == 0 then
		tutorial = nil -- guía desactivada en Ajustes
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local target = tutorial and findGuideTarget(tutorial.guide)
	if not root or not target then
		clearGuide()
		return
	end
	-- Recrear si cambió el destino o si el personaje reapareció.
	if guide.target ~= target or not guide.from or guide.from.Parent ~= root then
		clearGuide()
		guide.target = target
		guide.from = new("Attachment", { Name = "GuiaOrigen", Position = Vector3.new(0, -2, 0) })
		guide.from.Parent = root
		guide.to = new("Attachment", { Name = "GuiaDestino", Position = Vector3.new(0, 1, 0) })
		guide.to.Parent = target
		guide.beam = new("Beam", {
			Name = "GuiaTutorial",
			Attachment0 = guide.from,
			Attachment1 = guide.to,
			Color = ColorSequence.new(COLORS.accent),
			Transparency = NumberSequence.new(0.35),
			Width0 = 0.6,
			Width1 = 0.6,
			FaceCamera = true,
			LightEmission = 0.6,
			Segments = 1,
		})
		guide.beam.Parent = root
	end
	-- Se oculta al llegar, para no estorbar.
	local horizontal = Vector3.new(root.Position.X - target.Position.X, 0, root.Position.Z - target.Position.Z)
	guide.beam.Enabled = horizontal.Magnitude > 18
end

local function card(name, props)
	local frame = new("Frame", {
		Name = name,
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.15,
	}, {
		corner(10),
		padding(8),
		new("UIStroke", { Color = COLORS.brass, Thickness = 1.5, Transparency = 0.25 }), -- ART-015
		new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	for key, value in props or {} do
		frame[key] = value
	end
	return frame
end

local RAIL_BUTTONS = {
	{ id = "backpack", text = "Mochila", key = "B", icon = "mochila" },
	{ id = "speed", text = "Velocidad", key = "V", icon = "velocidad" }, -- DEC-025
	{ id = "rewards", text = "Premios", key = "P", icon = "premios" },
	{ id = "spin", text = "Ruleta", key = "R", icon = "ruleta" },
	{ id = "robux", text = "Robux", key = "M", icon = "robux" },
	{ id = "settings", text = "Ajustes", key = "O", icon = "ajustes" },
}

local function buildHud()
	gui = new("ScreenGui", {
		Name = "BuildAWatchUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	hud.scale = new("UIScale", { Scale = 1 })
	hud.scale.Parent = gui

	-- Columna izquierda: dinero y nivel; velocidad, carga y plot
	local left = new("Frame", {
		Name = "Izquierda",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(240, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local money = card("Dinero", { LayoutOrder = 1 })
	hud.coins = label("", 24, COLORS.accent, { LayoutOrder = 1 })
	local coinIcon = iconImage("monedas", 26)
	if coinIcon then
		coinIcon.AnchorPoint = Vector2.new(1, 0)
		coinIcon.Position = UDim2.new(1, 0, 0, 0)
		coinIcon.Parent = hud.coins
	end
	hud.level = label("", 15, COLORS.text, { LayoutOrder = 2 })
	local xpBar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = COLORS.row,
		LayoutOrder = 3,
	}, { corner(6) })
	hud.xpFill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = COLORS.ok }, { corner(6) })
	hud.xpFill.Parent = xpBar
	hud.xpText = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = COLORS.text,
		Text = "",
		ZIndex = 2,
	})
	hud.xpText.Parent = xpBar
	for _, item in { hud.coins, hud.level, xpBar } do
		item.Parent = money
	end
	money.Parent = left

	local info = card("Estado", { LayoutOrder = 2 })
	hud.speed = label("", 16, COLORS.text, { LayoutOrder = 1 })
	hud.zone = label("", 13, COLORS.muted, { LayoutOrder = 2 })
	hud.carry = label("", 13, COLORS.muted, { LayoutOrder = 3 })
	hud.training = label("", 13, COLORS.ok, { LayoutOrder = 4, Visible = false })
	hud.loot = label("", 13, COLORS.error, { LayoutOrder = 5, Visible = false })
	hud.museum = label("", 13, COLORS.muted, { LayoutOrder = 6 })
	for _, item in { hud.speed, hud.zone, hud.carry, hud.training, hud.loot, hud.museum } do
		item.Parent = info
	end
	info.Parent = left
	left.Parent = gui

	-- Arriba al centro: objetivo del tutorial y notificaciones debajo
	local top = new("Frame", {
		Name = "Centro",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.new(0.5, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		new("UISizeConstraint", { MinSize = Vector2.new(260, 0), MaxSize = Vector2.new(460, 4000) }),
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	hud.objectiveCard = card("Objetivo", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false })
	hud.objective = label("", 14, COLORS.accent, { LayoutOrder = 1 })
	hud.objective.Parent = hud.objectiveCard
	hud.objectiveCard.Parent = top
	toastList = new("Frame", {
		Name = "Notificaciones",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	toastList.Parent = top
	top.Parent = gui

	-- Derecha: barra de botones (a media altura: no tapa el salto táctil)
	local rail = new("Frame", {
		Name = "Botones",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.42, 0),
		Size = UDim2.fromOffset(120, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local showKeys = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
	hud.badges = {}
	for index, info in RAIL_BUTTONS do
		local text = info.text
		if showKeys then
			text ..= " [" .. info.key .. "]"
		end
		local item = button(text, true, function()
			togglePanel(info.id)
		end)
		item.Name = "Boton" .. info.text
		item.LayoutOrder = index
		item.Size = UDim2.fromOffset(120, 44)
		-- ART-015: carbón con borde de latón (antes bloques azules); el icono da el color
		item.BackgroundColor3 = COLORS.panel
		item.BackgroundTransparency = 0.1
		new("UIStroke", {
			Color = COLORS.brass,
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}).Parent = item
		local icon = iconImage(info.icon, 30)
		if icon then
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 6, 0.5, 0)
			icon.Parent = item
			item.TextXAlignment = Enum.TextXAlignment.Right
			new("UIPadding", { PaddingRight = UDim.new(0, 8) }).Parent = item
		end
		local badge = new("TextLabel", {
			Name = "Aviso",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -4, 0, 4),
			Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = COLORS.error,
			Font = Enum.Font.GothamBold,
			Text = "!",
			TextSize = 14,
			TextColor3 = COLORS.text,
			Visible = false,
			ZIndex = 3,
		}, { corner(10) })
		badge.Parent = item
		hud.badges[info.id] = badge
		item.Parent = rail
	end
	rail.Parent = gui

	-- Menú central
	panel = new("Frame", {
		Name = "Menu",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.92, 0.72),
		BackgroundColor3 = COLORS.panel,
		Visible = false,
		ZIndex = 5,
	}, {
		corner(12),
		new("UISizeConstraint", { MaxSize = Vector2.new(580, 480) }),
	})
	panelTitle = new("TextLabel", {
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -72, 0, 36),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
	})
	panelTitle.Parent = panel
	local closeButton = new("TextButton", {
		Name = "Cerrar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.fromOffset(40, 36),
		BackgroundColor3 = COLORS.error,
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextSize = 18,
		TextColor3 = COLORS.text,
	}, { corner(8) })
	closeButton.Activated:Connect(Ui.closePanel)
	closeButton.Parent = panel
	panelList = new("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		padding(10),
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	panelList.Parent = panel
	panel.Parent = gui

	gui.Parent = player:WaitForChild("PlayerGui")
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end
	updateScale()
end

-- Cada medio segundo: guía, puertas (por si aparecieron con streaming) y
-- cierre del menú si el jugador se aleja de la estación.
local function watchDistance()
	task.spawn(function()
		while true do
			task.wait(0.5)
			updateGuide()
			updateGates()
			local isTraining = player:GetAttribute("Training") ~= nil
			local loop = getSound("entrenar")
			if loop then
				loop.Looped = true
				if isTraining and not loop.IsPlaying then
					loop:Play()
				elseif not isTraining and loop.IsPlaying then
					loop:Stop()
				end
			end
			if player:GetAttribute("Training") and state then
				hud.training.Visible = true
				hud.training.Text = string.format(
					"Entrenando +%s/s · velocidad %s (pulsa la caminadora para parar)",
					PlayerLogic.formatBig(state.trainPerSecond),
					PlayerLogic.formatBig(state.speed)
				)
			else
				hud.training.Visible = false
			end
			if openPanelId == "boss" then
				local key = bossKey()
				if key ~= lastBossKey then
					lastBossKey = key
					render(true)
				elseif bossTimerLabel and bossTimerLabel.Parent then
					local info = bossInfo()
					if info then
						bossTimerLabel.Text = "<b>" .. bossTimerText(info) .. "</b>"
					end
				end
			end
			-- Los menús que se abren desde el HUD (Mochila, Robux, Premios) no se cierran al alejarse.
			if openPanelId and not HUD_PANELS[openPanelId] then
				local station = findStation(openPanelId)
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if station and root and (root.Position - station.Position).Magnitude > Config.STATION_DISTANCE + 4 then
					Ui.closePanel()
				end
			end
		end
	end)
end

-- ---------------------------------------------------------------------------
-- API
-- ---------------------------------------------------------------------------

-- Ajustes → «Ver historia» llama a esta función (la pone Main con Intro).
function Ui.onReplayIntro(handler)
	replayIntroHandler = handler
end

-- Main conecta aquí los efectos visuales (Vfx.onAction) tras cada acción correcta.
function Ui.onAction(handler)
	actionHandler = handler
end

-- Otros módulos del cliente (Intro) piden acciones por aquí.
function Ui.request(action, id, amount)
	request(action, id, amount)
end

function Ui.init(remote)
	actionRemote = remote
	buildHud()
	ContextActionService:BindAction("AbrirMochila", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			toggleBackpack()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.B, Enum.KeyCode.ButtonY)
	-- Atajos del HUD (DEV-013). Con un menú abierto, la cruceta se deja para
	-- navegar dentro del menú con el mando.
	local shortcuts = {
		[Enum.KeyCode.P] = "rewards",
		[Enum.KeyCode.V] = "speed", -- DEC-025
		[Enum.KeyCode.R] = "spin",
		[Enum.KeyCode.M] = "robux",
		[Enum.KeyCode.O] = "settings",
		[Enum.KeyCode.DPadUp] = "rewards",
		[Enum.KeyCode.DPadRight] = "spin",
		[Enum.KeyCode.DPadDown] = "robux",
		[Enum.KeyCode.DPadLeft] = "settings",
	}
	local keys = {}
	for keyCode in shortcuts do
		table.insert(keys, keyCode)
	end
	ContextActionService:BindAction("AtajosHud", function(_, inputState, input)
		local isDPad = input.KeyCode.Name:sub(1, 4) == "DPad"
		if isDPad and openPanelId then
			return Enum.ContextActionResult.Pass
		end
		if inputState == Enum.UserInputState.Begin then
			togglePanel(shortcuts[input.KeyCode])
		end
		return Enum.ContextActionResult.Sink
	end, false, table.unpack(keys))
	watchDistance()
end

function Ui.setState(newState)
	state = newState
	updateHud()
	updateGates()
	if openPanelId and not sliderDragging then
		render(true)
	end
end

return Ui
