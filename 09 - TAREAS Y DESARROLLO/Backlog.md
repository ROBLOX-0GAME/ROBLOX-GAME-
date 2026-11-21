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

### DEV-019 — Pases y productos de Robux: precios, multiplicadores ×2–×1024 y creación en Roblox

- **ID:** DEV-019.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Economía / monetización.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** Jhonn fija los precios (DEC-023): productos con la propuesta estándar, pases un 15–20 % más caros y 9 pases nuevos de entrenamiento que multiplican la velocidad ganada (×2 por 3 R$ … ×512 por 1.199 R$). Se añaden al código (se aplica el multiplicador más alto, combinado con la caminadora), se crean en el universo 10778093657 con Open Cloud, se ponen los IDs en `Config`, se cargan en la place y se prueban en Play. No se publica.

**Criterios de aceptación:**

- [x] DEC-023 en el Registro.
- [x] Multiplicadores en `GameData`, `PlayerLogic.coinMultiplier`, prueba automática y tienda Robux.
- [x] 15 pases y 7 productos creados en Roblox con su precio; IDs en `Config`.
- [x] Código cargado en la place; Play: pruebas en verde y la tienda abre la compra.

**Resultado (2026-11-20):** 15 pases y 7 productos a la venta en Roblox; IDs en `Config`; place guardada (versión 18, sin publicar). 48/48 pruebas. Ver [[Plan-de-Pruebas]] §25. Pendiente: compra real con otra cuenta y subir `MAX_TRAINED` para que rindan los pases altos.


### ART-014 — Identidad visual «taller de relojería fantástico» (arte y diseño de presentación)

- **ID:** ART-014.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Arte / mundo / interfaz.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** auditoría visual y mejora de la presentación con una identidad original («taller de relojería fantástico»: madera cálida, carbón, marfil, latón y oro, acentos cian), conservando low-poly, DEC-018 y DEC-022. **Bloque B (esta tarea):** arte nuevo en `art/` con Blender y Krita: identidad de las 5 zonas (vegetación y detalles), torre de reloj para la plaza e iconos de estaciones. **Bloque A (código en `game/src`):** queda diseñado para una tarea posterior porque `game/src/**` está reservado por DEV-019. No se toca la place ni se publica.

**Criterios de aceptación:**

- [x] Auditoría y propuesta DEC-025 redactadas (Memoria del área 06; al Registro cuando DEV-019 lo libere).
- [x] Modelos nuevos exportados en `art/export/modelos/` con vistas previas.
- [x] Iconos de estaciones en `art/texturas/export/`.
- [x] Diseño del Bloque A listo para aplicar en `game/src`.

**Resultado (2026-11-20):** 13 modelos y 5 iconos originales exportados (commit `0559a51`). Diseño del Bloque A en [[UI-UX]] §12. Propuesta DEC-025 en la memoria del área 06, pendiente de pasar al Registro cuando DEV-019 lo libere. Sigue en ART-015.

### ART-015 — Aplicar la presentación visual de ART-014 (código y Studio)

- **ID:** ART-015.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel, Studio con MCP).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Código de presentación / arte en Studio.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** aplicar [[UI-UX]] §12 en `game/src`: carteles por contexto, `Client/Vfx.luau`, brillo por rareza, HUD con la paleta de taller y decoración por zona en `WorldService` con respaldo genérico. Pasar DEC-025 al Registro como Propuesta. Con el OK de Zadiel y Jhonn: subir a Studio los 13 modelos y 5 iconos de ART-014 (método de ART-013), comprobar en Play y guardar sin publicar.

**Criterios de aceptación:**

- [x] DEC-025 en el Registro (Propuesta). Falta que Zadiel y Jhonn la aprueben o la rechacen.
- [x] Código de §12 aplicado sin tocar lógica, etiquetas, atributos ni red; `build.py --check`, `rojo build` y 48/48 pruebas.
- [x] Assets de ART-014 subidos e insertados, con sus IDs en `ids_roblox.md`.
- [x] Prueba en Play: carteles sin superponerse, efectos breves y rendimiento medido (triángulos y *draw calls*).

**Resultado (2026-11-20):** place guardada en la **versión 21**, sin publicar. 18/18 assets *Approved*, 48/48 pruebas, `PreloadAsync` 31/31 y, como mucho, 30.922 triángulos y 36 *draw calls*. Detalle en el Plan de Pruebas §26 y el [[Changelog]] §30. Pendiente: aprobar DEC-025, BUG-004 (permisos de los sonidos) y lo no aplicado de [[UI-UX]] §12.

### DEV-020 — 12 zonas, velocidad como estadística, casas con dueño dormido y botón de velocidad

- **ID:** DEV-020.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Gameplay / mundo / progresión.
- **Prioridad:** Crítica.
- **Estado:** Completada (código). La carga en la place y la prueba en Play pasan a DEV-021.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** decisión de Jhonn (DEC-024). 12 zonas: 100 · 1K · 10K · 100K · 1M · 14M · 200M · 2,8B · 40B · 560B · 7,5T · 99,9T de velocidad (con 100T se abrirá un mundo nuevo en el futuro). Los jugadores empiezan con 75. La «Velocidad» es una estadística; la velocidad real sigue una curva con tope (zona 5 = 85, zona 12 = 150), 50 como máximo en el lobby y 40 dentro de las casas. Cada zona es un 35 % más larga que la anterior. El dueño de cada casa duerme y se despierta si pasas más de 15 s dentro; dentro de la casa es lento. Botón «Velocidad» en el HUD con barra deslizante para la velocidad del lobby. El entrenamiento y la economía se reescalan para llegar a esas cifras sin pagar. Se comprueba que la cinemática inicial va antes del tutorial. El pase Dinero ×2 y las ventajas VIP van en DEV-021; el Renacer, después.

**Criterios de aceptación:**

- [x] DEC-024 en el Registro.
- [x] 12 zonas con su velocidad, largo creciente, casas y dueños.
- [x] Velocidad estadística, velocidad real con curva y topes (lobby 50, casas 40, zonas hasta 150).
- [x] Dueño dormido que despierta a los 15 s, lento dentro de la casa.
- [x] Botón de velocidad con barra deslizante.
- [x] Entrenamiento, mejoras y monedas reescalados; pruebas actualizadas y en verde.
- [ ] Cinemática antes del tutorial comprobada con un jugador nuevo (pasa a DEV-021).
- [ ] Código en la place y probado en Play (pasa a DEV-021; ya cargados Config y TrainingService).

**Resultado (2026-11-21):** código en `main` (`71ac1d0`, numeración `f0a4520`). Revisión estática sin errores. Las pruebas automáticas aún no se ejecutaron en Studio. Reserva liberada a pedido de Jhonn; lo pendiente sigue en DEV-021.

### ART-016 — Pendientes de ART-015: UI-UX §12, permisos de sonido y asset 203785492

- **ID:** ART-016.
- **Cuenta Claude:** Claude — Cuenta A (MacBook de Zadiel, Studio con MCP).
- **Responsable:** Zadiel.
- **Revisor:** Jhonn.
- **Área:** Interfaz / audio / pruebas.
- **Prioridad:** Media.
- **Estado:** En desarrollo.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-20.

**Descripción:** resolver lo pendiente de ART-015.
- **(1) Lo que falta de [[UI-UX]] §12:**
  - Carteles de vitrina y de mascota solo propios.
  - Rótulo de puerta solo si falta velocidad.
  - Aro de rareza en las vitrinas.
  - Ajuste «Efectos sí/no».
  - Panel de velocidad plegable.
- **(2) BUG-004:** permisos de los sonidos.
- **(3) Origen de `rbxassetid://203785492`.**

La parte (1) necesita `game/src/**`, reservado por DEV-020 (Jhonn): se aplica cuando lo libere.

**Criterios de aceptación:**

- [x] BUG-004 resuelto: los 10 audios tienen permiso de uso para el universo 10778093657 (Open Cloud `asset-permissions`, 10/10 correctos). Play: 10/10 *Success* y sin errores de permisos.
- [x] `203785492` investigado: es «Pop Close Sound» (audio de 2015 de otro usuario). No está en la place (0 coincidencias en edición, en el cliente ni en el servidor), así que lo pide la interfaz interna de Roblox. No afecta al juego.
- [ ] UI-UX §12 restante en `game/src` (esperando a DEV-020).
- [ ] Plan de Pruebas: marcar BUG-004 como resuelto (la ruta es de DEV-020).
- [x] Propuesta visual renumerada a DEC-025 en las notas libres.
- [x] DEC-025 en el título del Registro, en el Plan de Pruebas §26 y en los comentarios de `game/src` (hecho por Jhonn en DEV-020, `f0a4520`).

### DEV-021 — Puesto de Mochila y Carga, mejoras ×1,5 desde 100 monedas y prueba de DEV-020 en la place

- **ID:** DEV-021.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Economía / gameplay / pruebas.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** encargo de Jhonn (2026-11-21, trabajando sin preguntas; dudas en [[Recomendaciones-Claude]]).
- La mejora de la Mochila (más espacio para piezas) pasa de la Tienda al Puesto de Carga, que se llama «Mochila y Carga».
- Todas las mejoras empiezan en 100 monedas y suben un 50 % por nivel (×1,5). Máximo 8 niveles; la carga por viaje, 3 niveles (hasta 4 objetos). DEC-026.
- Cargar en la place todo el código de DEV-020 y DEV-021, probar en Play (pruebas, 12 zonas, dueño dormido, barra de velocidad y cinemática antes del tutorial con un jugador nuevo) y guardar sin publicar.
- Tener en cuenta el renderizado en todo (pocas instancias, nada pesado para móvil).

**Criterios de aceptación:**

- [x] Puesto «Mochila y Carga» con las mejoras de mochila y de carga.
- [x] Mejoras: 100 monedas, ×1,5 por nivel, máximo 8 (carga 3). DEC-026 en el Registro.
- [x] Código de DEV-020 y DEV-021 en la place (hash igual a `main`).
- [x] Play: pruebas automáticas en verde y recorrido real anotado en el Plan de Pruebas.
- [x] Place guardada (sin publicar).

**Resultado (2026-11-21):** código en `main` y en la place (versión 25, sin publicar). 50/50 pruebas y recorrido en [[Plan-de-Pruebas]] §27. La cinemática con un jugador nuevo queda para Jhonn (R-005). Dudas y riesgos en [[Recomendaciones-Claude]] (R-001 a R-006).


### ART-017 — Documento para Zadiel: piezas de reloj robables, mesa de armado y animaciones por rareza

- **ID:** ART-017.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Arte / diseño de juego.
- **Prioridad:** Alta.
- **Estado:** Completada (documento listo para revisar).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** Jhonn pide un documento con todas las indicaciones para que Zadiel diseñe los objetos robables de las casas: Caja, Movimiento/calibre (cuarzo, mecánico o automático), Esfera y Manecillas. Incluye las animaciones épicas por rareza (Krita, Blender y Roblox Studio) y la mesa de armado: piezas ordenadas por reloj o por rareza y marcos verdes con el orden caja → calibre → esfera → manecillas. Una pieza de otro reloj se puede poner, pero baja la rareza, el valor, el ingreso pasivo y la suerte. Es un documento para revisar antes de ejecutarlo; el cambio del sistema de piezas en el código será otra tarea DEV.

**Criterios de aceptación:**

- [x] `art/PROMPT_PIEZAS_RELOJ_ZADIEL.md` con el diseño, las herramientas, las animaciones y los criterios.
- [x] Preguntas abiertas en [[Recomendaciones-Claude]].

**Resultado (2026-11-21):** [[PROMPT_PIEZAS_RELOJ_ZADIEL]] con las 4 clases de pieza, los 3 calibres, 7 rarezas, 12 relojes propuestos, presupuesto de renderizado, mesa de armado con marcos verdes, 7 niveles de animación más «Reloj perfecto», herramientas (Krita, Blender, Studio) y el contrato de nombres para el código. Preguntas R-007 a R-010 en [[Recomendaciones-Claude]]. Siguiente: Jhonn lo revisa y Zadiel abre ART-018.

### DEV-022 — Respuestas de Jhonn a las recomendaciones: mejoras nuevas y dinero de las mascotas

- **ID:** DEV-022.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Economía / progresión.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** Jhonn respondió a [[Recomendaciones-Claude]] (2026-11-21). Esta tarea aplica DEC-027:
- Solo quedan dos mejoras con monedas:
  - **Vitrinas del plot:** de 4 a 12, +1 por nivel, 8 niveles; empiezan en 100 y cada nivel cuesta ×10.
  - **Carga por viaje:** 3 niveles (de 1 a 4); 100 y ×10.
- **Caminadora:** 30 niveles, ×2 de entrenamiento cada uno. Su precio sube por nivel (nunca por zona) y se calibra con el valor de los relojes.
- **Mochila:** fija en 60 piezas; solo se amplía con el pase de Robux.
- Se quitan las mejoras de **velocidad**, **salto** y **suerte**. La suerte viene solo de las mascotas y de los relojes exhibidos.
- **Mascotas:** dan monedas extra, ¼ de su bonus de velocidad (sumadas las equipadas).
- **Precios:** solo dependen del nivel, nunca de la zona.

**Criterios de aceptación:**

- [x] DEC-027 en el Registro y respuestas en [[Recomendaciones-Claude]].
- [x] Mejoras y mochila como arriba; pruebas actualizadas.
- [x] Mascotas con bonus de monedas.
- [x] Código en la place y probado en Play.

**Resultado (2026-11-21):** en `main` y en la place (versión 27). 50/50 pruebas; cinemática y tutorial verificados con datos reiniciados ([[Plan-de-Pruebas]] §28).

### DEV-023 — Reinicio de la zona de carreras cada 5 min, 12 rarezas y avisos de piezas muy raras

- **ID:** DEV-023.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Gameplay / interfaz.
- **Prioridad:** Alta.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** DEC-029 y parte de DEC-028.
- Las piezas de cada casa ya son únicas en el servidor (quien la roba primero se la lleva); se comprueba.
- Cada 5 min se cierra la zona de carreras: 30 s de cuenta atrás arriba, todos vuelven a la base con el botín guardado, se renuevan las piezas de todas las casas y se abre a los 10 s.
- Tabla de **12 rarezas** con su color y mensaje.
- Aviso arriba para todo el servidor cuando aparece una pieza Mítica o superior, con la zona. Con las piezas actuales (hasta Legendario) no salta todavía; servirá con las piezas nuevas de DEV-025.

**Criterios de aceptación:**

- [x] Reinicio cada 5 min con cuenta atrás, vuelta a la base, botín guardado, piezas renovadas y reapertura.
- [x] 12 rarezas en `GameData` y aviso para Mítica o superior.
- [x] Pruebas automáticas y prueba en Play.

**Resultado (2026-11-21):** en `main` y en la place (versión 28). 51/51 pruebas y ciclo completo probado ([[Plan-de-Pruebas]] §29). El aviso de piezas Míticas se probará con las piezas nuevas (DEV-025).

### DEV-024 — Pase Dinero ×2, ventajas VIP y ganancia offline

- **ID:** DEV-024.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Monetización / economía.
- **Prioridad:** Media.
- **Estado:** Completada.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** DEC-030.
- Crear en Roblox el pase **Dinero ×2** (249 R$): monedas ×2 al vender, en el botín y en el plot; se combina con el VIP.
- **VIP:**
  - Premios por tiempo en un 30 % menos de tiempo (el tiempo jugado cuenta ×1,43).
  - Etiqueta **[VIP]** dorada en el chat.
  - Ganancia offline hasta 8 h.
- **Ganancia offline para todos:** hasta 4 h sin VIP; al 50 % del ingreso del plot. Se paga al entrar.

**Criterios de aceptación:**

- [x] Pase Dinero ×2 creado y en `Config`.
- [x] VIP: premios más rápidos, etiqueta en el chat y offline de 8 h.
- [x] Ganancia offline de 4 h para todos.
- [x] Pruebas automáticas y prueba en Play.

**Resultado (2026-11-21):** en `main` y en la place (versión 29). 52/52 pruebas ([[Plan-de-Pruebas]] §30). Falta ver la etiqueta en el chat y una ganancia offline real.

### DEV-025 — Piezas de reloj (Caja, Calibre, Esfera, Manecillas), 12 rarezas y mesa de armado

- **ID:** DEV-025.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Gameplay / economía / interfaz.
- **Prioridad:** Crítica.
- **Estado:** Completada (pendiente de revisión de Zadiel).
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** DEC-028.
- Las casas dan **piezas de reloj** (Caja, Calibre, Esfera y Manecillas) de un reloj concreto y con una de las 12 rarezas. Cualquier pieza puede salir en cualquier zona; las zonas lejanas dan rarezas más altas. Desde la zona 3, cada zona tiene un reloj famoso exclusivo (nombres interpretados).
- **Mesa de armado:** 4 marcos verdes en orden (caja → calibre → esfera → manecillas) y piezas ordenadas por reloj o por rareza. Cada pieza de otro reloj resta 1 rareza y un 25 % de valor, ingreso y suerte.
- **Valor:** el mejor reloj (exclusivo de la zona 12, 4 piezas Atemporales) se vende por unos 1,8T.
- **Piezas antiguas:** solo salen durante la reparación del Cronómetro.
- Aspecto provisional hasta que lleguen los modelos de Zadiel (ART-018), con el contrato de nombres `pz_<reloj>_<clase>`.

**Criterios de aceptación:**

- [x] Catálogo de 16 relojes (6 generales y 10 exclusivos), 4 clases de pieza y tirada de rareza por zona.
- [x] Robo, botín y mochila con piezas nuevas; los avisos desde Mítico funcionan.
- [x] Mesa de armado con marcos, orden, vista previa y penalización por pieza ajena.
- [x] Vender y exhibir relojes con rareza; ingreso y suerte según el reloj.
- [x] Piezas antiguas solo durante el Cronómetro.
- [x] Datos antiguos compatibles; pruebas actualizadas y en verde; prueba en Play.
- [x] Documento de Zadiel actualizado con las respuestas de Jhonn.

**Resultado (2026-11-21):** en `main` y en la place (versión 32). 52/52 pruebas; 144 piezas de reloj en las casas y armado con pieza ajena comprobado en el servidor ([[Plan-de-Pruebas]] §31). [[PROMPT_PIEZAS_RELOJ_ZADIEL]] actualizado para ART-018. Faltan pruebas manuales: la mesa en pantalla, el aviso de piezas Míticas y las piezas antiguas durante el Cronómetro.

### DEV-026 — Mesa que se cierra sola, 12 relojes de lujo (uno por zona) y revisión de mecánicas

- **ID:** DEV-026.
- **Cuenta Claude:** Claude — Cuenta A (PC Windows de Jhonn).
- **Responsable:** Jhonn.
- **Revisor:** Zadiel.
- **Área:** Gameplay / interfaz.
- **Prioridad:** Crítica.
- **Estado:** En desarrollo.
- **Flujo:** directo en `main` (DEC-009).
- **Fecha de creación:** 2026-11-21.

**Descripción:** pedido de Jhonn (2026-11-21).
- **BUG:** el panel de la mesa de armado se cierra de repente. Causa: el cliente busca la estación `workshop` y acepta la de un plot libre (sin dueño), que está lejos, y el control de distancia cierra el panel.
- **12 relojes de lujo, uno exclusivo por zona (1 a 12),** con nombres interpretados y aspecto parecido al original: Speedmaster, Santos, Reverso, Daytona, Overseas, Nautilus, Royal Oak, Big Bang, RM 11, Breguet Tourbillon, Grandmaster Chime y Astronomia. Sustituyen a los 10 exclusivos de DEV-025. Los 6 relojes generales siguen saliendo al azar en cualquier zona.
- Añadir al prompt de Zadiel los 12 relojes con los materiales de cada zona.
- Revisar que todas las mecánicas funcionen. El Renacer queda fuera por ahora.

**Criterios de aceptación:**

- [ ] La mesa no se cierra mientras estás junto a tu plot.
- [ ] 12 exclusivos (zonas 1 a 12) en el juego y en el prompt, con materiales por zona.
- [ ] Revisión de mecánicas con resultados reales en el Plan de Pruebas.
- [ ] Pruebas automáticas en verde y prueba en Play.
