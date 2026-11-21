# Prompt — Piezas de reloj robables, mesa de armado y animaciones por rareza (Zadiel)

> Creado en **ART-017** (2026-11-21) por Claude en la PC de Jhonn, a partir de lo que pidió Jhonn. **Es un documento para revisar antes de ejecutarlo:** Jhonn puede cambiar cualquier cosa. Las dudas abiertas están en [[Recomendaciones-Claude]] (R-007 a R-010). Lo marcado como **Propuesta** necesita el visto bueno de Zadiel y Jhonn (DEC-020).
>
> **Para usarlo:** copia este archivo completo en Claude Code (en la raíz del repositorio) y pídele que siga la sección 9.

---

## 0. Qué pide Jhonn (resumen)

1. Las casas ya no tendrán piezas genéricas (engranaje, resorte…): tendrán **piezas de reloj reales**, de 4 clases:
   - **Caja** — la base del reloj, donde va todo.
   - **Movimiento o calibre** — el motor del reloj: de **cuarzo**, **mecánico** o **automático**.
   - **Esfera** — el dial: la carátula visible con los números o índices.
   - **Manecillas** — las agujas de horas, minutos y segundos.
2. **Animaciones visuales épicas** al armar un reloj: cuanto más rara la pieza o el reloj, más épica. Hay una animación especial cuando se arma un **reloj completo** (las 4 piezas correctas de ese reloj).
3. **Mesa de armado:** las piezas se ordenan para verlas fácil, **por reloj** (las del mismo reloj juntas) o **por rareza** (de menor a mayor o de mayor a menor). Hay **4 marcos verdes** que indican dónde va cada pieza, en este orden: **caja → calibre → esfera → manecillas**.
4. **Se puede poner una pieza de otro reloj**, pero el reloj **pierde rareza y valor**, y por tanto pierde **ingreso pasivo** y **% de suerte** cuando se exhibe.
5. Herramientas: **Krita, Blender y Roblox Studio** (más Material Maker y Audacity, que ya usamos).
6. **Siempre pensar en el renderizado:** que corra bien en móvil.

---

## 1. Antes de empezar (reglas del equipo)

1. Haz `git pull` y lee: `.claude/CLAUDE.md`, `AGENTS.md`, `ACTIVE_TASKS.md`, [[Backlog]], [[Registro-de-Decisiones]] (DEC-016, 018, 024, 025 y 026), [[Pipeline-de-Arte]] (§1 a §5), [[UI-UX]] §12 y [[Recomendaciones-Claude]].
2. Flujo DEC-009:
   - Registra tu tarea (por ejemplo **ART-018**) en el Backlog y reserva solo tus rutas en `ACTIVE_TASKS.md`.
   - Haz commit y push de la reserva antes de editar.
   - Haz `git pull` antes de cada push. Nunca uses force push.
3. **No cambies reglas del juego en `game/src`**: valores, piezas, recetas, guardado o servidor. Eso será una tarea DEV de Jhonn (ver §8). Tú entregas modelos, texturas, efectos y la especificación visual. Los efectos que solo se ven en el cliente (`Client/Vfx.luau`, que hiciste en ART-015) sí puedes prepararlos, reservando esa ruta.
4. Lo nuevo de estilo va como **Propuesta** al Registro (siguiente número libre, por ejemplo DEC-027).
5. **Permisos de audio (lección de BUG-004):** los sonidos subidos con tu cuenta necesitan permiso de uso para la experiencia **10778093657** (Open Cloud `asset-permissions`). Las imágenes y los modelos no lo necesitan.

---

## 2. Las 4 clases de pieza (diseño)

Todas se ven **low-poly colorido con PBR** (DEC-016, DEC-018 y DEC-025): formas simples, siluetas claras y materiales que brillan. Cada pieza debe reconocerse **a 20 studs y en una pantalla de móvil**.

| Clase | Qué es | Silueta (debe leerse sola) | Detalles mínimos |
|---|---|---|---|
| **Caja** | La base que lo contiene todo | Aro grueso con asas (lugs) para la correa y la corona a la derecha | Bisel, corona y fondo. Con o sin correa (si la lleva, que sea corta) |
| **Calibre** | El motor | Disco más pequeño que la caja, con detalle mecánico | Según el tipo (abajo) |
| **Esfera** | La carátula | Disco plano con 12 índices o números | Índices en relieve, logo **inventado** (nunca marcas reales) y subesferas en los relojes caros |
| **Manecillas** | Las agujas | 3 agujas unidas en el centro | Hora (corta y ancha), minutos (larga) y segundos (fina, de color) |

### Los 3 tipos de calibre

| Tipo | Cómo se ve | Idea de juego (propuesta R-009) |
|---|---|---|
| **Cuarzo** | Disco plano con una **pila** redonda y un circuito verde. Pocas piezas y limpio | El más común |
| **Mecánico** | **Engranajes visibles**, volante con espiral y rubíes rojos (puntos) | +10 % de valor |
| **Automático** | Como el mecánico, más un **rotor** en media luna que gira | +20 % de valor y +2 % de suerte exhibido |

Animación del calibre en reposo: los engranajes giran despacio y el rotor oscila. **Solo en el cliente** y solo cuando la pieza está cerca (≤ 30 studs).

---

## 3. Rarezas: cómo se ve cada una

Siete rarezas. La rareza cambia **material, color y brillo**, no la forma. Reutiliza los materiales PBR que ya existen (`ids_roblox.md`) antes de crear otros nuevos.

| Rareza | Color del marco y del brillo | Material principal | Brillo en el mundo |
|---|---|---|---|
| Común | Gris `#B0B4BC` | Acero (`metal_acero`) | Ninguno |
| Poco común | Verde `#4CAF6A` | Latón (`metal_laton`) | Ninguno |
| Raro | Azul `#3D8BFD` | Plata (`metal_plata`) + esmalte azul | Brillo suave (ya existe en `Vfx`) |
| Épico | Morado `#9B59E6` | Oro cepillado + esmalte negro | Brillo y destello cada 4 s |
| Legendario | Oro `#F2C14E` | Oro pulido + rubí | Brillo, destello y rayos suaves |
| Mítico | Rojo `#E04848` | Oro pulido + diamante + esmalte cósmico | Aura con partículas lentas |
| Divino | Cian `#5BD5E0` (degradado) | Cristal de zafiro + esmalte cósmico + diamante | Aura, partículas y un halo que gira |

---

## 4. Relojes (familias de piezas) — propuesta R-010

Cada reloj tiene **su** caja, **su** calibre, **su** esfera y **sus** manecillas. Las piezas del mismo reloj comparten **un motivo visual** (color de acento, forma de los índices…) para que el jugador vea que van juntas.

| # | Reloj | Rareza | Calibre | Motivo visual |
|---|---|---|---|---|
| 1 | Reloj de bolsillo | Común | Mecánico | Tapa con bisagra y cadena corta; números romanos |
| 2 | Reloj de pulsera | Poco común | Cuarzo | Caja redonda sencilla; índices de barra |
| 3 | Cronógrafo | Raro | Mecánico | 3 subesferas y pulsadores a los lados |
| 4 | Reloj real de rubí | Épico | Automático | Rubíes en los índices; bisel acanalado |
| 5 | Reloj del millonario | Legendario | Automático | Bisel de diamantes; esfera dorada |
| 6 | Reloj del Legado | Mítico | Automático | Usa la pieza del legado; esfera cósmica |
| 7 | Reloj del Capitán (zona 6) | Raro | Automático | Bisel giratorio de buceo; acento azul mar |
| 8 | Reloj del Banquero (zona 7) | Épico | Mecánico | Caja rectangular art déco |
| 9 | Reloj de la Isla (zona 8) | Épico | Automático | Esfera verde turquesa con palmeras grabadas |
| 10 | Reloj de Cristal (zona 9) | Legendario | Automático | Caja transparente (cristal de zafiro) con el calibre a la vista |
| 11 | Reloj Imperial (zona 10-11) | Mítico | Automático | Corona y águila inventadas; oro y morado |
| 12 | Reloj del Tiempo (zona 12) | Divino | Automático | Esfera de galaxia que gira; manecillas de luz |

Todos los nombres y diseños son **originales**: nada de marcas, logos ni modelos reales (Rolex, Patek, etc.).

---

## 5. Presupuesto de renderizado (obligatorio)

| Elemento | Límite |
|---|---|
| Pieza suelta (en el mundo) | **≤ 800 triángulos**, 1 a 3 mallas (una por material), tamaño ≈ 1,4 studs |
| Reloj armado (vitrina o mesa) | **≤ 3.000 triángulos** (como DEC-018) |
| Texturas | Reutilizar los mapas PBR existentes (sin subir mapas nuevos si el material ya existe); nuevos a **512 px** como máximo |
| Partículas | Máximo **3 emisores** a la vez por efecto, `Rate` ≤ 40 y vida ≤ 1,5 s; los efectos Mítico y Divino duran como mucho 4 s |
| Luces | Como máximo **1 `PointLight`** por pieza (las de Raro en adelante) y ninguna en Común o Poco común |
| Calidad | `RenderFidelity = Automatic` en las mallas, para que Roblox simplifique a distancia |
| Dónde se ven | Los efectos van **solo en el cliente** (`Vfx`), nunca en el servidor; si el jugador está a más de 60 studs, no se reproducen |
| Móvil | Respeta el ajuste «Efectos sí/no» de ART-016; con efectos desactivados solo se ve el destello final |

---

## 6. Mesa de armado (taller del plot)

Es la mesa que ya existe al fondo del plot (`mdl_taller`). Al usarla se abre un **panel de armado** (la parte de juego la programa Jhonn; tú entregas el diseño, los iconos y los efectos).

### 6.1 Disposición (propuesta)

```
┌──────────────────────── MESA DE ARMADO ────────────────────────┐
│  Reloj elegido: [ Cronógrafo ▼ ]      Ordenar: [Por reloj ▼]    │
│                                       (Por reloj · Rareza ↑ · ↓) │
│  ┌──────┐ → ┌──────┐ → ┌──────┐ → ┌──────┐                      │
│  │ CAJA │   │CALIBRE│  │ESFERA│   │MANEC.│   ← 4 marcos VERDES   │
│  │  1   │   │  2   │   │  3   │   │  4   │     (orden obligatorio)│
│  └──────┘   └──────┘   └──────┘   └──────┘                      │
│  Vista previa: Cronógrafo · Raro · 400 monedas · +12/min · +2 %  │
│                                                                  │
│  TUS PIEZAS (bandeja)                                            │
│  [Cronógrafo: Caja✔ Calibre✔ Esfera✔ Manecillas✔]               │
│  [Bolsillo: Caja ·  Esfera ·]   [Pulsera: Calibre ·]   …         │
│                                       [ ARMAR RELOJ ]            │
└──────────────────────────────────────────────────────────────────┘
```

### 6.2 Reglas visuales

- **Marcos verdes** (`#4CAF6A`, borde de 3 px) con el icono de la clase en gris claro y su número (1 a 4).
- **Orden obligatorio:** solo se ilumina el siguiente marco libre. El jugador no puede poner la esfera antes que el calibre (el marco siguiente parpadea suave para guiar).
- **Pieza correcta** (del reloj elegido): el marco queda **verde fijo** y aparece un ✔.
- **Pieza de otro reloj:** se puede poner, pero el marco se vuelve **amarillo** con el aviso «Pieza de otro reloj: −1 rareza, −25 % valor, ingreso y suerte» (propuesta R-008). Con 3 o más ajenas, el marco es **naranja**.
- **Vista previa en vivo:** rareza final, valor, ingreso por minuto y suerte, recalculados al poner cada pieza. Si baja algo, se muestra en rojo con una flecha ↓.
- **Ordenar la bandeja:**
  - **Por reloj** (por defecto): agrupa las piezas del mismo reloj y pone primero los relojes completos o casi completos.
  - **Rareza ↑ / Rareza ↓:** ordena por rareza.
- **Accesible:** funciona con clic, toque y mando (la cruceta mueve entre la bandeja y los marcos; A coloca). Los colores siempre van con un icono o un texto (✔, ⚠), no solo el color.

### 6.3 Iconos que necesita el panel (Krita, PNG 256×256 con transparencia, estilo de ART-010/014)

`ico_pz_caja`, `ico_pz_calibre`, `ico_pz_esfera`, `ico_pz_manecillas`, `ico_calibre_cuarzo`, `ico_calibre_mecanico`, `ico_calibre_automatico`, `ico_ok` (✔), `ico_aviso` (⚠) y un **marco de rareza** de 9 piezas (9-slice, `ui_marco_rareza.png`) que el código colorea.

---

## 7. Animaciones de armado (lo épico)

Hay dos momentos:

- **(A) Colocar una pieza:** la pieza vuela desde la bandeja hasta su marco y encaja.
- **(B) Armar el reloj:** las 4 piezas se juntan en 3D sobre la mesa del plot y el reloj terminado se presenta.

Cuanto más rara la pieza o el reloj, más épico. Si el reloj es **completo** (las 4 piezas correctas), se suma un remate especial: **«¡Reloj perfecto!»**.

### 7.1 Niveles de épica

| Rareza del reloj | Colocar pieza (A) | Armar el reloj (B) | Duración de B |
|---|---|---|---|
| Común | Encaje con un «clic» | Las piezas se apilan y hay un destello gris | 0,8 s |
| Poco común | + chispas verdes | + anillo de luz verde que se expande | 1,0 s |
| Raro | + estela azul en el vuelo | **Vista explosionada**: las piezas flotan separadas y bajan una a una | 1,5 s |
| Épico | + campanilla | + engranajes morados que giran detrás y la cámara se acerca un poco | 2,0 s |
| Legendario | + destello dorado | + rayos de luz dorados (Beams) y monedas que saltan | 2,5 s |
| Mítico | + pulso rojo | + «el tiempo se detiene»: desaturación breve y vórtice de engranajes | 3,0 s |
| Divino | + halo cian | + mini cinemática: cielo con estrellas, las manecillas giran hacia atrás y luego hacia adelante, y un rayo de luz desde arriba | 4,0 s |
| **Reloj perfecto** (cualquier rareza) | — | Remate: texto «¡RELOJ PERFECTO!», confeti de engranajes y sonido especial | +0,8 s |

Con **piezas de otro reloj**, la animación usa el nivel de la rareza **final** (rebajada) y no hay remate de «Reloj perfecto».

### 7.2 Con qué herramienta se hace cada cosa

**Krita (2D):**
- **Flipbooks** para partículas: chispa (4×4 cuadros), engranaje girando (8×8), estrella/destello (4×4), confeti de engranajes (4×4) y anillo de choque (4×4). PNG de **1024×1024** con transparencia; cada cuadro, centrado.
- Texturas de **Beam**: rayo dorado y rayo cian (256×64, degradado a transparente en los extremos).
- Texto «¡RELOJ PERFECTO!» como imagen (o fuente Gotham Black con borde de latón, si se hace en la UI).

**Blender (3D):**
- Modelar cada pieza (§2 y §4) con el script de base que ya usamos (`art/blender/scripts/`) y luego retocarla a mano.
- Para cada reloj, un **modelo armado** con las 4 piezas como mallas separadas y bien colocadas: `rlj_<reloj>_armado`.
- **Vista explosionada:** no exportes animación. Pon en Blender un *empty* por pieza en la posición «separada» (por ejemplo, 1,5 studs más arriba, en escalera) y anota esas posiciones. En Studio se convierten en `Attachment` (§7.3) y el código hace la animación con `TweenService`. Así pesa menos y funciona en todos los dispositivos.
- El **rotor** del automático y los **engranajes** del mecánico como mallas aparte (para girarlas en Studio).

**Roblox Studio (montaje y efectos):**
- Importa con el MCP (`open_cloud_invoke` + `insert_asset`) como en ART-008/013, con **escala ×0,01**.
- Monta los efectos como **plantillas** dentro de `ReplicatedStorage/Assets/Vfx`:
  - `vfx_armar_<rareza>`: un `Model` con `Attachment` + `ParticleEmitter` (flipbooks de Krita, `FlipbookLayout` 4×4 u 8×8), `Beam` y `PointLight`, todos con `Enabled = false`. El código los clona y los dispara con `:Emit()`.
  - `vfx_reloj_perfecto`: confeti y destello final.
- Sonidos (Audacity): `sfx_encajar` (clic, < 0,3 s), `sfx_armar_<rareza>` (7, de 1 a 3 s, que suban de intensidad) y `sfx_reloj_perfecto`. Recuerda el permiso de audio (§1.5).

### 7.3 Contrato con el código (para que Jhonn lo programe sin adivinar)

Cada asset en `ReplicatedStorage/Assets` con estos **nombres y atributos**:

| Asset | Nombre | Atributos | Hijos obligatorios |
|---|---|---|---|
| Pieza suelta | `pz_<reloj>_<clase>` (ej.: `pz_cronografo_esfera`) | `Clase` = Caja/Calibre/Esfera/Manecillas · `Reloj` = id · `Rareza` | `PrimaryPart` en el centro |
| Calibre | `pz_<reloj>_calibre` | además `TipoCalibre` = Cuarzo/Mecanico/Automatico | `Rotor` y `Engranaje*` si gira |
| Reloj armado | `rlj_<reloj>_armado` | `Reloj`, `Rareza` | Mallas `Caja`, `Calibre`, `Esfera`, `Manecillas` · `Attachment` `Exp_Caja`, `Exp_Calibre`, `Exp_Esfera`, `Exp_Manecillas` (posición explosionada) |
| Efecto | `vfx_armar_<rareza>` · `vfx_reloj_perfecto` | — | Emisores desactivados |

Los ids de reloj usan los de `GameData.Watches` (`pocket`, `wrist`, `chrono`, `royal`, `millionaire`, `legacy`) y, para los nuevos, los que se aprueben en R-010.

---

## 8. Lo que hará Jhonn en código (tarea DEV aparte; para que sepas qué esperar)

**Esto no lo haces tú. Es para que el arte encaje:**
- Nuevas piezas: `{ reloj, clase, rareza, tipoCalibre }` en el inventario y en el botín de las casas (cada zona da sobre todo piezas de sus relojes).
- Panel de armado con los marcos, el orden y la vista previa (§6).
- Penalización por pieza ajena (R-008), valor, ingreso pasivo y suerte.
- Disparo de las animaciones (§7) con las plantillas de §7.3, solo en el cliente.
- Conversión de las piezas antiguas al cargar los datos (R-007).

---

## 9. Pasos para ART-018 (Zadiel)

1. **Reserva** (por ejemplo): `art/blender/**`, `art/texturas/fuentes/**`, `art/texturas/export/ico_pz_*.png`, `art/texturas/export/vfx_*.png`, `art/export/modelos/pz_*`, `art/export/modelos/rlj_*`, `art/audio/**`, `art/Pipeline-de-Arte.md`, `art/texturas/ids_roblox.md`, `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md` y `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md`.
2. **Bocetos (Krita):** 1 lámina por reloj con sus 4 piezas y las 7 rarezas en miniatura. Súbela a `art/referencias/` y pide a Jhonn que la mire **antes** de modelar.
3. **Modelos (Blender):** primero los 6 relojes actuales (4 piezas cada uno, más el modelo armado). Respeta §5.
4. **Iconos (Krita):** los de §6.3.
5. **Efectos (Krita + Studio):** flipbooks y Beams; plantillas `vfx_*` en `ReplicatedStorage/Assets/Vfx`.
6. **Sonidos (Audacity):** los de §7.2, con su permiso de audio.
7. **Subir y montar con el MCP** (ART-008/013): IDs en `art/texturas/ids_roblox.md`.
8. **Revisar el renderizado:** `rbx-scene-analysis` (triángulos y memoria) y una partida en el simulador de móvil (`rbx-device-simulator-lua`).
9. **Capturas** a `art/export/vistas/` y nota en [[Pipeline-de-Arte]].
10. **Registro:** DEC-027 (Propuesta) con el estilo de las piezas y los niveles de épica.
11. **Cierre:** Backlog, Memoria del área 12, fila Completada y crear la tarea DEV para Jhonn con el contrato de §7.3.

## 10. Criterios de aceptación

- [ ] Las 4 clases se distinguen a 20 studs y en móvil; los 3 tipos de calibre se reconocen.
- [ ] 7 rarezas con colores y materiales de §3, sin marcas reales.
- [ ] 6 relojes actuales con sus 4 piezas y su modelo armado dentro del presupuesto de §5.
- [ ] Plantillas de efectos por rareza y de «Reloj perfecto», más épicas a mayor rareza.
- [ ] Iconos de §6.3 y sonidos de §7.2 subidos, con permisos.
- [ ] Contrato de nombres y atributos de §7.3 cumplido.
- [ ] Revisión de renderizado hecha y anotada.
