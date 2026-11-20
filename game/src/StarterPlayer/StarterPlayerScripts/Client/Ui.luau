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

local player = Players.LocalPlayer

local Ui = {}

local COLORS = {
	panel = Color3.fromRGB(28, 30, 38),
	row = Color3.fromRGB(42, 45, 56),
	text = Color3.fromRGB(240, 240, 245),
	muted = Color3.fromRGB(170, 172, 185),
	accent = Color3.fromRGB(240, 196, 80),
	ok = Color3.fromRGB(76, 175, 106),
	error = Color3.fromRGB(214, 84, 84),
	info = Color3.fromRGB(80, 130, 210),
	button = Color3.fromRGB(80, 130, 210),
	buttonOff = Color3.fromRGB(88, 90, 102),
}

local PANEL_TITLES = {
	workshop = "Taller de tu plot — Fabricar relojes",
	shop = "Tienda — Vender y mejorar",
	plot = "Tu plot — Vitrinas y mejoras",
	backpack = "Mochila",
	boss = "Cronómetro Maestro — Reparación",
	pets = "Criadero — Huevos y mascotas",
	robux = "Tienda Robux — Pases y productos",
}

local state = nil
local bossTimerLabel = nil -- etiqueta del menú del jefe que se actualiza cada medio segundo
local lastBossKey = ""
local actionRemote = nil
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
	item.Activated:Connect(onActivated)
	return item
end

local function formatNumber(value)
	local text = tostring(math.floor(value))
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
	if #items > 4 then
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
	end
	Ui.toast(result.message, kind)
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
		if owned > 0 then
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
			"Caminadora ×%.1f · velocidad entrenada %.1f / %d · suerte del plot +%.1f%%",
			state.treadmillMultiplier,
			state.trained,
			Config.MAX_TRAINED,
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
			"Vitrinas %d/%d · Ingreso +%d cada %d s",
			state.museumCount,
			state.museumSlots,
			state.museumIncome,
			Config.MUSEUM_TICK_SECONDS
		)
	)
	local anyDisplayed = false
	for _, watchId in GameData.WatchOrder do
		local displayed = state.museum[watchId] or 0
		if displayed > 0 then
			anyDisplayed = true
			local watch = GameData.Watches[watchId]
			addRow(string.format("<b>%s</b> × %d exhibido  ·  +%d c/u", watch.name, displayed, watch.income), {
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
			addRow(string.format("<b>%s</b> × %d  ·  +%d por ciclo", watch.name, owned, watch.income), {
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
		addRow("Todavía no tienes mascotas. Compra huevos en el Criadero de la base.")
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
		addRow(
			string.format("<b>%s</b> — %s monedas\n%s", egg.name, formatNumber(egg.cost), table.concat(odds, " · ")),
			{
				{
					text = "Abrir",
					enabled = state.coins >= egg.cost,
					onActivated = function()
						request("hatchEgg", eggId)
					end,
				},
			}
		)
	end
	addPetRows()
end

local function renderBackpack()
	addHeader(string.format("Piezas %d/%d", state.partCount, state.capacity))
	for _, partId in GameData.PartOrder do
		local part = GameData.Parts[partId]
		local owned = state.parts[partId] or 0
		local buttons = nil
		if owned > 0 then
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
		addRow(string.format("<b>%s</b> × %d  <font color=\"#aaaab9\">(%s)</font>", part.name, owned, part.rarity), buttons)
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
		if owned > 0 then
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
		addRow(string.format("<b>%s</b>\n%s", pass.name, pass.desc), {
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
		addRow(string.format("<b>%s</b>\n%s", product.name, product.desc), {
			{
				text = text,
				enabled = available,
				onActivated = function()
					request("buyProduct", productKey)
				end,
			},
		})
	end
	addRow("Las compras las procesa Roblox. Los huevos muestran sus probabilidades en el Criadero.")
end

local function bossKey()
	local info = bossInfo()
	if not info then
		return ""
	end
	return string.format("%s|%d|%d|%d", tostring(info.active), info.points, info.goal, info.mine)
end

local RENDERERS = {
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

local function toggleBackpack()
	if openPanelId == "backpack" then
		Ui.closePanel()
	else
		Ui.openPanel("backpack")
	end
end

-- ---------------------------------------------------------------------------
-- HUD
-- ---------------------------------------------------------------------------

local function updateHud()
	if not state then
		return
	end
	hud.coins.Text = string.format("<b>%s</b> monedas", formatNumber(state.coins))
	hud.level.Text = string.format("Nivel <b>%d</b>", state.level)
	local fraction = 1
	if state.levelNeed > 0 then
		fraction = math.clamp(state.levelXp / state.levelNeed, 0, 1)
		hud.xpText.Text = string.format("%d / %d XP", state.levelXp, state.levelNeed)
	else
		hud.xpText.Text = "Nivel máximo"
	end
	hud.xpFill.Size = UDim2.fromScale(fraction, 1)
	hud.backpack.Text = string.format(
		"Mochila: %d/%d piezas",
		state.partCount + state.carriedCount,
		state.capacity
	)
	hud.speed.Text = string.format(
		"Velocidad: %.1f (base %.1f × %.2f) · Zona máx.: %s",
		state.walkSpeed,
		state.baseSpeed,
		state.speedMultiplier,
		GameData.Zones[state.highestZone].name
	)
	if state.carriedCount > 0 then
		hud.loot.Visible = true
		hud.loot.Text = string.format("<b>Botín encima: %d</b> — ¡llévalo a la base!", state.carriedCount)
	else
		hud.loot.Visible = false
	end
	hud.museum.Text = string.format(
		"Plot: +%d cada %d s · suerte +%.1f%%",
		state.museumIncome,
		Config.MUSEUM_TICK_SECONDS,
		state.plotLuck * 100
	)

	local tutorial = state.tutorial
	if tutorial then
		hud.objective.Visible = true
		hud.objective.Text = string.format(
			"<b>Objetivo %d/%d</b>\n%s (%d/%d)\n<font color=\"#aaaab9\">Premio: %d monedas</font>",
			tutorial.index,
			tutorial.total,
			tutorial.text,
			tutorial.progress,
			tutorial.target,
			tutorial.reward
		)
	else
		hud.objective.Visible = false
	end
end

-- ---------------------------------------------------------------------------
-- Guía del tutorial: una línea luminosa del personaje al destino (DEV-002)
-- ---------------------------------------------------------------------------

local guide = { beam = nil, from = nil, to = nil, target = nil }

-- Estación por id (etiqueta "Station"); funciona con streaming porque las
-- estaciones son modelos persistentes.
local findStation = stationById

local function findGuideTarget(guideId)
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
		local open = state.walkSpeed >= (gate:GetAttribute("MinSpeed") or 0)
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

local function buildHud()
	gui = new("ScreenGui", {
		Name = "BuildAWatchUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local stats = new("Frame", {
		Name = "Estadisticas",
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(230, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLORS.panel,
		BackgroundTransparency = 0.15,
	}, {
		corner(10),
		padding(10),
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	hud.coins = label("", 20, COLORS.accent, { LayoutOrder = 1 })
	hud.level = label("", 16, COLORS.text, { LayoutOrder = 2 })
	local xpBar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = COLORS.row,
		LayoutOrder = 3,
	}, { corner(6) })
	hud.xpFill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = COLORS.ok,
	}, { corner(6) })
	hud.xpFill.Parent = xpBar
	hud.xpText = new("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = COLORS.text,
		Text = "",
		ZIndex = 2,
	})
	hud.xpText.Parent = xpBar
	hud.backpack = label("", 15, COLORS.muted, { LayoutOrder = 4 })
	hud.museum = label("", 15, COLORS.muted, { LayoutOrder = 5 })
	hud.speed = label("", 15, COLORS.muted, { LayoutOrder = 4 })
	hud.loot = label("", 15, COLORS.error, { LayoutOrder = 4, Visible = false })
	hud.objective = label("", 15, COLORS.accent, { LayoutOrder = 6, Visible = false })
	hud.training = label("", 15, COLORS.ok, { LayoutOrder = 4, Visible = false })
	for _, item in { hud.coins, hud.level, xpBar, hud.backpack, hud.speed, hud.training, hud.loot, hud.museum, hud.objective } do
		item.Parent = stats
	end
	stats.Parent = gui

	-- Botón de mochila (necesario en pantallas táctiles)
	local backpackButton = button("Mochila", true, toggleBackpack)
	backpackButton.Name = "BotonMochila"
	backpackButton.AnchorPoint = Vector2.new(0, 0.5)
	backpackButton.Position = UDim2.new(0, 12, 0.5, 0)
	backpackButton.Size = UDim2.fromOffset(110, 44)
	backpackButton.Parent = gui

	local robuxButton = button("Robux", true, function()
		if openPanelId == "robux" then
			Ui.closePanel()
		else
			Ui.openPanel("robux")
		end
	end)
	robuxButton.Name = "BotonRobux"
	robuxButton.AnchorPoint = Vector2.new(0, 0.5)
	robuxButton.Position = UDim2.new(0, 12, 0.5, 52)
	robuxButton.Size = UDim2.fromOffset(110, 44)
	robuxButton.Parent = gui

	-- Notificaciones
	toastList = new("Frame", {
		Name = "Notificaciones",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = UDim2.new(0.9, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		new("UISizeConstraint", { MaxSize = Vector2.new(420, 4000) }),
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	toastList.Parent = gui

	-- Menú central
	panel = new("Frame", {
		Name = "Menu",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.92, 0.72),
		BackgroundColor3 = COLORS.panel,
		Visible = false,
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
end

-- Cada medio segundo: guía, puertas (por si aparecieron con streaming) y
-- cierre del menú si el jugador se aleja de la estación.
local function watchDistance()
	task.spawn(function()
		while true do
			task.wait(0.5)
			updateGuide()
			updateGates()
			if player:GetAttribute("Training") and state then
				hud.training.Visible = true
				hud.training.Text = string.format(
					"Entrenando ×%.1f: %.1f / %d (pulsa la caminadora para parar)",
					state.treadmillMultiplier,
					state.trained,
					Config.MAX_TRAINED
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
			if openPanelId and openPanelId ~= "backpack" then
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

function Ui.init(remote)
	actionRemote = remote
	buildHud()
	ContextActionService:BindAction("AbrirMochila", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			toggleBackpack()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.B, Enum.KeyCode.ButtonY)
	watchDistance()
end

function Ui.setState(newState)
	state = newState
	updateHud()
	updateGates()
	if openPanelId then
		render(true)
	end
end

return Ui
