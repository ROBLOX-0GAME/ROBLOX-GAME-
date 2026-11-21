--[[
	MonetizationService — pases de juego y productos con Robux (DEV-006).

	Pases (compra única): al entrar se consulta a Roblox qué pases tiene el
	jugador; no se guardan en DataStore (Roblox es la fuente de verdad).
	Productos (compra repetible): ProcessReceipt entrega el producto, guarda
	el id de la compra en los datos del jugador y SOLO confirma a Roblox
	(PurchaseGranted) cuando los datos quedaron guardados. Si algo falla,
	devuelve NotProcessedYet y Roblox reintenta; el id guardado evita entregar
	dos veces.

	Los IDs están en Config.GAMEPASS_IDS / Config.PRODUCT_IDS. Mientras sean 0
	la compra responde «Próximamente».
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local GameData = require(Shared.GameData)
local PlayerLogic = require(Shared.PlayerLogic)
local CharacterService = require(script.Parent.CharacterService)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local PetService = require(script.Parent.PetService)
local MuseumService = require(script.Parent.MuseumService)

local MonetizationService = {}

local random = Random.new()
local passKeyById = {}
local productKeyById = {}
for key, id in Config.GAMEPASS_IDS do
	if id ~= 0 then
		passKeyById[id] = key
	end
end
for key, id in Config.PRODUCT_IDS do
	if id ~= 0 then
		productKeyById[id] = key
	end
end

local function refreshPlayer(player)
	local data = DataService.get(player)
	-- DEC-030: el cliente muestra la etiqueta [VIP] en el chat con este atributo
	player:SetAttribute("VIP", data ~= nil and PlayerLogic.hasPass(data, "vip"))
	CharacterService.apply(player)
	PetService.refresh(player)
	DataService.replicate(player)
end

local function ownsPass(player, passId)
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
		end)
		if ok then
			return result == true
		end
		warn(string.format("[Monetization] Error consultando pase %d de %s (intento %d): %s", passId, player.Name, attempt, tostring(result)))
		task.wait(1)
	end
	return false
end

-- Consulta todos los pases del jugador y los aplica.
local function syncPasses(player)
	local data = DataService.get(player)
	if not data then
		return
	end
	local owned = {}
	local testing = RunService:IsStudio() and Config.STUDIO_GRANT_ALL_PASSES
	for key, id in Config.GAMEPASS_IDS do
		if testing then
			owned[key] = true
		elseif id ~= 0 and ownsPass(player, id) then
			owned[key] = true
		end
	end
	-- Conserva pases comprados durante esta sesión aunque la consulta tarde.
	for key in data.passes do
		owned[key] = true
	end
	if not player.Parent then
		return
	end
	PlayerLogic.setPasses(data, owned)
	refreshPlayer(player)
	MuseumService.grantOffline(player) -- DEC-030: con los pases ya conocidos (tope VIP)
	if testing then
		Net.notify(player, "Modo de prueba: todos los pases activos (no se guardan).", "info")
	end
end

-- Acción del cliente: abrir la compra de un pase.
function MonetizationService.promptPass(player, data, passKey)
	local pass = GameData.GamePasses[passKey]
	if not pass then
		return false, "Ese pase no existe."
	end
	if PlayerLogic.hasPass(data, passKey) then
		return false, "Ya tienes el pase «" .. pass.name .. "»."
	end
	local id = Config.GAMEPASS_IDS[passKey]
	if not id or id == 0 then
		return false, "«" .. pass.name .. "» estará disponible próximamente."
	end
	MarketplaceService:PromptGamePassPurchase(player, id)
	return true, "Abriendo la compra de «" .. pass.name .. "»…"
end

-- Acción del cliente: abrir la compra de un producto.
function MonetizationService.promptProduct(player, productKey)
	local product = GameData.Products[productKey]
	if not product then
		return false, "Ese producto no existe."
	end
	local id = Config.PRODUCT_IDS[productKey]
	if not id or id == 0 then
		return false, "«" .. product.name .. "» estará disponible próximamente."
	end
	MarketplaceService:PromptProductPurchase(player, id)
	return true, "Abriendo la compra de «" .. product.name .. "»…"
end

local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local data = player and DataService.get(player)
	if not player or not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local productKey = productKeyById[receipt.ProductId]
	if not productKey then
		warn("[Monetization] Producto sin configurar:", receipt.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = tostring(receipt.PurchaseId)
	if PlayerLogic.hasReceipt(data, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- ya entregado antes
	end

	local ok, message = PlayerLogic.grantProduct(data, productKey, random:NextNumber())
	if not ok then
		warn("[Monetization] No se pudo entregar", productKey, message)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	PlayerLogic.addReceipt(data, purchaseId)
	if not DataService.saveNow(player) then
		-- No se confirmó el guardado: Roblox reintentará. El id ya está en
		-- memoria, así que el reintento en esta sesión no entrega dos veces.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Net.notify(player, message, "ok")
	refreshPlayer(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService.init()
	DataService.onLoaded(function(player)
		syncPasses(player)
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		local key = passKeyById[passId]
		local data = DataService.get(player)
		if not purchased or not key or not data then
			return
		end
		local owned = table.clone(data.passes)
		owned[key] = true
		PlayerLogic.setPasses(data, owned)
		Net.notify(player, "¡Gracias! Pase activado: " .. GameData.GamePasses[key].name, "ok")
		refreshPlayer(player)
	end)

	MarketplaceService.ProcessReceipt = processReceipt
end

return MonetizationService
