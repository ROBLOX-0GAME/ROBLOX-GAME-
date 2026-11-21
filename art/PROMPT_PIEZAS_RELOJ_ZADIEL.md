# Prompt — Piezas de reloj robables, mesa de armado y animaciones por rareza (Zadiel)

> **Actualizado en DEV-025 (2026-11-21)** con las respuestas de Jhonn (DEC-028): 12 rarezas, 16 relojes, calibre solo visual, visuales parecidas a los originales con nombres inventados, y el código ya programado (§8).
>
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

| Tipo | Cómo se ve |
|---|---|
| **Cuarzo** | Disco plano con una **pila** redonda y un circuito verde. Pocas piezas y limpio |
| **Mecánico** | **Engranajes visibles**, volante con espiral y rubíes rojos (puntos) |
| **Automático** | Como el mecánico, más un **rotor** en media luna que gira |

**Decidido (DEC-028):** el tipo de calibre es **solo visual**; no cambia valor ni suerte. Cada reloj tiene su tipo fijo (§4).

Animación del calibre en reposo: los engranajes giran despacio y el rotor oscila. **Solo en el cliente** y solo cuando la pieza está cerca (≤ 30 studs).

---

## 3. Rarezas: cómo se ve cada una

**Doce rarezas (DEC-028).** La rareza cambia **material, color y brillo**, no la forma. Reutiliza los materiales PBR que ya existen (`ids_roblox.md`) antes de crear otros nuevos. Los colores son los de `GameData.Rarities`, que el código ya usa en el mundo, en el panel y en los avisos.

| # | Rareza | Color (contorno) | Material principal | Brillo en el mundo |
|---|---|---|---|---|
| 1 | Común | Gris `#B0B4BC` | Acero (`metal_acero`) | Ninguno |
| 2 | Poco común | Verde `#4CAF6A` | Latón (`metal_laton`) | Ninguno |
| 3 | Raro | Azul `#3D8BFD` | Plata (`metal_plata`) + esmalte azul | Brillo suave (ya existe en `Vfx`) |
| 4 | Épico | Morado `#9B59E6` | Oro cepillado + esmalte negro | Brillo y destello cada 4 s |
| 5 | Legendario | Naranja/oro `#F2A032` | Oro pulido + rubí | Brillo, destello y rayos suaves |
| 6 | Mítico | Rojo `#E03C3C` | Oro pulido + diamante | Aura con partículas lentas |
| 7 | Divino | Amarillo `#FFDD33` con contorno blanco | Oro blanco + diamantes | Aura, partículas y halo blanco |
| 8 | Celestial | Cian `#5BD5E0` con contorno blanco | Cristal de zafiro + nácar | Halo que gira y estrellas pequeñas |
| 9 | Cósmico | Morado-rosa `#D65CE6` con contorno oscuro | Esmalte de galaxia | Nebulosa suave alrededor |
| 10 | Eterno | Blanco `#FFFFFF` con contorno dorado | Porcelana + oro | Rayos dorados lentos |
| 11 | Ancestral | Verde jade `#00A86B` con contorno negro | Jade + bronce antiguo | Runas que giran (1 emisor) |
| 12 | Atemporal | **Arcoíris** (degradado animado) | Cristal prismático | Aura arcoíris y destello; el más vistoso |

Desde **Mítico**, sale un aviso arriba de la pantalla para todo el servidor (ya programado, DEC-029).

---

## 4. Relojes (familias de piezas): decidido en DEC-028

Cada reloj tiene **su** caja, **su** calibre, **su** esfera y **sus** manecillas. Las piezas del mismo reloj comparten **un motivo visual** para que el jugador vea que van juntas. Las piezas de los relojes generales pueden salir en cualquier zona; desde la zona 3, cada zona tiene además **un reloj exclusivo**.

**Nombres y visuales (respuesta de Jhonn):** los nombres son **interpretados** (inventados, sin marcas), pero el **aspecto debe parecerse al reloj original** en el que se inspira: misma silueta, forma de caja, bisel, disposición de la esfera y colores típicos. **Nunca** pongas logos, coronas, textos ni nombres de marca reales en la esfera; usa el logo inventado del juego.

| # | Id | Nombre en el juego | Se parece a | Calibre | Dónde sale | Valor base (Común) |
|---|---|---|---|---|---|---|
| 1 | `pocket` | Reloj de bolsillo | Clásico de bolsillo con tapa | Mecánico | General | 60 |
| 2 | `wrist` | Reloj de pulsera | Pulsera sencilla de diario | Cuarzo | General | 150 |
| 3 | `chrono` | Cronógrafo | Cronógrafo deportivo de 3 subesferas | Mecánico | General | 400 |
| 4 | `legacy` | Reloj del Legado | Reloj único con la pieza del legado | Automático | General (necesita la pieza del legado) | 1.000 |
| 5 | `royal` | Reloj real de rubí | Reloj de gala con rubíes | Automático | General | 1.200 |
| 6 | `millionaire` | Reloj del millonario | Bisel de diamantes y esfera dorada | Automático | General | 3.000 |
| 7 | `fechador` | Rolando Fechamaster | Rolex Datejust (bisel estriado, lupa de fecha) | Automático | Zona 3 | 500 |
| 8 | `lunamaster` | Omigo Lunamaster | Omega Speedmaster (cronógrafo negro, taquímetro) | Mecánico | Zona 4 | 800 |
| 9 | `tanque` | Cartero Tanque | Cartier Tank (caja rectangular, números romanos) | Cuarzo | Zona 5 | 1.200 |
| 10 | `submar` | Rolando Submar | Rolex Submariner (bisel giratorio de buceo) | Automático | Zona 6 | 1.600 |
| 11 | `roblereal` | Audemar Roble Real | Audemars Piguet Royal Oak (bisel octogonal con tornillos, esfera de cuadros) | Automático | Zona 7 | 2.000 |
| 12 | `luminosa` | Panerei Luminosa | Panerai Luminor (caja cojín, protector de corona) | Mecánico | Zona 8 | 2.500 |
| 13 | `fusion` | Hublón Fusión de Cristal | Hublot Big Bang de zafiro (caja transparente) | Automático | Zona 9 | 3.000 |
| 14 | `nautil` | Philippon Nautil | Patek Philippe Nautilus (caja con «orejas», esfera horizontal en relieve) | Automático | Zona 10 | 3.500 |
| 15 | `patrimonio` | Vacherón Patrimonio | Vacheron Constantin Patrimony (de vestir, muy fino y limpio) | Mecánico | Zona 11 | 4.200 |
| 16 | `tourbillon` | Ricardo Mil Tourbillon | Richard Mille (caja tonneau, tourbillon a la vista) | Mecánico | Zona 12 | 5.000 |

El valor se multiplica por 6 en cada rareza. El mejor reloj del juego, el **Ricardo Mil Tourbillon Atemporal original** (sus 4 piezas propias y Atemporales), vale unos **1.800T** (rango acordado: 1.500T–1.950T). Su modelo armado debe ser el más espectacular.

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
- **Pieza de otro reloj:** se puede poner, pero el marco se vuelve **amarillo** con el aviso «de otro reloj: −1 rareza y −25 %» (decidido en DEC-028). Si las 4 piezas son ajenas, sale un «Reloj Genérico» que vale el 10 %.
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
| Divino y Celestial | + halo del color de la rareza | + mini cinemática: cielo con estrellas, las manecillas giran hacia atrás y luego hacia adelante, y un rayo de luz desde arriba | 4,0 s |
| Cósmico, Eterno y Ancestral | + halo y estela del color | + la cinemática de Divino con su color y su efecto (nebulosa, rayos dorados o runas) | 4,0 s |
| Atemporal | + destello arcoíris | + la cinemática completa en arcoíris; el reloj gira presentado | 4,0 s |
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
| Pieza suelta | `pz_<reloj>_<clase>` (ej.: `pz_chrono_dial`) | `Clase` = Caja/Calibre/Esfera/Manecillas · `Reloj` = id · `Rareza` | `PrimaryPart` en el centro |
| Calibre | `pz_<reloj>_calibre` | además `TipoCalibre` = Cuarzo/Mecanico/Automatico | `Rotor` y `Engranaje*` si gira |
| Reloj armado | `rlj_<reloj>_armado` | `Reloj`, `Rareza` | Mallas `Caja`, `Calibre`, `Esfera`, `Manecillas` · `Attachment` `Exp_Caja`, `Exp_Calibre`, `Exp_Esfera`, `Exp_Manecillas` (posición explosionada) |
| Efecto | `vfx_armar_<rareza>` · `vfx_reloj_perfecto` | — | Emisores desactivados |

Los ids de reloj son los de la tabla de §4 (`GameData.Watches`). La clase va en inglés en el nombre, como en el código: `case`, `movement`, `dial` y `hands` (ej.: `pz_chrono_dial`). El código ya busca `pz_<reloj>_<clase>` con `AssetLibrary.dress`. Mientras no exista, la pieza se ve con una forma provisional (cilindro o barra) del color de su rareza. Los relojes armados usan los nombres `mdl_reloj_*` de `AssetLibrary.WATCH_ASSETS`.

---

## 8. Lo que ya está programado (DEV-025, 2026-11-21)

**Esto no lo haces tú. Ya está en la place (v32) y en `game/src`:**
- Piezas `reloj.clase.rareza` en el inventario y en el botín de las casas; la tirada depende de la zona, con el reloj exclusivo desde la zona 3.
- Panel de la mesa con los 4 marcos en orden, la bandeja con los 3 modos de orden y la vista previa (§6). Es un panel de texto provisional: tu diseño y tus iconos lo sustituirán.
- Penalización por pieza ajena, valor, ingreso pasivo y suerte.
- Avisos desde Mítico.
- Falta en código (cuando entregues el arte): disparar las animaciones de §7 con las plantillas de §7.3, solo en el cliente.

---

## 9. Pasos para ART-018 (Zadiel)

1. **Reserva** (por ejemplo): `art/blender/**`, `art/texturas/fuentes/**`, `art/texturas/export/ico_pz_*.png`, `art/texturas/export/vfx_*.png`, `art/export/modelos/pz_*`, `art/export/modelos/rlj_*`, `art/audio/**`, `art/Pipeline-de-Arte.md`, `art/texturas/ids_roblox.md`, `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md` y `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md`.
2. **Bocetos (Krita):** 1 lámina por reloj con sus 4 piezas y las 12 rarezas en miniatura. Súbela a `art/referencias/` y pide a Jhonn que la mire **antes** de modelar.
3. **Modelos (Blender):** primero los 6 generales y luego los 10 exclusivos (4 piezas cada uno, más el modelo armado). Respeta §5.
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
- [ ] 12 rarezas con los colores y materiales de §3; relojes parecidos a sus originales, sin logos ni nombres de marca.
- [ ] 6 relojes actuales con sus 4 piezas y su modelo armado dentro del presupuesto de §5.
- [ ] Plantillas de efectos por rareza y de «Reloj perfecto», más épicas a mayor rareza.
- [ ] Iconos de §6.3 y sonidos de §7.2 subidos, con permisos.
- [ ] Contrato de nombres y atributos de §7.3 cumplido.
- [ ] Revisión de renderizado hecha y anotada.
