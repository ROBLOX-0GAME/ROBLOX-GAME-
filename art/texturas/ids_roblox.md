# IDs de Roblox de los mapas PBR (ART-008)

Place oficial: **84500108687089** («Reloj creation oficial 1», universo 10778093657).

Cada material tiene 4 mapas en `art/texturas/export/tex_<material>_{color,normal,rugosidad,metalico}.png`. Se suben **una vez** y aquí se apunta su **ID de imagen** (Asset Manager → clic derecho → *Copy Asset ID*), no el de un Decal. 0 = aún no subido.

| Material | color | normal | rugosidad | metalico |
|---|---|---|---|---|
| `metal_oro_pulido` | 0 | 0 | 0 | 0 |
| `metal_oro_cepillado` | 0 | 0 | 0 | 0 |
| `metal_acero` | 0 | 0 | 0 | 0 |
| `metal_laton` | 0 | 0 | 0 | 0 |
| `metal_plata` | 0 | 0 | 0 | 0 |
| `cristal_zafiro` | 0 | 0 | 0 | 0 |
| `esmalte_blanco` | 0 | 0 | 0 | 0 |
| `esmalte_negro` | 0 | 0 | 0 | 0 |
| `esmalte_azul` | 0 | 0 | 0 | 0 |
| `esmalte_cosmico` | 0 | 0 | 0 | 0 |
| `cuero_correa` | 0 | 0 | 0 | 0 |
| `gema_rubi` | 0 | 0 | 0 | 0 |
| `gema_diamante` | 0 | 0 | 0 | 0 |
| `gema_zafiro` | 0 | 0 | 0 | 0 |

## Modelos que llevan `SurfaceAppearance` (20)

- Relojes (ART-006): `mdl_reloj_bolsillo`, `_pulsera`, `_cronografo`, `_legado`, `_real`, `_millonario` → 31 MeshParts.
- Piezas robables (ART-009): `mdl_pieza_engranaje`, `_resorte`, `_tornillo`, `_cristal`, `_correa`, `_rubi`, `_diamante`.
- Legado (ART-009): `mdl_legado_espiral`, `_corona`, `_rotor`.
- Cápsulas (ART-009): `mdl_capsula_laton`, `_plata`, `_oro`, `_cosmica`.

Se importan con el **3D Importer** (unidad **Stud**) y se guardan en `ReplicatedStorage/Assets` con su nombre exacto. Cada uno llega como Model con un MeshPart por material, con el nombre del material.

## Script de montaje (barra de comandos de Studio)

No es código del juego (no va a `game/src`). Copia los números de la tabla en `IDS` y ejecútalo; también puede ejecutarlo Claude con el MCP de Studio.

```lua
local IDS = {
	-- material = { color, normal, rugosidad, metalico }
	metal_oro_pulido    = { 0, 0, 0, 0 },
	metal_oro_cepillado = { 0, 0, 0, 0 },
	metal_acero         = { 0, 0, 0, 0 },
	metal_laton         = { 0, 0, 0, 0 },
	metal_plata         = { 0, 0, 0, 0 },
	cristal_zafiro      = { 0, 0, 0, 0 },
	esmalte_blanco      = { 0, 0, 0, 0 },
	esmalte_negro       = { 0, 0, 0, 0 },
	esmalte_azul        = { 0, 0, 0, 0 },
	esmalte_cosmico     = { 0, 0, 0, 0 },
	cuero_correa        = { 0, 0, 0, 0 },
	gema_rubi           = { 0, 0, 0, 0 },
	gema_diamante       = { 0, 0, 0, 0 },
	gema_zafiro         = { 0, 0, 0, 0 },
}
local PREFIJOS = { "^mdl_reloj_", "^mdl_pieza_", "^mdl_legado_", "^mdl_capsula_" }
local function esPbr(nombre)
	for _, p in PREFIJOS do
		if nombre:match(p) then return true end
	end
	return false
end
local function id(n) return "rbxassetid://" .. n end
local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
local hechos, avisos = 0, {}
for _, modelo in assets:GetChildren() do
	if esPbr(modelo.Name) then
		for _, parte in modelo:GetDescendants() do
			if parte:IsA("MeshPart") then
				local m = IDS[parte.Name]
				if not m or m[1] == 0 then
					table.insert(avisos, modelo.Name .. "/" .. parte.Name)
				else
					local viejo = parte:FindFirstChildOfClass("SurfaceAppearance")
					if viejo then viejo:Destroy() end
					parte.TextureID = ""
					local sa = Instance.new("SurfaceAppearance")
					sa.ColorMap, sa.NormalMap, sa.RoughnessMap, sa.MetalnessMap = id(m[1]), id(m[2]), id(m[3]), id(m[4])
					sa.Parent = parte
					if parte.Name == "cristal_zafiro" then
						-- En los relojes el cristal deja ver la esfera; la pieza suelta tiene que verse
						parte.Transparency = modelo.Name == "mdl_pieza_cristal" and 0.3 or 0.85
					end
					hechos += 1
				end
			end
		end
	end
end
print(("SurfaceAppearance montados: %d"):format(hechos))
if #avisos > 0 then warn("Sin IDs o con otro nombre: " .. table.concat(avisos, ", ")) end
```

Hay que comprobar el contador y que no haya avisos. Esperado: **78 MeshParts** = relojes 31 + piezas 15 (5 + 1 + 2 + 2 + 3 + 1 + 1) + legado 11 (3 + 3 + 5) + cápsulas 21 (5 + 5 + 5 + 6), según las tablas de [[Pipeline-de-Arte]].
