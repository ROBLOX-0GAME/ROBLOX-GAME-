
# 🎨 PIPELINE DE ARTE — BUILD A WATCH!

> Creado en ART-001 (2026-11-20). Responsable actual: Jhonn. Después pasará a Michael y Einell (Cuenta B, dirección visual según [[OWNERS]]). Todo lo que aquí aparece es **propuesta** hasta que el equipo lo apruebe ([[Registro-de-Decisiones]]).

## 1. Herramientas

| Herramienta | Versión instalada (PC de Jhonn · MacBook de Zadiel) | Uso |
|---|---|---|
| Blender | 5.3 · 5.3 (Apple Silicon) | Modelado 3D low-poly, exportación FBX. Admite scripts: Claude genera modelos base con Python. |
| Krita | instalada | Paleta, texturas pintadas, iconos de la interfaz y arte 2D. |
| Material Maker | 1.8 (portable, en el Escritorio) · 1.8 (`/Applications`, binario universal) | Materiales procedurales (metal, madera, cristal) cuando se pase a más detalle. |
| Audacity | 4 | Edición de efectos de sonido y música. |
| Roblox Studio | — (solo en las PC Windows; la MacBook no lo tiene) | Importar modelos (3D Importer), subir texturas y audio (Asset Manager). |
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

1. **Modelo base:** ejecuta los generadores desde la raíz del repositorio.
   ```
   # Windows
   "C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/generar_todo.py
   # macOS
   /Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/generar_todo.py
   ```
   Desde ART-006, `generar_todo.py` **no** regenera los relojes (los hace `relojes_detallados.py`, ver «Materiales PBR de los relojes»); solo lo hace si se piden por nombre.
   O modela a mano en Blender respetando la escala y la paleta.
2. **Vista previa:** con `vista_previa.py` (mismo comando) se generan `art/export/vistas/*.png`, para revisar en Obsidian o GitHub.
3. **Detallar a mano** en Blender, Krita y Material Maker. Guarda la fuente en `art/` y vuelve a exportar.
4. **Importar en Studio:** abre la place oficial → **3D Importer** → elige el FBX → unidad **Stud** → importar. Sube `tex_paleta.png` (Asset Manager) y ponla como `TextureID` del MeshPart. Guarda el modelo en **`ReplicatedStorage/Assets/`** (crea la carpeta `Assets`) con su nombre exacto (`mdl_caminadora`). Va en ReplicatedStorage porque el cliente también usa algunos, como la pieza del legado.
5. **Conectado al juego (DEV-014, `AssetLibrary`):** al pulsar Play, cada servicio busca su modelo en `ReplicatedStorage/Assets`.
   - Si **existe**, lo coloca sobre la pieza provisional (base con base, centrado) y oculta la pieza, que conserva colisiones, avisos y lógica.
   - Si **no existe**, se queda la pieza provisional. El juego nunca se rompe por un asset que falte.
   - **Orientación:** el frente del asset debe mirar hacia su LookVector (−Z en Studio). Si al importarlo quedó girado, añade al asset el atributo numérico **`GiroY`** (grados, por ejemplo 180) y no hay que tocar código.
   - **Decoración:** árboles, farolas, bancas, vallas, rocas, cajas, carteles de zona, postes de las puertas y el arco de salida aparecen solos al importar sus modelos.
   - **Dueños de las casas:** crea en Studio un personaje R15 (Avatar → Build Rig y ropa o accesorios **originales**) y guárdalo como `npc_dueno_z1` … `npc_dueno_z5` (o `npc_dueno` para todas las zonas). Debe tener `Humanoid` y `HumanoidRootPart`.
   - **Sonidos:** sube cada `art/audio/export/sfx_*.ogg` y pega su ID en `Config.SOUND_IDS` (por ejemplo `robar = 1234567890`). **Iconos:** sube cada `ico_*.png` y pega su ID en `Config.ICON_IDS`. Con 0 no suenan ni se muestran.
6. **Registrar** el asset en la lista (§7) y en el [[Changelog]], con autor y licencia si aplica.

> ⚠️ **Place oficial:** la place que genera `build.py` o Rojo solo contiene código. Los modelos importados se guardan en la place **publicada** de Roblox, y Rojo sincroniza el código en ella (`servePlaceIds`, ver [[Arquitectura-General]]). Hay que publicar esa place antes de empezar a importar assets.

### Notas de importación (ART-002)

- **Orientación:** en Blender, el **frente** de cada modelo (puertas, carteles, pantallas) mira hacia **−Y**. En Studio se rota el modelo para que el frente mire hacia donde mira su pieza provisional.
- **Casas huecas:** son una sola malla con interior. En Studio, pon el MeshPart con `CollisionFidelity = PreciseConvexDecomposition` para poder entrar por la puerta. Si no basta, sepáralas en paredes en Blender.
- **Piezas robables, vitrinas y decoración pequeña:** `CanCollide = false`, igual que las piezas provisionales.
- **Revisión rápida:** `vista_previa.py` genera `art/export/vistas/_hoja_contactos.png` con todos los modelos en una imagen.

### Materiales PBR de los relojes (ART-006, propuesta)

Los 6 relojes dejan la textura de paleta y usan **materiales PBR** (metal, cristal, esmalte, cuero y gemas), sin perder la forma low-poly ni el sombreado plano. El resto de modelos sigue con la paleta.

**1. Materiales (Material Maker 1.8).** `art/blender/scripts/materiales_pbr.py` escribe un proyecto por material (`art/texturas/fuentes/mm_<material>.ptex`), lo exporta con Material Maker por línea de comandos (`--export-material`, 512 px) y deja 4 mapas por material en `art/texturas/export/`:

| Material | Uso | Rugosidad | Metálico |
|---|---|---|---|
| `metal_oro_pulido` | Cajas, coronas y asas de oro | 0,12–0,22 | 1 |
| `metal_oro_cepillado` | Biseles y esfera del Real (vetas finas) | 0,30–0,45 | 1 |
| `metal_acero` | Pulsera y cronógrafo, índices | 0,26–0,40 | 1 |
| `cristal_zafiro` | Cristal (azulado, liso) | 0,02–0,06 | 0 |
| `esmalte_blanco`, `esmalte_negro`, `esmalte_azul` | Esferas, números romanos y agujas | 0,08–0,16 | 0 |
| `cuero_correa` | Correa de la pulsera (grano) | 0,55–0,80 | 0 |
| `gema_rubi`, `gema_diamante`, `gema_zafiro` | Gemas talladas (facetas en el normal) | 0,01–0,08 | 0 |

Archivos de cada material: `tex_<material>_color.png`, `_normal.png` (espacio tangente, convención OpenGL, la de Roblox), `_rugosidad.png` y `_metalico.png`. Los `.ptex` se pueden abrir y retocar en Material Maker; después se exporta con `-- sin_ptex` para no sobrescribirlos.

**2. Modelos (Blender).** `art/blender/scripts/relojes_detallados.py` construye cada reloj con caja, tapa, bisel, esfera, índices o números romanos, agujas a las 10:10, cristal, corona y gemas talladas. Une las piezas **por material** (una malla por material, con el nombre del material), desenvuelve las UV con *Smart UV Project* y exporta a `art/export/modelos/` con el **mismo nombre** de antes. El `.blend` queda en `art/blender/fuentes/` con los materiales enlazados por ruta relativa.

| Reloj | Triángulos | Mallas (MeshParts) |
|---|---|---|
| `mdl_reloj_bolsillo` | 1.456 | oro pulido, oro cepillado, esmalte blanco/negro/azul, cristal |
| `mdl_reloj_pulsera` | 960 | acero, esmalte azul, cuero, cristal |
| `mdl_reloj_cronografo` | 1.376 | acero, esmalte azul/blanco/negro, cristal |
| `mdl_reloj_legado` | 1.538 | oro pulido/cepillado, esmalte blanco/negro/azul, zafiros, cristal |
| `mdl_reloj_real` | 1.566 | oro pulido/cepillado, esmalte negro, rubíes, cristal |
| `mdl_reloj_millonario` | 2.090 | oro pulido, esmalte negro, diamantes, cristal |

**3. Vistas previas.** `vista_previa.py` renderiza con **EEVEE** (cielo en degradado y luz de estudio) los `.blend` marcados con `render_pbr`; el resto sigue con Workbench. También actualiza la hoja de contactos.

**Comandos** (desde la raíz del repositorio; en Windows cambia la ruta de Blender por `"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe"`):
```
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/materiales_pbr.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/relojes_detallados.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/vista_previa.py
```
`materiales_pbr.py` busca Material Maker en `/Applications` (macOS) o en `Escritorio/material_maker*` (Windows); si está en otro sitio, indica su ruta en la variable de entorno `MATERIAL_MAKER`.

**4. Montarlos en Roblox Studio (PC Windows).**
1. **3D Importer** → `mdl_reloj_<nombre>.fbx` → unidad **Stud**. Se importa como un **Model** con un MeshPart por material (`metal_oro_pulido`, `cristal_zafiro`…). Guárdalo en `ReplicatedStorage/Assets` con su nombre exacto (`mdl_reloj_bolsillo`). `AssetLibrary` ya acepta Models.
2. Sube con el **Asset Manager** los 4 mapas de cada material usado (`art/texturas/export/tex_<material>_*.png`). Se suben una vez y se reutilizan en todos los relojes.
3. En cada MeshPart: borra el `TextureID` si lo trae y añade un **`SurfaceAppearance`** con `ColorMap` = `_color`, `NormalMap` = `_normal`, `RoughnessMap` = `_rugosidad` y `MetalnessMap` = `_metalico`. Truco: monta un `SurfaceAppearance` por material una vez y cópialo a los MeshParts con el mismo nombre.
4. **Cristal:** en el MeshPart `cristal_zafiro`, sube `Transparency` (entre 0,8 y 0,9, ajústalo a ojo) para que se vea la esfera. Metales, esmaltes, cuero y gemas no necesitan más ajustes: el aspecto lo da el `SurfaceAppearance`.
5. Comprueba la orientación (frente hacia −Z en Studio); si sale girado, usa el atributo `GiroY` (§5).

## 6. Control de recursos

Según [[Recursos-y-Referencias]] §8, todo recurso externo anota su procedencia, autor, licencia y permisos. Los assets hechos por el equipo o generados por script son propios. Las referencias externas van a `art/referencias/` con su fuente.

## 7. Lista de assets (prioridad y pieza que sustituyen)

Medidas en studs, tomadas de las piezas provisionales del código.

**Prioridad 1 — lo que más se ve**

| Asset | Sustituye a | Medida | Estado |
|---|---|---|---|
| `mdl_caminadora` | Caminadora del plot (PlotService) | 5 × 1 × 8 | ✅ Base generada (152 triángulos) |
| `mdl_plot_suelo`, `mdl_taller`, `mdl_vitrina`, `mdl_panel_plot` | Piezas del plot | 34×40 · 14×3,5×4 · 2×2,5×2 · 4×4×2 | ✅ Base (72 / 268 / 48 / 36 triángulos) |
| `mdl_estacion_tienda`, `_robux`, `_criadero`, `_cronometro`, `_carga` | Mostradores del muro (WorldService) | 14 × 5 × 8, más techo | ✅ Base (216 / 136 / 444 / 524 / 156) |
| `mdl_muro_frontal`, `mdl_cartel_salida` | Muro frontal | segmentos de 116 × 18 × 2 | ✅ Base (444 / 48) |
| `mdl_casa_z1` … `mdl_casa_z5`, `mdl_pedestal` | Casas por zona (HouseService) | 26 × 12 × 24 (puerta 8 × 9) | ✅ Base: madera, ladrillo, moderna, mansión y dorada con cúpula (128–336); pedestal 36 |
| `mdl_pieza_engranaje`, `_resorte`, `_tornillo`, `_cristal`, `_correa`, `_rubi`, `_diamante` | Esferas robables | ≈ 1,4 | ✅ Base (24–480) |
| `mdl_puerta_velocidad_poste` | Extremos de la barrera de zona (la barrera sigue siendo la pieza del código) | 2 × 2 × 40 | ✅ Base (132) |

**Prioridad 2 — progresión y recompensas**

| Asset | Sustituye a | Estado |
|---|---|---|
| `mdl_capsula_laton` | Cápsula (Criadero, Premios) | ✅ Base generada (328 triángulos) |
| `mdl_capsula_plata`, `_oro`, `_cosmica` | Cápsulas | ✅ Base (328 / 328 / 382; la Cósmica lleva estrellas) |
| `mdl_reloj_bolsillo`, `_pulsera`, `_cronografo`, `_legado`, `_real`, `_millonario` | Marcadores de las vitrinas | ✅ Detallados con materiales PBR (ART-006): Model con una malla por material, 960–2.090 triángulos |
| `mdl_legado_espiral`, `_corona`, `_rotor` | Pieza luminosa de la introducción | ✅ Base (488 / 272 / 160) |
| `mdl_mascota_raton`, `_gato`, `_zorro`, `_halcon`, `_dragon`, `_fenix`, `_titan`, `_senor_tiempo`, `_suprema` | Esferas de mascota (PetService) | ✅ Base (96–450) |
| Dueños de las casas | NPC de bloques (OwnerNpc) | Pendiente: personaje R15 con skins originales «al estilo» de Roblox, sin copiar personajes reales |

**Prioridad 3 — ambiente, interfaz y sonido** (ART-004)

| Asset | Uso | Estado |
|---|---|---|
| `mdl_arbol`, `mdl_arbusto`, `mdl_farola`, `mdl_banca`, `mdl_valla`, `mdl_roca`, `mdl_cartel_zona`, `mdl_caja_madera` | Ambiente de la base y de las zonas | ✅ Base (36–126 triángulos) |
| `ico_monedas`, `ico_velocidad`, `ico_mochila`, `ico_premios`, `ico_ruleta`, `ico_robux`, `ico_ajustes`, `ico_carga` | Iconos del HUD (PNG 256×256 con transparencia, en `art/texturas/export/`) | ✅ Retocados en ART-010 (propuesta): contorno oscuro de 7 px, sombra suave, transformación «Standard» y formas nuevas en monedas, mochila, carga (cajas apiladas) y robux (gema verde original, sin parecido con el logotipo oficial). Pendiente: retoque manual en Krita (`.kra` en `art/texturas/fuentes/`) |
| `sfx_robar`, `sfx_alarma_dueno`, `sfx_atrapado`, `sfx_guardar_botin`, `sfx_comprar`, `sfx_abrir_capsula`, `sfx_ruleta`, `sfx_subir_nivel`, `sfx_entrenar` (bucle de 1 s), `sfx_boton` | Efectos (OGG en `art/audio/export/`) | ✅ Base sintetizada (`art/audio/sonidos.py` → `convertir_ogg.py`). ART-010: todos por debajo de 2 s (`sfx_ruleta` pasó de 2,28 a 1,65 s). Pendiente: pulir en Audacity (`.aup3` en `art/audio/fuentes/`) |
| `mus_base`, `mus_persecucion` | Música | Pendiente: hacerla a mano o con licencia; no se sintetiza |

**Regenerar sonido e iconos**
```
# Windows
python art/audio/sonidos.py
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/audio/convertir_ogg.py
"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" --background --factory-startup --python art/blender/scripts/iconos.py
# macOS
python3 art/audio/sonidos.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/audio/convertir_ogg.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python art/blender/scripts/iconos.py
```

---

**Estado:** Propuesta (ART-001) · **Documentos relacionados:** [[Recursos-y-Referencias]], [[Diseño-del-Mundo]], [[GDD]], [[Changelog]]
