--[[
	RaceService — reinicio de la zona de carreras cada 5 minutos (DEC-029).

	Ciclo (cifras en Config):
	  1. La zona está abierta RACE_RESET_SECONDS. Workspace guarda en el atributo
	     «RaceCloseAt» la hora del servidor (GetServerTimeNow) en que se cierra,
	     para que cada cliente muestre la cuenta atrás.
	  2. RACE_WARNING_SECONDS antes, aviso a todos («La zona se cierra en 30 s»).
	  3. Al cerrar: «RaceOpen» = false, todos los que estén fuera de la base vuelven
	     a la plaza (HouseService guarda su botín al llegar a la base), las puertas
	     se cierran en el cliente y se renuevan las piezas de todas las casas.
	  4. A los RACE_CLOSED_SECONDS se vuelve a abrir.

	Mientras está cerrada, quien salga de la base vuelve a la plaza.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Net = require(script.Parent.Net)
local WorldService = require(script.Parent.WorldService)
local HouseService = require(script.Parent.HouseService)

local RaceService = {}

local open = true
local random = Random.new()

function RaceService.isOpen()
	return open
end

local function getRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- Devuelve a la plaza a quien esté fuera de la base.
local function sendHome()
	local spawn = WorldService.SpawnPosition or Vector3.new(0, 3, -30)
	for _, player in Players:GetPlayers() do
		local root = getRoot(player)
		if root and not WorldService.isInHub(root.Position) then
			local offset = Vector3.new(random:NextNumber(-8, 8), 3, random:NextNumber(-8, 8))
			player.Character:PivotTo(CFrame.new(spawn + offset))
		end
	end
end

local function setOpen(value)
	open = value
	Workspace:SetAttribute("RaceOpen", value)
end

local function cycle()
	while true do
		setOpen(true)
		Workspace:SetAttribute("RaceCloseAt", Workspace:GetServerTimeNow() + Config.RACE_RESET_SECONDS)
		task.wait(Config.RACE_RESET_SECONDS - Config.RACE_WARNING_SECONDS)
		Net.announce({ kind = "race", phase = "warning", seconds = Config.RACE_WARNING_SECONDS })
		task.wait(Config.RACE_WARNING_SECONDS)

		setOpen(false)
		Net.announce({ kind = "race", phase = "closed", seconds = Config.RACE_CLOSED_SECONDS })
		sendHome()
		HouseService.resetAll()
		local closedUntil = os.clock() + Config.RACE_CLOSED_SECONDS
		while os.clock() < closedUntil do
			task.wait(0.5)
			sendHome() -- nadie sale mientras está cerrada
		end
		Net.announce({ kind = "race", phase = "open" })
	end
end

function RaceService.init()
	setOpen(true)
	task.spawn(cycle)
end

return RaceService
