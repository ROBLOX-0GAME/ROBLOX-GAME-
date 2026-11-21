# Prompt — Piezas de reloj robables, mesa de armado y animaciones por rareza (Zadiel)

> **Actualizado en DOC-001 (2026-11-21):** §11 con **la lista completa de tareas de Zadiel**, en orden, incluidos los permisos de sonido automáticos para su Claude. Ver §11 antes que nada.
>
> **Actualizado en DEV-026 (2026-11-21):** 12 relojes de lujo, uno por zona, con el material de cada zona (DEC-031, §4.1).
>
> **Actualizado en DEV-025 (2026-11-21)** con las respuestas de Jhonn (DEC-028): 12 rarezas, 16 relojes, calibre solo visual, visuales parecidas a los originales con nombres inventados, y el código ya programado (§8).
>
> Creado en **ART-017** (2026-11-21) por Claude en la PC de Jhonn, a partir de lo que pidió Jhonn. **Es un documento para revisar antes de ejecutarlo:** Jhonn puede cambiar cualquier cosa. Las dudas R-007 a R-010 de [[Recomendaciones-Claude]] ya están respondidas por Jhonn y aplicadas (DEC-028 y DEC-031). Lo marcado como **Propuesta** necesita el visto bueno de Zadiel y Jhonn (DEC-020).
>
> **Para usarlo:** abre Claude Code en la raíz del repositorio y pídele: «Lee `art/PROMPT_PIEZAS_RELOJ_ZADIEL.md` y haz las tareas de la §11 en orden». La §11 remite a las demás secciones cuando hace falta.

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

1. Haz `git pull` y lee: `.claude/CLAUDE.md`, `AGENTS.md`, `ACTIVE_TASKS.md`, [[Backlog]], [[Registro-de-Decisiones]] (DEC-016, 018, 024, 025, 026 y **028 a 031**), [[Pipeline-de-Arte]] (§1 a §5), [[UI-UX]] §12 y [[Recomendaciones-Claude]].
2. Flujo DEC-009:
   - Registra tu tarea (por ejemplo **ART-018**) en el Backlog y reserva solo tus rutas en `ACTIVE_TASKS.md`.
   - Haz commit y push de la reserva antes de editar.
   - Haz `git pull` antes de cada push. Nunca uses force push.
3. **No cambies reglas del juego en `game/src`**: valores, piezas, recetas, guardado o servidor. Eso será una tarea DEV de Jhonn (ver §8). Tú entregas modelos, texturas, efectos y la especificación visual. Lo que solo se ve en el cliente sí puedes tocarlo, reservando esas rutas: `Client/Vfx.luau` (ART-015) y la interfaz de [[UI-UX]] §12 (ART-016, §11.3).
4. Lo nuevo de estilo va como **Propuesta** al Registro (siguiente número libre: **DEC-032**; mira antes el Registro por si alguien lo usó).
5. **Permisos de audio (lección de BUG-004):** los sonidos subidos con tu cuenta necesitan permiso de uso para la experiencia **10778093657**. Las imágenes y los modelos no lo necesitan. Tu Claude lo hace solo, con el procedimiento de §11.2.

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

## 4. Relojes (familias de piezas): DEC-028 y DEC-031

Cada reloj tiene **su** caja, **su** calibre, **su** esfera y **sus** manecillas. Las piezas del mismo reloj comparten **un motivo visual** para que el jugador vea que van juntas.

**Nombres y visuales (respuesta de Jhonn):** los nombres son **interpretados** (inventados, sin marcas), pero el **aspecto debe parecerse al reloj original** en el que se inspira: misma silueta, forma de caja, bisel, disposición de la esfera y colores típicos. **Nunca** pongas logos, coronas, textos ni nombres de marca reales en la esfera; usa el logo inventado del juego.

### 4.1 Los 12 relojes de lujo: uno exclusivo por zona (DEC-031)

Lista elegida por Jhonn. Cada reloj **solo sale en su zona** y se hace con el **material de esa zona**, que además encaja con el ambiente de las casas. La rareza (§3) se suma encima: cambia el acabado y el brillo, pero el material base del reloj se reconoce siempre.

| Zona | Id | Nombre en el juego | Se parece a | Rasgos que deben leerse | Material de la zona | Calibre | Valor base |
|---|---|---|---|---|---|---|---|
| 1 · Barrio Humilde | `lunamaster` | Omigo Lunamaster | Omega Speedmaster | Cronógrafo negro, 3 subesferas, bisel taquimétrico | Acero mate | Mecánico | 200 |
| 2 · Barrio Obrero | `santo` | Cartero Santo | Cartier Santos | Caja cuadrada, 8 tornillos en el bisel, números romanos | Acero cepillado con tornillos vistos | Automático | 300 |
| 3 · Zona Residencial | `reverso` | Jaguar-LeColtre Reversible | Jaeger-LeCoultre Reverso | Caja rectangular art déco con gallones; se da la vuelta | Acero y esmalte art déco | Mecánico | 500 |
| 4 · Mansiones | `daytona` | Rolando Daytuna | Rolex Daytona | Cronógrafo, bisel taquimétrico, brazalete de 3 eslabones | Oro amarillo | Automático | 800 |
| 5 · Colina de los Millonarios | `overseas` | Vacherón Ultramar | Vacheron Constantin Overseas | Bisel con 6 muescas (cruz de Malta), esfera con relieve solar | Oro rosa | Automático | 1.200 |
| 6 · Puerto de los Yates | `nautil` | Philippon Nautil | Patek Philippe Nautilus | Bisel octogonal redondeado con «orejas», esfera azul con relieve horizontal | Acero con esfera azul | Automático | 1.600 |
| 7 · Distrito Financiero | `roblereal` | Audemar Roble Real | Audemars Piguet Royal Oak | Bisel octogonal con 8 tornillos hexagonales, esfera de cuadros, brazalete integrado | Acero y oro blanco | Automático | 2.000 |
| 8 · Isla Privada | `bigbang` | Hublón Gran Explosión | Hublot Big Bang | Caja robusta, bisel con 6 tornillos en H, correa de caucho | Cerámica y caucho | Automático | 2.500 |
| 9 · Ciudad de Cristal | `rm11` | Ricardo Mil RM-11 | Richard Mille RM 11 | Caja tonneau, esfera calada que deja ver el calibre | Carbono y zafiro transparente | Automático | 3.000 |
| 10 · Valle Dorado | `tourbillon` | Bregué Clásico Tourbillon | Breguet Classique Tourbillon | Caja redonda con canto acanalado, esfera guilloché, tourbillon a la vista, agujas de punta hueca | Oro con guilloché | Mecánico | 3.500 |
| 11 · Palacio Imperial | `granmaestro` | Philippon Gran Maestro Campana | Patek Philippe Grandmaster Chime | Caja grabada a mano, dos esferas (reversible), complicaciones | Oro rosa y esmalte | Mecánico | 4.200 |
| 12 · Ciudadela del Tiempo | `astronomia` | Jacobo y Cía. Astronomía | Jacob & Co. Astronomia | Cúpula de zafiro con globo terráqueo, luna y tourbillon que giran a la vista | Zafiro y gemas | Mecánico | 5.000 |

**El mejor reloj del juego** es el **Jacobo y Cía. Astronomía Atemporal original** (sus 4 piezas propias y Atemporales): vale unos **1.800T** (rango acordado: 1.500T–1.950T). Su modelo armado debe ser el más espectacular, con el globo y el tourbillon girando (solo en el cliente, §5).

### 4.2 Los 6 relojes generales: salen al azar en cualquier zona

| # | Id | Nombre en el juego | Aspecto | Calibre | Valor base |
|---|---|---|---|---|---|
| 1 | `pocket` | Reloj de bolsillo | Clásico de bolsillo con tapa y cadena; números romanos | Mecánico | 60 |
| 2 | `wrist` | Reloj de pulsera | Pulsera sencilla de diario; índices de barra | Cuarzo | 150 |
| 3 | `chrono` | Cronógrafo | Deportivo de 3 subesferas con pulsadores | Mecánico | 400 |
| 4 | `legacy` | Reloj del Legado | Único; usa la pieza del legado; esfera cósmica | Automático | 1.000 |
| 5 | `royal` | Reloj real de rubí | De gala, con rubíes en los índices y bisel acanalado | Automático | 1.200 |
| 6 | `millionaire` | Reloj del millonario | Bisel de diamantes y esfera dorada | Automático | 3.000 |

El valor se multiplica por 6 en cada rareza (§3).

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
- Sonidos (Audacity): `sfx_encajar` (clic, < 0,3 s), `sfx_armar_<rareza>` (**12**, uno por rareza, de 1 a 3 s, que suban de intensidad) y `sfx_reloj_perfecto`. Tu Claude les da el permiso de audio al subirlos (§11.2).

### 7.3 Contrato con el código (para que Jhonn lo programe sin adivinar)

Cada asset en `ReplicatedStorage/Assets` con estos **nombres y atributos**:

| Asset | Nombre | Atributos | Hijos obligatorios |
|---|---|---|---|
| Pieza suelta | `pz_<reloj>_<clase>` (ej.: `pz_chrono_dial`) | `Clase` = Caja/Calibre/Esfera/Manecillas · `Reloj` = id · `Rareza` | `PrimaryPart` en el centro |
| Calibre | `pz_<reloj>_movement` (ej.: `pz_astronomia_movement`) | además `TipoCalibre` = Cuarzo/Mecanico/Automatico | `Rotor` y `Engranaje*` si gira |
| Reloj armado | El nombre de `AssetLibrary.WATCH_ASSETS` (ej.: `mdl_reloj_bolsillo`, `mdl_reloj_astronomia`) | `Reloj`, `Rareza` | Mallas `Caja`, `Calibre`, `Esfera`, `Manecillas` · `Attachment` `Exp_Caja`, `Exp_Calibre`, `Exp_Esfera`, `Exp_Manecillas` (posición explosionada) |
| Efecto | `vfx_armar_<rareza>` · `vfx_reloj_perfecto` | — | Emisores desactivados |

Los ids de reloj son los de la tabla de §4 (`GameData.Watches`). La clase va en inglés en el nombre, como en el código: `case`, `movement`, `dial` y `hands` (ej.: `pz_chrono_dial`). El código ya busca `pz_<reloj>_<clase>` con `AssetLibrary.dress`. Mientras no exista, la pieza se ve con una forma provisional (cilindro o barra) del color de su rareza. Los relojes armados usan los nombres `mdl_reloj_*` de `AssetLibrary.WATCH_ASSETS`.

---

## 8. Lo que ya está programado (DEV-025 a DEV-027, 2026-11-21)

**Esto no lo haces tú. Ya está en la place (v35) y en `game/src`, con 53/53 pruebas:**
- Piezas `reloj.clase.rareza` en el inventario y en el botín de las casas; la tirada depende de la zona, con el reloj de lujo exclusivo de cada zona (DEC-031).
- Panel de la mesa con los 4 marcos en orden, la bandeja con los 3 modos de orden y la vista previa (§6). Es un panel de texto provisional: tu diseño y tus iconos lo sustituirán.
- Penalización por pieza ajena, valor, ingreso pasivo y suerte.
- Avisos desde Mítico.
- La mesa ya no se cierra sola (DEV-026) y el aviso de robo muestra las monedas que se cobrarán (DEV-027).
- Falta en código (cuando entregues el arte): disparar las animaciones de §7 con las plantillas de §7.3, solo en el cliente.

---

## 9. Pasos para ART-018 (Zadiel)

1. **Reserva** (por ejemplo): `art/blender/**`, `art/texturas/fuentes/**`, `art/texturas/export/ico_pz_*.png`, `art/texturas/export/vfx_*.png`, `art/export/modelos/pz_*`, `art/export/modelos/rlj_*`, `art/audio/**`, `art/Pipeline-de-Arte.md`, `art/texturas/ids_roblox.md`, `12 - RECURSOS Y REFERENCIAS/Memoria-de-Area.md` y `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md`.
2. **Bocetos (Krita):** 1 lámina por reloj con sus 4 piezas y las 12 rarezas en miniatura. Súbela a `art/referencias/` y pide a Jhonn que la mire **antes** de modelar.
3. **Modelos (Blender):** primero los 6 generales y luego los 12 de lujo, de la zona 1 a la 12 (4 piezas cada uno, más el modelo armado). Respeta §5.
4. **Iconos (Krita):** los de §6.3.
5. **Efectos (Krita + Studio):** flipbooks y Beams; plantillas `vfx_*` en `ReplicatedStorage/Assets/Vfx`.
6. **Sonidos (Audacity):** los de §7.2. Al subirlos, tu Claude les da permiso y lo comprueba (§11.2).
7. **Subir y montar con el MCP** (ART-008/013): IDs en `art/texturas/ids_roblox.md`.
8. **Revisar el renderizado:** `rbx-scene-analysis` (triángulos y memoria) y una partida en el simulador de móvil (`rbx-device-simulator-lua`).
9. **Capturas** a `art/export/vistas/` y nota en [[Pipeline-de-Arte]].
10. **Registro:** DEC-032 (Propuesta) con el estilo de las piezas y los niveles de épica.
11. **Cierre:** Backlog, Memoria del área 12, fila Completada y crear la tarea DEV para Jhonn con el contrato de §7.3.

## 10. Criterios de aceptación

- [ ] Las 4 clases se distinguen a 20 studs y en móvil; los 3 tipos de calibre se reconocen.
- [ ] 12 rarezas con los colores y materiales de §3; relojes parecidos a sus originales, sin logos ni nombres de marca.
- [ ] Los 18 relojes (6 generales y 12 de lujo) con sus 4 piezas y su modelo armado dentro del presupuesto de §5.
- [ ] Plantillas de efectos por rareza y de «Reloj perfecto», más épicas a mayor rareza.
- [ ] Iconos de §6.3 y sonidos de §7.2 subidos; los sonidos con permiso para 10778093657 y 100 % *Success* en la comprobación de §11.2.
- [ ] Contrato de nombres y atributos de §7.3 cumplido.
- [ ] Revisión de renderizado hecha y anotada.

---

## 11. Lista completa de tareas de Zadiel (en orden)

> Añadida en DOC-001 (2026-11-21) a pedido de Jhonn. Es **todo** lo que queda de tu parte. Haz cada bloque como una tarea propia (ID en el Backlog, reserva de rutas, commit y push), con el flujo de §1. Si algo no está claro, pregunta a Jhonn antes de decidir por tu cuenta.

### 11.1 Revisar lo que Jhonn decidió e hizo en tu ausencia (primero)

Eres el revisor de estas tareas. Lee cada una, prueba en Play lo que te toque y deja tu visto bueno o tus cambios en el Backlog y el Registro:

| Qué | Dónde | Qué mirar |
|---|---|---|
| DEC-028 · Piezas, 12 rarezas y pieza ajena | Registro | ¿Te encaja para el arte? |
| DEC-029 · Piezas compartidas, reinicio cada 5 min y avisos | Registro | El aviso arriba de la pantalla (colores por rareza, §3) |
| DEC-030 · VIP, Dinero ×2 y ganancia offline | Registro | Etiqueta [VIP] dorada en el chat |
| DEC-031 · 12 relojes de lujo, uno por zona, con su material | Registro y §4.1 | Que la lista y los materiales se puedan modelar con el presupuesto de §5 |
| DEV-025, DEV-026, DEV-027 y DOC-001 | Backlog y [[Plan-de-Pruebas]] §31–§33 | La mesa de armado provisional (tu diseño la sustituirá) |

**Cómo aprobar:** en el Registro, cambia «Decidida por Jhonn» por «Aprobada por Jhonn y Zadiel (fecha)». Si no estás de acuerdo, no cambies nada del juego: escríbelo en el Backlog y avisa a Jhonn.

### 11.2 Sonidos: permisos automáticos para tu Claude (BUG-004)

**Estado:** BUG-004 ya está **resuelto**: lo hiciste en ART-016 (10/10 permisos con Open Cloud). Jhonn lo volvió a comprobar el 2026-11-21: **10/10 sonidos cargan** (`PreloadAsync` *Success*). **No hay que repetirlo** con esos 10.

**Lo que queda:** cada sonido **nuevo** que subas (los de §7.2: `sfx_encajar`, 12 `sfx_armar_<rareza>` y `sfx_reloj_perfecto`) necesita su permiso. **Claude, hazlo tú solo** al subir cada lote, sin esperar a que Zadiel lo pida:

1. **Comprueba el permiso del MCP** con una llamada inofensiva:
   `open_cloud_invoke(method: "GET", endpoint: "/cloud/v2/universes/10778093657", scopes: ["asset-permissions:write"])`.
   Si dice que el permiso no está activado, pide a Zadiel que lo active: *Assistant Settings → MCP Permissions → `asset-permissions:write`*.
2. **Da el permiso** a todos los audios nuevos en una sola llamada:
   ```
   open_cloud_invoke(
     method: "PATCH",
     endpoint: "/asset-permissions-api/v1/assets/permissions",
     scopes: ["asset-permissions:write"],
     body: {
       "subjectType": "Universe",
       "subjectId": "10778093657",
       "action": "Use",
       "requests": [ { "assetId": <ID1> }, { "assetId": <ID2> } ]
     }
   )
   ```
   La respuesta trae `successAssetIds` y `errors`. Cada ID debe estar en `successAssetIds`. `CannotManageAsset` significa que el audio no es de la cuenta con la que está abierto Studio.
3. **Comprueba en Play** (cliente) que cargan:
   ```lua
   local CP = game:GetService("ContentProvider")
   local ids = { <ID1>, <ID2> } -- los audios nuevos
   local sounds, ok = {}, 0
   for _, id in ids do
   	local s = Instance.new("Sound")
   	s.SoundId = "rbxassetid://" .. id
   	s.Parent = workspace
   	table.insert(sounds, s)
   end
   CP:PreloadAsync(sounds, function(_, status)
   	if status == Enum.AssetFetchStatus.Success then ok += 1 end
   end)
   for _, s in sounds do s:Destroy() end
   return ok .. "/" .. #ids .. " Success"
   ```
   Debe dar el 100 %. Anota el resultado en el [[Plan-de-Pruebas]] y los IDs en `art/texturas/ids_roblox.md`.
4. **Plan B** (solo si la llamada da 403 aunque la comprobación del paso 1 pase): el endpoint no aceptó el token del MCP. Zadiel lo hace a mano en 2 min: *Creator Dashboard → Development Items → Audio → cada audio → Permissions → añadir la experiencia 10778093657*. Después, el paso 3.

**Nunca** pongas claves de API ni cookies en archivos ni en el chat.

### 11.3 Terminar ART-016: lo que falta de [[UI-UX]] §12

`game/src` ya está libre (DEV-020 a DEV-027 cerradas). Reserva **solo** los archivos que toques (lo normal: `game/src/StarterPlayer/StarterPlayerScripts/Client/Ui.luau` y `Vfx.luau`; si hace falta, `PlotService.luau` para los carteles). Son cosas del cliente, sin cambiar reglas del juego:

1. Carteles de vitrina y de mascota: que cada jugador vea solo los suyos.
2. Rótulo de la puerta de zona: solo si al jugador le falta velocidad.
3. Aro de rareza en las vitrinas, con el color de §3.
4. Ajuste «Efectos sí/no» en Ajustes [O]. Con efectos desactivados, solo se ve el destello final (§5).
5. Panel de velocidad plegable.

Después: Play con las pruebas automáticas en verde (**53/53** como mínimo), capturas y la fila de ART-016 como Completada. El criterio «marcar BUG-004 en el Plan de Pruebas» ya está hecho (DOC-001).

### 11.4 ART-018: arte de las piezas y de los 18 relojes (la tarea grande)

Sigue §2 a §7 y los pasos de §9, con los criterios de §10:

1. Bocetos de los 18 relojes (§4.1 y §4.2). **Enséñaselos a Jhonn antes de modelar.**
2. Modelos: 18 relojes × 4 piezas, más el modelo armado de cada uno. Empieza por el **Omigo Lunamaster** (zona 1) y un general, para validar el estilo antes de hacer el resto.
3. Iconos de §6.3, efectos `vfx_armar_<rareza>` (12) y `vfx_reloj_perfecto`, y sonidos de §7.2 (con §11.2).
4. Nombres y atributos exactos de §7.3. El código ya busca `pz_<reloj>_<clase>` con las clases en inglés (`case`, `movement`, `dial` y `hands`) y viste las vitrinas con `AssetLibrary.WATCH_ASSETS`.
5. Renderizado (§5): `rbx-scene-analysis` y el simulador de móvil. Anota triángulos y memoria.
6. Al cerrar, crea la tarea **DEV** para Jhonn: disparar las animaciones de §7 con tus plantillas, solo en el cliente.

### 11.5 Propuestas de UX que puedes llevar (decide Jhonn)

- **Avisos de piezas raras:** al renovar la zona pueden llegar 4 o 5 a la vez ([[Plan-de-Pruebas]] §33). Propón cómo mostrarlos: en cola, solo el de mayor rareza o agrupados. Va como Propuesta al Registro y Jhonn decide.
- **Mesa de armado:** el panel actual es de texto. Tu diseño de §6 (marcos con icono, bandeja visual y vista previa) lo sustituye. Coordina con Jhonn qué parte programa cada uno.

### 11.6 Lo que NO te toca

- Las pruebas manuales de jugabilidad de la lista de Jhonn (las hace él).
- Publicar el juego (lo decide Jhonn).
- El Renacer (aparcado por Jhonn).
- Cambiar valores, rarezas, zonas o economía en `game/src` (tarea DEV de Jhonn).
