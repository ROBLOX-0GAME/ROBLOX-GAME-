--[[
	BossService — jefe cooperativo sin combate: el Cronómetro Maestro (DEV-004).

	Cada Config.BOSS_INTERVAL_SECONDS el Cronómetro de la base se avería.
	Durante Config.BOSS_DURATION_SECONDS todos los jugadores del servidor
	pueden entregarle piezas guardadas; cada rareza vale distintos puntos.
	  - Si llegan a la meta (BOSS_POINTS_PER_PLAYER × jugadores), cada
	    participante gana monedas según sus puntos.
	  - Si se acaba el tiempo, se devuelven las piezas a quien siga conectado.

	El estado se publica como atributos de la estación (los lee el cliente):
	BossActive, BossPoints, BossGoal, BossEndsAt, BossNextAt (tiempo de
	servidor) y el atributo BossPoints de cada jugador (su aporte).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)
local CharacterService = require(script.Parent.CharacterService)
local PetService = require(script.Parent.PetService)

local random = Random.new()

local BossService = {}

local station = nil
local smoke = nil
local clockHand = nil
local active = false
local points = 0
local goal = 0
local endsAt = 0
local nextAt = 0
local contributions = {} -- [Player] = { points = n, parts = { [partId] = n } }

local function now()
	return Workspace:GetServerTimeNow()
end

local function publish()
	station:SetAttribute("BossActive", active)
	station:SetAttribute("BossPoints", points)
	station:SetAttribute("BossGoal", goal)
	station:SetAttribute("BossEndsAt", endsAt)
	station:SetAttribute("BossNextAt", nextAt)
end

local function notifyAll(text, kind)
	for _, player in Players:GetPlayers() do
		Net.notify(player, text, kind)
	end
end

local function start()
	active = true
	points = 0
	goal = math.max(Config.BOSS_MIN_GOAL, Config.BOSS_POINTS_PER_PLAYER * #Players:GetPlayers())
	endsAt = now() + Config.BOSS_DURATION_SECONDS
	contributions = {}
	for _, player in Players:GetPlayers() do
		player:SetAttribute("BossPoints", 0)
	end
	smoke.Enabled = true
	publish()
	notifyAll(
		string.format(
			"¡El Cronómetro Maestro se averió! Entrégale piezas en la base: %d s para reunir %d puntos.",
			Config.BOSS_DURATION_SECONDS,
			goal
		),
		"info"
	)
end

local function finish(success)
	if not active then
		return -- ya terminó (p. ej. dos entregas alcanzaron la meta a la vez)
	end
	active = false
	nextAt = now() + Config.BOSS_INTERVAL_SECONDS
	smoke.Enabled = false

	for player, entry in contributions do
		local data = DataService.get(player)
		if player.Parent and data then
			if success then
				local coins = PlayerLogic.bossReward(entry.points)
				data.coins += coins
				data.stats.earned += coins
				Net.notify(
					player,
					string.format("¡Cronómetro reparado! Tu aporte: %d puntos → +%d monedas.", entry.points, coins),
					"ok"
				)
				-- Premio extra: huevo de mascota para quien aportó bastante (DEV-005)
				if entry.points >= Config.BOSS_EGG_MIN_POINTS then
					local petId = PlayerLogic.rollPet(Config.BOSS_EGG, random:NextNumber())
					local granted, message = PlayerLogic.grantPet(data, petId)
					Net.notify(player, "Premio del Cronómetro: " .. message, granted and "ok" or "error")
					if granted then
						CharacterService.apply(player)
						PetService.refresh(player)
					end
				end
			else
				local refunded = PlayerLogic.refundParts(data, entry.parts)
				Net.notify(player, string.format("No se logró repararlo. Te devolvimos %d piezas.", refunded), "error")
			end
			DataService.replicate(player)
		end
		player:SetAttribute("BossPoints", 0)
	end
	contributions = {}

	if success then
		notifyAll("¡El Cronómetro Maestro vuelve a funcionar gracias a todos!", "ok")
	else
		notifyAll("Se acabó el tiempo: el Cronómetro Maestro sigue averiado.", "error")
	end
	points = 0
	publish()
end

-- Llamado por ActionService (ya validó distancia a la estación).
function BossService.contribute(player, data, partId, amount)
	if not active then
		local wait = math.max(0, math.floor(nextAt - now()))
		return false, string.format("El Cronómetro funciona bien. Próxima avería en %d s.", wait)
	end
	local ok, message, gained = PlayerLogic.contributeParts(data, partId, amount)
	if not ok then
		return false, message
	end
	local entry = contributions[player]
	if not entry then
		entry = { points = 0, parts = {} }
		contributions[player] = entry
	end
	entry.points += gained
	entry.parts[partId] = (entry.parts[partId] or 0) + amount
	points += gained
	player:SetAttribute("BossPoints", entry.points)
	publish()
	if points >= goal then
		task.defer(finish, true)
	end
	return true, message
end

function BossService.init()
	station = WorldService.buildStation({
		id = "boss",
		title = "Cronómetro Maestro",
		action = "Entregar piezas",
		position = Vector3.new(-55, 0, -70),
		color = Color3.fromRGB(150, 110, 200),
	})

	-- Esfera del reloj sobre el mostrador
	local face = WorldService.makePart({
		Name = "Esfera",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1, 9, 9),
		CFrame = CFrame.new(station.Position + Vector3.new(0, 9, 0)) * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(245, 240, 225),
		Material = Enum.Material.SmoothPlastic,
	})
	face.Parent = station.Parent
	clockHand = WorldService.makePart({
		Name = "Aguja",
		Size = Vector3.new(0.4, 3.6, 0.4),
		Position = station.Position + Vector3.new(0, 10.6, 0.7),
		Color = Color3.fromRGB(30, 30, 35),
		CanCollide = false,
	})
	clockHand.Parent = station.Parent
	smoke = Instance.new("Smoke")
	smoke.Color = Color3.fromRGB(80, 80, 80)
	smoke.Size = 3
	smoke.RiseVelocity = 4
	smoke.Enabled = false
	smoke.Parent = face

	nextAt = now() + Config.BOSS_FIRST_DELAY_SECONDS
	publish()

	Players.PlayerRemoving:Connect(function(player)
		-- Quien se va pierde su aporte (sus piezas ya se guardaron sin ellas).
		contributions[player] = nil
	end)

	task.spawn(function()
		local angle = 0
		while true do
			task.wait(1)
			if active and now() >= endsAt then
				finish(false)
			elseif not active and now() >= nextAt then
				start()
			end
			-- La aguja gira solo cuando el reloj funciona.
			if not active then
				angle = (angle + 6) % 360
				clockHand.CFrame = CFrame.new(station.Position + Vector3.new(0, 9, 0.7))
					* CFrame.Angles(0, 0, math.rad(angle))
					* CFrame.new(0, 1.6, 0)
			end
		end
	end)
end

return BossService
