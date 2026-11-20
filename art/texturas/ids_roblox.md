# IDs de Roblox de los assets PBR (ART-008)

Place oficial: **84500108687089** («Reloj creation oficial 1», universo **10778093657**, dueño Lubu465 / Jhonn).

> ✅ **Todo subido y montado (2026-11-20, ART-008, MacBook de Zadiel con el MCP de Studio).**
>
> - 20 modelos y 43 imágenes subidos con Open Cloud a la cuenta **zadiel799** (colaborador de Team Create). Todos con moderación **Approved**.
> - Insertados en `ReplicatedStorage/Assets`, con 78 `SurfaceAppearance` montados y la place guardada en Roblox (versión 9).
> - **No hace falta volver a subirlos** (ver el aviso de `art/PROMPT_SUBIDA_JHONN.md`).

Cada material tiene 4 mapas en `art/texturas/export/tex_<material>_{color,normal,rugosidad,metalico}.png`. Los IDs son **IDs de imagen** (no de Decal).

## Mapas por material

**Metálico:** los mapas `_metalico` son de un solo color. En los 5 metales son blancos e idénticos byte a byte, así que se subió **uno** (`tex_metalico_blanco`, **121756755964550**) y lo comparten. En los demás son negros: no se suben y el `SurfaceAppearance` va sin `MetalnessMap`, porque 0 ya es «no metálico». Por eso hay 43 imágenes y no 56.

| Material | color | normal | rugosidad | metalico |
|---|---|---|---|---|
| `metal_oro_pulido` | 140708891491313 | 78350027821314 | 100596153448526 | 121756755964550 |
| `metal_oro_cepillado` | 95377997889458 | 129488302562120 | 134936573960299 | 121756755964550 |
| `metal_acero` | 107987213102182 | 113581725399975 | 128154705523236 | 121756755964550 |
| `metal_laton` | 115900097026165 | 119617548734190 | 120356655222440 | 121756755964550 |
| `metal_plata` | 73984446013359 | 95875105046488 | 139968076454185 | 121756755964550 |
| `cristal_zafiro` | 124883275540432 | 132946180445312 | 83073597043265 | — |
| `esmalte_blanco` | 97063976235650 | 137773934482230 | 125231089101794 | — |
| `esmalte_negro` | 124617569798086 | 120246716874399 | 78085331976276 | — |
| `esmalte_azul` | 122227954222853 | 121149303807392 | 101997175491149 | — |
| `esmalte_cosmico` | 135680316977798 | 119960372170161 | 113458423958157 | — |
| `cuero_correa` | 115987793338398 | 104503020025322 | 109715036711722 | — |
| `gema_rubi` | 98544583465146 | 118995243729249 | 138502457088541 | — |
| `gema_diamante` | 112616112175434 | 94895534415329 | 139563592621522 | — |
| `gema_zafiro` | 129446461011714 | 78991913926779 | 109169999035958 | — |

El filtro de texto de Roblox cambió el **nombre visible** de los 3 mapas de `esmalte_negro` por «#####» (por la palabra «negro»). Las imágenes están aprobadas y los IDs funcionan; solo cambia el nombre en el Creator Dashboard.

## Modelos (20) — 78 MeshParts

| Modelo | Asset ID | MeshParts |
|---|---|---|
| `mdl_reloj_bolsillo` | 122744765011249 | 6 |
| `mdl_reloj_pulsera` | 99076422156779 | 4 |
| `mdl_reloj_cronografo` | 91123933333242 | 5 |
| `mdl_reloj_legado` | 87020639808181 | 7 |
| `mdl_reloj_real` | 92919798411998 | 5 |
| `mdl_reloj_millonario` | 132820626723326 | 4 |
| `mdl_pieza_engranaje` | 91226303531045 | 5 |
| `mdl_pieza_resorte` | 95737653753144 | 1 |
| `mdl_pieza_tornillo` | 122648049135891 | 2 |
| `mdl_pieza_cristal` | 136917614231841 | 2 |
| `mdl_pieza_correa` | 133426499522495 | 3 |
| `mdl_pieza_rubi` | 85975085072049 | 1 |
| `mdl_pieza_diamante` | 72128024010925 | 1 |
| `mdl_legado_espiral` | 127853470078445 | 3 |
| `mdl_legado_corona` | 108333111669826 | 3 |
| `mdl_legado_rotor` | 97630352378927 | 5 |
| `mdl_capsula_laton` | 75552677263161 | 5 |
| `mdl_capsula_plata` | 104656701437680 | 5 |
| `mdl_capsula_oro` | 107062303724030 | 5 |
| `mdl_capsula_cosmica` | 93830023070600 | 6 |

Al insertarse llegan como **paquetes** (`PackageLink` con el mismo ID). Los cambios de escala y `SurfaceAppearance` solo están en la copia de la place; si se reinsertan desde el asset, hay que volver a pasar el script.

## Cómo llegan del FBX (lo aprendido)

- **Escala ×100:** el FBX va en centímetros (1 unidad de Blender = 100 studs). Hay que aplicar `ScaleTo(0.01)`. Después las medidas coinciden con Blender: relojes ≈ 1,4–1,85 studs, piezas ≈ 1,4, cápsulas ≈ 2 × 3.
- **Nombres:** se conservan. Cada modelo es un Model con un MeshPart por material, con el nombre del material, sin anidar.
- **Orientación:** correcta. El frente (cristal) mira a −Z, el LookVector de `AssetLibrary`; no hace falta `GiroY`. No hay espejo (XII arriba, III a la derecha).
- **Anclaje:** las piezas llegan sin anclar; el script las ancla.
- **Texturas:** no vienen en el FBX (se exporta con `path_mode=STRIP`); las pone el script.

## Script de montaje (barra de comandos de Studio o MCP)

No es código del juego (no va a `game/src`). Es idempotente: se puede volver a ejecutar sin duplicar nada.

```lua
local METAL = 121756755964550 -- tex_metalico_blanco, compartido por los 5 metales
local IDS = { -- material = { color, normal, rugosidad, metalico (0 = sin mapa) }
	metal_oro_pulido    = { 140708891491313, 78350027821314,  100596153448526, METAL },
	metal_oro_cepillado = { 95377997889458,  129488302562120, 134936573960299, METAL },
	metal_acero         = { 107987213102182, 113581725399975, 128154705523236, METAL },
	metal_laton         = { 115900097026165, 119617548734190, 120356655222440, METAL },
	metal_plata         = { 73984446013359,  95875105046488,  139968076454185, METAL },
	cristal_zafiro      = { 124883275540432, 132946180445312, 83073597043265,  0 },
	esmalte_blanco      = { 97063976235650,  137773934482230, 125231089101794, 0 },
	esmalte_negro       = { 124617569798086, 120246716874399, 78085331976276,  0 },
	esmalte_azul        = { 122227954222853, 121149303807392, 101997175491149, 0 },
	esmalte_cosmico     = { 135680316977798, 119960372170161, 113458423958157, 0 },
	cuero_correa        = { 115987793338398, 104503020025322, 109715036711722, 0 },
	gema_rubi           = { 98544583465146,  118995243729249, 138502457088541, 0 },
	gema_diamante       = { 112616112175434, 94895534415329,  139563592621522, 0 },
	gema_zafiro         = { 129446461011714, 78991913926779,  109169999035958, 0 },
}
local PREFIJOS = { "^mdl_reloj_", "^mdl_pieza_", "^mdl_legado_", "^mdl_capsula_" }
local function esPbr(n) for _, p in PREFIJOS do if n:match(p) then return true end end return false end
local function id(n) return "rbxassetid://" .. n end
local hechos, avisos = 0, {}
for _, modelo in game:GetService("ReplicatedStorage"):WaitForChild("Assets"):GetChildren() do
	if esPbr(modelo.Name) then
		if modelo:GetScale() > 0.5 then modelo:ScaleTo(modelo:GetScale() * 0.01) end -- FBX en cm
		for _, parte in modelo:GetDescendants() do
			if parte:IsA("BasePart") then parte.Anchored = true end
			if parte:IsA("MeshPart") then
				local m = IDS[parte.Name]
				if not m then
					table.insert(avisos, modelo.Name .. "/" .. parte.Name)
				else
					local viejo = parte:FindFirstChildOfClass("SurfaceAppearance")
					if viejo then viejo:Destroy() end
					parte.TextureID = ""
					local sa = Instance.new("SurfaceAppearance")
					sa.ColorMap, sa.NormalMap, sa.RoughnessMap = id(m[1]), id(m[2]), id(m[3])
					if m[4] ~= 0 then sa.MetalnessMap = id(m[4]) end
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
print(("SurfaceAppearance montados: %d"):format(hechos)) -- esperado: 78
if #avisos > 0 then warn("Sin IDs o con otro nombre: " .. table.concat(avisos, ", ")) end
```

Resultado real en ART-008: **78 montados, 0 avisos**.
