--[[
	Main — punto de entrada del cliente de BUILD A WATCH!
	Conecta los remotos del servidor con la interfaz.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Ui = require(script.Parent:WaitForChild("Ui"))
local Intro = require(script.Parent:WaitForChild("Intro"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild(Config.REMOTES.State)
local notifyRemote = remotes:WaitForChild(Config.REMOTES.Notify)
local openPanelRemote = remotes:WaitForChild(Config.REMOTES.OpenPanel)
local actionRemote = remotes:WaitForChild(Config.REMOTES.Action)

Ui.init(actionRemote)
Intro.init(Ui.request)

stateRemote.OnClientEvent:Connect(function(state)
	Ui.setState(state)
	Intro.onState(state) -- cinemática y pieza del legado la primera vez (DEV-011)
end)

notifyRemote.OnClientEvent:Connect(function(text, kind)
	Ui.toast(text, kind)
end)

openPanelRemote.OnClientEvent:Connect(function(panelId)
	Ui.openPanel(panelId)
end)

