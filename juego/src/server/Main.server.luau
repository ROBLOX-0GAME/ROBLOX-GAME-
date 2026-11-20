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

DataService.init()
WorldService.init()
HouseService.init()
CharacterService.init()
ActionService.init()
MuseumService.init()
DataService.start() -- al final: los demás servicios ya escuchan onLoaded

print("[BUILD A WATCH!] Servidor iniciado.")
