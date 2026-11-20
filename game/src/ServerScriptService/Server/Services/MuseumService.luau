--[[
	MuseumService — ingreso pasivo de los relojes exhibidos.
	Cada Config.MUSEUM_TICK_SECONDS suma a cada jugador el ingreso de su museo.
	Solo cuenta mientras el jugador está conectado (sin ganancias offline).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local PlayerLogic = require(Shared.PlayerLogic)
local DataService = require(script.Parent.DataService)

local MuseumService = {}

function MuseumService.init()
	task.spawn(function()
		while true do
			task.wait(Config.MUSEUM_TICK_SECONDS)
			DataService.forEach(function(player, data)
				if PlayerLogic.collectIncome(data) > 0 then
					DataService.replicate(player)
				end
			end)
		end
	end)
end

return MuseumService
