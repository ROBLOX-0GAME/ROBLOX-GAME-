--[[
	AssetLibrary — usa los modelos de arte cuando existen (DEV-014).

	Los modelos se importan en Studio desde art/export/modelos y se guardan en
	ReplicatedStorage/Assets con su nombre (mdl_caminadora, mdl_casa_z1…).
	Las piezas provisionales siguen haciendo el trabajo (colisiones, avisos,
	lógica). Si existe el modelo, `dress` coloca una copia encima y oculta la
	pieza provisional. Si no existe, no hace nada: el juego nunca se rompe por
	un asset que falte.

	Convención: el FRENTE del asset en Studio mira hacia su LookVector (-Z).
	Si al importar quedó girado, pon en el asset el atributo GiroY (grados).

	Funciona en servidor y en cliente (la pieza del legado la viste el cliente).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetLibrary = {}

AssetLibrary.FOLDER_NAME = "Assets"

-- Nombre del asset de cada elemento del juego
AssetLibrary.PART_ASSETS = {
	gear = "mdl_pieza_engranaje",
	spring = "mdl_pieza_resorte",
	screw = "mdl_pieza_tornillo",
	crystal = "mdl_pieza_cristal",
	strap = "mdl_pieza_correa",
	ruby = "mdl_pieza_rubi",
	diamond = "mdl_pieza_diamante",
}
AssetLibrary.WATCH_ASSETS = {
	pocket = "mdl_reloj_bolsillo",
	wrist = "mdl_reloj_pulsera",
	chrono = "mdl_reloj_cronografo",
	legacy = "mdl_reloj_legado",
	royal = "mdl_reloj_real",
	millionaire = "mdl_reloj_millonario",
	-- DEV-026: 12 relojes de lujo, uno exclusivo por zona (arte ART-018)
	lunamaster = "mdl_reloj_lunamaster",
	santo = "mdl_reloj_santo",
	reverso = "mdl_reloj_reverso",
	daytona = "mdl_reloj_daytona",
	overseas = "mdl_reloj_overseas",
	nautil = "mdl_reloj_nautil",
	roblereal = "mdl_reloj_roblereal",
	bigbang = "mdl_reloj_bigbang",
	rm11 = "mdl_reloj_rm11",
	tourbillon = "mdl_reloj_tourbillon",
	granmaestro = "mdl_reloj_granmaestro",
	astronomia = "mdl_reloj_astronomia",
}
AssetLibrary.PET_ASSETS = {
	mouse = "mdl_mascota_raton",
	cat = "mdl_mascota_gato",
	fox = "mdl_mascota_zorro",
	hawk = "mdl_mascota_halcon",
	dragon = "mdl_mascota_dragon",
	phoenix = "mdl_mascota_fenix",
	titan = "mdl_mascota_titan",
	chronolord = "mdl_mascota_senor_tiempo",
	supreme = "mdl_mascota_suprema",
}
AssetLibrary.STATION_ASSETS = {
	shop = "mdl_estacion_tienda",
	robux = "mdl_estacion_robux",
	pets = "mdl_estacion_criadero",
	boss = "mdl_estacion_cronometro",
	carry = "mdl_estacion_carga",
}
AssetLibrary.LEGACY_ASSETS = {
	celestial = "mdl_legado_espiral",
	sapphire = "mdl_legado_corona",
	rainbow = "mdl_legado_rotor",
}

function AssetLibrary.folder()
	return ReplicatedStorage:FindFirstChild(AssetLibrary.FOLDER_NAME)
end

-- Devuelve el asset o nil. `folder` permite usar otra carpeta (pruebas).
function AssetLibrary.find(name, folder)
	folder = folder or AssetLibrary.folder()
	if not folder or type(name) ~= "string" then
		return nil
	end
	return folder:FindFirstChild(name)
end

local function bounds(instance)
	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end
	return instance:GetBoundingBox()
end

local function eachPart(instance, callback)
	if instance:IsA("BasePart") then
		callback(instance)
	end
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			callback(descendant)
		end
	end
end

--[[
	Coloca una copia del asset `name` sobre `target` (BasePart o Model).
	options:
	  folder   carpeta de assets (por defecto ReplicatedStorage/Assets)
	  parent   dónde poner la copia (por defecto, dentro de target)
	  facing   Vector3: dirección hacia la que debe mirar el frente del asset
	  weld     true si target se mueve (mascotas, pieza animada): suelda la copia
	  hide     false para no ocultar la pieza provisional
	Devuelve la copia o nil si el asset no existe.
]]
function AssetLibrary.dress(target, name, options)
	options = options or {}
	local asset = AssetLibrary.find(name, options.folder)
	if not asset or not target then
		return nil
	end
	local clone = asset:Clone()
	clone.Name = "Visual_" .. name

	local targetCFrame, targetSize = bounds(target)
	local bottom = targetCFrame.Position - Vector3.new(0, targetSize.Y / 2, 0)
	-- Orientación: la del objetivo, o hacia `facing`, más el ajuste GiroY del asset
	local orientation = targetCFrame - targetCFrame.Position
	if options.facing and options.facing.Magnitude > 0 then
		orientation = CFrame.lookAt(Vector3.zero, Vector3.new(options.facing.X, 0, options.facing.Z))
	end
	local giro = asset:GetAttribute("GiroY")
	if type(giro) == "number" then
		orientation *= CFrame.Angles(0, math.rad(giro), 0)
	end
	clone:PivotTo(CFrame.new(bottom) * orientation)
	-- Ajuste fino: base del asset sobre la base del objetivo y centrado en XZ
	local cloneCFrame, cloneSize = bounds(clone)
	local cloneBottom = cloneCFrame.Position - Vector3.new(0, cloneSize.Y / 2, 0)
	clone:PivotTo(clone:GetPivot() + (bottom - cloneBottom))

	eachPart(clone, function(part)
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.Anchored = not options.weld
	end)
	if options.weld and target:IsA("BasePart") then
		eachPart(clone, function(part)
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = target
			weld.Part1 = part
			weld.Parent = part
		end)
	end
	if options.hide ~= false then
		eachPart(target, function(part)
			part.Transparency = 1
		end)
	end
	clone.Parent = options.parent or target
	return clone
end

-- Coloca un asset de decoración (sin pieza provisional) con su base en `position`.
-- Devuelve la copia o nil si el asset no existe.
function AssetLibrary.place(name, position, facing, parent, options)
	options = options or {}
	local asset = AssetLibrary.find(name, options.folder)
	if not asset then
		return nil
	end
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.CFrame = CFrame.new(position + Vector3.new(0, 0.5, 0))
	local clone = AssetLibrary.dress(anchor, name, { folder = options.folder, facing = facing, parent = parent })
	-- Sin `parent`, dress deja la copia dentro del ancla: hay que sacarla antes de destruir el ancla (DEV-015)
	if clone and clone.Parent == anchor then
		clone.Parent = nil
	end
	anchor:Destroy()
	return clone
end

return AssetLibrary
