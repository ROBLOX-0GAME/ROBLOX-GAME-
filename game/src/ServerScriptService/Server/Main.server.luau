--[[
	Main — punto de entrada del servidor de BUILD A WATCH!
	Inicia los servicios en orden. Cada servicio está en Server/Services.
]]

local Services = script.Parent:WaitForChild("Services")

local DataService = require(Services.DataService)
local WorldService = require(Services.WorldService)
local HouseService = require(Services.HouseService)
local CharacterService = require(Services.CharacterService)
local ActionService = require(Services.ActionService)
local MuseumService = require(Services.MuseumService)
local BossService = require(Services.BossService)
local PetService = require(Services.PetService)
local PlotService = require(Services.PlotService)
local TrainingService = require(Services.TrainingService)
local MonetizationService = require(Services.MonetizationService)
local RewardService = require(Services.RewardService)
local RaceService = require(Services.RaceService) -- DEC-029: reinicio de la zona cada 5 min

DataService.init()
WorldService.init()
HouseService.init()
CharacterService.init()
ActionService.init()
MuseumService.init()
BossService.init()
PetService.init()
PlotService.init()
TrainingService.init()
MonetizationService.init()
RewardService.init()
RaceService.init()
DataService.start() -- al final: los demás servicios ya escuchan onLoaded

print("[BUILD A WATCH!] Servidor iniciado.")
