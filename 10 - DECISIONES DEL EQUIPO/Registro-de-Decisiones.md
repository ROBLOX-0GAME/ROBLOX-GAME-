
# 🧠 REGISTRO DE DECISIONES DEL EQUIPO

## 1. Propósito

Este documento registra las decisiones oficiales de Roblox Game Studio.

Su objetivo es evitar contradicciones, conservar el contexto del proyecto y permitir que los integrantes humanos y los agentes IA trabajen siguiendo los mismos criterios.

## 2. Estados de las decisiones

- **Propuesta:** pendiente de evaluación.
- **Aprobada:** aceptada oficialmente por el equipo.
- **Rechazada:** descartada.
- **Reemplazada:** sustituida por una decisión posterior.

## 3. Autoridad de decisión

- Las decisiones estratégicas corresponden al equipo humano.
- Los agentes IA pueden investigar, proponer y recomendar soluciones.
- Ningún agente puede presentar una propuesta como decisión aprobada.
- Las decisiones técnicas importantes deben documentarse.
- Los cambios que afecten varias áreas deben revisarse con los responsables correspondientes.

## 4. Registro de decisiones

### DEC-001 — Código en Git y flujo parcialmente gestionado con Rojo

- **Fecha:** 2026-11-19.
- **Estado:** Aprobada por la persona usuaria responsable del proyecto.
- **Responsable:** Equipo Roblox Game Studio.
- **Área:** Arquitectura técnica.

**Contexto:**

El repositorio existente contiene la bóveda de Obsidian, pero no tenía un proyecto de código Roblox.

**Decisión:**

Crear el código fuente dentro de game/ en este mismo repositorio. Usar Rojo con flujo parcialmente gestionado: Git conserva el código y Roblox Studio conserva el place, el mundo y los assets. Fijar la versión de Rojo y dejar la sincronización en vivo bloqueada hasta crear el place y aprobar su placeId.

**Justificación:**

La documentación del proyecto recomienda mantener el código versionado y revisar cambios en GitHub, mientras Studio conserva recursos que no se gestionan como archivos de texto.

**Consecuencias:**

La MacBook sigue dedicada a Obsidian; Rojo y Roblox Studio se instalarán en las PC Windows de desarrollo. El scaffold y los enlaces quedan en game/ y en el Dashboard. La conexión en vivo no se activa sin placeId.

**Documentos afectados:**

- [[Arquitectura-General]]
- [[Dashboard]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[game/README|Proyecto fuente de Roblox con Rojo]]

### DEC-002 — Ramas por tarea y revisión obligatoria

- **Fecha:** 2026-11-19.
- **Estado:** Reemplazada por DEC-009 (2026-11-20).
- **Responsable:** Cuenta A (Jhonn/Zadiel).
- **Área:** GitHub y coordinación de agentes.

**Decisión:**

Cada tarea usa una rama task/<ID>-<slug>. main recibe cambios solo por Pull Request, con al menos una aprobación humana y los controles automatizados aprobados. Cuenta A coordina la integración; nadie aprueba su propio Pull Request.

**Consecuencias:**

ACTIVE_TASKS.md registra las rutas reservadas; el control de GitHub Actions bloquea Pull Requests que invadan rutas de otra tarea. La configuración de protección de main debe activarse en GitHub Settings y no se modifica desde un archivo del repositorio.

**Documentos afectados:**

- [[Protocolo-de-Trabajo-IA]]
- [[Backlog]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[ACTIVE_TASKS]]
- [[10 - DECISIONES DEL EQUIPO/Memoria-de-Area|Memoria de Decisiones]]

### DEC-009 — Trabajo directo en main con sincronización automática de Obsidian

- **Fecha:** 2026-11-20.
- **Estado:** Aprobada por Zadiel para todo el equipo.
- **Responsable:** Cuenta A (Zadiel).
- **Área:** GitHub, Obsidian y coordinación de agentes.
- **Reemplaza:** DEC-002.

**Decisión:**

Se trabaja directamente en `main`, sin ramas por tarea, sin Pull Requests y sin protección de rama. Cada vez que Claude avanza en algo que se pueda anotar, lo registra en la memoria de Obsidian (Memoria-de-Area.md del área, Backlog y, si hay una decisión, este registro) y lo sube a `main`. Obsidian Git hace commit, subida y bajada cada 5 minutos en todos los equipos.

Se mantienen las reservas de rutas en [[ACTIVE_TASKS]]: antes de editar se reserva y se sube la reserva a `main`; al terminar se marca Completada. El hook de Claude Code bloquea las rutas reservadas por otra tarea.

**Consecuencias:**

Los cambios llegan a todos en minutos, pero ya no hay revisión previa: se revisa sobre lo ya subido. Nunca se usa force push. Si dos personas editan la misma nota a la vez, Obsidian Git puede generar un conflicto que hay que resolver a mano; las reservas sirven para evitarlo. No se cambia de rama desde Obsidian.

**Documentos afectados:**

- [[Protocolo-de-Trabajo-IA]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[Backlog]]
- [[10 - DECISIONES DEL EQUIPO/Memoria-de-Area|Memoria de Decisiones]]

### Plantilla de decisión

#### Plantilla — Título de la decisión

- **Fecha:** Pendiente.
- **Estado:** Propuesta.
- **Responsable:** Pendiente.
- **Área:** Pendiente.

**Contexto:**

¿Qué situación requiere una decisión?

**Opciones consideradas:**

1. Opción A.
2. Opción B.
3. Opción C.

**Decisión:**

Pendiente de aprobación.

**Justificación:**

Pendiente.

**Consecuencias:**

Pendiente.

**Documentos afectados:**

Pendiente.

---

## 5. Reglas de modificación

1. No modificar decisiones aprobadas sin registrar una revisión.
2. No eliminar decisiones antiguas.
3. Registrar el motivo de cada cambio.
4. Identificar qué documentos resultan afectados.
5. Mantener un historial comprensible.
6. Comunicar las decisiones que afecten a otras áreas.

## 6. Relación con los agentes IA

Los agentes deben:

- Consultar este documento antes de realizar cambios importantes.
- Respetar las decisiones aprobadas.
- Informar cuando una tarea contradiga una decisión existente.
- Proponer modificaciones cuando detecten problemas.
- Esperar aprobación humana cuando corresponda.

## 7. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Backlog]]
- [[Equipo-y-Responsabilidades]]
- [[Instrucciones-Generales]]
- [[Protocolo-de-Trabajo-IA]]

---

**Estado:** Activo  
**Responsable:** Equipo Roblox Game Studio

## 8. Propuestas abiertas

Propuestas de DEV-001 a DEV-006, integradas por DEV-007 y renumeradas para no chocar con DEC-001 y DEC-002 aprobadas. Ninguna está aprobada: el equipo debe revisarlas.

#### DEC-003 — Bucle MVP y cifras de balance iniciales

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Responsable:** Jhonn. **Área:** Sistemas, economía y progresión.
- **Propuesta:** cajas de piezas → Taller → Tienda/Museo → mejoras, con las cifras de `game/src/ReplicatedStorage/Shared/Config.luau` y `GameData.luau`. Sin robo, mascotas ni compras con Robux en esta versión.
- **Documentos afectados:** [[Economia-y-Progresion]], [[Lista-de-Sistemas]], [[Backlog]].

#### DEC-004 — Tutorial de 5 objetivos con premios

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Responsable:** Jhonn. **Área:** Sistemas / UX.
- **Propuesta:** recoger 5 cajas (20) → fabricar (30) → vender (30) → exhibir (40) → mejorar (50); guía luminosa hacia el destino. Textos en `game/src/ReplicatedStorage/Shared/GameData.luau`.
- **Documentos afectados:** [[GDD]], [[UI-UX]], [[Backlog]].

#### DEC-005 — Bucle principal: robo por zonas con persecución

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn; falta que el equipo apruebe las cifras). **Área:** Gameplay / economía.
- **Propuesta:** 5 zonas con puertas de velocidad; botín que se pierde si el dueño te atrapa; reemplaza a las cajas de DEC-003. Detalle en [[GDD]] §15.2.
- **Reemplaza en parte:** DEC-003 (la recolección por cajas).

#### DEC-006 — Jefe cooperativo: Cronómetro Maestro

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Área:** Sistemas / multijugador.
- **Propuesta:** evento cada 7 min; entrega de piezas por puntos de rareza; 12 monedas por punto si se repara; reembolso si falla. Detalle en [[GDD]] §15.3.

#### DEC-007 — Mascotas con multiplicador de velocidad

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Progresión / economía.
- **Propuesta:** 3 huevos (500 / 5.000 / 40.000), 5 mascotas de +5% a +60%, hasta 3 equipadas, tope de velocidad 60; solo monedas del juego. Detalle en [[GDD]] §15.4.

#### DEC-008 — Velocidad como eje y monetización con ventajas

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Economía / monetización.
- **Propuesta:** sin fuerza; caminadoras de entrenamiento; 6 pases (incluye ventajas fuertes de velocidad) y 5 productos. Detalle en [[GDD]] §15.5.
- **Nota:** los números DEC de las ramas DEV-001 a DEV-006 chocan con DEC-001 y DEC-003 aprobadas en `main`. Se renumerarán al integrar.

#### DEC-010 — Plot personal con taller, vitrinas y caminadora

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Sistemas / economía.
- **Propuesta:** un plot por jugador; el taller y el museo pasan al plot; los relojes exhibidos dan ingreso y suerte (tope 15%); caminadora personal mejorable (×1 a ×6, Turbo ×2); vitrinas mejorables (3 a 15). Detalle en [[GDD]] §15.6.
- **Sustituye en parte:** las caminadoras compartidas de DEC-008 y el Museo y el Taller compartidos de DEC-003.

#### DEC-011 — Mascotas en cápsulas, recompensas diarias y por tiempo, y mascotas Robux

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Economía / monetización.
- **Propuesta:** cápsulas en lugar de huevos; racha diaria de 7 días; 5 premios por tiempo jugado al día; Cápsula Cósmica solo con Robux con mascotas de +80% a +150% y probabilidades visibles. Detalle en [[GDD]] §15.7.

#### DEC-012 — Base en media luna con 6 plots y muro frontal

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Mundo / sistemas.
- **Propuesta:** 6 jugadores y 6 plots de 34 × 40 en media luna alrededor de la plaza; caminadora delante y taller al fondo; muro frontal con abertura y las estaciones Tienda, Robux, Criadero y Cronómetro. Detalle en [[GDD]] §15.8.

#### DEC-013 — Historia inicial, pieza del legado, tutorial e ingreso pasivo del 30%

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Experiencia de inicio / economía.
- **Propuesta:** cinemática del abandono y llegada a la ciudad; pieza del legado ficticia, protegida y usable en el Reloj del Legado; tutorial de 6 pasos; ingreso pasivo = 30% del valor cada 10 min. Detalle en [[GDD]] §15.9.
- **Nota:** se evitan marcas reales (Patek Philippe, Graff) por derechos de marca.

#### DEC-014 — Ingreso pasivo cada 30 segundos

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Economía.
- **Propuesta:** el 30% del valor del reloj exhibido se paga cada 30 s (antes, cada 10 min en DEC-013). Ajustable en `Config.PLOT_INCOME_PERIOD_SECONDS`.

#### DEC-015 — HUD multiplataforma, ruleta diaria, ajustes y capacidad de carga

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn). **Área:** Interfaz / economía.
- **Propuesta:** HUD con barra de botones a la derecha, escala por dispositivo y atajos; ruleta diaria con 7 premios y giros extra con Robux; ajustes guardados; carga por viaje de 1 a 4 con 3 mejoras (500 / 1.500 / 4.500). Detalle en [[GDD]] §15.10.

#### DEC-016 — Pipeline de arte y estilo low-poly

- **Fecha:** 2026-11-20. **Estado:** Propuesta (dirección dada por Jhonn; la dirección visual pasará a Michael y Einell). **Área:** Arte / assets.
- **Propuesta:** estilo low-poly colorido tipo simulador de Roblox con una textura de paleta común; herramientas Blender, Krita, Material Maker y Audacity; carpeta `art/` para fuentes y exportaciones; 1 unidad = 1 stud; modelos base generados por script y detallados a mano. Detalle en [[Pipeline-de-Arte]].

#### DEC-017 — Los assets viven en ReplicatedStorage/Assets con respaldo provisional

- **Fecha:** 2026-11-20. **Estado:** Propuesta. **Área:** Arquitectura / arte.
- **Propuesta:** los modelos importados se guardan en `ReplicatedStorage/Assets` con su nombre; el código los coloca sobre las piezas provisionales, que conservan la lógica; sin asset, se usa la pieza provisional. Sonidos e iconos por ID en `Config`. Detalle en [[Pipeline-de-Arte]] §5.

#### DEC-018 — Materiales PBR para los relojes

- **Fecha:** 2026-11-20. **Estado:** **Aprobada** por Zadiel el 2026-11-20 (INFRA-003; antes, Propuesta de ART-006). Incluye la ampliación a piezas robables, pieza del legado y cápsulas (ART-009). **Área:** Arte / dirección visual. **Revisan:** Zadiel y Jhonn (DEC-020).
- **Propuesta:** los 6 relojes usan materiales PBR (oro pulido y cepillado, acero, cristal de zafiro, esmaltes, cuero y gemas) con `SurfaceAppearance`, una malla por material y menos de 3.000 triángulos, sin perder la forma low-poly ni el sombreado plano. El resto de modelos sigue con la paleta común (DEC-016). Si se aprueba, el mismo tratamiento podría pasar a las piezas robables, la pieza del legado y las cápsulas. Detalle en [[Pipeline-de-Arte]].

#### DEC-019 — La MacBook también se usa para arte (sin Roblox Studio)

- **Fecha:** 2026-11-20. **Estado:** Reemplazada por DEC-021 (INFRA-005): la MacBook ya se usa también con Roblox Studio y Rojo. **Área:** Arquitectura / equipo.
- **Propuesta:** la MacBook de Zadiel, además de Obsidian y tareas escolares, se usa para el arte (Blender, Material Maker, Krita y Audacity, con los scripts de `art/`). Sigue sin Roblox Studio ni Rojo: la importación de assets se hace en las PC Windows. Cambia lo dicho en [[Arquitectura-General]] («Entorno de trabajo por dispositivo»).

#### DEC-020 — El equipo queda en Zadiel y Jhonn

- **Fecha:** 2026-11-20. **Estado:** **Aprobada** por Zadiel (INFRA-003). **Área:** Equipo / coordinación.
- **Decisión:** Michael y Einell dejan de participar. Zadiel y Jhonn toman todas las decisiones y revisan todo, también el área que era de la Cuenta B (mundo, narrativa, personajes, dirección visual, arte, contenido y UX). Las propuestas que esperaban a Michael y Einell (por ejemplo DEC-016, DEC-018 y DEC-019) las deciden ahora Zadiel y Jhonn. Donde reglas o notas antiguas digan «Cuenta B» o «Michael y Einell», se entiende Zadiel y Jhonn. Actualizados [[OWNERS]], AGENTS.md y `.claude/CLAUDE.md`.

#### DEC-021 — La MacBook de Zadiel sirve para todo el desarrollo

- **Fecha:** 2026-11-20 (Propuesta en ART-008; ampliada en INFRA-005). **Estado:** **Aprobada** por Zadiel y Jhonn el 2026-11-20 (INFRA-005 e INFRA-008). **Área:** Arquitectura / equipo. **Deciden:** Zadiel y Jhonn (DEC-020).
- **Decisión:** la MacBook de Zadiel se puede usar para **todo** el trabajo del proyecto, igual que las PC Windows: Obsidian y Git, arte (Blender, Material Maker, Krita y Audacity), Roblox Studio con su MCP y Open Cloud en la place oficial por Team Create, código en `game/src` con Rojo y pruebas en Play. Ya se usó así en ART-008 y ART-013. Reemplaza a DEC-019 («sin Roblox Studio ni Rojo»).
- **Se mantiene:** el código entra solo por `game/src` (el repositorio es la fuente de verdad), no se publica sin el OK de Zadiel y Jhonn, y no se guarda la place a la vez desde dos equipos en Team Create.
- **Notas alineadas** en INFRA-007: `.claude/CLAUDE.md`, `AGENTS.md` y [[Arquitectura-General]].

#### DEC-022 — Iluminación de la place para los PBR y el low-poly colorido

- **Fecha:** 2026-11-20. **Estado:** **Aprobada** por Zadiel y Jhonn el 2026-11-20 (INFRA-006; antes, Propuesta de ART-013). Aplicada en la place (versión 16). **Área:** Arte / dirección visual. **Deciden:** Zadiel y Jhonn (DEC-020).
- **Propuesta:** `Lighting.Technology = Future` (se pone a mano), `Brightness` 2,5, `ClockTime` 14,5, `GlobalShadows` activado con `ShadowSoftness` 0,2, `Ambient` 70/70/80, `OutdoorAmbient` 128/128/140 y `EnvironmentDiffuseScale` y `EnvironmentSpecularScale` a 1 (antes en 0: los metales PBR no reflejaban nada).
  - `Atmosphere`: densidad 0,25, Offset 0,1, Color 199/220/255, Decay 106/112/125, Glare 0,2 y Haze 1.
  - `ColorCorrection`: saturación +0,15, contraste +0,08, brillo +0,02 y tinte 255/250/242.
  - `Bloom` suave: intensidad 0,4, tamaño 24 y umbral 1,6.
- **Motivo:** los reflejos y el bloom hacen lucir los relojes y las piezas PBR, y la saturación y la luz cálida mantienen el estilo low-poly colorido. Para volver atrás: los valores anteriores eran `Brightness` 1, `ClockTime` 14, sin sombras, `Ambient` y `OutdoorAmbient` 128/128/128, escalas de entorno en 0 y sin efectos.

#### DEC-023 — Precios en Robux y pases de entrenamiento ×2–×512

- **Fecha:** 2026-11-20. **Estado:** **Decidida por Jhonn** el 2026-11-20 (DEV-019). Zadiel la revisa (DEC-020). **Área:** Economía / monetización.
- **Pases (compra única):** Mascota Suprema 459 · VIP 349 · Corredor VIP 289 · Caminadora Turbo 229 · Ranura de Mascota 179 · Mochila Gigante 119 R$ (un 15–20 % más que la propuesta inicial, a pedido de Jhonn).
- **Pases de entrenamiento (nuevos):** ×2 3 · ×4 5 · ×8 15 · ×16 35 · ×32 75 · ×64 149 · ×128 299 · ×256 599 · ×512 1.199 R$. Multiplican la **velocidad ganada al entrenar** en la caminadora, que hará falta para llegar más lejos. Se usa el más alto que tengas (no se suman entre sí) y se combina con la mejora de la caminadora y la Caminadora Turbo. Por ahora llegan hasta ×512 (el ×1024 queda para más adelante).
- **Productos (repetibles):** Bolsa 25 · Cofre 99 · Bóveda 399 · Entrenamiento instantáneo 49 · Cápsula de Oro 49 · Cápsula Cósmica 149 · Giro extra 19 R$.
- **Pendiente de revisar (Claude, sin decidir):** el entrenamiento tiene tope `Config.MAX_TRAINED` = 30 de velocidad. Con ×512 (0,01 × 512 = 5,12 por segundo) se llega al tope en unos 6 s, así que los pases altos solo rinden si se sube ese tope y se añaden zonas más lejanas.

#### DEC-024 — 12 zonas, velocidad como estadística y dueños dormidos

- **Fecha:** 2026-11-20. **Estado:** **Decidida por Jhonn** el 2026-11-20 (DEV-020). Zadiel la revisa (DEC-020). **Área:** Gameplay / mundo / progresión. Reemplaza las velocidades de zona de DEC-005 y el entrenamiento con tope de DEC-008.
- **Zonas (velocidad necesaria):** 1: 100 · 2: 1K · 3: 10K · 4: 100K · 5: 1M · 6: 14M · 7: 200M · 8: 2,8B · 9: 40B · 10: 560B · 11: 7,5T · 12: 99,9T. Con 100T se abrirá un mundo nuevo en una actualización futura. Los jugadores empiezan con 75.
- **Velocidad real:** la «Velocidad» es una estadística. La velocidad física sigue una curva logarítmica por tramos: 75 → 30, 1M → 85, 99,9T → 150 (tope por la física de Roblox). En la base, como máximo 50 (el jugador elige su velocidad con una barra en el HUD); dentro de las casas, 40, para buscar piezas con comodidad.
- **Zonas más largas:** cada zona mide un 35 % más que la anterior (130 → ~3.400 studs).
- **Dueños:** duermen. Si pasas más de 15 s dentro de su casa se despiertan y te persiguen; dentro de la casa son lentos y fuera corren casi como la velocidad que exige su zona. Si te atrapan pierdes el botín.
- **Propuesta de Claude (cifras ajustables en `Config`/`GameData`):** entrenamiento base 0,5/s; la mejora de la caminadora duplica el entrenamiento por nivel (hasta 40 niveles); la mejora de velocidad de la Tienda da +25 % por nivel; cada pieza robada trae monedas que crecen ×8 por zona.

#### DEC-025 — Dirección visual «taller de relojería fantástico»

- **Fecha:** 2026-11-20. **Estado:** Propuesta (ART-014; se aplica en ART-015 para poder probarla). **Área:** Arte / mundo / interfaz. **Deciden:** Zadiel y Jhonn (DEC-020).
- **Propuesta:** identidad original de taller de relojería fantástico. Conserva el low-poly colorido (DEC-016), los PBR (DEC-018) y la iluminación (DEC-022).
  - **Acentos:** madera cálida, carbón `#1E1F26`, marfil `#F2F0EA`, latón `#C27B3A`, oro `#F2C14E` y cian `#5BD5E0`, todos de la paleta actual.
  - **Lectura:** carteles por contexto, a menos distancia y sin superponerse.
  - **Efectos breves solo en el cliente:** fabricar, vender, subir de nivel, abrir cápsula, recompensa rara, tutorial y carrera.
  - **Rarezas:** brillo a partir de Raro.
  - **HUD:** compacto, con iconos.
  - **Zonas:** cada una con identidad propia de vegetación y detalles, y torre de reloj como punto focal de la plaza.
  - Detalle en [[UI-UX]] §12 y en [[Pipeline-de-Arte]] (ART-014).
- **Límites:** solo cambia la presentación. No toca nombres, puertas, límites, requisitos, economía, etiquetas, atributos existentes ni red, y si falta un asset se usa el genérico.

#### DEC-026 — Mejoras desde 100 monedas con crecimiento ×1,5 y Puesto de Mochila y Carga

- **Fecha:** 2026-11-21. **Estado:** **Reemplazada en parte por DEC-027** (2026-11-21). **Área:** Economía. Reemplazaba los precios de mejoras de DEC-003, DEC-010 y DEC-015.
- **Mejoras:** todas empiezan en 100 monedas y cada nivel cuesta un 50 % más (×1,5). Máximo 8 niveles por ahora (mochila, velocidad, salto, suerte, vitrinas y caminadora). La carga por viaje tiene 3 niveles (de 1 a 4 objetos).
- **Mochila y Carga:** la mejora de la mochila sale de la Tienda y se compra, junto con la carga por viaje, en el puesto «Mochila y Carga».
- **Ajustes de Claude para que 8 niveles no rompan límites (propuesta):** vitrinas +1 por nivel (3 + 8 = 11; el plot tiene 15 sitios) y salto +1 por nivel. Dudas en [[Recomendaciones-Claude]].

#### DEC-027 — Solo tres mejoras con monedas, mochila fija y mascotas con dinero

- **Fecha:** 2026-11-21. **Estado:** **Decidida por Jhonn** (respuestas a [[Recomendaciones-Claude]], DEV-022). Zadiel la revisa (DEC-020). **Área:** Economía. Reemplaza en parte DEC-026.
- **Vitrinas del plot:** de 4 a 12, +1 por mejora (8 mejoras). Empiezan en 100 monedas y cada nivel cuesta ×10 (la última, 1B).
- **Carga por viaje:** 3 mejoras (de 1 a 4 objetos). 100 y ×10.
- **Caminadora:** 30 niveles, ×2 de entrenamiento cada uno. El precio sube por nivel y se calibra con el valor de los relojes: el mejor reloj (original con las 4 piezas Atemporales) vale 1.500T–1.950T.
- **Mochila:** fija en 60 piezas; solo se amplía con el pase de Robux.
- **Sin** mejoras de velocidad, salto ni suerte. La suerte la dan las mascotas y los relojes exhibidos.
- **Mascotas:** dan monedas extra, ¼ de su bonus de velocidad.
- **Precios:** solo dependen del nivel, nunca de la zona.

#### DEC-028 — Piezas de reloj con 12 rarezas, relojes por zona y penalización por pieza ajena

- **Fecha:** 2026-11-21. **Estado:** **Decidida por Jhonn** (DEV-025, pendiente de implementar). **Área:** Gameplay / arte. Desarrolla [[PROMPT_PIEZAS_RELOJ_ZADIEL]].
- **Piezas:** Caja, Calibre, Esfera y Manecillas de un reloj concreto, con rareza. Las 7 piezas antiguas solo salen durante la reparación del Cronómetro.
- **Rarezas (12):** Común, Poco común, Raro, Épico, Legendario, Mítico, Divino, Celestial, Cósmico, Eterno, Ancestral y Atemporal, cada una con su color.
- **Reparto:** cualquier pieza puede salir en cualquier zona por suerte; las zonas lejanas dan rarezas más altas. Desde la zona 3, cada zona tiene un reloj famoso exclusivo.
- **Pieza ajena:** −1 rareza y −25 % de valor, ingreso y suerte por cada una.
- **Calibres:** cuarzo, mecánico y automático solo cambian el aspecto.
- **Nombres:** interpretados (sin marcas reales), con un aspecto parecido a los originales y sin copiar logos ni nombres.

#### DEC-029 — Piezas compartidas, reinicio de zonas cada 5 min y avisos de piezas raras

- **Fecha:** 2026-11-21. **Estado:** **Decidida por Jhonn** (DEV-023). **Área:** Gameplay.
- Las piezas de cada casa son únicas en el servidor: quien la roba primero se la lleva.
- Cada 5 min se cierra la zona de carreras: 30 s de aviso, todos vuelven a la base con su botín guardado, se renuevan las piezas y se abre a los 10 s.
- Aviso arriba para todo el servidor cuando aparece una pieza Mítica o superior, con la zona y el mensaje y color de su rareza.

#### DEC-030 — Ventajas VIP, Dinero ×2 y ganancia offline

- **Fecha:** 2026-11-21. **Estado:** **Decidida por Jhonn** (DEV-024). **Área:** Monetización.
- **Dinero ×2:** pase de 249 R$ (monedas ×2 al vender y en el plot; se combina con el VIP).
- **VIP:** premios por tiempo en un 30 % menos de tiempo, etiqueta [VIP] en el chat y ganancia offline hasta 8 h.
- **Ganancia offline:** sin VIP, hasta 4 h; al 50 % del ingreso del plot.
