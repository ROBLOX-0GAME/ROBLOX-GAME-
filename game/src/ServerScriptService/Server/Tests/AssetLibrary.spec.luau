--[[
	Pruebas de AssetLibrary (DEV-014). Crean assets de prueba en memoria, sin
	tocar ReplicatedStorage/Assets. Las ejecuta Tests/RunTests al pulsar Play.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AssetLibrary = require(Shared.AssetLibrary)
local GameData = require(Shared.GameData)

return function(t)
	local function makeFolder()
		local folder = Instance.new("Folder")
		local model = Instance.new("Model")
		model.Name = "mdl_prueba"
		local part = Instance.new("Part")
		part.Size = Vector3.new(2, 1, 2)
		part.Anchored = true
		part.CanCollide = true
		part.CFrame = CFrame.new(100, 50, 100)
		part.Parent = model
		model.PrimaryPart = part
		model.Parent = folder
		return folder
	end

	local function makeTarget()
		local target = Instance.new("Part")
		target.Anchored = true
		target.Size = Vector3.new(4, 2, 4)
		target.CFrame = CFrame.new(10, 5, 10)
		return target
	end

	local function near(a, b)
		return math.abs(a - b) < 1e-3
	end

	t.test("DEV-014: dress pone el asset sobre la base de la pieza y la oculta", function()
		local folder, target = makeFolder(), makeTarget()
		local clone = AssetLibrary.dress(target, "mdl_prueba", { folder = folder })
		t.ok(clone ~= nil, "devuelve la copia")
		t.eq(target.Transparency, 1, "oculta la pieza provisional")
		t.ok(target.CanCollide, "la pieza conserva su colisión")
		local cframe, size = clone:GetBoundingBox()
		t.ok(near(cframe.Position.Y - size.Y / 2, 4), "base del asset = base de la pieza")
		t.ok(near(cframe.Position.X, 10) and near(cframe.Position.Z, 10), "centrado sobre la pieza")
		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				t.ok(not part.CanCollide and part.Anchored and not part.CanQuery, "el visual no choca ni se detecta")
			end
		end
		t.eq(clone.Parent, target, "la copia vive dentro de la pieza")
		t.eq(clone.Name, "Visual_mdl_prueba", "nombre de la copia")
		target:Destroy()
		folder:Destroy()
	end)

	t.test("DEV-014: sin asset no cambia nada", function()
		local folder, target = makeFolder(), makeTarget()
		t.eq(AssetLibrary.dress(target, "mdl_inexistente", { folder = folder }), nil, "devuelve nil")
		t.eq(target.Transparency, 0, "la pieza provisional sigue visible")
		t.eq(#target:GetChildren(), 0, "no añade nada")
		t.eq(AssetLibrary.dress(target, nil, { folder = folder }), nil, "nombre nil no falla")
		t.eq(AssetLibrary.place("mdl_inexistente", Vector3.zero, nil, nil, { folder = folder }), nil, "place sin asset devuelve nil")
		target:Destroy()
		folder:Destroy()
	end)

	t.test("DEV-014: orientación, ajuste GiroY y soldadura", function()
		local folder, target = makeFolder(), makeTarget()
		local facing = AssetLibrary.dress(target, "mdl_prueba", { folder = folder, facing = Vector3.new(1, 0, 0) })
		t.ok(near(facing:GetPivot().LookVector.X, 1), "mira hacia `facing`")

		local asset = folder:FindFirstChild("mdl_prueba")
		asset:SetAttribute("GiroY", 90)
		local turned = AssetLibrary.dress(makeTarget(), "mdl_prueba", { folder = folder })
		t.ok(near(math.abs(turned:GetPivot().LookVector.X), 1), "GiroY gira el asset 90°")
		asset:SetAttribute("GiroY", nil)

		local moving = makeTarget()
		local welded = AssetLibrary.dress(moving, "mdl_prueba", { folder = folder, weld = true })
		local part = welded:FindFirstChildWhichIsA("BasePart")
		t.ok(not part.Anchored, "soldado: no anclado")
		local weld = part:FindFirstChildOfClass("WeldConstraint")
		t.ok(weld ~= nil and weld.Part0 == moving, "soldado a la pieza que se mueve")

		local placed = AssetLibrary.place("mdl_prueba", Vector3.new(0, 0, 0), Vector3.new(0, 0, -1), nil, { folder = folder })
		local cframe, size = placed:GetBoundingBox()
		t.ok(near(cframe.Position.Y - size.Y / 2, 0), "place apoya la base en el suelo")
		folder:Destroy()
	end)

	t.test("DEV-014: cada elemento del juego tiene nombre de asset", function()
		for _, partId in GameData.PartOrder do
			if not GameData.Parts[partId].protected then
				t.ok(AssetLibrary.PART_ASSETS[partId] ~= nil, "pieza " .. partId)
			end
		end
		for _, watchId in GameData.WatchOrder do
			t.ok(AssetLibrary.WATCH_ASSETS[watchId] ~= nil, "reloj " .. watchId)
		end
		for _, petId in GameData.PetOrder do
			t.ok(AssetLibrary.PET_ASSETS[petId] ~= nil, "mascota " .. petId)
		end
		for _, piece in GameData.LegacyPieces do
			t.ok(AssetLibrary.LEGACY_ASSETS[piece.id] ~= nil, "legado " .. piece.id)
		end
		for _, stationId in { "shop", "robux", "pets", "boss", "carry" } do
			t.ok(AssetLibrary.STATION_ASSETS[stationId] ~= nil, "estación " .. stationId)
		end
	end)
end
