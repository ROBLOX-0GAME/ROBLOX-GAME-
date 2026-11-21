--[[
	Vfx — efectos visuales breves, solo en el cliente (ART-015, propuesta DEC-025).

	Refuerzan acciones que ya existen; no deciden nada ni hablan con el servidor:
	  - Vfx.onAction(action, result): la acción pedida por la interfaz salió bien
	    (fabricar, vender, abrir cápsula, premios, mejoras).
	  - Vfx.onSound(key): el servidor ya avisa con un sonido de subir de nivel,
	    robar, guardar el botín y ser atrapado; se reutiliza ese aviso.
	  - Vfx.onState(state): estela mientras se lleva botín (carrera).
	  - Brillo en las piezas robables Raras o mejores cercanas (etiqueta "PiezaRobable",
	    atributo "Rarity", que pone HouseService).

	Límites: como mucho MAX_ACTIVE efectos a la vez, partículas con Emit (Rate = 0),
	todo se destruye solo, revisión de brillos cada 0,5 s (sin RenderStepped) y la
	mitad de partículas en pantallas táctiles. Si algo falla, el juego sigue igual.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local GameData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameData"))

local player = Players.LocalPlayer

local Vfx = {}

-- Paleta «taller fantástico» (colores de tex_paleta)
local BRASS = Color3.fromRGB(194, 123, 58)
local GOLD = Color3.fromRGB(242, 193, 78)
local CYAN = Color3.fromRGB(91, 213, 224)
local IVORY = Color3.fromRGB(242, 240, 234)
local RED = Color3.fromRGB(217, 83, 79)

local MAX_ACTIVE = 3
local PARTICLE_SCALE = UserInputService.TouchEnabled and 0.5 or 1
local GLOW_DISTANCE = 40
local MAX_GLOWS = 6
local COMMON_RARITIES = { ["Común"] = true, ["Poco común"] = true }

local active = 0
local folder = nil
local trail = nil

local function getFolder()
	if not folder or not folder.Parent then
		folder = Instance.new("Folder")
		folder.Name = "EfectosLocales"
		folder.Parent = Workspace
	end
	return folder
end

local function getRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- Reserva un hueco de efecto; devuelve false si ya hay demasiados.
local function acquire(seconds)
	if active >= MAX_ACTIVE then
		return false
	end
	active += 1
	task.delay(seconds, function()
		active -= 1
	end)
	return true
end

local function anchorAt(position, seconds)
	local part = Instance.new("Part")
	part.Name = "Efecto"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	part.Parent = getFolder()
	task.delay(seconds, function()
		part:Destroy()
	end)
	return part
end

-- Ráfaga de chispas (una sola emisión)
local function burst(position, colorA, colorB, count, speed, rise)
	local anchor = anchorAt(position, 1.5)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.45, 0.9)
	emitter.Speed = NumberRange.new(speed * 0.6, speed)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, rise or -10, 0)
	emitter.Drag = 3
	emitter.LightEmission = 0.7
	emitter.Color = ColorSequence.new(colorA, colorB or colorA)
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
	emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	emitter.Parent = anchor
	emitter:Emit(math.max(1, math.floor(count * PARTICLE_SCALE)))
end

-- Destello de luz que se apaga
local function flash(position, color, range, seconds)
	local anchor = anchorAt(position, seconds + 0.1)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = 4
	light.Shadows = false
	light.Parent = anchor
	TweenService
		:Create(light, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 })
		:Play()
end

-- Anillo que se expande a los pies
local function ring(position, color)
	local part = anchorAt(position, 0.6)
	part.Shape = Enum.PartType.Cylinder
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.2
	part.Size = Vector3.new(0.15, 2, 2)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	TweenService:Create(
		part,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.15, 14, 14), Transparency = 1 }
	):Play()
end

local function feet(root)
	return root.Position - Vector3.new(0, 2.8, 0)
end

local function inFront(root, distance, height)
	return root.Position + root.CFrame.LookVector * distance + Vector3.new(0, height, 0)
end

-- ---------------------------------------------------------------------------
-- Acciones y avisos
-- ---------------------------------------------------------------------------

local ACTION_EFFECTS = {
	craft = function(root) -- fabricar: chispas de latón y cian sobre el taller
		burst(inFront(root, 3, 1.5), BRASS, CYAN, 26, 9)
		flash(inFront(root, 3, 2), GOLD, 10, 0.6)
	end,
	sell = function(root) -- vender: monedas que suben
		burst(root.Position + Vector3.new(0, 1, 0), GOLD, BRASS, 14, 8, 6)
	end,
	openCapsule = function(root) -- abrir cápsula: destello y anillo
		burst(inFront(root, 2, 1), GOLD, CYAN, 22, 10)
		flash(inFront(root, 2, 1.5), GOLD, 12, 0.8)
		ring(feet(root), CYAN)
	end,
	claimDaily = function(root)
		burst(root.Position + Vector3.new(0, 2, 0), GOLD, IVORY, 16, 7, 4)
	end,
	buyUpgrade = function(root) -- mejoras: pequeño destello cian
		burst(root.Position, CYAN, IVORY, 10, 6, 4)
	end,
}
ACTION_EFFECTS.sellPart = ACTION_EFFECTS.sell
ACTION_EFFECTS.hatchEgg = ACTION_EFFECTS.openCapsule
ACTION_EFFECTS.claimLegacy = ACTION_EFFECTS.openCapsule
ACTION_EFFECTS.claimPlaytime = ACTION_EFFECTS.claimDaily
ACTION_EFFECTS.spinWheel = ACTION_EFFECTS.claimDaily
ACTION_EFFECTS.buyPlotUpgrade = ACTION_EFFECTS.buyUpgrade
ACTION_EFFECTS.buyCarryUpgrade = ACTION_EFFECTS.buyUpgrade

local SOUND_EFFECTS = {
	subir_nivel = function(root) -- subir de nivel: anillo cian y chispas doradas
		ring(feet(root), CYAN)
		burst(root.Position + Vector3.new(0, 1, 0), GOLD, CYAN, 20, 9, 4)
		flash(root.Position, CYAN, 12, 0.7)
	end,
	robar = function(root) -- recompensa robada
		burst(inFront(root, 2, 0.5), CYAN, IVORY, 10, 6)
	end,
	guardar_botin = function(root) -- botín a salvo en la base
		ring(feet(root), BRASS)
		burst(root.Position, GOLD, BRASS, 16, 8, 5)
	end,
	atrapado = function(root)
		burst(root.Position, RED, IVORY, 10, 7)
	end,
}

-- Ajuste «Efectos visuales» (ART-016). Con efectos desactivados solo queda un destello breve.
local effectsOn = true

local function finalFlash(root)
	flash(root.Position, GOLD, 8, 0.4)
end

local function run(effect, seconds)
	local root = getRoot()
	if not effect or not root or not acquire(seconds) then
		return
	end
	if not effectsOn then
		effect = finalFlash
	end
	local ok, problem = pcall(effect, root)
	if not ok then
		warn("[Vfx] efecto omitido: " .. tostring(problem))
	end
end

function Vfx.onAction(action, result)
	if type(result) == "table" and result.ok then
		run(ACTION_EFFECTS[action], 1.2)
	end
end

function Vfx.onSound(key)
	run(SOUND_EFFECTS[key], 1.2)
end

-- ---------------------------------------------------------------------------
-- Estela de carrera: mientras se lleva botín encima
-- ---------------------------------------------------------------------------

local function removeTrail()
	if trail then
		trail:Destroy()
		trail = nil
	end
end

local function addTrail(root)
	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, 1, 0)
	top.Parent = root
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -1, 0)
	bottom.Parent = root
	local effect = Instance.new("Trail")
	effect.Attachment0 = top
	effect.Attachment1 = bottom
	effect.Lifetime = 0.35
	effect.LightEmission = 0.5
	effect.Color = ColorSequence.new(CYAN, IVORY)
	effect.Transparency = NumberSequence.new(0.35, 1)
	effect.Name = "EstelaBotin"
	effect.Parent = root
	-- Se guardan juntos para borrarlos de una vez
	trail = {
		Destroy = function()
			effect:Destroy()
			top:Destroy()
			bottom:Destroy()
		end,
		root = root,
	}
end

function Vfx.onState(state)
	if type(state) ~= "table" then
		return
	end
	if type(state.settings) == "table" then
		effectsOn = state.settings.effects ~= 0
	end
	local root = getRoot()
	local carrying = (state.carriedCount or 0) > 0
	if carrying and root and effectsOn then
		if not trail or trail.root ~= root then
			removeTrail()
			addTrail(root)
		end
	else
		removeTrail()
	end
end

-- ---------------------------------------------------------------------------
-- Brillo por rareza en las piezas robables cercanas
-- ---------------------------------------------------------------------------

local glows = {} -- [pieza] = Highlight

local function clearGlow(item)
	if glows[item] then
		glows[item]:Destroy()
		glows[item] = nil
	end
end

local function updateGlows()
	local root = getRoot()
	local count = 0
	for item in glows do
		if not item.Parent then
			clearGlow(item)
		else
			count += 1
		end
	end
	for _, item in CollectionService:GetTagged("PiezaRobable") do
		local rarity = item:GetAttribute("Rarity")
		local near = effectsOn
			and root
			and item:IsA("BasePart")
			and (item.Position - root.Position).Magnitude <= GLOW_DISTANCE
		if rarity and not COMMON_RARITIES[rarity] and near then
			if not glows[item] and count < MAX_GLOWS then
				local highlight = Instance.new("Highlight")
				highlight.Name = "BrilloRareza"
				-- La pieza provisional queda invisible bajo el modelo: se resalta el modelo
				highlight.Adornee = item:FindFirstChildWhichIsA("Model") or item
				highlight.FillColor = GameData.RarityColors[rarity] or GOLD
				highlight.OutlineColor = GameData.RarityColors[rarity] or GOLD
				highlight.FillTransparency = 0.85
				highlight.OutlineTransparency = 0.2
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = item
				glows[item] = highlight
				count += 1
			end
		elseif glows[item] then
			clearGlow(item)
			count -= 1
		end
	end
end

-- ---------------------------------------------------------------------------
-- Carteles propios y aro de rareza en las vitrinas (ART-016)
-- ---------------------------------------------------------------------------

local RING_DROP = 3.15 -- del centro del reloj (y = 3,6 en el plot) a la base de la vitrina

local function addRarityRing(marker, rarity)
	local baseRing = Instance.new("Part")
	baseRing.Name = "AroRareza"
	baseRing.Shape = Enum.PartType.Cylinder
	baseRing.Material = Enum.Material.Neon
	baseRing.Color = GameData.RarityColors[rarity] or GOLD
	baseRing.Transparency = 0.35
	baseRing.Anchored = true
	baseRing.CanCollide = false
	baseRing.CanQuery = false
	baseRing.CanTouch = false
	baseRing.CastShadow = false
	baseRing.Size = Vector3.new(0.08, 2.8, 2.8)
	baseRing.CFrame = CFrame.new(marker.Position - Vector3.new(0, RING_DROP, 0)) * CFrame.Angles(0, 0, math.rad(90))
	baseRing.Parent = marker -- se borra con la vitrina cuando el servidor la redibuja
	-- Pulso suave en bucle (un solo tween por aro, sin RenderStepped)
	TweenService:Create(
		baseRing,
		TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.7 }
	):Play()
end

local function updateOwnership()
	local myId = player.UserId
	-- Vitrinas: cartel y aro solo en las propias
	for _, marker in CollectionService:GetTagged("RelojExhibido") do
		local mine = marker:GetAttribute("OwnerUserId") == myId
		local sign = marker:FindFirstChild("Cartel")
		if sign then
			sign.Enabled = mine
		end
		local existing = marker:FindFirstChild("AroRareza")
		if mine and not existing and marker:IsA("BasePart") then
			addRarityRing(marker, marker:GetAttribute("Rarity"))
		elseif not mine and existing then
			existing:Destroy()
		end
	end
	-- Mascotas: cada jugador ve solo los nombres de las suyas
	for _, other in Players:GetPlayers() do
		local pets = other.Character and other.Character:FindFirstChild("Mascotas")
		if pets then
			for _, gui in pets:GetDescendants() do
				if gui:IsA("BillboardGui") then
					gui.Enabled = other == player
				end
			end
		end
	end
end

function Vfx.init()
	task.spawn(function()
		while true do
			task.wait(0.5)
			local ok, problem = pcall(updateGlows)
			if not ok then
				warn("[Vfx] brillo omitido: " .. tostring(problem))
			end
			ok, problem = pcall(updateOwnership)
			if not ok then
				warn("[Vfx] carteles omitidos: " .. tostring(problem))
			end
		end
	end)
	player.CharacterAdded:Connect(removeTrail)
end

return Vfx
