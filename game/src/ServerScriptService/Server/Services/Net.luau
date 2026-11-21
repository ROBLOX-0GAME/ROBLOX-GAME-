--[[
	Net — crea los remotos en ReplicatedStorage.Remotes y ofrece ayudas.
	Se crean una sola vez, la primera vez que un servicio requiere este módulo.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Net = {}

local folder = Instance.new("Folder")
folder.Name = "Remotes"

local function create(className, name)
	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = folder
	return remote
end

Net.State = create("RemoteEvent", Config.REMOTES.State)
Net.Notify = create("RemoteEvent", Config.REMOTES.Notify)
Net.OpenPanel = create("RemoteEvent", Config.REMOTES.OpenPanel)
Net.Action = create("RemoteFunction", Config.REMOTES.Action)
Net.Sound = create("RemoteEvent", Config.REMOTES.Sound)
Net.Announce = create("RemoteEvent", Config.REMOTES.Announce) -- DEC-029

folder.Parent = ReplicatedStorage

-- kind: "info" | "ok" | "error"
function Net.notify(player, text, kind)
	Net.Notify:FireClient(player, text, kind or "info")
end

-- Aviso arriba para todo el servidor (DEC-029): pieza muy rara o reinicio de la zona.
-- info = { kind = "rarePart" | "race", ... }
function Net.announce(info)
	Net.Announce:FireAllClients(info)
end

-- Pide al cliente reproducir un efecto (clave de Config.SOUND_IDS). DEV-014.
function Net.sound(player, key)
	Net.Sound:FireClient(player, key)
end

return Net
