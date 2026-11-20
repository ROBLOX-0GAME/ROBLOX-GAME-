# 📋 BACKLOG — PRODUCCIÓN Y DESARROLLO

## 1. Propósito

Centralizar las tareas, mejoras, errores y objetivos de desarrollo de Roblox Game Studio.

## 2. Estados de las tareas

- **Pendiente:** todavía no iniciada.
- **En progreso:** actualmente en desarrollo.
- **En revisión:** esperando revisión.
- **Bloqueada:** depende de otra tarea o decisión.
- **Completada:** finalizada y verificada.

## 3. Prioridades

- **Crítica:** bloquea el proyecto o compromete su funcionamiento.
- **Alta:** necesaria para el desarrollo principal.
- **Media:** importante, pero no urgente.
- **Baja:** mejora opcional.

## 4. Organización de tareas

### Cuenta A — Gameplay, systems e implementación técnica
Responsables de la cuenta: Zadiel y Jhonn.

Áreas principales:
- Loop, mecánicas, habilidades y crafting.
- Inventario, progresión y economía.
- Implementación técnica de Roblox.

### Cuenta B — World & presentation
Responsables de la cuenta: Michael y Einell.

Áreas principales:
- Mundo, narrativa y personajes.
- Dirección visual, assets y contenido.
- Experiencia de usuario (UX).

Ambas cuentas pueden colaborar en otras áreas cuando la tarea lo requiera. Registra una persona responsable y una revisora por tarea; las tareas transversales requieren revisión de ambas parejas.

## 5. Tareas pendientes

### INFRA-001 — Coordinación de agentes y preparación de Rojo

- **ID:** INFRA-001.
- **Responsable:** Jhonn y Zadiel (Cuenta A).
- **Revisión:** Jhonn y Zadiel; Michael y Einell para cambios transversales.
- **Área:** GitHub, coordinación de archivos y entorno Rojo.
- **Prioridad:** Alta.
- **Estado:** En revisión.
- **Rama:** `task/INFRA-001-coordination-rojo`.
- **Alcance:** crear el registro de propietarios y reservas, las reglas de ramas y revisión, una comprobación de conflictos para Pull Requests, y el scaffold inicial de Rojo en `game/`.
- **Criterios de aceptación:**
  - [x] La propiedad de áreas refleja Cuenta A (Jhonn/Zadiel) y Cuenta B (Michael/Einell); los archivos compartidos exigen coordinación.
  - [x] Cada tarea trabaja en `task/<ID>-<slug>` y reserva rutas antes de editarlas.
  - [x] Una comprobación automatizada bloquea la integración de un Pull Request que cambie rutas reservadas por otra tarea.
  - [x] Claude Code bloquea Edit/Write en main, rutas sin reserva integrada y rutas activas reservadas por otra tarea.
  - [x] Los Pull Requests de reserva que reclaman rutas superpuestas se detectan aunque solo modifiquen el registro central.
  - [x] Los cambios de Backlog.md y ACTIVE_TASKS.md quedan limitados al ID de la tarea del Pull Request.
  - [x] Los Pull Requests usan una plantilla con responsable, revisor, rutas reservadas y verificaciones.
  - [x] `game/default.project.json` puede construir el scaffold; Rojo no permite la sincronización en vivo hasta que se añada el `placeId`.
  - [ ] Activar en GitHub Settings la protección de `main`: Pull Request obligatorio, una aprobación y los controles `reservation-check` y `rojo-build`; bloquear force push y eliminación de la rama.
  - [ ] Limitar escritura a los @handles de las cuatro personas autorizadas; mantener solo las administraciones necesarias dentro de ese grupo.
  - [ ] Desactivar el borrado/transferencia de repositorios por miembros desde los ajustes de la organización.
- **Dependencias:** protección y acceso de GitHub pendientes de ajustes administrativos y confirmación de los @handles de Michael y Einell; la sincronización en vivo espera a que se cree el place y se registre su `placeId`.
- **Documentos relacionados:** [[ACTIVE_TASKS]], [[OWNERS]], [[Protocolo-de-Trabajo-IA]], [[Arquitectura-General]].

### Diseño
- [ ] Definir concepto principal del juego.
- [ ] Aprobar los pilares de diseño.
- [ ] Definir el alcance del MVP.
- [ ] Diseñar el bucle principal de gameplay.

### Arquitectura y entorno de desarrollo
- [ ] Instalar Roblox Studio manualmente en las PC Windows destinadas al desarrollo; la MacBook se reserva para Obsidian y tareas escolares.
- [ ] Abrir o identificar el place/proyecto fuente en una PC de desarrollo y registrar su ruta o repo en Arquitectura-General.md.
- [ ] Definir estructura definitiva del proyecto.
- [ ] Establecer estándares de código.
- [ ] Diseñar arquitectura de sistemas.
- [ ] Definir estrategia de guardado.

### Gameplay
- [ ] Diseñar movimiento.
- [ ] Diseñar combate.
- [ ] Diseñar habilidades.
- [ ] Diseñar enemigos y jefes.

### Mundo
- [ ] Definir regiones.
- [ ] Diseñar zonas.
- [ ] Diseñar NPC.
- [ ] Diseñar misiones.

### Sistemas
- [ ] Diseñar inventario.
- [ ] Diseñar economía.
- [ ] Diseñar progresión.
- [ ] Diseñar multijugador.

### Infraestructura
- [ ] Definir pruebas.
- [ ] Establecer controles de seguridad.
- [ ] Establecer procedimientos de integración.
- [ ] Preparar documentación técnica.

## 6. Plantilla para nuevas tareas

### Nombre de la tarea

- **ID:** Pendiente.
- **Responsable:** Pendiente.
- **Área:** Pendiente.
- **Prioridad:** Media.
- **Estado:** Pendiente.
- **Fecha de creación:** Pendiente.

**Descripción:**

Pendiente.

**Criterios de aceptación:**

- [ ] Pendiente.

**Dependencias:**

Pendiente.

**Documentos relacionados:**

Pendiente.

## 7. Reglas de producción

1. Toda tarea debe tener un objetivo claro.
2. Las tareas deben tener criterios de aceptación.
3. Los cambios importantes deben revisarse.
4. No se deben sobrescribir cambios de otros integrantes.
5. Las tareas bloqueadas deben documentar su causa.
6. Las tareas completadas deben verificarse antes de cerrarse.
7. Las decisiones importantes deben registrarse.
8. Toda tarea que reserve rutas debe figurar en [[ACTIVE_TASKS]] antes de editarlas.
9. Al finalizar, liberar la reserva y actualizar Backlog dentro del Pull Request de la tarea.

## 8. Documentos relacionados

- [[Dashboard]]
- [[GDD]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Diseño-del-Mundo]]
- [[Registro-de-Decisiones]]
- [[Plan-de-Pruebas]]
- [[Equipo-y-Responsabilidades]]
- [[Protocolo-de-Trabajo-IA]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[09 - TAREAS Y DESARROLLO/Memoria-de-Area|Memoria de Producción]]

---

**Estado:** Borrador inicial
### DEV-007 — Integrar el juego (DEV-001 a DEV-006) en game/

- **ID:** DEV-007.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Michael y Einell revisan `game/src/StarterPlayer/StarterPlayerScripts/` (interfaz, ruta de Cuenta B según OWNERS.md).
- **Área:** Arquitectura técnica, sistemas, economía y progresión.
- **Prioridad:** Alta.
- **Estado:** En revisión (Pull Request final; reserva fusionada en PR #3).
- **Rama:** `task/DEV-007-integracion-juego`.
- **Fecha de creación:** 2026-11-20.

**Descripción:**

Las ramas `task/DEV-001-base-mvp` a `task/DEV-006-velocidad-robux` se hicieron antes de que INFRA-001 llegara a `main` y guardan el código en `juego/`. Esta tarea las integra respetando DEC-001 (código en `game/`) y DEC-002 (ramas, reservas y revisión):

1. Mover el código Luau a `game/src/ReplicatedStorage/Shared`, `game/src/ServerScriptService/Server` y `game/src/StarterPlayer/StarterPlayerScripts/Client`, y retirar los archivos Bootstrap y Placeholder.
2. Mantener la compilación con Rojo 7.7.1 (control `rojo-build`) y adaptar `build.py` para la revisión estática local.
3. Llevar a la bóveda el diseño (GDD §15), Changelog, Plan de Pruebas y memorias, y renumerar las decisiones propuestas para que no choquen con DEC-001 y DEC-002 aprobadas.
4. Al terminar, cerrar las ramas DEV-001 a DEV-006 sin fusionarlas: su contenido llega a `main` por esta tarea.

Contenido que se integra (todo como propuesta, salvo lo aprobado): bucle de robo por 5 zonas con dueños que persiguen y puertas de velocidad; fabricación, venta y museo; tutorial de 5 objetivos; jefe cooperativo Cronómetro Maestro; mascotas con multiplicador de velocidad; caminadoras de entrenamiento; 6 pases y 5 productos con Robux con IDs pendientes. Por indicación de Jhonn, solo se programan mecánicas; el arte y el sonido se harán con Krita, Blender, Audacity y Material Maker.

**Criterios de aceptación:**

- [x] El código vive en `game/src`. La compilación con Rojo la confirma el control `rojo-build` de este PR.
- [x] Revisión estática local sin errores: 20 scripts, 73 `require`. Las 35 pruebas se ejecutan al pulsar Play en Studio y están pendientes de que Jhonn las corra.
- [x] El diseño (GDD §15), el Changelog, el Plan de Pruebas y las memorias están en la bóveda; las decisiones se renumeraron a DEC-003…DEC-008 y siguen como propuestas.
- [ ] Michael o Einell revisan la interfaz; Zadiel revisa el resto.
- [ ] En el Pull Request final, la fila DEV-007 de ACTIVE_TASKS.md queda Completada.

**Dependencias:** INFRA-001 (Completada).

**Documentos relacionados:** [[ACTIVE_TASKS]], [[OWNERS]], [[Registro-de-Decisiones]], [[Arquitectura-General]].

### INFRA-002 — Trabajo directo en main y sincronización automática de Obsidian

- **ID:** INFRA-002.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Zadiel.
- **Revisor:** Jhonn; Michael y Einell como revisión transversal (afecta a ambas cuentas).
- **Área:** Coordinación, Git y Obsidian.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Rama:** `task/INFRA-002-sync-directo-main` (solo para aplicar este cambio; después se trabaja en `main`).
- **Fecha de creación:** 2026-11-20.

**Descripción:**

Por decisión de Zadiel para todo el equipo, se deja de usar ramas por tarea y Pull Requests. Claude trabaja directamente en `main`: anota lo que hace en la memoria de Obsidian y lo sube a GitHub. Obsidian Git hace commit, subida y bajada cada 5 minutos. Se mantienen las reservas de rutas en ACTIVE_TASKS.md para que dos personas no editen lo mismo a la vez. Reemplaza DEC-002 por DEC-009.

**Criterios de aceptación:**

- [x] El hook de `.claude/settings.json` permite editar en `main` y sigue bloqueando rutas reservadas por otra tarea (6 casos probados localmente).
- [x] `.claude/CLAUDE.md`, el Protocolo, OWNERS.md, AGENTS.md, ACTIVE_TASKS.md, las reglas y los prompts describen el flujo nuevo.
- [x] DEC-009 queda registrada y DEC-002 marcada como Reemplazada.
- [x] Obsidian Git de la Mac de Zadiel configurado para sincronizar cada 5 minutos en ambos sentidos (pendiente de recargar Obsidian). Faltan las PC de Jhonn, Michael y Einell.
- [x] La fila INFRA-002 de ACTIVE_TASKS.md queda Completada.

**Dependencias:** INFRA-001 y DEV-007 (Completadas).

**Documentos relacionados:** [[ACTIVE_TASKS]], [[OWNERS]], [[Registro-de-Decisiones]], [[Protocolo-de-Trabajo-IA]].
### DEV-008 — Plot personal con mesa, vitrinas y caminadora mejorables

- **ID:** DEV-008.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Michael y Einell revisan `game/src/StarterPlayer/StarterPlayerScripts/` (interfaz).
- **Área:** Sistemas, economía y progresión.
- **Prioridad:** Alta.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Rama:** `task/DEV-008-plot-personal`.
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

Cada jugador recibe su propio **plot** en la base al entrar (10 plots, uno por jugador del servidor). En su plot tiene:

1. **Mesa de elaboración** personal: fabrica relojes ahí (reemplaza al Taller compartido).
2. **Vitrinas** donde coloca sus relojes fabricados; los relojes exhibidos dan ingreso pasivo (reemplaza al Museo compartido).
3. **Caminadora** personal enfrente del plot para entrenar velocidad (reemplaza a las 3 caminadoras compartidas).

El plot y la caminadora se **mejoran** con monedas: el plot añade vitrinas y la caminadora sube su multiplicador. Solo el dueño usa su plot. El pase «Caminadora Turbo» pasa a multiplicar el entrenamiento de la caminadora personal. Solo mecánicas: los modelos y las skins de los dueños de las casas se harán después (Krita, Blender, Material Maker).

**Criterios de aceptación:**

- [x] Se asigna un plot libre al entrar y se libera al salir; se muestra el nombre del dueño.
- [x] Fabricar, exhibir y entrenar solo funcionan en el plot propio (validado en el servidor).
- [x] Mejoras de plot y de caminadora con precios crecientes; los datos anteriores se adaptan sin pérdidas.
- [x] 4 pruebas automáticas nuevas (34 en total) y revisión estática sin errores. Pendiente: ejecutarlas en Studio.
- [x] Al terminar, la fila DEV-008 queda Completada (flujo directo en `main`, DEC-009).

**Dependencias:** DEV-007 (Completada). Para no solaparse con INFRA-002 (en desarrollo), esta tarea no toca `game/README.md` ni el Registro de Decisiones; su decisión se registrará cuando INFRA-002 termine.

**Documentos relacionados:** [[GDD]] §15, [[Changelog]], [[ACTIVE_TASKS]].
### DEV-009 — Mascotas en cápsulas: compra, recompensas diarias y por tiempo, y Robux

- **ID:** DEV-009.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Michael y Einell revisan la interfaz.
- **Área:** Sistemas, economía, progresión y monetización.
- **Prioridad:** Alta.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

Las mascotas salen de **cápsulas** (sustituyen a los «huevos»), que se consiguen de tres formas:

1. **Comprándolas** con monedas: Latón, Plata y Oro.
2. **Recompensas diarias**, con una racha de 7 días, y **recompensas por tiempo jugado** cada día.
3. **Robux**: la Cápsula Cósmica, solo con Robux, trae mascotas exclusivas más poderosas, con las probabilidades visibles.

Las cápsulas ganadas o compradas con Robux se guardan en la Mochila y se abren cuando el jugador quiera. Solo mecánicas; el arte de las cápsulas y las mascotas se hará después.

**Criterios de aceptación:**

- [x] Cápsulas con monedas, inventario de cápsulas y apertura validada en el servidor.
- [x] Recompensa diaria una vez por día (UTC), con racha de 7 días que se reinicia si se salta un día.
- [x] Recompensas por tiempo jugado: niveles por día que se reclaman una sola vez.
- [x] Cápsula Cósmica (Robux) con mascotas exclusivas más fuertes y probabilidades visibles; se entrega una sola vez por compra.
- [x] 3 pruebas nuevas (37 bloques en total) y revisión estática sin errores. Pendiente: ejecutarlas en Studio.
- [x] La fila DEV-009 de ACTIVE_TASKS queda Completada.

**Dependencias:** DEV-005, DEV-006 y DEV-008 (Completadas).

**Documentos relacionados:** [[GDD]] §15, [[Changelog]], [[ACTIVE_TASKS]].
### DEV-010 — Base en media luna: 6 plots, muro frontal con estaciones y salida a correr

- **ID:** DEV-010.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Cuenta B revisa la distribución, que es visible para el jugador.
- **Área:** Sistemas y mundo (distribución funcional; el arte final va aparte).
- **Prioridad:** Alta.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

- Servidores de **6 jugadores**, con **6 plots** colocados en **media luna** alrededor de la plaza central de la base.
- **Plots más amplios:** la caminadora va **delante** de cada plot, las vitrinas en el centro y el taller **al fondo**.
- En la parte delantera de la base (donde empieza la carrera) va un **muro amplio**. Pegadas a él están la Tienda, el Criadero de cápsulas, el puesto de Robux y el Cronómetro Maestro. El muro deja una **abertura** para salir a correr hacia las zonas.

**Criterios de aceptación:**

- [x] 6 plots en arco, orientados hacia la plaza; cada uno con la caminadora delante, las vitrinas (hasta 15) y el taller al fondo.
- [x] Muro frontal con la abertura central y las 4 estaciones pegadas a él.
- [x] Nada se superpone: plots, estaciones, aparición y camino.
- [x] Revisión estática sin errores y pruebas actualizadas.
- [x] La fila DEV-010 de ACTIVE_TASKS queda Completada.

**Nota:** el límite de 6 jugadores se configura en Roblox (Game Settings → Places → Max Players) al publicar; el código prepara 6 plots.

**Dependencias:** DEV-008 (Completada).

**Documentos relacionados:** [[GDD]] §15, [[Changelog]], [[ACTIVE_TASKS]].
### DEV-011 — Historia inicial, pieza del legado, tutorial nuevo e ingreso pasivo del 30%

- **ID:** DEV-011.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Cuenta B revisa la historia, los textos y la cinemática.
- **Área:** Sistemas, economía y experiencia de inicio.
- **Prioridad:** Alta.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

1. **Cinemática breve** la primera vez que se entra: el jugador fue abandonado por sus padres y, al cumplir 18 años, lo dejan en un lugar desconocido (la plaza central del juego).
2. Allí encuentra una **pieza muy luminosa de un reloj de alta categoría**, elegida al azar. La conserva para siempre: puede guardarla o usarla. Se usan nombres de piezas ficticios en vez de marcas reales (Patek Philippe, Graff), que son marcas registradas.
3. Después empieza el **tutorial**: cómo ganar velocidad, qué hacer, qué piezas conseguir, dónde fabricar y qué hacer con los relojes.
4. **Economía:** vender da mucho más dinero (es lo activo). Exhibir en el plot da, de forma pasiva, el **30% del valor del reloj** cada periodo configurable.

**Criterios de aceptación:**

- [x] Cinemática con texto de la historia y cámara, solo la primera vez, con opción de saltar.
- [x] La pieza del legado se recoge una sola vez (validado en el servidor), es aleatoria, está protegida contra venta y descarte, y se puede usar en una receta especial.
- [x] El tutorial empieza después de la pieza y enseña velocidad, robo, taller, venta, exhibición y mejoras, con guía en el mundo.
- [x] Ingreso pasivo = 30% del valor de venta por periodo, con acumulación de fracciones.
- [x] Pruebas actualizadas y nuevas, y revisión estática sin errores.
- [x] La fila DEV-011 de ACTIVE_TASKS queda Completada.

**Dependencias:** DEV-010 (Completada).

**Documentos relacionados:** [[GDD]] §15, [[Changelog]], [[ACTIVE_TASKS]].
### DEV-012 — Ingreso pasivo cada 30 segundos

- **ID:** DEV-012.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Economía.
- **Prioridad:** Media.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):** el reloj exhibido da el 30% de su valor **cada 30 segundos** en lugar de cada 10 minutos. Se ajustan los textos del tutorial, del plot y de la documentación.

**Criterios de aceptación:**

- [x] `PLOT_INCOME_PERIOD_SECONDS` = 30 y textos coherentes en el tutorial y en el plot.
- [x] Pruebas y revisión estática sin errores.
- [x] La fila DEV-012 de ACTIVE_TASKS queda Completada.

**Dependencias:** DEV-011 (Completada).
