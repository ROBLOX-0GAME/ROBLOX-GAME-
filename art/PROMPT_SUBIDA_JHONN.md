# Prompt para Jhonn — Crear la API key y subir los assets PBR a Roblox

> Creado en ART-011 (2026-11-20) por Claude en la PC Windows de Zadiel. **Jhonn:** haz tú la parte 1 (crear la clave) y después abre Claude Code **en la raíz del repositorio** y pega: «Haz `git pull` y sigue `art/PROMPT_SUBIDA_JHONN.md` desde la parte 2».

---

Eres Claude Code de la **Cuenta A**, trabajando con **Jhonn** en BUILD A WATCH!. La place oficial es **84500108687089** («Reloj creation oficial 1», universo 10778093657) y es de **Jhonn (Lubu465, ID de usuario 2311077683)**. Los assets deben subirse **a nombre de Jhonn** para que carguen en su experiencia; por eso la API key es suya.

Qué hay que subir (ya está en el repositorio):
- **56 mapas PBR** (`art/texturas/export/tex_<material>_{color,normal,rugosidad,metalico}.png`, 14 materiales) como **Image**.
- **20 modelos PBR** (`art/export/modelos/mdl_{reloj,pieza,legado,capsula}_*.fbx`) como **Model**.

El script `art/tools/subir_roblox.py` (solo Python estándar) lo sube todo con Open Cloud, guarda los IDs en `art/tools/ids_roblox.json` y genera `art/tools/montar_assets.luau` para Studio.

## Parte 1 — Crear la API key (la hace Jhonn, en el navegador)

1. Entra en **https://create.roblox.com** con la cuenta **Lubu465**.
2. Menú **Open Cloud → API Keys → Create API Key**.
3. **Name:** `build-a-watch-assets`.
4. **Access Permissions:** en *Select API System* elige **Assets** y marca **Read** y **Write**.
5. **Security → Accepted IP Addresses:** `0.0.0.0/0` (o solo la IP pública de tu PC si prefieres).
6. **Expiration:** pon una fecha cercana (por ejemplo, 30 días). Se puede revocar al terminar.
7. **Save & Generate Key** → **Copy Key to Clipboard**. Solo se muestra una vez.
8. Guarda la clave como variable de entorno **en una terminal aparte, fuera de Claude Code**, para que no quede escrita en la conversación:
   - Windows (PowerShell o CMD): `setx ROBLOX_API_KEY "pega-aquí-la-clave"` y **cierra y vuelve a abrir** la terminal y Claude Code.
   - macOS: añade `export ROBLOX_API_KEY="pega-aquí-la-clave"` a `~/.zshrc` y abre una terminal nueva.
9. **Nunca** pegues la clave en el chat, en un commit, en Obsidian ni en WhatsApp.

## Parte 2 — Reglas antes de empezar (Claude)

1. Comprueba que estás en la raíz del repositorio (`ACTIVE_TASKS.md`, `art/`, `game/`). Haz `git pull`.
2. Lee `.claude/CLAUDE.md`, `ACTIVE_TASKS.md`, **DEC-020** en `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md` (ahora deciden Zadiel y Jhonn) y `art/Pipeline-de-Arte.md` (secciones de materiales PBR de ART-006 y ART-009).
3. Flujo DEC-009: directo en `main`. Registra una tarea nueva (**ART-012 — Subida de assets PBR con Open Cloud**) en `09 - TAREAS Y DESARROLLO/Backlog.md` y su fila en `ACTIVE_TASKS.md` («En desarrollo»; responsable Jhonn, revisor Zadiel) con estas rutas: `art/tools/ids_roblox.json`, `art/tools/montar_assets.luau`, `09 - TAREAS Y DESARROLLO/Changelog.md` y `09 - TAREAS Y DESARROLLO/Backlog.md`. Commit + `git push` de la reserva y escribe `ART-012` en `.claude/tarea-activa`.
4. **ART-008** (importar en Studio y probar en Play) puede estar reservada por otra sesión (la MacBook de Zadiel). **No edites sus rutas** (`art/texturas/ids_roblox.md`, `art/export/vistas/studio_*.png`) ni toques la place sin que Jhonn confirme que ART-008 está libre o que la coordina él.
5. No toques `game/src`. No publiques el juego. No inventes IDs ni digas que algo se subió o se probó si no lo ves en la salida.

## Parte 3 — Subir (Claude)

1. Comprueba que la clave está disponible **sin mostrarla**:
   - PowerShell: `if ($env:ROBLOX_API_KEY) { "clave presente" } else { "falta la clave" }`
   - bash/zsh: `[ -n "$ROBLOX_API_KEY" ] && echo "clave presente" || echo "falta la clave"`

   Si falta, para y pide a Jhonn la parte 1 (y que reinicie Claude Code tras `setx`).
2. Prueba sin subir nada:
   `python art/tools/subir_roblox.py --usuario 2311077683 --prueba`
   Debe decir **14 materiales, 20 modelos, pendientes 56 imágenes y 20 modelos** (menos si ya se subió una parte).
3. Sube primero un solo grupo para comprobar permisos: `python art/tools/subir_roblox.py --usuario 2311077683 --solo modelos`. Si responde 401/403, la clave no tiene **Assets Read/Write** o la IP no está aceptada: díselo a Jhonn. Si va bien, ejecuta sin `--solo` para las imágenes.
4. El script guarda los IDs tras cada subida y reintenta los errores 429/5xx. Si se corta, vuelve a ejecutarlo: solo sube lo que falte.
5. Al terminar debe decir **56 imágenes y 20 modelos**. Revisa `art/tools/ids_roblox.json` (todos los valores son números) y que `art/tools/montar_assets.luau` tenga las tablas llenas.
6. `git pull`, commit («ART-012: IDs de Roblox de los assets PBR») y `git push` de `art/tools/ids_roblox.json` y `art/tools/montar_assets.luau`. Los IDs no son secretos; la clave no está en ellos (compruébalo con `git diff`).

## Parte 4 — Montar en Studio (solo si ART-008 está libre o Jhonn la coordina)

1. Jhonn abre la place **84500108687089** en Roblox Studio. Si el **MCP de Roblox Studio** está conectado, úsalo (lista sus herramientas antes); si no, Jhonn pega el contenido de `art/tools/montar_assets.luau` en la **barra de comandos** (View → Command Bar).
2. Confirma con Jhonn antes de modificar la place. El script carga los 20 modelos en `ReplicatedStorage/Assets` (sustituye los de paleta) y monta los `SurfaceAppearance`.
3. Debe imprimir **«Modelos cargados: 20 · SurfaceAppearance montados: 78»** sin avisos. Si un modelo llega con otra estructura (MeshParts con otro nombre, anidados), anótalo y ajusta el script en `subir_roblox.py` (no a mano en el `.luau`).
4. **Prueba en Play** (no la declares si no la haces): los relojes en las vitrinas, piezas robables en las casas, cápsulas en Criadero/Premios y piezas del legado en la introducción; el frente mira al jugador (si no, atributo numérico `GiroY` = 180 en el Model, sin tocar código); el cristal deja ver la esfera; los metales y gemas se ven bien.
5. Guarda la place solo si Jhonn lo confirma (Team Create guarda solo; **no publiques**).
6. Anota en el Changelog qué se subió, qué se montó y qué se probó de verdad. Marca ART-012 como **Completada** y sube. Si hiciste el montaje y la prueba, avisa a Zadiel para cerrar ART-008 y rellenar `art/texturas/ids_roblox.md` con los IDs.

## Al terminar

- Jhonn puede **revocar la clave** en Open Cloud → API Keys si no se va a subir nada más.
- Informe: archivos tocados, commits, número de assets subidos, contador de Studio, prueba en Play y pendientes.
