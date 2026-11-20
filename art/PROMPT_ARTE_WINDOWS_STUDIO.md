# Prompt de traspaso — Relojes PBR en Studio y siguiente arte (PC Windows)

> Creado en ART-007 (2026-11-20) por Claude en la MacBook de Zadiel. **Cópialo completo en Claude Code** en la PC Windows que tiene Roblox Studio, con la bóveda abierta como carpeta de trabajo (abre Claude Code **en la raíz del repositorio**, no en la carpeta de usuario, para que funcione el control de reservas de `.claude/settings.json`).

---

Eres Claude Code de la **Cuenta A**, trabajando en la **PC Windows con Roblox Studio**. Sigues el arte de **BUILD A WATCH!** (juego de Roblox) donde lo dejó Zadiel desde su MacBook en **ART-006**: los 6 relojes ya tienen materiales PBR en el repositorio, pero **nadie los ha importado todavía en Studio** (la MacBook no tiene Studio).

## 1. Antes de nada: reglas del equipo

1. Comprueba que estás en la raíz de la bóveda (contiene `ACTIVE_TASKS.md`, `art/` y `game/`). Si no, pide la ruta. No inventes rutas.
2. Haz `git pull` y lee, en este orden:
   - `.claude/CLAUDE.md`, `AGENTS.md`, `OWNERS.md` y `ACTIVE_TASKS.md`
   - `09 - TAREAS Y DESARROLLO/Backlog.md` (ART-003 a ART-007 y DEV-014)
   - `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md` (DEC-009, DEC-016, DEC-017, **DEC-018** y DEC-019)
   - **`art/Pipeline-de-Arte.md`**, sobre todo §5 y la sección **«Materiales PBR de los relojes (ART-006, propuesta)»**
   - `09 - TAREAS Y DESARROLLO/Changelog.md` §21 (lo que se hizo de verdad en ART-006)
3. **Flujo (DEC-009):** directo en `main`, sin ramas ni Pull Requests. Antes de editar: `git pull`, comprueba que la ruta no esté reservada, registra la tarea en `Backlog.md`, añade su fila en `ACTIVE_TASKS.md` («En desarrollo»), haz commit y `git push` de la reserva y escribe el ID en `.claude/tarea-activa`. `git pull` + commit + `git push` después de cada avance. Al terminar, fila en «Completada». Nunca force push ni descartes cambios ajenos.
4. **Propiedad:** el arte es de la **Cuenta B (Michael y Einell)**. Anótalos como revisores y deja como **propuesta** cualquier cambio de estilo.
5. **No toques `game/src`.** El arte entra solo por `ReplicatedStorage/Assets` y `AssetLibrary` (DEC-017). Si hace falta código, pídelo como tarea aparte.
6. **No inventes un placeId** ni digas que guardaste o publicaste la place si no lo hiciste. No publiques el juego desde Claude.
7. **Sin marcas reales.** Escribe en español. No guardes secretos (los IDs de assets de Roblox no son secretos; las cookies y claves de API sí). No declares pruebas que no hayas ejecutado.

## 2. Verifica la PC (pide permiso antes de instalar)

Ejecuta y muestra el resultado:

```powershell
git --version; python --version
& "C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --version | Select-Object -First 1
Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "material_maker*" -Directory
Get-ChildItem "$env:LOCALAPPDATA\Roblox\Versions" -ErrorAction SilentlyContinue | Select-Object -First 3
```

- Se necesitan: Roblox Studio, Blender 5.3, Material Maker 1.8 (portable en el Escritorio), Krita y Audacity 4. Según el Pipeline ya estaban en esta PC; confírmalo.
- `materiales_pbr.py` busca Material Maker en `Escritorio\material_maker*\material_maker.exe`. Si el ejecutable tiene otro nombre o está en otro sitio, usa la variable `MATERIAL_MAKER`:
  `$env:MATERIAL_MAKER = "C:\ruta\a\material_maker.exe"`
- Si tienes conectado el **MCP de Roblox Studio**, lista sus skills (`list_roblox_skills`) y carga la que corresponda antes de usarlo. Puede ayudarte a ejecutar Luau en Studio y comprobar el árbol, pero **confirma con la persona** antes de modificar la place.

## 3. Tarea 1 (abre ART-008): importar los relojes PBR en Studio

**Requisito:** la **place oficial publicada** (ver el aviso de §5 del Pipeline). Si aún no existe, detente y pide a la persona que la cree y la publique; no la sustituyas por `Proyecto Roblox Studio.rbxl` sin preguntar.

Reserva por ejemplo: `art/texturas/ids_roblox.md`, `art/Pipeline-de-Arte.md`, `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md`, `09 - TAREAS Y DESARROLLO/Changelog.md` y `09 - TAREAS Y DESARROLLO/Backlog.md`.

1. **Importar modelos.** En Studio: **3D Importer** → `art/export/modelos/mdl_reloj_<nombre>.fbx` (bolsillo, pulsera, cronografo, legado, real, millonario) → unidad **Stud**. Cada uno debe llegar como **Model** con un MeshPart por material, con el nombre del material (`metal_oro_pulido`, `cristal_zafiro`, `gema_rubi`…). Si el importador cambia los nombres o anida las piezas, anótalo y ajusta el paso 3. Guarda cada Model en **`ReplicatedStorage/Assets`** con su nombre exacto (`mdl_reloj_bolsillo`…). Si ya había una versión antigua (de paleta), sustitúyela.
2. **Subir texturas.** Con el **Asset Manager** (o *Bulk Import*), sube los 44 mapas `art/texturas/export/tex_<material>_{color,normal,rugosidad,metalico}.png` de los 11 materiales. Usa el **ID de imagen** (Asset Manager → clic derecho → *Copy Asset ID*), no el de un Decal. Apunta todos los IDs en un archivo nuevo **`art/texturas/ids_roblox.md`** (tabla material → 4 IDs) para no volver a subirlos.
3. **Montar `SurfaceAppearance`.** Pega los IDs en esta tabla y ejecuta el script en la **barra de comandos** de Studio (no es código del juego; no va a `game/src`):

   ```lua
   -- Rellena con los IDs de imagen (solo el número)
   local IDS = {
       metal_oro_pulido    = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       metal_oro_cepillado = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       metal_acero         = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       cristal_zafiro      = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       esmalte_blanco      = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       esmalte_negro       = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       esmalte_azul        = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       cuero_correa        = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       gema_rubi           = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       gema_diamante       = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
       gema_zafiro         = { color = 0, normal = 0, rugosidad = 0, metalico = 0 },
   }
   local function id(n) return "rbxassetid://" .. n end
   local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
   local hechos, avisos = 0, {}
   for _, modelo in assets:GetChildren() do
       if modelo.Name:match("^mdl_reloj_") then
           for _, parte in modelo:GetDescendants() do
               if parte:IsA("MeshPart") then
                   local m = IDS[parte.Name]
                   if not m or m.color == 0 then
                       table.insert(avisos, modelo.Name .. "/" .. parte.Name)
                   else
                       local viejo = parte:FindFirstChildOfClass("SurfaceAppearance")
                       if viejo then viejo:Destroy() end
                       parte.TextureID = ""
                       local sa = Instance.new("SurfaceAppearance")
                       sa.ColorMap, sa.NormalMap = id(m.color), id(m.normal)
                       sa.RoughnessMap, sa.MetalnessMap = id(m.rugosidad), id(m.metalico)
                       sa.Parent = parte
                       if parte.Name == "cristal_zafiro" then parte.Transparency = 0.85 end
                       hechos += 1
                   end
               end
           end
       end
   end
   print(("SurfaceAppearance montados: %d"):format(hechos))
   if #avisos > 0 then warn("Sin IDs o con otro nombre: " .. table.concat(avisos, ", ")) end
   ```

   Comprueba el contador (deben salir todas las piezas: 6 + 4 + 5 + 7 + 5 + 4 = **31 MeshParts**) y que no haya avisos.
4. **Probar en Play** (prueba real, no la declares si no la haces):
   - Los relojes aparecen en las vitrinas del plot en lugar de los marcadores provisionales (`AssetLibrary`).
   - El frente mira hacia el jugador. Si sale girado, añade al Model el atributo numérico **`GiroY`** (por ejemplo 180), sin tocar código.
   - Se ven los metales, el cristal deja ver la esfera y el tamaño encaja (≈ 1,4 studs).
   - Haz capturas y guárdalas en `art/export/vistas/studio_<reloj>.png` si es posible.
5. **Guarda la place** (solo si la persona lo confirma) y anota en el Changelog exactamente qué se hizo y qué se probó.

## 4. Tarea 2 (solo si DEC-018 está aprobada): PBR para piezas robables, legado y cápsulas

Mira en el Registro de Decisiones si **DEC-018** está **Aprobada** por Michael y Einell. **Si sigue como Propuesta, no hagas esta parte**: pasa a la §5 y déjalo anotado.

Si está aprobada, abre otra tarea (por ejemplo ART-009) y reserva `art/**` más la documentación:

1. **Materiales nuevos** en el diccionario `MATERIALES` de `art/blender/scripts/materiales_pbr.py`, con el mismo formato. Propuesta: `metal_laton` (cápsula de latón), `metal_plata`, `metal_cosmico` u `esmalte_cosmico` (cápsula Cósmica, morado/cian), `resorte_acero` si hace falta otro acabado, y lo que pidan las piezas del legado (espiral, corona, rotor). Reutiliza los 11 existentes siempre que se pueda.
   ```powershell
   & "C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/materiales_pbr.py
   ```
   Si alguien retocó a mano un `.ptex`, usa `-- sin_ptex` para no sobrescribirlo.
2. **Script nuevo** `art/blender/scripts/piezas_detalladas.py` que reutilice las funciones de `relojes_detallados.py` (`material_pbr`, `unir_por_material`, `gema`, `exportar`…). Muévelas a un módulo común solo si no rompe los relojes, y vuelve a generarlos para comprobarlo.
   - **Piezas robables:** `mdl_pieza_engranaje`, `_resorte`, `_tornillo`, `_cristal`, `_correa`, `_rubi`, `_diamante` (≈ 1,4 studs). Objetivo: **menos de 1.000 triángulos** cada una.
   - **Pieza del legado:** `mdl_legado_espiral`, `_corona`, `_rotor`.
   - **Cápsulas:** `mdl_capsula_laton`, `_plata`, `_oro`, `_cosmica` (≈ 2 × 3 studs).
   - **Mismos nombres, medidas, origen en la base y frente hacia −Y** que los modelos base de `modelos_prioridad1.py` y `modelos_prioridad2.py`, para no tocar código.
   - Haz que `generar_todo.py` no los sobrescriba (como ya hace con `mdl_reloj_`).
3. Vistas con `vista_previa.py` (EEVEE para los `.blend` con `render_pbr`) y **revísalas de verdad** antes de subir. Importa en Studio y monta los `SurfaceAppearance` igual que en la §3, ampliando el filtro del script.
4. Documenta en el Pipeline (tabla de materiales y de triángulos), Changelog, memoria del área 12 y Backlog.

## 5. Tarea 3: retocar iconos (Krita) y sonidos (Audacity)

Abre otra tarea (por ejemplo ART-010). Esto **no depende** de DEC-018.

- **Iconos del HUD** (`art/texturas/export/ico_*.png`, 256×256 con transparencia; los generó `iconos.py`): monedas, velocidad, mochila, premios, ruleta, robux, ajustes y carga.
  - Ábrelos en Krita, mejora contorno, brillo y legibilidad a tamaño pequeño, y guarda la fuente `.kra` en `art/texturas/fuentes/` y el PNG exportado con el **mismo nombre**.
  - El de Robux debe ser un dibujo **original**, no el logotipo oficial.
  - Claude no puede pintar en Krita: propón los cambios, deja que la persona los haga y revisa el resultado. Si hace falta, puede ajustar `iconos.py` y regenerarlos.
- **Sonidos** (`art/audio/export/sfx_*.ogg`, sintetizados por `art/audio/sonidos.py`): pule en Audacity (normalizar, recortar silencios, fundidos, menos de 2 s; `sfx_entrenar` en bucle de 1 s).
  - Guarda los proyectos `.aup3` en `art/audio/fuentes/` y exporta OGG con el mismo nombre.
  - Comprueba la duración de cada uno con un script y súbelos en Studio. Pega sus IDs en `Config.SOUND_IDS` **solo** dentro de una tarea de código que reserve `game/src` (pídela aparte).
- **Música** (`mus_base`, `mus_persecucion`): sigue pendiente. Hecha a mano o con licencia registrada en `art/referencias/` y en [[Recursos-y-Referencias]]; no se sintetiza.

## 6. Informe al terminar cada tarea

Resume:
- qué se hizo y qué archivos se tocaron;
- comprobaciones ejecutadas de verdad: importación, contador de `SurfaceAppearance`, prueba en Play, triángulos y vistas revisadas;
- commits subidos y si la place se guardó;
- propuestas pendientes de aprobar (DEC-018, DEC-019) y el siguiente paso.

Después marca la reserva como **Completada** y súbela.
