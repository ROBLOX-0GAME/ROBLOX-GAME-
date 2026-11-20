--[[
	RunTests — ejecuta los módulos *.spec de esta carpeta al pulsar Play en
	Studio (nunca en servidores publicados). Resultado en la ventana Output:
	  [Pruebas] N correctas, M fallidas
	Se desactiva con Config.RUN_TESTS_IN_STUDIO = false.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

if not RunService:IsStudio() or not Config.RUN_TESTS_IN_STUDIO then
	return
end

local passed, failed = 0, 0
local currentTest = ""

local function fail(message)
	error(message, 0)
end

local t = {}

function t.ok(condition, message)
	if not condition then
		fail("se esperaba verdadero: " .. tostring(message))
	end
end

function t.eq(actual, expected, message)
	if actual ~= expected then
		fail(string.format("%s — esperado %s, obtenido %s", tostring(message), tostring(expected), tostring(actual)))
	end
end

function t.test(name, fn)
	currentTest = name
	local success, err = pcall(fn)
	if success then
		passed += 1
	else
		failed += 1
		warn(string.format("[Pruebas] FALLA «%s»: %s", currentTest, tostring(err)))
	end
end

for _, child in script.Parent:GetChildren() do
	if child:IsA("ModuleScript") and string.sub(child.Name, -5) == ".spec" then
		local success, err = pcall(function()
			require(child)(t)
		end)
		if not success then
			failed += 1
			warn(string.format("[Pruebas] Error cargando %s: %s", child.Name, tostring(err)))
		end
	end
end

local summary = string.format("[Pruebas] %d correctas, %d fallidas", passed, failed)
if failed > 0 then
	warn(summary)
else
	print(summary)
end
