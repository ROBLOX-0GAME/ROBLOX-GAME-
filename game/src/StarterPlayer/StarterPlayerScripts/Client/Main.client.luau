--[[
	Main — punto de entrada del cliente de BUILD A WATCH!
	Conecta los remotos del servidor con la interfaz.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Ui = require(script.Parent:WaitForChild("Ui"))
local Intro = require(script.Parent:WaitForChild("Intro"))
local Vfx = require(script.Parent:WaitForChild("Vfx")) -- efectos solo en el cliente (ART-015)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotes:WaitForChild(Config.REMOTES.State)
local notifyRemote = remotes:WaitForChild(Config.REMOTES.Notify)
local openPanelRemote = remotes:WaitForChild(Config.REMOTES.OpenPanel)
local actionRemote = remotes:WaitForChild(Config.REMOTES.Action)
local soundRemote = remotes:WaitForChild(Config.REMOTES.Sound)

Ui.init(actionRemote)
Intro.init(Ui.request)
Ui.onReplayIntro(Intro.replay)
Vfx.init()
Ui.onAction(Vfx.onAction)

stateRemote.OnClientEvent:Connect(function(state)
	Ui.setState(state)
	Intro.onState(state) -- cinemática y pieza del legado la primera vez (DEV-011)
	Vfx.onState(state) -- estela mientras se lleva botín (ART-015)
end)

notifyRemote.OnClientEvent:Connect(function(text, kind)
	Ui.toast(text, kind)
end)

soundRemote.OnClientEvent:Connect(function(key)
	Ui.playSound(key)
	Vfx.onSound(key) -- subir de nivel, robar, guardar botín, atrapado (ART-015)
end)

openPanelRemote.OnClientEvent:Connect(function(panelId)
	Ui.openPanel(panelId)
end)
