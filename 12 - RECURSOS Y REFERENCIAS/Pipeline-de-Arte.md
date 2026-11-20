
# 🎨 PIPELINE DE ARTE — BUILD A WATCH!

> Creado en ART-001 (2026-11-20). Responsable actual: Jhonn. Después pasará a Michael y Einell (Cuenta B, dirección visual según [[OWNERS]]). Todo lo que aquí aparece es **propuesta** hasta que el equipo lo apruebe ([[Registro-de-Decisiones]]).

## 1. Herramientas

| Herramienta | Versión instalada (PC de Jhonn) | Uso |
|---|---|---|
| Blender | 5.3 | Modelado 3D low-poly, exportación FBX. Admite scripts: Claude genera modelos base con Python. |
| Krita | instalada | Paleta, texturas pintadas, iconos de la interfaz y arte 2D. |
| Material Maker | 1.8 (portable, en el Escritorio) | Materiales procedurales (metal, madera, cristal) cuando se pase a más detalle. |
| Audacity | 4 | Edición de efectos de sonido y música. |
| Roblox Studio | — | Importar modelos (3D Importer), subir texturas y audio (Asset Manager). |
| Substance 3D Painter | no instalado | Mencionado en la idea original; Material Maker cubre su papel por ahora. |

## 2. Estilo visual (propuesta)

- **Low-poly colorido tipo simulador de Roblox:** formas simples, sombreado plano y colores saturados de una paleta común.
- Primero se hacen modelos base (por script o a mano) y después se detallan a mano con las herramientas.
- **Una sola textura de paleta** (`art/texturas/export/tex_paleta.png`, 256×256, 16 colores en celdas de 64 px). Cada cara del modelo apunta con sus UV al centro de una celda. Así hay un único material para todo y la paleta se retoca en Krita sin rehacer los modelos.
- Paleta inicial: negro, gris oscuro, gris, blanco, madera, madera oscura, dorado, bronce, rojo, naranja, verde, verde oscuro, azul, azul oscuro, morado y cian. Los valores exactos están en `art/blender/scripts/arte_comun.py`.
- **Sin marcas reales:** las marcas de relojería son inspiración, no permiso de uso (memoria del área 12).

## 3. Carpeta `art/` (fuentes y exportaciones, en Git)

```
art/
  blender/scripts/   generadores Python (arte_comun.py, generar_todo.py, vista_previa.py)
  blender/fuentes/   .blend de cada modelo
  export/modelos/    .fbx listos para Roblox
  export/vistas/     imágenes de vista previa (para revisar sin abrir Blender)
  texturas/fuentes/  .kra (Krita) y .ptex (Material Maker)
  texturas/export/   .png listos para Roblox (tex_paleta.png, iconos)
  audio/fuentes/     proyectos .aup3 (Audacity)
  audio/export/      .ogg o .mp3 listos para Roblox
  referencias/       imágenes de referencia con su licencia anotada
```

Según DEC-001, **Roblox Studio guarda los assets ya importados en la place** y Git guarda las fuentes y exportaciones de `art/`.

## 4. Formatos, escala y límites

| Tipo | Formato | Reglas |
|---|---|---|
| Modelo | FBX (una malla por pieza) | **1 unidad de Blender = 1 stud.** Origen en la base, centrado. Sombreado plano. Pocos triángulos: el objetivo low-poly es menos de 1.000 por objeto (Roblox admite muchos más por malla; comprobar el límite vigente en el Creator Hub). |
| Textura | PNG | Máximo 1024×1024 (Roblox reduce lo que sea mayor). En low-poly basta con la paleta de 256×256. |
| Icono de la interfaz | PNG con transparencia | 256×256, en Krita. |
| Audio | OGG o MP3 | Efectos cortos (menos de 2 s), volumen normalizado en Audacity. Comprobar los límites de subida vigentes en el Creator Hub. |

**Nombres:** `mdl_` modelo, `tex_` textura, `ico_` icono, `sfx_` efecto, `mus_` música. En minúsculas, sin tildes ni espacios. Ejemplos: `mdl_caminadora.fbx`, `sfx_robar.ogg`.

## 5. Flujo de trabajo

1. **Modelo base:** ejecuta los generadores.
   ```
   "C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/generar_todo.py
   ```
   O modela a mano en Blender respetando la escala y la paleta.
2. **Vista previa:** con `vista_previa.py` (mismo comando) se generan `art/export/vistas/*.png`, para revisar en Obsidian o GitHub.
3. **Detallar a mano** en Blender, Krita y Material Maker. Guarda la fuente en `art/` y vuelve a exportar.
4. **Importar en Studio:** abre la place oficial → **3D Importer** → elige el FBX → unidad **Stud** → importar. Sube `tex_paleta.png` (Asset Manager) y ponla como `TextureID` del MeshPart. Guarda el modelo en `ServerStorage/Assets/` con su nombre (`mdl_caminadora`).
5. **Conectar al juego** (tarea de código posterior): los servicios usarán el modelo de `ServerStorage/Assets` si existe y, si no, la pieza provisional actual. Así el juego nunca se rompe por un asset que falte.
6. **Registrar** el asset en la lista (§7) y en el [[Changelog]], con autor y licencia si aplica.

> ⚠️ **Place oficial:** la place que genera `build.py` o Rojo solo contiene código. Los modelos importados se guardan en la place **publicada** de Roblox, y Rojo sincroniza el código en ella (`servePlaceIds`, ver [[Arquitectura-General]]). Hay que publicar esa place antes de empezar a importar assets.

## 6. Control de recursos

Según [[Recursos-y-Referencias]] §8, todo recurso externo anota su procedencia, autor, licencia y permisos. Los assets hechos por el equipo o generados por script son propios. Las referencias externas van a `art/referencias/` con su fuente.

## 7. Lista de assets (prioridad y pieza que sustituyen)

Medidas en studs, tomadas de las piezas provisionales del código.

**Prioridad 1 — lo que más se ve**

| Asset | Sustituye a | Medida | Estado |
|---|---|---|---|
| `mdl_caminadora` | Caminadora del plot (PlotService) | 5 × 1 × 8 | ✅ Base generada (152 triángulos) |
| `mdl_plot_suelo`, `mdl_taller`, `mdl_vitrina`, `mdl_panel_plot` | Piezas del plot | 34×40 · 14×3,5×4 · 2×2,5×2 · 4×4×2 | Pendiente |
| `mdl_estacion_tienda`, `_robux`, `_criadero`, `_cronometro`, `_carga` | Mostradores del muro (WorldService) | 14 × 5 × 8, más techo | Pendiente |
| `mdl_muro_frontal`, `mdl_cartel_salida` | Muro frontal | segmentos de 116 × 18 × 2 | Pendiente |
| `mdl_casa_z1` … `mdl_casa_z5`, `mdl_pedestal` | Casas por zona (HouseService) | 26 × 12 × 24 (puerta 8 × 9) | Pendiente |
| `mdl_pieza_engranaje`, `_resorte`, `_tornillo`, `_cristal`, `_correa`, `_rubi`, `_diamante` | Esferas robables | ≈ 1,4 | Pendiente |
| `mdl_puerta_velocidad` | Barrera de zona | 260 × 40 × 2 | Pendiente |

**Prioridad 2 — progresión y recompensas**

| Asset | Sustituye a | Estado |
|---|---|---|
| `mdl_capsula_laton` | Cápsula (Criadero, Premios) | ✅ Base generada (328 triángulos) |
| `mdl_capsula_plata`, `_oro`, `_cosmica` | Cápsulas | Pendiente (mismo generador, otro color) |
| `mdl_reloj_bolsillo`, `_pulsera`, `_cronografo`, `_legado`, `_real`, `_millonario` | Marcadores de las vitrinas | Pendiente |
| `mdl_legado_espiral`, `_corona`, `_rotor` | Pieza luminosa de la introducción | Pendiente |
| `mdl_mascota_*` (9) | Esferas de mascota (PetService) | Pendiente |
| Dueños de las casas | NPC de bloques (OwnerNpc) | Pendiente: personaje R15 con skins originales «al estilo» de Roblox, sin copiar personajes reales |

**Prioridad 3 — ambiente, interfaz y sonido**

- **Escenografía por zona:** árboles, farolas, bancos, vallas y carteles.
- **Iconos** (Krita, 256×256): `ico_monedas`, `ico_velocidad`, `ico_mochila`, `ico_premios`, `ico_ruleta`, `ico_robux`, `ico_ajustes`, `ico_carga`.
- **Sonido** (Audacity):
  - Efectos: `sfx_robar`, `sfx_alarma_dueno`, `sfx_atrapado`, `sfx_guardar_botin`, `sfx_comprar`, `sfx_abrir_capsula`, `sfx_ruleta`, `sfx_subir_nivel`, `sfx_entrenar` (bucle), `sfx_boton`.
  - Música: `mus_base`, `mus_persecucion`.

---

**Estado:** Propuesta (ART-001) · **Documentos relacionados:** [[Recursos-y-Referencias]], [[Diseño-del-Mundo]], [[GDD]], [[Changelog]]
