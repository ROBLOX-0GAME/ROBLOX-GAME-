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
### DEV-013 — HUD multiplataforma, ruleta diaria, ajustes y capacidad de carga

- **ID:** DEV-013.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. **Michael y Einell revisan el HUD**, que está en la ruta de Cuenta B (`game/src/StarterPlayer/StarterPlayerScripts`).
- **Área:** Interfaz (funcional), sistemas y economía.
- **Prioridad:** Alta.
- **Estado:** Completada (pendiente de prueba en Studio).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

1. **HUD ordenado para móvil, tablet, PC y consola.** Muestra dinero, velocidad, recompensas diarias y por tiempo, ruleta diaria, Tienda Robux, ajustes y otros datos clave. Se adapta al tamaño de pantalla y respeta los controles táctiles. Tiene atajos de teclado y de mando. Es funcional; el diseño visual final se hará después con las herramientas de arte.
2. **Ruleta diaria:** un giro gratis al día. También se pueden comprar giros extra con Robux, con las probabilidades visibles.
3. **Ajustes:** guía del tutorial, notificaciones, tamaño de la interfaz y repetir la introducción.
4. **Capacidad de carga:** un puesto para comprar más espacio para llevar objetos robados de las casas. Se empieza llevando 1 objeto por viaje y hay 3 mejoras, hasta un máximo de 4.

**Criterios de aceptación:**

- [x] HUD con tarjetas de dinero, nivel, velocidad y botín, y una barra de botones (Mochila, Premios, Ruleta, Robux, Ajustes) con avisos «!» cuando hay algo por reclamar.
- [x] Escala según la pantalla; los botones no tapan el joystick ni el botón de salto; atajos de teclado y mando.
- [x] Ruleta diaria validada en el servidor (una vez al día UTC, más giros extra comprados).
- [x] Ajustes guardados por jugador.
- [x] Capacidad de carga 1 → 4 (3 mejoras) en un puesto propio; el servidor limita el botín por viaje.
- [x] Pruebas nuevas y revisión estática sin errores.
- [x] La fila DEV-013 de ACTIVE_TASKS queda Completada.

**Dependencias:** DEV-012 (Completada).
### ART-001 — Pipeline de arte (estilo low-poly) y primeros assets de prueba

- **ID:** ART-001.
- **Cuenta Claude:** Claude 1 — Cuenta A (temporalmente; el arte es área de Cuenta B según OWNERS.md).
- **Responsable:** Jhonn por ahora; después pasa a Michael y Einell.
- **Revisor:** Michael y Einell (dirección visual); Zadiel revisa la parte técnica.
- **Área:** Dirección visual, assets y audio.
- **Prioridad:** Alta.
- **Estado:** Completada (pipeline listo; faltan la importación en Studio y la conexión en el código).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción (dirección de Jhonn, 2026-11-20):**

Empezar la parte artística con el estilo que Claude produce mejor, **low-poly colorido tipo simulador de Roblox**, que después se detallará a mano con las herramientas. Se crea el pipeline:

1. Herramientas registradas: Blender 5.3, Krita, Material Maker 1.8 y Audacity 4 (Substance 3D Painter no está instalado).
2. Carpeta `art/` para fuentes y exportaciones.
3. Formatos, límites de Roblox, escala y nombres.
4. Lista priorizada de assets enlazada con las piezas provisionales del juego.
5. Primeros assets de prueba generados con Blender por script, para validar el proceso.

**Criterios de aceptación:**

- [x] Nota «Pipeline-de-Arte» con herramientas, estilo, paleta, formatos, límites, nombres, flujo de importación y lista de assets.
- [x] Tabla de herramientas actualizada y estilo visual registrado como propuesta.
- [x] Carpeta `art/` con estructura documentada y `.gitignore` para archivos temporales.
- [x] Al menos un modelo y la paleta exportados por script desde Blender, con su conteo de triángulos.
- [x] La fila ART-001 de ACTIVE_TASKS queda Completada.

**Dependencias:** ninguna (el código del juego ya es funcional).
### ART-002 — Modelos low-poly de prioridad 1

- **ID:** ART-002.
- **Cuenta Claude:** Claude 1 — Cuenta A (temporal; área de Cuenta B).
- **Responsable:** Jhonn.
- **Revisor:** Michael y Einell; Zadiel revisa la parte técnica.
- **Área:** Assets.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** generar con los scripts de Blender los modelos base de prioridad 1 de [[Pipeline-de-Arte]] §7: piezas del plot, 5 estaciones, muro frontal y cartel, casas de las 5 zonas y pedestal, las 7 piezas robables y el marco de la puerta de velocidad. Cada uno con la medida de su pieza provisional, en FBX con su fuente y su vista previa.

**Criterios de aceptación:**

- [x] Todos los modelos de prioridad 1 exportados (FBX + .blend + vista previa) con su conteo de triángulos.
- [x] Vistas previas revisadas; lista de assets del Pipeline actualizada.
- [x] La fila ART-002 de ACTIVE_TASKS queda Completada.

**Dependencias:** ART-001 (Completada).
### ART-003 — Modelos low-poly de prioridad 2 (cápsulas, relojes, legado y mascotas)

- **ID:** ART-003.
- **Cuenta Claude:** Claude 1 — Cuenta A (temporal; área de Cuenta B).
- **Responsable:** Jhonn.
- **Revisor:** Michael y Einell; Zadiel revisa la parte técnica.
- **Área:** Assets.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** generar con los scripts de Blender los modelos base de prioridad 2 de [[Pipeline-de-Arte]] §7: cápsulas de Plata, Oro y Cósmica; los 6 relojes; las 3 piezas del legado; y las 9 mascotas. Mismo estilo low-poly y la paleta común.

**Criterios de aceptación:**

- [x] 21 modelos exportados (FBX + .blend + vista previa) con su conteo de triángulos.
- [x] Hoja de contactos revisada y lista de assets del Pipeline actualizada.
- [x] La fila ART-003 de ACTIVE_TASKS queda Completada.

**Dependencias:** ART-002 (Completada).
### ART-004 — Prioridad 3: ambiente, iconos del HUD y efectos de sonido

- **ID:** ART-004.
- **Cuenta Claude:** Claude 1 — Cuenta A (temporal; área de Cuenta B).
- **Responsable:** Jhonn.
- **Revisor:** Michael y Einell; Zadiel revisa la parte técnica.
- **Área:** Assets y audio.
- **Prioridad:** Media.
- **Estado:** Completada (música pendiente).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** completar la prioridad 3 de [[Pipeline-de-Arte]]:

1. Modelos de ambiente low-poly.
2. Iconos del HUD (PNG 256×256 con transparencia, renderizados en Blender con la paleta).
3. Efectos de sonido base, sintetizados por script y convertidos a OGG con el motor de audio de Blender, para pulir después en Audacity.

**Criterios de aceptación:**

- [x] Modelos de ambiente exportados con vista previa.
- [x] 8 iconos `ico_*` en `art/texturas/export/`.
- [x] 10 efectos `sfx_*` en `art/audio/export/` (OGG), con su fuente reproducible.
- [x] La fila ART-004 de ACTIVE_TASKS queda Completada.

**Dependencias:** ART-003 (Completada).
### DEV-014 — Conectar el arte al juego (modelos, iconos y sonidos con respaldo)

- **ID:** DEV-014.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel; Michael y Einell revisan la interfaz y el arte.
- **Área:** Arquitectura técnica e integración de assets.
- **Prioridad:** Alta.
- **Estado:** Completada (para verlo falta publicar la place e importar los assets).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** el juego usará los modelos de `ReplicatedStorage/Assets` (importados en Studio desde `art/export/modelos`) cuando existan. Se colocan sobre la pieza provisional, que se oculta pero conserva colisiones, avisos y lógica. Si un modelo no existe, se queda la pieza provisional. Los iconos y sonidos se activan al poner sus IDs de Roblox en `Config`.

**Criterios de aceptación:**

- [x] Módulo compartido `AssetLibrary` con `find` y `dress` (alinear la base, orientar, ocultar la pieza provisional, soldar si se mueve).
- [x] Plots, estaciones, muro, salida, casas, pedestales, piezas robables, vitrinas, relojes, mascotas, pieza del legado y dueños usan su asset si existe.
- [x] Sonidos (`Config.SOUND_IDS`) en los momentos clave e iconos (`Config.ICON_IDS`) en el HUD, inactivos mientras valgan 0.
- [x] Pruebas de `AssetLibrary` y revisión estática sin errores.
- [x] Instrucciones de importación actualizadas en [[Pipeline-de-Arte]].
- [x] La fila DEV-014 de ACTIVE_TASKS queda Completada.

**Dependencias:** ART-001 a ART-004 (Completadas). Para verlo en el juego hace falta la place publicada con los assets importados.
### ART-005 — Traspaso del arte a Zadiel (MacBook)

- **ID:** ART-005.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel; Michael y Einell (dueños del área de arte).
- **Área:** Coordinación de arte.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** prompt de traspaso `art/PROMPT_ARTE_ZADIEL_MAC.md` para que Zadiel continúe desde su MacBook con el diseño y los materiales de los relojes. El prompt indica cómo verificar o instalar Blender, Krita, Material Maker y Audacity en macOS, comprobar el pipeline y abrir su propia tarea (ART-006).

**Criterios de aceptación:**

- [x] Prompt con reglas del equipo, verificación e instalación de herramientas, prueba del pipeline en macOS, tarea de materiales PBR y siguientes pasos.
- [x] Enlazado desde `art/README.md` y registrado en el Changelog.

### ART-006 — Materiales PBR de los relojes (MacBook de Zadiel)

- **ID:** ART-006.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel (cubre de forma temporal el área de arte de la Cuenta B).
- **Revisor:** Michael y Einell (dueños del arte); Jhonn (técnica e importación en Studio).
- **Área:** Arte — relojes.
- **Prioridad:** Alta.
- **Estado:** Completada (para verlos en el juego falta importarlos en Studio y montar los `SurfaceAppearance`).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** que los 6 relojes (`mdl_reloj_bolsillo`, `_pulsera`, `_cronografo`, `_legado`, `_real`, `_millonario`) parezcan de lujo sin perder el estilo low-poly. Materiales procedurales (metal dorado pulido y cepillado, acero, cristal de zafiro, esmalte blanco/negro/azul, cuero y gemas rubí/diamante/zafiro) exportados como mapas PBR de 512×512 (`_color`, `_normal`, `_rugosidad`, `_metalico`). Cada reloj pasa a ser un Model con una malla por material para usar `SurfaceAppearance` en Roblox. Mismos nombres de FBX para que el juego los use sin tocar código.

**Criterios de aceptación:**

- [x] Pipeline comprobado en macOS (Blender 5.3) y comandos de macOS documentados en `art/Pipeline-de-Arte.md` y `art/README.md`.
- [x] Mapas PBR en `art/texturas/export/tex_*_{color,normal,rugosidad,metalico}.png` y sus fuentes en `art/texturas/fuentes/`.
- [x] Los 6 relojes separados por material, con UV y menos de 3.000 triángulos, exportados a `art/export/modelos/` con el mismo nombre y su `.blend` en `art/blender/fuentes/`.
- [x] Vistas previas con materiales y hoja de contactos actualizada.
- [x] Sección «Materiales PBR de los relojes» en [[Pipeline-de-Arte]] con instrucciones de `SurfaceAppearance` para quien importe en Studio.
- [x] Changelog, memoria del área 12 y propuestas en el Registro de Decisiones (materiales PBR; MacBook también para arte).
- [x] La fila ART-006 de ACTIVE_TASKS queda Completada.

**Dependencias:** ART-003 (relojes base), DEV-014 (`AssetLibrary` acepta Models). No toca `game/src`.

### ART-007 — Traspaso a la PC Windows: importar los relojes PBR en Studio y seguir el arte

- **ID:** ART-007.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn (quien importa en Windows); Michael y Einell (dueños del arte).
- **Área:** Coordinación de arte.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** prompt de traspaso `art/PROMPT_ARTE_WINDOWS_STUDIO.md` para que Claude Code siga en la PC Windows con Roblox Studio: importar los 6 relojes de ART-006 y montar sus `SurfaceAppearance`; si se aprueba DEC-018, aplicar materiales PBR a piezas robables, pieza del legado y cápsulas; después retocar iconos (Krita) y sonidos (Audacity).

**Criterios de aceptación:**

- [x] Prompt con reglas, verificación de herramientas en Windows, importación en Studio, tratamiento PBR condicionado a DEC-018, iconos, sonidos e informe.
- [x] Enlazado desde `art/README.md` y registrado en el Changelog.
- [x] La fila ART-007 de ACTIVE_TASKS queda Completada.

### ART-008 — Importar los relojes PBR en Roblox Studio

- **ID:** ART-008.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel, con Roblox Studio).
- **Responsable:** Zadiel.
- **Revisor:** Michael y Einell (dueños del arte); Jhonn (técnica).
- **Área:** Arte / Studio.
- **Prioridad:** Alta.
- **Estado:** Completada (2026-11-20, MacBook de Zadiel con Studio y MCP). Place oficial 84500108687089 guardada en la versión 9, sin publicar.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** importar los 6 `mdl_reloj_*.fbx` con el 3D Importer en `ReplicatedStorage/Assets`, subir los 44 mapas PBR, anotar sus IDs en `art/texturas/ids_roblox.md` y montar los `SurfaceAppearance` (31 MeshParts), según §3 de `art/PROMPT_ARTE_WINDOWS_STUDIO.md`.

**Criterios de aceptación:**

- [x] Existe la place oficial publicada (la creó Jhonn).
- [x] 6 relojes en `ReplicatedStorage/Assets` y 31 `SurfaceAppearance` montados sin avisos. Ampliado a los 20 modelos PBR de ART-009: 78 `SurfaceAppearance`, 0 avisos.
- [x] Prueba en Play realizada y anotada en el Changelog §27. `AssetLibrary` coloca los 20 y el cliente carga 78 de 78 contenidos.
- [x] IDs en `art/texturas/ids_roblox.md`; capturas en `art/export/vistas/studio_*.png`.
- [ ] Ver un reloj en una vitrina con un jugador real. Bloqueado por `Ui.luau:766` (DEV-011), que rompe el cliente: hace falta una tarea de código.

### ART-010 — Retocar iconos del HUD y sonidos

- **ID:** ART-010.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows).
- **Responsable:** Zadiel.
- **Revisor:** Michael y Einell (dueños del arte).
- **Área:** Arte / interfaz y audio.
- **Prioridad:** Media.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** mejorar la legibilidad de los 8 iconos del HUD (`iconos.py`: contorno oscuro y borde de luz; rehacer monedas, mochila y carga) para retocarlos después en Krita, y pulir los 10 sonidos en Audacity (normalizar, recortar, fundidos, menos de 2 s; `sfx_entrenar` en bucle de 1 s). Los cambios de estilo son propuesta para Michael y Einell. ART-009 (PBR de piezas, legado y cápsulas) no se abre: DEC-018 sigue como Propuesta.

**Criterios de aceptación:**

- [x] Iconos regenerados, revisados a 256 px y a tamaño pequeño, con el mismo nombre (`22d555c`; propuesta de estilo).
- [x] Retoque por script en lugar de Krita (contorno, sombra y formas nuevas en `iconos.py`); Krita queda para retoques opcionales (Zadiel, 2026-11-20: «realiza tú todo lo que falte»).
- [x] Todos los sonidos por debajo de 2 s, medidos con script (`sfx_ruleta` pasó de 2,28 a 1,65 s, `3f2754a`).
- [x] Sonidos pulidos por script en `sonidos.py` (fundidos, recorte de cola y nivelación), en lugar de proyectos `.aup3`.
- [x] Pipeline, Memoria de Área 12 y Changelog actualizados; fila de ACTIVE_TASKS Completada.

### INFRA-003 — El equipo queda en Zadiel y Jhonn (DEC-020) y se aprueba DEC-018

- **ID:** INFRA-003.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Coordinación / equipo.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Zadiel indica que Michael y Einell dejan el equipo: las decisiones y revisiones pasan a Zadiel y Jhonn, incluida el área de la antigua Cuenta B (mundo, arte, UX). Se registra DEC-020, se actualizan OWNERS.md, AGENTS.md y `.claude/CLAUDE.md`, y DEC-018 queda Aprobada por Zadiel. Las reglas de `.claude/rules/` no se reescriben: DEC-020 indica que, donde digan «Cuenta B» o «Michael y Einell», responden y revisan Zadiel y Jhonn.

**Criterios de aceptación:**

- [x] DEC-020 registrada como Aprobada (Zadiel) y DEC-018 marcada como Aprobada.
- [x] OWNERS.md, AGENTS.md y `.claude/CLAUDE.md` reflejan el equipo nuevo (y `.claude/CLAUDE.md` anota la place oficial 84500108687089).
- [x] Fila de ACTIVE_TASKS Completada.

### ART-009 — Materiales PBR para piezas robables, legado y cápsulas

- **ID:** ART-009.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn (DEC-020).
- **Área:** Arte / assets.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** con DEC-018 aprobada, las 7 piezas robables, las 3 piezas del legado y las 4 cápsulas pasan a materiales PBR (una malla por material, como los relojes). Materiales nuevos: `metal_laton`, `metal_plata` y `esmalte_cosmico`; el resto reutiliza los 11 existentes. Script `art/blender/scripts/piezas_detalladas.py`, con los mismos nombres, medidas y orientación que los modelos base.

**Criterios de aceptación:**

- [x] 3 materiales nuevos generados con Material Maker (12 mapas).
- [x] 14 modelos exportados; piezas por debajo de 1.000 triángulos.
- [x] `generar_todo.py` no los sobrescribe; los relojes siguen generándose igual.
- [x] Vistas EEVEE revisadas; Pipeline, Changelog y memoria del área 12 actualizados.

### ART-011 — Subida de assets con Open Cloud (script y prompt para Jhonn)

- **ID:** ART-011.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arte / herramientas.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** la place oficial es de Jhonn (Lubu465), así que los assets deben subirse con una API key suya para que carguen en la experiencia. Se crea `art/tools/subir_roblox.py` (Open Cloud Assets API: 56 PNG como Image y 20 FBX como Model; guarda los IDs en `art/texturas/ids_roblox.json` y genera `art/tools/montar_assets.luau`) y `art/PROMPT_SUBIDA_JHONN.md` para que Jhonn cree la clave y lo ejecute con su Claude. La importación en Studio y la prueba en Play siguen en ART-008.

**Criterios de aceptación:**

- [x] Script con modo de prueba (`--prueba`) ejecutado sin clave.
- [x] Prompt para Jhonn con creación de la API key, ejecución, montaje en Studio y reglas de reserva.
- [x] La clave nunca se guarda en el repositorio.


### INFRA-004 — Documento de estado del proyecto (hecho y pendiente)

- **ID:** INFRA-004.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Centro de control.
- **Prioridad:** Media.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** nota `00 - CENTRO DE CONTROL/Estado-del-Proyecto.md` con todo lo hecho hasta hoy (infraestructura, código, arte y place oficial), lo comprobado de verdad y lo que falta, por prioridad.

**Criterios de aceptación:**

- [x] Nota creada con lo hecho, lo verificado, lo pendiente y las decisiones por aprobar.
- [x] Sin secretos: se confirma que no hay ninguna API key en el repositorio.
- [x] La fila INFRA-004 de ACTIVE_TASKS queda Completada.

### DEV-015 — Errores que impiden jugar y prueba fallida de AssetLibrary

- **ID:** DEV-015.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Código / pruebas.
- **Prioridad:** Crítica.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Zadiel pide probar el juego y todo lo hecho. La foto de INFRA-004 indica que el cliente no carga (`Ui.luau:766: Malformed string`) y que falla 1 de 47 pruebas («place apoya la base en el suelo»). Se corrigen ambos, `build.py` pasa a detectar cadenas sin cerrar y se prueba en Studio.

**Criterios de aceptación:**

- [ ] `Ui.luau`: la cadena de la pieza del legado usa `
` en vez de un salto de línea real.
- [x] `AssetLibrary.place` sin `parent` devuelve una copia válida (no destruida con el ancla).
- [x] `build.py` falla ante cadenas sin cerrar; la revisión pasa en `main`.
- [x] Prueba en Studio: 47/47 pruebas y cliente con HUD. Verificada en Play por DEV-016 (versión 13).

**Cierre (2026-11-20, ART-013):** commits `dda2573` y `af644e6`; la prueba en Studio la hizo DEV-016. Queda pendiente, fuera de esta tarea, buscar en la place el origen de `rbxassetid://203785492` («Asset type does not match»).

### ART-013 — Integrar en la place oficial el arte restante

- **ID:** ART-013.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel, Roblox Studio con su MCP).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arte / integración visual.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** según [[PROMPT_INTEGRACION_VISUAL_ZADIEL]] (ART-012), y con el método de ART-008, se sube a la cuenta zadiel799 con Open Cloud la textura de paleta, los 36 modelos low-poly, los 8 iconos y los 10 sonidos. Los modelos se insertan en `ReplicatedStorage/Assets` de la place oficial (84500108687089) con escala ×0,01, piezas ancladas y `TextureID` = `tex_paleta`. La iluminación queda como propuesta DEC-022. No se toca `game/src` ni se publica.

**Criterios de aceptación:**

- [x] `tex_paleta` y los 36 modelos subidos e insertados, con sus IDs en `art/texturas/ids_roblox.md`.
- [x] Medidas comparadas con el Pipeline §7 (diferencias anotadas, sin corregirlas en código).
- [x] 8 iconos y 10 sonidos subidos (o anotados como rechazados) y tarea DEV para Jhonn con los IDs.
- [x] Iluminación propuesta como DEC-022 (aplicada solo si Zadiel lo confirma).
- [x] Verificación real: Play, consola, `PreloadAsync`, `AssetLibrary.dress`, capturas `studio_art013_*.png` y triángulos/memoria.

### ART-012 — Prompt de integración visual para Zadiel

- **ID:** ART-012.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Arte / integración visual.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Jhonn pide un prompt para que Zadiel lleve el diseño y la integración visual en la place oficial (84500108687089) con las herramientas acordadas (Blender, Material Maker, Krita, Audacity y Roblox Studio con su MCP). Guardado en [[PROMPT_INTEGRACION_VISUAL_ZADIEL]]. La integración en sí es **ART-013** (la abre Zadiel). Jhonn sigue con el gameplay (DEV-016).

**Criterios de aceptación:**

- [x] Prompt guardado con reglas, herramientas, reparto de zonas en Team Create, tarea ART-013 (36 modelos de paleta, iconos, sonidos, iluminación como propuesta) y cierre.

**Resultado (2026-11-20):** 55/55 assets *Approved* (0 rechazados), 36 modelos montados (9 con escala propia por el límite de 2048 studs), iluminación DEC-022 aplicada como propuesta, 47/47 pruebas, `PreloadAsync` 55/55 y place guardada en la **versión 16**, sin publicar. Detalle en [[Changelog]] §28. Pendiente: DEV-018 para Jhonn, aprobar DEC-022 y DEC-021, `Technology = Future` a mano y el texto del arco de salida que se mezcla con `mdl_cartel_salida`.

### DEV-016 — Cargar el código de main en la place y prueba completa en Play

- **ID:** DEV-016.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Código / gameplay.
- **Prioridad:** Crítica.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** la place oficial aún tiene el código anterior a DEV-015 (`Ui.luau:766` sigue roto en Studio; comprobado con el MCP el 2026-11-20). Se copia `game/src` de `main` a la place con el MCP de Studio, se pone `84500108687089` en `servePlaceIds` y se prueba en Play el bucle establecido (tutorial, robo, persecución, taller, venta, vitrinas, caminadora, mascotas, jefe y ruleta). Los errores de gameplay se corrigen en `game/src` (sin tocar las rutas de DEV-015) y se cargan de nuevo. No se publica.

**Criterios de aceptación:**

- [x] Los 25 scripts de la place iguales a `game/src` de `main`.
- [x] `servePlaceIds` con la place oficial.
- [x] Play: servidor sin errores, pruebas automáticas y cliente con HUD.
- [x] Recorrido del bucle principal anotado con resultado real.
- [x] Errores encontrados corregidos o anotados como bug.

**Resultado (2026-11-20):** place guardada en Roblox, versión 13, sin publicar. 47/47 pruebas, HUD cargado y consola sin errores. Bucle principal recorrido en Play sin bugs nuevos (detalle en la memoria del área 04). Pendiente: jefe con aportes, zonas 2–5, pases y productos de Robux (IDs en 0).

### DEV-017 — Prueba del jefe y de las zonas 2 a 5; Plan de Pruebas al día

- **ID:** DEV-017.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Código / pruebas.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** siguiente paso tras DEV-016. En Play sobre la place oficial: el Cronómetro Maestro con aportes de piezas (puntos, premio o devolución) y el robo en las zonas 2 a 5, incluida la defensa del servidor si no tienes la velocidad mínima. Se pone al día el §22 del Plan de Pruebas (filas pendientes de DEV-015, ya probadas en DEV-016, y la celda rota por un salto de línea). Los bugs que salgan se corrigen en `game/src`. No se publica.

**Criterios de aceptación:**

- [x] Plan de Pruebas §22 corregido y actualizado.
- [x] Jefe con aportes probado (puntos, y premio o devolución).
- [x] Zonas 2 a 5: robo permitido o rechazado según la velocidad, con resultado real.
- [x] Bugs corregidos o anotados.

**Resultado (2026-11-20):** todo correcto en Play, sin bugs nuevos (ver Plan de Pruebas §23). No se cambió código ni se guardó la place.


### DEV-018 — Conectar los iconos y sonidos de ART-013 (Config.ICON_IDS y Config.SOUND_IDS)

- **ID:** DEV-018.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Código / interfaz y sonido.
- **Prioridad:** Media.
- **Estado:** Completada (sonidos bloqueados por BUG-004).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** ART-013 subió los 8 iconos y los 10 sonidos, todos *Approved* en la cuenta zadiel799. Hay que pegar los IDs en `game/src/ReplicatedStorage/Shared/Config.luau` (con 0 no se muestran ni suenan), cargar el código en la place y comprobar en Play el HUD y los sonidos. Los IDs están en `art/texturas/ids_roblox.md`.

```lua
SOUND_IDS = {
	robar = 136358381895007, alarma_dueno = 101439249349776, atrapado = 121771660127526,
	guardar_botin = 102296286128091, comprar = 127864647773254, abrir_capsula = 119271899636402,
	ruleta = 137255558095184, subir_nivel = 85030530372481, entrenar = 99286256408690, boton = 83644407334698,
},
ICON_IDS = {
	monedas = 110143721253053, velocidad = 85592491428255, mochila = 72587806417673, premios = 107634380113502,
	ruleta = 135014274216635, robux = 130773426233365, ajustes = 115724324517779, carga = 84558382393109,
},
```

**Criterios de aceptación:**

- [x] IDs en `Config.luau` y cargados en la place.
- [ ] Play: los 8 iconos se ven en el HUD (✅) y los 10 sonidos suenan sin errores de carga en Output (❌ BUG-004).

**Resultado (2026-11-20):** IDs en `Config` y en la place (versión 17). Iconos visibles en el HUD. Sonidos bloqueados por permisos de audio (BUG-004 en [[Plan-de-Pruebas]] §24): Zadiel debe dar acceso a la experiencia 10778093657 desde su cuenta, o Jhonn resube los audios.

### INFRA-005 — La MacBook de Zadiel sirve para todo (DEC-021)

- **ID:** INFRA-005.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arquitectura / equipo.
- **Prioridad:** Media.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Zadiel indica que la MacBook se puede usar para todo. Se actualiza DEC-021 (antes solo Studio, MCP y Open Cloud) y DEC-019 queda reemplazada.

**Criterios de aceptación:**

- [x] DEC-021 actualizada con el alcance completo y DEC-019 marcada como reemplazada.

### INFRA-006 — DEC-022 aprobada (iluminación)

- **ID:** INFRA-006.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arte / dirección visual.
- **Prioridad:** Baja.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Zadiel informa de que Jhonn aprobó DEC-022 (iluminación de ART-013, ya aplicada en la place, versión 16). Se cambia su estado en el Registro.

**Criterios de aceptación:**

- [x] DEC-022 marcada como Aprobada por Zadiel y Jhonn.

### INFRA-007 — Alinear las notas con DEC-021 (la MacBook sirve para todo)

- **ID:** INFRA-007.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arquitectura / equipo.
- **Prioridad:** Media.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** `.claude/CLAUDE.md`, `AGENTS.md` y [[Arquitectura-General]] todavía dicen que la MacBook es solo para Obsidian y tareas escolares, lo que contradice DEC-021 (aprobada por Zadiel en INFRA-005). Se corrigen. En Arquitectura-General también se actualiza lo que ya no es cierto en la misma sección: la place existe (84500108687089) y `servePlaceIds` la tiene desde DEV-016.

**Criterios de aceptación:**

- [x] Las 3 notas dicen que Studio y Rojo se usan en las PC Windows y en la MacBook de Zadiel (DEC-021).
- [x] Arquitectura-General sin la propuesta DEC-019 (reemplazada) y con la place y `servePlaceIds` al día.

### INFRA-008 — DEC-021 aprobada por Jhonn

- **ID:** INFRA-008.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arquitectura / equipo.
- **Prioridad:** Baja.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Zadiel informa de que Jhonn aprobó DEC-021 (la MacBook sirve para todo). Se cambia su estado en el Registro.

**Criterios de aceptación:**

- [x] DEC-021 marcada como Aprobada por Zadiel y Jhonn.
