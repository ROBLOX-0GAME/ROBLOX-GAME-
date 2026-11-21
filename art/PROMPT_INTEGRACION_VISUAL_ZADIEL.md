# Prompt — Diseño e integración visual en la place oficial (Zadiel)

> Creado en ART-012 (2026-11-20) por Claude en la PC de Jhonn. **Cópialo completo en Claude Code**, abierto en la raíz del repositorio. Reparto: Zadiel lleva el arte y la integración visual (ART-013) y Jhonn sigue con el gameplay (DEV-016).

---

Eres Claude Code de la **Cuenta A**. Trabajas con **Zadiel** en **BUILD A WATCH!** (Roblox). Zadiel lleva el **diseño y la integración visual**: modelos, materiales, iconos, sonido e iluminación. Jhonn lleva el gameplay y el código (`game/src`, Rojo). Según DEC-020, los dos deciden y revisan todo.

## 0. Reglas (antes de tocar nada)

1. Confirma que estás en la raíz de la bóveda: tiene que haber `ACTIVE_TASKS.md`, `art/` y `game/`. Haz `git pull`.
2. Lee: `.claude/CLAUDE.md`, `AGENTS.md`, `OWNERS.md`, `ACTIVE_TASKS.md`, `09 - TAREAS Y DESARROLLO/Backlog.md` (ART-008 a ART-012, DEV-015 y DEV-016), `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md` (DEC-016, 017, 018, 020 y 021), **`art/Pipeline-de-Arte.md`** (§1, §2, §5 «Importación en Studio con el MCP» y §7), **`art/texturas/ids_roblox.md`** y `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md`.
3. Flujo DEC-009: se trabaja directo en `main`.
   - Registra **ART-013** en `Backlog.md` y reserva sus rutas en `ACTIVE_TASKS.md`.
   - Haz commit y push de la reserva y escribe `ART-013` en `.claude/tarea-activa`.
   - Haz `git pull`, commit y push después de cada avance. Nunca uses force push.
   - Rutas que puedes reservar: `art/**` (sin las de otra tarea activa), `art/Pipeline-de-Arte.md`, `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md`, `09 - TAREAS Y DESARROLLO/Changelog.md` y `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md`.
   - Antes, cierra **DEV-015** si ya terminó (sus commits `dda2573` y `af644e6` están en `main`), para liberar `Changelog.md` y `Plan-de-Pruebas.md`.
4. **No edites `game/src` ni scripts dentro de Studio.** Rojo y DEV-016 los sobrescriben, y son del área de Jhonn. Lo que necesite código (cargar iconos, sonidos o luces desde scripts) se anota como **tarea DEV para Jhonn**, con los IDs listos.
5. Los cambios de estilo quedan como **Propuesta** en el Registro hasta que Jhonn los apruebe. Claude no aprueba decisiones.
6. No inventes un placeId. **No publiques.** Solo vale *Save to Roblox*, y solo si Zadiel lo autoriza. No declares pruebas que no hayas ejecutado. Sin marcas reales. No guardes API keys, cookies ni tokens.

## 1. Herramientas acordadas (Pipeline §1)

- **Blender 5.3:** modelado low-poly y exportación FBX (scripts en `art/blender/scripts/`).
- **Material Maker 1.8:** materiales PBR (`materiales_pbr.py`).
- **Krita:** textura de paleta `tex_paleta.png`, retoque de iconos (`.kra` en `art/texturas/fuentes/`) y arte 2D.
- **Audacity 4:** sonidos en `art/audio/` (`sonidos.py`, `convertir_ogg.py`).
- **Roblox Studio + MCP de Studio:**
  - Antes de usarlo, ejecuta `list_roblox_studios` y verifica que abriste la place **84500108687089**, universo 10778093657. Si ves otra place, detente.
  - Ejecuta `list_roblox_skills` y carga las que apliquen: `rbx-import-asset`, `rbx-open-cloud-usage`, `rbx-permissions` y `rbx-scene-analysis`.
  - Sube assets con `open_cloud_invoke` (`POST /assets/v1/assets`), insértalos con `insert_asset` y revisa con `inspect_instance`, `screen_capture` y `start_stop_play`.
  - En Studio: *Assistant → Settings → MCP Permissions* con `asset:read` y `asset:write`, y la carpeta `art/` aprobada para subidas.
- **Team Create:** Jhonn puede estar en la place al mismo tiempo. Tu zona es `ReplicatedStorage/Assets`, `Lighting` y los assets de sonido e imagen. No toques `ServerScriptService`, `StarterPlayer` ni `ReplicatedStorage/Shared`. Avisa antes de hacer Play o *Save to Roblox* para no pisarse. **Pide confirmación a Zadiel antes de cada cambio en la place.**

## 2. Tarea ART-013 — Integrar el arte restante

Sigue el mismo método que ART-008 (Pipeline §5):

1. **Textura de paleta.** Sube `art/texturas/export/tex_paleta.png` como Image y anota el ID en `ids_roblox.md`.
2. **36 modelos low-poly** de `art/export/modelos/`:
   - Plot: `mdl_plot_suelo`, `mdl_taller`, `mdl_vitrina`, `mdl_panel_plot`, `mdl_caminadora`.
   - Estaciones: `mdl_estacion_tienda`, `_robux`, `_criadero`, `_cronometro`, `_carga`.
   - Muro: `mdl_muro_frontal`, `mdl_cartel_salida`, `mdl_puerta_velocidad_poste`.
   - Casas: `mdl_casa_z1` a `mdl_casa_z5` y `mdl_pedestal`.
   - Mascotas (9): `mdl_mascota_raton`, `_gato`, `_zorro`, `_halcon`, `_dragon`, `_fenix`, `_titan`, `_senor_tiempo`, `_suprema`.
   - Ambiente: `mdl_arbol`, `mdl_arbusto`, `mdl_farola`, `mdl_banca`, `mdl_valla`, `mdl_roca`, `mdl_cartel_zona`, `mdl_caja_madera`.

   Para cada uno:
   - Súbelo como Model e insértalo en `ReplicatedStorage/Assets` con su nombre exacto.
   - Aplica la **escala ×0,01**, ancla las piezas y pon el ID de `tex_paleta` en el `TextureID` de cada MeshPart.
   - Compara la medida con la tabla del Pipeline §7. Si no coincide, anótalo; no lo corrijas en código.
   - Anota cada ID en `ids_roblox.md`.
3. **Iconos y sonidos.** Sube los 8 `ico_*.png` (Image) y los 10 sonidos de `art/audio/export/` (Audio). Si la moderación rechaza alguno, anótalo y sigue. Pon sus IDs en `ids_roblox.md` y crea en Backlog una **tarea DEV para Jhonn** que los pase a `Config.ICON_IDS` y `Config.SOUND_IDS`.
4. **Pase de iluminación (propuesta).** Propón ajustes de `Lighting` (Technology Future, Atmosphere, ColorCorrection y Bloom suave) que hagan lucir los PBR sin perder el estilo low-poly colorido. Aplícalos solo si Zadiel lo confirma. Registra los valores como **DEC-022 (Propuesta)**.
5. **Verificación real:**
   - Haz Play con `start_stop_play` y revisa la consola con `get_console_output`.
   - Ejecuta en el cliente `ContentProvider:PreloadAsync` sobre todos los assets y cuenta los *Success*.
   - Comprueba que `AssetLibrary.dress` sustituye las piezas provisionales.
   - Haz capturas con `screen_capture` del plot, el muro, una casa y una mascota. Repite la primera captura si sale vacía.
   - Revisa triángulos y memoria con `rbx-scene-analysis`.
   - Guarda las capturas en `art/export/vistas/studio_art013_*.png`.
6. **Guardar:** *Save to Roblox* solo con autorización de Zadiel. Anota el número de versión. No publiques.

## 3. Cierre

- Actualiza `art/Pipeline-de-Arte.md` (§5 y §7, con los estados), `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md` y `Changelog.md`. Si propusiste algo, agrégalo a `Registro-de-Decisiones.md` como Propuesta.
- Marca ART-013 como **Completada** en `ACTIVE_TASKS.md` y haz push.
- Informe de cierre: resumen, rutas, responsable (Zadiel), revisor (Jhonn), rama `main` y commits, pruebas que de verdad ejecutaste (con números), assets rechazados, propuestas pendientes y próximo paso. Después pide liberar la reserva.
