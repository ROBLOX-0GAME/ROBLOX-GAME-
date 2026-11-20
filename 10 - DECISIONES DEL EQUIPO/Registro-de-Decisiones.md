
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
