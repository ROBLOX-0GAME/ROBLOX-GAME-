# 📍 ESTADO DEL PROYECTO — BUILD A WATCH!

> Foto del proyecto el **2026-11-20**, hecha en INFRA-004 por Claude (MacBook de Zadiel). Resume lo hecho entre todos, lo que se ha **comprobado de verdad** y lo que falta. El detalle está en [[Backlog]], [[Changelog]] y [[Registro-de-Decisiones]]. Esta nota no aprueba nada: las decisiones siguen su estado en el Registro.

## 1. En una frase

El código del juego y casi todo el arte base están hechos y dentro de la **place oficial**. Los relojes, las piezas, el legado y las cápsulas ya tienen materiales PBR. **Un error en el cliente (`Ui.luau:766`) impide jugar**, y faltan las configuraciones online (DataStores, pases, productos, IDs de sonido e iconos) para publicar.

## 2. Datos clave

| Dato | Valor |
|---|---|
| Place oficial | **84500108687089** («Reloj creation oficial 1») |
| Universo | **10778093657** |
| Dueño | Jhonn (**Lubu465**); Zadiel (**zadiel799**) colabora en Team Create |
| Versión guardada | **9** (2026-11-20, ART-008). **Sin publicar** |
| Repositorio | `ROBLOX-0GAME/ROBLOX-GAME-` (**público**), rama `main`, flujo directo (DEC-009) |
| Equipo | Zadiel y Jhonn deciden y revisan todo (DEC-020) |
| Código | `game/src` (Luau, Rojo 7.7.1). `servePlaceIds` sigue vacío |
| Arte | `art/` (Blender 5.3, Material Maker 1.8, Krita, Audacity) |

## 3. Qué es el juego

Simulador de Roblox de **fabricar relojes de lujo ficticios**:
- Robas piezas en 5 zonas cada vez más ricas; para entrar a cada zona hace falta velocidad. Si el dueño de la casa te atrapa, pierdes el botín.
- Fabricas relojes en tu plot y los vendes o los expones en vitrinas, que dan ingreso pasivo.
- Subes la velocidad con mejoras, caminadoras y mascotas.
- Hay un jefe cooperativo (Cronómetro Maestro), una historia inicial con la pieza del legado, un tutorial, una ruleta diaria y pases y productos con Robux.
- Todas las cifras de balance son **propuesta** (DEC-003 a DEC-015).

## 4. Lo que está hecho

### 4.1 Organización y herramientas
- **Bóveda Obsidian** con 13 áreas, memorias de área, Backlog, Changelog y Registro de Decisiones.
- **Coordinación de agentes:** reservas en `ACTIVE_TASKS.md` con hook de bloqueo (INFRA-001) y trabajo directo en `main` con Obsidian Git cada 5 min (INFRA-002, DEC-009).
- **Equipo:** queda en Zadiel y Jhonn (INFRA-003, DEC-020).
- **Place oficial** creada por Jhonn y anotada en el repositorio (INFRA-003).

### 4.2 Código del juego (Jhonn, DEV-001 a DEV-014)

| Tarea | Qué hace |
|---|---|
| DEV-001…007 | Base técnica: datos con DataStore y bloqueo de sesión, remotos seguros (el servidor decide), robo por zonas con persecución, taller, tienda, museo, jefe y tutorial, integrados en `game/` |
| DEV-008 | Plot personal: mesa, vitrinas y caminadora mejorables |
| DEV-009 | Mascotas en cápsulas, recompensas diarias y por tiempo, mascotas Robux |
| DEV-010 | Base en media luna: 6 plots, muro frontal con estaciones y salida a correr |
| DEV-011 | Historia inicial, pieza del legado, tutorial nuevo e ingreso pasivo del 30 % |
| DEV-012 | Ingreso pasivo cada 30 s |
| DEV-013 | HUD multiplataforma, ruleta diaria, ajustes y capacidad de carga |
| DEV-014 | `AssetLibrary`: usa los modelos de `ReplicatedStorage/Assets` si existen y, si no, la pieza provisional |

### 4.3 Arte (Jhonn y luego Zadiel, ART-001 a ART-011)

| Tarea | Resultado |
|---|---|
| ART-001…004 | Pipeline low-poly con paleta común: **56 modelos base**, 8 iconos del HUD y 10 efectos de sonido |
| ART-005, ART-007 | Prompts de traspaso entre la PC de Jhonn y la MacBook |
| ART-006 | **6 relojes PBR**: 11 materiales de Material Maker (oro, acero, cristal, esmaltes, cuero, gemas); una malla por material; 960–2.090 triángulos |
| ART-009 | PBR para **7 piezas robables, 3 piezas del legado y 4 cápsulas**; materiales nuevos: latón, plata y esmalte cósmico |
| ART-010 | Iconos con contorno y sombra (propuesta de estilo) y sonidos pulidos por script, todos de menos de 2 s |
| ART-011 | Script de subida por Open Cloud (`art/tools/subir_roblox.py`). **Ya no hace falta** (ver ART-008) |
| **ART-008** | **20 modelos PBR y 43 mapas subidos e importados en la place oficial**, con 78 `SurfaceAppearance`. IDs en `art/texturas/ids_roblox.md` |

## 5. Lo comprobado de verdad (no solo en papel)

| Comprobación | Resultado | Cuándo |
|---|---|---|
| Revisión estática (`python game/tools/build.py`) | ✅ Sin errores, 99 `require` | 2026-11-20 |
| Compilación con Rojo 7.7.1 | ✅ Correcta | 2026-11-20 |
| Código de la place = `game/src` de `main` | ✅ 25 de 25 scripts idénticos byte a byte | ART-008 |
| Play: servidor | ✅ `[BUILD A WATCH!] Servidor iniciado.`, mapa con 6 plots y vitrinas | ART-008 |
| Play: pruebas automáticas | ⚠️ **46 correctas y 1 fallida** («place apoya la base en el suelo», prueba de `AssetLibrary`) | ART-008 |
| Play: cliente | ❌ **No carga la interfaz**: `Client/Ui.luau:766: Malformed string` | ART-008 |
| Assets PBR en `AssetLibrary` | ✅ Los 20 se colocan base con base, ocultan la pieza provisional y miran bien | ART-008 |
| Texturas en el cliente | ✅ 78 de 78 contenidos cargan (`PreloadAsync`) | ART-008 |
| Prueba en servidor real con otra cuenta | ⏳ No hecha | — |
| API key en GitHub | ✅ **No hay ninguna** en archivos ni historial (y no debe haberla: repo público) | INFRA-004 |

## 6. Lo que falta, por prioridad

### 🔴 Bloquea jugar (tarea de código, `game/src`)
1. **`StarterPlayer/StarterPlayerScripts/Client/Ui.luau` líneas 766–767:** una cadena entre comillas tiene un salto de línea real (viene de `a644eac`, DEV-011). Sin esto no hay HUD ni menús. Arreglo probable: cambiar el salto por `\n`. Después, volver a cargar el código en la place.
2. **Prueba fallida de `AssetLibrary`** («place apoya la base en el suelo»): revisar `AssetLibrary.place` o la prueba.
3. **`rbxassetid://203785492`** da «Asset type does not match» en Play. No está en el repositorio: averiguar de dónde sale.

### 🟠 Para que funcione online
4. **DataStores:** en Studio, Game Settings → Security → *Enable Studio Access to API Services*. Sin esto el juego va en «Modo de prueba» y no guarda.
5. **Pases y productos de Robux:** crearlos (Jhonn, en el Creator Dashboard u Open Cloud) y poner sus IDs en `Config.GAMEPASS_IDS` (6) y `Config.PRODUCT_IDS` (7). Ahora valen 0.
6. **Sonidos e iconos:** subir `art/audio/export/sfx_*.ogg` (10) y `art/texturas/export/ico_*.png` (8) y poner sus IDs en `Config.SOUND_IDS` y `Config.ICON_IDS`. Ahora valen 0, así que no suenan ni se ven.
7. **Resto de modelos base** (plots, estaciones, casas, mascotas, ambiente…): aún no están en `ReplicatedStorage/Assets`, y el juego usa piezas provisionales. Se suben igual que en ART-008.
8. **Dueños de las casas:** personaje R15 con ropa original (`npc_dueno_z1`…`z5` o `npc_dueno`).
9. **Música:** `mus_base` y `mus_persecucion`, hechas a mano o con licencia registrada.
10. **Rojo con la place:** poner `84500108687089` en `servePlaceIds` (tarea de código) para sincronizar el código sin copiarlo a mano.

### 🟡 Antes de publicar
11. Prueba completa en Play: robar, persecución, fabricar, vender, vitrinas, mascotas, jefe y ruleta.
12. Prueba en un **servidor real con otra cuenta**: que se vean las texturas y que se guarden los datos.
13. **Publicar** (File → Publish): solo Jhonn o con su OK.

### ⚪ Decisiones por aprobar (Zadiel y Jhonn, DEC-020)
- **Propuestas:** DEC-003 a DEC-008 y DEC-010 a DEC-015 (cifras y mecánicas), DEC-016 (estilo low-poly), DEC-017 (assets en `ReplicatedStorage/Assets`), DEC-019 (MacBook para arte) y **DEC-021** (Studio en la MacBook).
- **Aprobadas:** DEC-001, DEC-009, DEC-018 y DEC-020.
- Si se aprueba DEC-021, actualizar `.claude/CLAUDE.md` y [[Arquitectura-General]] (todavía dicen que la MacBook es solo para Obsidian).

### 🧹 Orden en la documentación
- INFRA-001 y DEV-007 siguen «En revisión» en el Backlog (eran del flujo con PR, que ya no se usa): cerrarlas.
- En el Backlog hay una entrada de plantilla («Nombre de la tarea») sin rellenar.

## 7. Seguridad: la API key de Roblox

- **No se guarda en GitHub.** El repositorio es **público**: una clave subida la puede usar cualquiera para crear o cambiar assets en la cuenta de su dueño.
- **Ahora mismo no hace falta:** los assets PBR ya se subieron con el MCP de Studio (ART-008).
- Si un script la necesita, va **solo en una variable de entorno local** (`ROBLOX_API_KEY`), como explica `art/PROMPT_SUBIDA_JHONN.md`.
- Para GitHub Actions, iría como **secreto cifrado del repositorio** (Settings → Secrets and variables → Actions, o `gh secret set ROBLOX_API_KEY` escribiendo la clave cuando lo pida), nunca en un archivo.
- Si una clave se ha pegado en un chat o en otro sitio compartido, conviene **revocarla y crear una nueva** en create.roblox.com → Open Cloud → API Keys, con la caducidad más corta posible.

## 8. Siguiente paso recomendado

1. **Tarea de código (Jhonn):** arreglar `Ui.luau:766` y la prueba de `AssetLibrary`, y cargar el código en la place.
2. Activar el acceso a API en Studio y hacer una partida de prueba completa.
3. Subir sonidos e iconos y crear pases y productos; rellenar `Config`.
4. Importar el resto de modelos base y los dueños R15.
5. Probar en un servidor real con otra cuenta y publicar con el OK de Jhonn.

---

[[Dashboard]] · [[Backlog]] · [[Changelog]] · [[Registro-de-Decisiones]] · [[Pipeline-de-Arte]] · [[ACTIVE_TASKS|Reservas]]
