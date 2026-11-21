# IDs de Roblox de los assets (ART-008 y ART-013)

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

## Arte de paleta, iconos y sonidos (ART-013)

> ✅ **Subido y montado el 2026-11-20 (ART-013, MacBook de Zadiel con el MCP de Studio).** 55 assets subidos con Open Cloud a la cuenta **zadiel799**, todos con moderación **Approved** (0 rechazados): 1 textura, 36 modelos, 8 iconos y 10 sonidos.

**Textura de paleta:** `tex_paleta` = **129172292521580** (Image). Va en el `TextureID` de los 36 MeshParts.

### Modelos de paleta (36), uno con un solo MeshPart

Medida en studs (ancho × alto × fondo), tomada del FBX con Blender y comprobada en Studio después de escalar (error ≤ 0,01).

| Grupo | Modelo | Asset ID | Medida | Triángulos | Escala |
|---|---|---|---|---|---|
| Plot | `mdl_plot_suelo` | 78357556491071 | 34,00 × 0,61 × 40,00 | 72 | 0,01953 |
| Plot | `mdl_taller` | 90410658738431 | 14,00 × 7,00 × 4,00 | 268 | 0,01 |
| Plot | `mdl_vitrina` | 120394604746418 | 2,20 × 2,70 × 2,20 | 48 | 0,01 |
| Plot | `mdl_panel_plot` | 71669807923796 | 4,00 × 4,40 × 1,47 | 36 | 0,01 |
| Plot | `mdl_caminadora` | 126244229180559 | 5,00 × 4,50 × 8,00 | 152 | 0,01 |
| Estaciones | `mdl_estacion_tienda` | 70980106624805 | 18,00 × 11,50 × 12,40 | 216 | 0,01 |
| Estaciones | `mdl_estacion_robux` | 93991858516146 | 18,00 × 11,50 × 12,78 | 136 | 0,01 |
| Estaciones | `mdl_estacion_criadero` | 107063510250577 | 18,00 × 11,50 × 12,40 | 444 | 0,01 |
| Estaciones | `mdl_estacion_cronometro` | 95118912882694 | 18,00 × 20,30 × 13,05 | 524 | 0,01 |
| Estaciones | `mdl_estacion_carga` | 128077277286957 | 18,00 × 11,50 × 12,40 | 156 | 0,01 |
| Muro | `mdl_muro_frontal` | 82721668197898 | 116,00 × 19,20 × 2,80 | 444 | 0,05664 |
| Muro | `mdl_cartel_salida` | 127197281207314 | 31,00 × 17,60 × 1,70 | 48 | 0,01514 |
| Muro | `mdl_puerta_velocidad_poste` | 136876326524920 | 2,40 × 42,20 × 2,40 | 132 | 0,02061 |
| Casas | `mdl_casa_z1` | 87578367101285 | 28,00 × 17,00 × 26,00 | 128 | 0,01367 |
| Casas | `mdl_casa_z2` | 127478311496252 | 28,00 × 18,00 × 26,00 | 140 | 0,01367 |
| Casas | `mdl_casa_z3` | 138306408647467 | 28,00 × 14,00 × 26,00 | 156 | 0,01367 |
| Casas | `mdl_casa_z4` | 88289117250668 | 28,00 × 14,00 × 28,00 | 228 | 0,01367 |
| Casas | `mdl_casa_z5` | 81967967878916 | 28,00 × 16,60 × 28,00 | 336 | 0,01367 |
| Casas | `mdl_pedestal` | 70424147336358 | 2,60 × 2,15 × 2,60 | 36 | 0,01 |
| Mascotas | `mdl_mascota_raton` | 114829888364928 | 0,88 × 1,28 × 2,19 | 388 | 0,01 |
| Mascotas | `mdl_mascota_gato` | 94567017287842 | 0,82 × 1,54 × 1,63 | 172 | 0,01 |
| Mascotas | `mdl_mascota_zorro` | 134202202267047 | 0,72 × 1,38 × 2,39 | 192 | 0,01 |
| Mascotas | `mdl_mascota_halcon` | 134760149576149 | 2,40 × 1,30 × 1,69 | 254 | 0,01 |
| Mascotas | `mdl_mascota_dragon` | 137540561074651 | 2,20 × 1,40 × 2,46 | 340 | 0,01 |
| Mascotas | `mdl_mascota_fenix` | 137752654641018 | 2,60 × 1,60 × 1,88 | 266 | 0,01 |
| Mascotas | `mdl_mascota_titan` | 104156018706785 | 1,60 × 1,77 × 0,62 | 96 | 0,01 |
| Mascotas | `mdl_mascota_senor_tiempo` | 85929616105447 | 1,18 × 1,90 × 1,00 | 450 | 0,01 |
| Mascotas | `mdl_mascota_suprema` | 89455696384592 | 2,00 × 1,38 × 1,02 | 274 | 0,01 |
| Ambiente | `mdl_arbol` | 137614089573209 | 6,24 × 10,60 × 6,08 | 92 | 0,01 |
| Ambiente | `mdl_arbusto` | 82176063343762 | 4,15 × 2,32 × 2,66 | 126 | 0,01 |
| Ambiente | `mdl_farola` | 74855617881365 | 1,21 × 9,80 × 2,70 | 100 | 0,01 |
| Ambiente | `mdl_banca` | 121834526473783 | 5,00 × 2,90 × 1,50 | 72 | 0,01 |
| Ambiente | `mdl_valla` | 101537379089158 | 8,00 × 3,40 × 0,84 | 114 | 0,01 |
| Ambiente | `mdl_roca` | 83623291975758 | 3,64 × 2,42 × 3,20 | 60 | 0,01 |
| Ambiente | `mdl_cartel_zona` | 108963012850807 | 5,30 × 7,47 × 0,65 | 36 | 0,01 |
| Ambiente | `mdl_caja_madera` | 70795912012932 | 2,74 × 2,30 × 2,06 | 48 | 0,01 |

**Escala distinta de ×0,01 en 9 modelos.** Studio limita un MeshPart a 2048 studs por eje. El FBX llega en centímetros, así que los modelos de más de 20,48 studs (suelo del plot, 5 casas, muro, cartel de salida y poste) llegan **reducidos de forma uniforme** hasta que caben en 2048. Las proporciones se conservan, pero el factor ya no es 0,01. El montaje escala cada modelo hasta su medida real del FBX.

Al insertarse llegan como **paquetes**. La escala, el anclaje y el `TextureID` solo están en la copia de la place: si se reinsertan desde el asset, hay que volver a montarlos.

### Iconos (Image) y sonidos (Audio)

| Icono | ID | | Sonido | ID |
|---|---|---|---|---|
| `ico_monedas` | 110143721253053 | | `sfx_robar` | 136358381895007 |
| `ico_velocidad` | 85592491428255 | | `sfx_alarma_dueno` | 101439249349776 |
| `ico_mochila` | 72587806417673 | | `sfx_atrapado` | 121771660127526 |
| `ico_premios` | 107634380113502 | | `sfx_guardar_botin` | 102296286128091 |
| `ico_ruleta` | 135014274216635 | | `sfx_comprar` | 127864647773254 |
| `ico_robux` | 130773426233365 | | `sfx_abrir_capsula` | 119271899636402 |
| `ico_ajustes` | 115724324517779 | | `sfx_ruleta` | 137255558095184 |
| `ico_carga` | 84558382393109 | | `sfx_subir_nivel` | 85030530372481 |
|  |  | | `sfx_entrenar` | 99286256408690 |
|  |  | | `sfx_boton` | 83644407334698 |

Los iconos y sonidos **no** están conectados al juego: hay que pegarlos en `Config.ICON_IDS` y `Config.SOUND_IDS` (tarea DEV-018 de Jhonn).

### Script de montaje de los modelos de paleta

Idempotente. No es código del juego (no va a `game/src`). Se ejecuta en la barra de comandos o con el MCP.

```lua
local PALETA = "rbxassetid://129172292521580"
local REAL = { -- ancho, alto y fondo en studs (FBX medido en Blender)
	mdl_plot_suelo={34.00,0.61,40.00}, mdl_taller={14.00,7.00,4.00}, mdl_vitrina={2.20,2.70,2.20}, mdl_panel_plot={4.00,4.40,1.47}, mdl_caminadora={5.00,4.50,8.00},
	mdl_estacion_tienda={18.00,11.50,12.40}, mdl_estacion_robux={18.00,11.50,12.78}, mdl_estacion_criadero={18.00,11.50,12.40}, mdl_estacion_cronometro={18.00,20.30,13.05}, mdl_estacion_carga={18.00,11.50,12.40},
	mdl_muro_frontal={116.00,19.20,2.80}, mdl_cartel_salida={31.00,17.60,1.70}, mdl_puerta_velocidad_poste={2.40,42.20,2.40},
	mdl_casa_z1={28.00,17.00,26.00}, mdl_casa_z2={28.00,18.00,26.00}, mdl_casa_z3={28.00,14.00,26.00}, mdl_casa_z4={28.00,14.00,28.00}, mdl_casa_z5={28.00,16.60,28.00}, mdl_pedestal={2.60,2.15,2.60},
	mdl_mascota_raton={0.88,1.28,2.19}, mdl_mascota_gato={0.82,1.54,1.63}, mdl_mascota_zorro={0.72,1.38,2.39}, mdl_mascota_halcon={2.40,1.30,1.69}, mdl_mascota_dragon={2.20,1.40,2.46}, mdl_mascota_fenix={2.60,1.60,1.88}, mdl_mascota_titan={1.60,1.77,0.62}, mdl_mascota_senor_tiempo={1.18,1.90,1.00}, mdl_mascota_suprema={2.00,1.38,1.02},
	mdl_arbol={6.24,10.60,6.08}, mdl_arbusto={4.15,2.32,2.66}, mdl_farola={1.21,9.80,2.70}, mdl_banca={5.00,2.90,1.50}, mdl_valla={8.00,3.40,0.84}, mdl_roca={3.64,2.42,3.20}, mdl_cartel_zona={5.30,7.47,0.65}, mdl_caja_madera={2.74,2.30,2.06},
}
for nombre, r in REAL do
	local m = game.ReplicatedStorage.Assets:FindFirstChild(nombre)
	if m then
		local _, s = m:GetBoundingBox()
		local actual, objetivo = math.max(s.X, s.Y, s.Z), math.max(r[1], r[2], r[3])
		if actual > objetivo * 1.5 then m:ScaleTo(m:GetScale() * objetivo / actual) end
		for _, p in m:GetDescendants() do
			if p:IsA("BasePart") then p.Anchored = true end
			if p:IsA("MeshPart") then p.TextureID = PALETA end
		end
	end
end
```

Resultado real en ART-013: 36 modelos, 36 MeshParts con paleta, 0 faltantes.
