# Prompt de traspaso — Arte y materiales de los relojes (MacBook de Zadiel)

> Creado en ART-005 (2026-11-20) por Claude 1 en la PC de Jhonn. **Cópialo completo en Claude Code** desde la MacBook, con la bóveda abierta como carpeta de trabajo.

---

Eres Claude Code de la **Cuenta A**, trabajando en la **MacBook de Zadiel**. Zadiel continúa la parte artística de **BUILD A WATCH!** (juego de Roblox): **diseño y creación de los materiales de los relojes** con Blender, Krita, Material Maker y Audacity. Antes la llevaba Jhonn desde su PC con Windows.

## 1. Antes de nada: lee y respeta las reglas del equipo

1. Comprueba que estás en la carpeta de la bóveda (la que contiene `ACTIVE_TASKS.md`, `art/` y `game/`). Si no, pídele a Zadiel la ruta. No inventes rutas.
2. Lee, en este orden:
   - `.claude/CLAUDE.md`
   - `AGENTS.md`
   - `ACTIVE_TASKS.md`
   - `09 - TAREAS Y DESARROLLO/Backlog.md` (secciones ART-001 a ART-005 y DEV-014)
   - `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md` (DEC-009, DEC-016 y DEC-017)
   - **`art/Pipeline-de-Arte.md`** (el documento principal de esta área)
   - `art/README.md`
3. **Flujo vigente (DEC-009):** se trabaja **directo en `main`**, sin ramas ni Pull Requests.
   - Antes de editar: `git pull`, comprueba que la ruta no esté reservada por otra tarea, registra la tarea en `Backlog.md` (sección al final), añade su fila en `ACTIVE_TASKS.md` con estado «En desarrollo» y haz `git push` de la reserva.
   - Escribe el ID de la tarea en `.claude/tarea-activa` (archivo local).
   - Haz `git pull` + commit + `git push` después de cada avance, y deja la fila en «Completada» al terminar.
   - Nunca uses force push ni descartes cambios ajenos. Obsidian Git sincroniza cada 5 minutos.
4. **Propiedad:** según `OWNERS.md`, el arte y la dirección visual son de la **Cuenta B (Michael y Einell)**. Zadiel la cubre de forma temporal: anota a Michael y Einell como revisores y no cambies decisiones de estilo sin dejarlas como **propuesta**.
5. **No toques `game/src`** (código del juego). El arte se conecta solo a través de `ReplicatedStorage/Assets` y `AssetLibrary` (DEC-017). Si hace falta código, pídelo como tarea aparte.
6. **Sin marcas reales:** nada de logotipos ni nombres de relojerías reales (Patek Philippe, Rolex, Graff…). Solo diseños ficticios «inspirados en» la alta relojería.
7. Escribe en español. No guardes secretos. No declares pruebas que no hayas ejecutado.

## 2. Verifica las herramientas de la Mac (y pide permiso antes de instalar)

Ejecuta y muestra el resultado a Zadiel:

```bash
sw_vers; uname -m
ls /Applications | grep -i -E "blender|krita|audacity|material"
which git python3 brew
/Applications/Blender.app/Contents/MacOS/Blender --version 2>/dev/null | head -1
```

Lo que se necesita:

| Herramienta | Para qué | Cómo instalar en macOS |
|---|---|---|
| Blender (4.4 o superior; en Windows se usa la 5.3) | Modelos, exportar FBX, scripts del pipeline | `brew install --cask blender` o blender.org |
| Krita | Pintar texturas, iconos y la paleta | `brew install --cask krita` o krita.org |
| Material Maker (1.8 o superior) | Materiales procedurales de los relojes (metal, cristal, cuero, esmalte) | Descarga la versión de macOS en https://rodzill4.itch.io/material-maker o en las *releases* de GitHub `RodZill4/material-maker` y muévela a `/Applications` |
| Audacity | Pulir los efectos de `art/audio` | `brew install --cask audacity` |
| git y python3 | Repositorio y `art/audio/sonidos.py` | `xcode-select --install` |

- Si falta Homebrew o alguna herramienta, **explica qué vas a instalar y pide confirmación a Zadiel** antes de ejecutar nada (pide contraseña de administrador).
- La primera vez que se abra una app descargada, macOS puede bloquearla: ábrela con clic derecho → **Abrir**.
- Si el Mac es Apple Silicon (`arm64`), descarga las versiones para Apple Silicon.
- **Esto cambia una decisión anterior:** `Arquitectura-General.md` decía que la MacBook era solo para Obsidian y tareas escolares. Regístralo en el Registro de Decisiones como **propuesta**: «MacBook también para arte, sin Roblox Studio».

## 3. Comprueba que el pipeline funciona en la Mac

Los scripts son Python y usan rutas relativas, así que deberían funcionar igual. Desde la raíz del repositorio:

```bash
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/generar_todo.py -- mdl_reloj_bolsillo
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/vista_previa.py -- mdl_reloj_bolsillo
```

- Debe imprimir el número de triángulos (unos 236) y crear `art/export/vistas/mdl_reloj_bolsillo.png`. Abre la imagen y revísala.
- Si algo falla por la versión de Blender, corrígelo en `art/blender/scripts/` sin romper Windows. En Blender 4.4 y superior la colección de tiras de audio se llama `strips`.
- Añade a `art/Pipeline-de-Arte.md` y a `art/README.md` los **comandos para macOS** junto a los de Windows.

## 4. Tu tarea: materiales de los relojes (abre una tarea nueva, por ejemplo ART-006)

**Situación actual:** los 6 relojes (`mdl_reloj_bolsillo`, `_pulsera`, `_cronografo`, `_legado`, `_real`, `_millonario`) son low-poly con **una única textura de paleta** de colores planos (ver `art/blender/scripts/modelos_prioridad2.py`).

**Objetivo:** que se vean como relojes de lujo, con materiales reales, sin perder el estilo low-poly del juego.

1. **Materiales en Material Maker** (proyecto `.ptex` en `art/texturas/fuentes/`):
   - **Metal dorado** pulido y cepillado.
   - **Acero.**
   - **Cristal** de zafiro (azulado, liso).
   - **Esmalte** de esfera (blanco, negro, azul).
   - **Cuero** de correa.
   - **Gemas:** rubí, diamante y zafiro.

   Exporta cada material como mapas PBR de 512×512 (máximo 1024): `_color`, `_normal`, `_rugosidad`, `_metalico`. Usa nombres como `tex_metal_oro_color.png` en `art/texturas/export/`.
2. **En Blender:**
   - Separa cada reloj por material (caja, esfera, cristal, correa, gemas). En Roblox, cada `MeshPart` lleva un solo material (`SurfaceAppearance`), así que un reloj será un **Model con varias mallas**. `AssetLibrary` ya acepta Models.
   - Desenvuelve las UV de cada parte (*Smart UV Project*) y asigna el material.
   - Mantén el reloj por debajo de unos **3.000 triángulos**.
   - Puedes añadir detalles: números romanos, biseles y coronas más finas.
3. **Exporta** a `art/export/modelos/` con el **mismo nombre** (`mdl_reloj_bolsillo.fbx`…), para que el juego los use sin cambiar código. Guarda el `.blend` en `art/blender/fuentes/`. Si los haces a mano, documenta los pasos o deja un script nuevo (por ejemplo `art/blender/scripts/relojes_detallados.py`).
4. **Vistas previas:** genera las previsualizaciones (con renderizado EEVEE o Cycles para ver los materiales) y actualiza la hoja de contactos.
5. **Paleta y estilo:** si cambias colores de la paleta común (`tex_paleta.png`), hazlo en Krita y anótalo. Afecta a todos los modelos.
6. **Documenta:**
   - [[Pipeline-de-Arte]]: sección nueva «Materiales PBR de los relojes», con nombres de archivos y cómo montar `SurfaceAppearance` en Studio.
   - Changelog (paso a paso, con lo que se ejecutó de verdad).
   - Memoria del área 12.
   - Propuesta en el Registro de Decisiones.

**Cómo se verán en Roblox:** en la PC con Studio se importa el FBX (3D Importer, unidad Stud) en `ReplicatedStorage/Assets`. A cada MeshPart se le añade un `SurfaceAppearance` con sus 4 mapas subidos. La MacBook no tiene Roblox Studio, así que deja instrucciones claras para quien importe desde Windows.

## 5. Siguientes pasos de arte (cuando acabes los relojes)

- Mismo tratamiento para las **piezas robables**, la **pieza del legado** y las **cápsulas**.
- Retocar los **iconos** en Krita (`art/texturas/export/ico_*.png`).
- Pulir los **sonidos** en Audacity (`art/audio/fuentes` → `export`).
- **Música:** `mus_base` y `mus_persecucion`, hechas a mano o con licencia registrada.

## 6. Informe al terminar cada tarea

Resume: qué se hizo, archivos tocados, comprobaciones ejecutadas (por ejemplo, triángulos y vistas revisadas), commit subido, propuestas pendientes de aprobar y siguiente paso. Luego marca la reserva como Completada.
