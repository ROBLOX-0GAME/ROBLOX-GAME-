--[[
	Main — punto de entrada del cliente de BUILD A WATCH!
	Conecta los remotos del servidor con la interfaz.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Ui = require(script.Parent:WaitForChild("Ui"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild(Config.REMOTES.State)
local notifyRemote = remotes:WaitForChild(Config.REMOTES.Notify)
local openPanelRemote = remotes:WaitForChild(Config.REMOTES.OpenPanel)
local actionRemote = remotes:WaitForChild(Config.REMOTES.Action)

Ui.init(actionRemote)

stateRemote.OnClientEvent:Connect(function(state)
	Ui.setState(state)
end)

notifyRemote.OnClientEvent:Connect(function(text, kind)
	Ui.toast(text, kind)
end)

openPanelRemote.OnClientEvent:Connect(function(panelId)
	Ui.openPanel(panelId)
end)

Ui.toast("¡Bienvenido a BUILD A WATCH! Recoge cajas de piezas en la zona de arena.", "info")
