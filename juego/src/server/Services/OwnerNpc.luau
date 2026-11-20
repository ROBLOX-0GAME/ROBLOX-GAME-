--[[
	OwnerNpc — crea al dueño de una casa: un personaje sencillo de bloques
	con Humanoid para poder caminar con MoveTo. Es provisional; la Cuenta B
	puede reemplazar el modelo conservando HumanoidRootPart y Humanoid.
]]

local OwnerNpc = {}

local function weld(part0, part1)
	local constraint = Instance.new("WeldConstraint")
	constraint.Part0 = part0
	constraint.Part1 = part1
	constraint.Parent = part0
end

local function block(name, size, color, cframe)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.CFrame = cframe
	part.CanCollide = false
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- Devuelve { model, humanoid, root }
function OwnerNpc.create(displayName, color, position, parent)
	local model = Instance.new("Model")
	model.Name = displayName

	local origin = CFrame.new(position + Vector3.new(0, 3, 0))

	local root = block("HumanoidRootPart", Vector3.new(2, 2, 1), color, origin)
	root.Transparency = 1
	root.CanCollide = true
	root.Massless = false
	root.Parent = model

	local torso = block("Torso", Vector3.new(2, 2, 1), color, origin)
	torso.Parent = model
	weld(root, torso)

	local head = block("Head", Vector3.new(1.4, 1.4, 1.4), Color3.fromRGB(245, 205, 160), origin * CFrame.new(0, 1.7, 0))
	head.Parent = model
	weld(root, head)

	for _, x in { -0.5, 0.5 } do
		local leg = block("Pierna", Vector3.new(0.9, 2, 0.9), Color3.fromRGB(50, 50, 70), origin * CFrame.new(x, -2, 0))
		leg.Parent = model
		weld(root, leg)
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = 3 -- sin piernas articuladas: flota a esta altura sobre el suelo
	humanoid.DisplayName = displayName
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.NameDisplayDistance = 80
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid.Parent = model

	model.PrimaryPart = root
	model.Parent = parent
	-- El servidor controla su física para que la persecución sea justa.
	root:SetNetworkOwner(nil)

	return { model = model, humanoid = humanoid, root = root }
end

return OwnerNpc
