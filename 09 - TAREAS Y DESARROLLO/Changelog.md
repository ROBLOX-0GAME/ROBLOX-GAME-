 
# 📝 CHANGELOG — BUILD A WATCH!

> **Nota (DEV-007, 2026-11-20):** los pasos de DEV-001 a DEV-006 se hicieron en la carpeta `juego/`; DEV-007 movió el código a `game/` (DEC-001). Los números de decisión de este historial ya están renumerados (las propuestas empiezan en DEC-003).

## 1. Propósito

Registrar cada paso del desarrollo: qué se hizo, dónde, quién lo pidió y cómo se verificó. Lo más reciente va arriba dentro de cada tarea.

**Formato de cada entrada:** `fecha · tarea · paso — descripción (rutas) · verificación`.

Reglas:

- Una entrada por paso real; no registrar pasos que no ocurrieron.
- Indicar siempre si una verificación se **ejecutó** o está **pendiente**.
- Las cifras de balance y las mecánicas siguen siendo **propuestas** hasta que el equipo las apruebe en [[Registro-de-Decisiones]].

---

## 2. DEV-001 — Base técnica y bucle principal (MVP)

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Cuenta:** Claude 1 (Cuenta A) · **Rama:** `task/DEV-001-base-mvp`

### Registro de pasos

- **2026-11-20 · DEV-001 · Paso 1 — Inicio.** Lectura de instrucciones, Dashboard, Protocolo, Backlog, Registro de Decisiones, GDD, Visión, Arquitectura, Sistemas, Economía, Multijugador y memorias de área. Se detecta la place `Proyecto Roblox Studio.rbxl` (binaria, 89 KB, plantilla vacía) en la raíz del repositorio. · Verificación: ejecutada (lectura y `git status`).
- **2026-11-20 · DEV-001 · Paso 2 — Rama y registro.** Creada la rama `task/DEV-001-base-mvp` desde `main` (sin cambios remotos pendientes). Tarea registrada en [[Backlog]]. Creado este Changelog. · Verificación: ejecutada (`git fetch`, `git switch`).
- **2026-11-20 · DEV-001 · Paso 3 — Herramientas.** Se intentó instalar Rojo 7.7.1 y Lune 0.11.1; la descarga de ejecutables fue bloqueada por los permisos de esta sesión. Se adopta la alternativa: estructura compatible con Rojo + script propio `juego/build.py` (Python) que genera la place `.rbxlx`. · Verificación: ejecutada (bloqueo confirmado).
- **2026-11-20 · DEV-001 · Paso 4 — Módulos compartidos.** `juego/src/shared/`: `Config.luau` (cifras técnicas y de balance), `GameData.luau` (6 piezas, 4 relojes, 5 mejoras) y `PlayerLogic.luau` (reglas puras: mochila, fabricación, niveles, venta, mejoras, museo, suerte y reparación de datos guardados). · Verificación: revisión estática ejecutada (paso 8).
- **2026-11-20 · DEV-001 · Paso 5 — Servidor.** `juego/src/server/`: `Main.server.luau` y servicios `Net` (remotos), `DataService` (DataStore con reintentos, bloqueo de sesión, autoguardado cada 120 s, guardado al salir y al cerrar el servidor, modo temporal en Studio sin API), `WorldService` (mapa con suelo, zona de recolección, aparición y estaciones Taller/Tienda/Museo con ProximityPrompt), `PartSpawner` (30 cajas compartidas que reaparecen a los 8 s), `ActionService` (única entrada de acciones: tipos, límite de 8 solicitudes/s, distancia a la estación y reglas), `MuseumService` (ingreso cada 10 s) y `CharacterService` (velocidad y salto). · Verificación: revisión estática ejecutada; prueba en Studio pendiente.
- **2026-11-20 · DEV-001 · Paso 6 — Cliente.** `juego/src/client/`: `Main.client.luau` y `Ui.luau` (HUD de monedas/nivel/XP/mochila/museo, notificaciones, menús de Taller, Tienda, Museo y Mochila). Controles con teclado, mando (selección automática, botón B cierra, botón Y mochila) y táctil (botón "Mochila"). · Verificación: revisión estática ejecutada; prueba en Studio y en móvil pendiente.
- **2026-11-20 · DEV-001 · Paso 7 — Pruebas.** `juego/src/server/Tests/`: 13 pruebas de `PlayerLogic` y un ejecutor que solo corre en Studio al pulsar Play. · Verificación: **pendiente** (requiere Studio; no se ejecutaron en esta sesión).
- **2026-11-20 · DEV-001 · Paso 8 — Compilación.** `juego/build.py` + `juego/default.project.json` (formato Rojo). El script revisa bloques, `require` y campos de módulos, y genera `juego/build/BuildAWatch.rbxlx`. · Verificación: **ejecutada** — 15 scripts, 38 `require` verificados, 0 errores; XML válido; el revisor detectó correctamente errores introducidos a propósito (bloque sin cerrar, `require` y campo inexistentes).
- **2026-11-20 · DEV-001 · Paso 9 — Documentación.** `juego/README.md`, `.gitignore` (`juego/build/`, bloqueos de Studio), [[Arquitectura-General]] §13, [[Plan-de-Pruebas]] §9, [[Registro-de-Decisiones]] (DEC-001 y DEC-003 como propuestas), memorias de 03, 07 y 09, enlace en [[Dashboard]] y estado en [[Backlog]]. · Verificación: ejecutada (revisión de archivos).
- **2026-11-20 · DEV-001 · Paso 10 — Prueba en Studio (Jhonn).** Jhonn abrió la place en Studio y reporta que el bucle es totalmente funcional, con algunos errores menores aún sin detallar. El guardado real sigue sin probarse porque no se ha activado el acceso a API (requiere publicar la experiencia). · Verificación: manual, reportada por Jhonn.
- **2026-11-20 · DEV-001 · Paso 11 — Primer error registrado.** BUG-001 en [[Plan-de-Pruebas]]: la mochila se llena sin piezas suficientes para ningún reloj y el jugador queda bloqueado. Jhonn decide corregirlo más adelante. · Verificación: reportado por Jhonn en Studio.
- **2026-11-20 · DEV-001 · Paso 12 — Corrección de BUG-001.** Se añaden la venta de piezas sueltas en la Tienda (`PlayerLogic.sellPart`, acción `sellPart`) y la opción de tirar piezas desde la Mochila en cualquier lugar (`discardPart`). Nuevo campo `sell` en las piezas de `GameData.luau` (propuesta). Hay 2 pruebas nuevas, con lo que el total pasa de 13 a 15. `build.py` ahora también detecta funciones locales usadas antes de declararse; esa revisión atrapó un error real de orden en esta corrección antes de subirla. · Verificación: revisión estática ejecutada sin errores; prueba en Studio pendiente.

### Pendiente para cerrar DEV-001

1. ~~Probar el bucle en Studio~~ (hecho, Paso 10). Registrar como BUG-00X en [[Plan-de-Pruebas]] los errores menores encontrados.
1b. Probar el guardado: publicar la experiencia (privada) y activar *Enable Studio Access to API Services*.
2. Probar con mando y en el emulador de dispositivos móviles de Studio.
3. Zadiel revisa la solicitud de cambios; el equipo aprueba o corrige las cifras de balance.

---

## 3. DEV-002 — Tutorial guiado para jugadores nuevos

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Cuenta:** Claude 1 (Cuenta A) · **Rama:** `task/DEV-002-tutorial` (sale de DEV-001)

### Registro de pasos

- **2026-11-20 · DEV-002 · Paso 1 — Elección y registro.** Jhonn pidió continuar con la creación del juego después de BUG-001. Se elige el tutorial: estaba pendiente en la memoria del GDD y es lo que más ayuda a un jugador nuevo. El robo, el jefe, las mascotas y las compras con Robux quedan fuera porque necesitan aprobación del equipo. Rama creada y tarea registrada en [[Backlog]]. · Verificación: ejecutada.
- **2026-11-20 · DEV-002 · Paso 2 — Datos y reglas.** `GameData.Tutorial` define 5 pasos con 170 monedas de premio en total (propuesta). `PlayerLogic` incorpora el campo guardado `tutorial`, con reparación para partidas anteriores, y las funciones `tutorialValue`, `tutorialStep` y `advanceTutorial`. El tutorial también se incluye en la vista que recibe el cliente. · Verificación: revisión estática ejecutada sin errores.
- **2026-11-20 · DEV-002 · Paso 3 — Servidor.** `DataService.replicate` completa los objetivos cumplidos después de cada cambio y avisa al jugador. · Verificación: revisión estática ejecutada.
- **2026-11-20 · DEV-002 · Paso 4 — Interfaz.** El HUD muestra el objetivo, el progreso y el premio. Una línea luminosa (Beam) va del personaje a la zona de arena o a la estación y se oculta a menos de 18 studs del destino. · Verificación: revisión estática ejecutada; prueba en Studio pendiente.
- **2026-11-20 · DEV-002 · Paso 5 — Pruebas.** Hay 2 pruebas nuevas: el orden, el pago único y el fin del tutorial, más la reparación de datos. El total pasa a 17. · Verificación: **pendiente** (se ejecutan con Play en Studio).

### Pendiente para cerrar DEV-002

1. Jhonn: `python juego/build.py`, Play en Studio y confirmar `[Pruebas] 17 correctas, 0 fallidas`.
2. Completar los 5 objetivos con datos nuevos y comprobar que la guía apunta bien.
3. Revisión de Zadiel y aprobación de textos y premios (DEC-004).

---

## 4. DEV-003 — Robo por zonas con persecución

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Rama:** `task/DEV-003-robo-zonas`

### Registro de pasos

- **2026-11-20 · DEV-003 · Paso 1 — Dirección del juego.** Jhonn define la estructura: correr por zonas cada vez más ricas, entrar en casas con piezas de distintas rarezas, el dueño persigue al salir y la velocidad decide hasta dónde llegas (las mascotas multiplicarán la velocidad). Orden pedido: robo → jefe → mascotas. Diseño escrito en [[GDD]] §15. · Verificación: ejecutada.
- **2026-11-20 · DEV-003 · Paso 2 — Datos.** `GameData`: 5 zonas con 4 dueños cada una, pieza Diamante, Reloj del millonario, Velocidad hasta nivel 10 y Suerte = probabilidad de robar 2 piezas. `Config`: base segura, tiempos de persecución y tope de velocidad 60. · Verificación: revisión estática.
- **2026-11-20 · DEV-003 · Paso 3 — Reglas.** `PlayerLogic`: botín (`carried`), `stealPart`, `depositLoot`, `loseLoot`, `freeSpace`, `canEnterZone`, `highestZone` y `rollPart` con tabla de zona. Se elimina `luckMultiplier`. · Verificación: revisión estática.
- **2026-11-20 · DEV-003 · Paso 4 — Mundo y casas.** `WorldService` se rehace: base segura, camino, 5 zonas, puertas de velocidad y muros límite; las estaciones se marcan con CollectionService y son persistentes con streaming. Nuevo `HouseService`: 20 casas con 3 piezas que reaparecen, robo validado, cola de persecución, botín guardado al entrar a la base y botín perdido al morir. Nuevo `OwnerNpc`: el dueño (un personaje de bloques) sale por la puerta y te persigue con `MoveTo`. Se elimina `PartSpawner`. · Verificación: revisión estática; prueba en Studio pendiente.
- **2026-11-20 · DEV-003 · Paso 5 — Interfaz.** El HUD muestra la velocidad, la zona máxima y el botín encima. Las puertas se abren solo en el cliente que cumple la velocidad. La guía del tutorial apunta a la primera casa y la Mochila muestra el botín. El primer paso del tutorial pasa a ser «Roba 5 piezas y llévalas a la base». · Verificación: revisión estática.
- **2026-11-20 · DEV-003 · Paso 6 — Pruebas.** Hay 4 pruebas nuevas: robo, guardado y pérdida del botín, límite de mochila con suerte, zonas y velocidad, y rareza por zona. Se ajusta la prueba de `rollPart`. Total: 25. · Verificación: **pendiente** en Studio. Revisión estática ejecutada: 0 errores, 42 `require`.

---

## 5. DEV-004 — Jefe cooperativo: Cronómetro Maestro

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Rama:** `task/DEV-004-jefe-cronometro`

### Registro de pasos

- **2026-11-20 · DEV-004 · Paso 1 — Diseño.** Se adapta la propuesta previa del jefe sin combate (memoria de 08 - Multijugador) al nuevo bucle de robo: es un evento cooperativo de entrega de piezas. Escrito en [[GDD]] §15.3. · Verificación: ejecutada.
- **2026-11-20 · DEV-004 · Paso 2 — Reglas.** `Config` recibe los tiempos, la meta y el premio del evento. `GameData.RepairPoints` define los puntos por rareza. `PlayerLogic` incorpora `contributeParts`, `refundParts` y `bossReward`. · Verificación: revisión estática.
- **2026-11-20 · DEV-004 · Paso 3 — Servidor.** `BossService` crea la estación con la esfera, la aguja que gira y el humo, maneja el ciclo del evento y publica su estado en atributos; además evita cerrar el evento dos veces. `ActionService` incorpora la acción `contribute`, que ahora recibe también al jugador. · Verificación: revisión estática; prueba en Studio pendiente.
- **2026-11-20 · DEV-004 · Paso 4 — Interfaz.** Menú «Cronómetro Maestro» con temporizador en vivo, progreso, aporte propio y botones para entregar. Se refresca cuando cambia el estado. · Verificación: revisión estática (0 errores, 49 `require`).
- **2026-11-20 · DEV-004 · Paso 5 — Pruebas.** 2 pruebas nuevas: entregas y reembolso, y rarezas con puntos y color. Total: 27. · Verificación: **pendiente** en Studio.

---

## 6. DEV-005 — Mascotas con multiplicador de velocidad

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Rama:** `task/DEV-005-mascotas`

### Registro de pasos

- **2026-11-20 · DEV-005 · Paso 1 — Diseño.** Jhonn pidió que las mascotas den un multiplicador de velocidad, porque la velocidad decide hasta qué zona se llega. Se definen 5 mascotas, 3 huevos y un máximo de 3 equipadas. Escrito en [[GDD]] §15.4. · Verificación: ejecutada.
- **2026-11-20 · DEV-005 · Paso 2 — Reglas.** `GameData` recibe `Pets`, `Eggs` y la rareza Épico. `Config` recibe los límites y el huevo de premio del jefe. `PlayerLogic` incorpora `petMultiplier` (ahora `walkSpeed` multiplica y redondea), `rollPet`, `grantPet`, `hatchEgg`, `equipPet`, `unequipPet`, `equipBest` y `releasePet`, y repara los datos de mascotas. · Verificación: revisión estática.
- **2026-11-20 · DEV-005 · Paso 3 — Servidor.** `PetService` crea el Criadero y las esferas que siguen al jugador. `ActionService` recibe 5 acciones nuevas y vuelve a aplicar la velocidad y las mascotas tras cada cambio. `BossService` entrega el huevo de premio. · Verificación: revisión estática (0 errores, 56 `require`).
- **2026-11-20 · DEV-005 · Paso 4 — Interfaz.** Menú del Criadero con precios y probabilidades. La Mochila incorpora una sección de mascotas con Equipar, Quitar, Liberar y «Equipar mejores». El HUD muestra la velocidad con el multiplicador. · Verificación: revisión estática.
- **2026-11-20 · DEV-005 · Paso 5 — Pruebas.** 3 pruebas nuevas: huevos, equipar con límite y multiplicador, y reparación de datos con tope de velocidad. Total: 30. · Verificación: **pendiente** en Studio.

---

## 7. DEV-006 — Velocidad como eje: caminadoras y Robux

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Rama:** `task/DEV-006-velocidad-robux`

### Registro de pasos

- **2026-11-20 · DEV-006 · Paso 1 — Búsqueda en el repositorio.** Se revisaron la bóveda, todas las ramas y `main`. Mecánicas del formulario: fuerza/velocidad/salto, herramientas, piezas, fabricación, venta, museo, suerte, mascotas, compras opcionales, robo, jefe y 10 jugadores. La rama `Roblox-game-studio-v2` solo tiene notas vacías. Se detecta que `main` incorporó INFRA-001: código en `game/`, reservas de rutas y decisiones DEC-001 y DEC-003 aprobadas. Se informa a Jhonn. · Verificación: ejecutada (`git grep`, `git diff`).
- **2026-11-20 · DEV-006 · Paso 2 — Dirección.** Jhonn decide que el juego se enfoca en velocidad, sin fuerza; que algunos pases pueden ser «pay to win» (por ejemplo, una mascota 20% mejor que tu mejor y una caminadora con mucho multiplicador); y que el diseño visual se hará con Krita, Blender, Audacity y Material Maker, así que por ahora solo se programan mecánicas. · Verificación: ejecutada.
- **2026-11-20 · DEV-006 · Paso 3 — Datos y reglas.** `Config` recibe el entrenamiento, los IDs de Robux en 0, el modo de prueba y el tope de velocidad 80. `GameData` recibe `Treadmills`, `GamePasses`, `Products` y la Mascota Suprema. `PlayerLogic` incorpora la velocidad base con entrenamiento, `speedMultiplier`, `coinMultiplier`, `petSlots`, `petBonus` (Suprema dinámica), `setPasses`, caminadoras, `trainTick`, `grantProduct` y recibos. · Verificación: revisión estática.
- **2026-11-20 · DEV-006 · Paso 4 — Servidor.** `MonetizationService` consulta los pases al entrar, abre las compras y procesa los recibos sin entregar dos veces. `TrainingService` crea 3 caminadoras, inicia y detiene el entrenamiento y entrena cada segundo. `DataService.saveNow` guarda al momento tras una compra. `CharacterService` deja quieto al jugador mientras entrena. `ActionService` recibe `buyTreadmill`, `buyPass` y `buyProduct`. · Verificación: revisión estática (0 errores, 73 `require`).
- **2026-11-20 · DEV-006 · Paso 5 — Interfaz mínima.** Botón y menú «Robux», sección de caminadoras en la Tienda, línea de entrenamiento y velocidad (base × multiplicador) en el HUD, y ranuras y bonus reales en las mascotas. · Verificación: revisión estática.
- **2026-11-20 · DEV-006 · Paso 6 — Pruebas.** 5 pruebas nuevas: caminadoras, pases, Mascota Suprema, pérdida de ranura, y productos y recibos. Total: 35. · Verificación: **pendiente** en Studio.

---

## 8. DEV-007 — Integración del juego en game/

- **Responsable:** Jhonn · **Revisor:** Zadiel; Michael o Einell para la interfaz · **Rama:** `task/DEV-007-integracion-juego`

### Registro de pasos

- **2026-11-20 · DEV-007 · Paso 1 — Bloqueo detectado.** `main` incorporó INFRA-001 (PR #1): código en `game/` (DEC-001 aprobada), reservas en ACTIVE_TASKS.md y revisión obligatoria (DEC-002). Las ramas DEV-001 a DEV-006 usaban `juego/` y números de decisión repetidos. · Verificación: ejecutada (`git diff`).
- **2026-11-20 · DEV-007 · Paso 2 — Cierre de INFRA-001.** Jhonn marcó INFRA-001 como Completada (PR #2 fusionado). · Verificación: comprobado en `origin/main`.
- **2026-11-20 · DEV-007 · Paso 3 — Reserva.** PR #3 de reserva, que solo cambia Backlog.md y ACTIVE_TASKS.md. Antes de subirlo se pasó el script de control de `main` en local; después se fusionó. · Verificación: ejecutada.
- **2026-11-20 · DEV-007 · Paso 4 — Código.** 21 archivos movidos de `juego/` a `game/src/ReplicatedStorage/Shared`, `game/src/ServerScriptService/Server` y `game/src/StarterPlayer/StarterPlayerScripts/Client`. Se retiraron Bootstrap y Placeholder de INFRA-001. `build.py` pasa a `game/tools/build.py`, ahora lee `game/default.project.json` y respeta los servicios con `$path`. · Verificación: revisión estática ejecutada (20 scripts, 73 `require`, 0 errores, XML válido).
- **2026-11-20 · DEV-007 · Paso 5 — Bóveda.** Se trajeron el GDD §15, el Plan de Pruebas y las memorias con rutas `game/`. En las notas que `main` había cambiado (Arquitectura, Registro, Dashboard, memorias 03 y 09, `.gitignore`) solo se añadieron secciones. Decisiones renumeradas: la antigua DEC-001 queda cubierta por la DEC-001 aprobada y las propuestas pasan a DEC-003 a DEC-008. · Verificación: revisión de archivos.
- **2026-11-20 · DEV-007 · Paso 6 — Cierre.** La fila DEV-007 de ACTIVE_TASKS.md pasa a Completada en este PR final. Las ramas DEV-001 a DEV-006 no se fusionan: su contenido llega por DEV-007. · Verificación: pendiente de los checks `reservation-check` y `rojo-build` en GitHub y de la prueba en Studio.

---

## 9. DEV-008 — Plot personal con taller, vitrinas y caminadora

- **Responsable:** Jhonn · **Revisor:** Zadiel; Michael o Einell para la interfaz · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-008 · Paso 1 — Prueba de DEV-007.** Jhonn fusionó DEV-007 (PR #4, con `reservation-check` y `rojo-build` en verde) y probó el juego en Studio. · Verificación: reportada por Jhonn.
- **2026-11-20 · DEV-008 · Paso 2 — Dirección.** Jhonn pide un plot por jugador. El taller va al fondo, el plot hace de museo con ingreso pasivo y un poco de suerte, y la caminadora va enfrente. El plot y la caminadora se mejoran. Las skins de los dueños de las casas quedan para la fase de arte. · Verificación: ejecutada.
- **2026-11-20 · DEV-008 · Paso 3 — Reserva.** PR #5 de reserva. Hubo dos conflictos con INFRA-002 en el Backlog y en ACTIVE_TASKS: se acotó la reserva y Zadiel resolvió el último y fusionó. Luego INFRA-002 cambió el flujo a trabajo directo en `main` (DEC-009) y se añadió el Registro de Decisiones a la reserva (`7d78a6a`). · Verificación: ejecutada.
- **2026-11-20 · DEV-008 · Paso 4 — Código (`fa0e72f`).**
  - Nuevo `PlotService`: 10 plots, asignación y liberación, cartel del dueño, aparición en el propio plot, taller, panel de vitrinas y caminadora, y solo el dueño puede usarlos.
  - `TrainingService` usa la caminadora del plot.
  - `ActionService` valida la cercanía al plot propio (`plotPart`) y tiene la acción `buyPlotUpgrade`.
  - `WorldService` quita el Taller y el Museo compartidos y amplía la base.
  - `GameData`: suerte por reloj, mejoras «Vitrinas del plot» y «Caminadora del plot», y el pase Turbo pasa a ×2.
  - `PlayerLogic`: `plotLuck`, `treadmillMultiplier`, `trainTick(data, segundos)` y adaptación de datos de la Caminadora de Acero al nivel 3.
  - Interfaz: panel «Tu plot» con las vitrinas y sus mejoras.
  - · Verificación: revisión estática ejecutada (21 scripts, 81 `require`, 0 errores).
- **2026-11-20 · DEV-008 · Paso 5 — Pruebas.** La prueba de las caminadoras compartidas se reemplaza por 4 pruebas nuevas: caminadora y Turbo, adaptación de datos, suerte del plot y vitrinas. **Corrección:** hay **34** bloques de prueba. Los totales anteriores de este Changelog (25, 27, 30 y 35) estaban mal sumados; los reales eran 21, 23, 26 y 31. · Verificación: pendiente en Studio.
- **2026-11-20 · DEV-008 · Paso 6 — Documentación y cierre.** GDD §15.6, Plan de Pruebas §15, propuesta DEC-010, memorias de las áreas 02, 04 y 07, y Backlog. La fila DEV-008 de ACTIVE_TASKS pasa a Completada. · Verificación: revisión de archivos.

---

## 10. DEV-009 — Cápsulas, recompensas diarias y por tiempo, y mascotas Robux

- **Responsable:** Jhonn · **Revisor:** Zadiel; Michael o Einell para la interfaz · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-009 · Paso 1 — Dirección y reserva.** Jhonn pide que las mascotas salgan de cápsulas, que se consigan comprándolas, con recompensas diarias o por tiempo, y con Robux (más fuertes). No había reservas activas; la reserva se subió en `82f37ba`. · Verificación: ejecutada.
- **2026-11-20 · DEV-009 · Paso 2 — Código (`0491286`).**
  - `GameData`: cápsulas (antes huevos; se conservan los ids), Cápsula Cósmica, 3 mascotas de Robux, rarezas Mítico y Divino, `DailyRewards`, `PlaytimeRewards` y producto `cosmicCapsule`.
  - `PlayerLogic`: inventario `capsules`, `giveReward`, `openCapsule`, `dailyStatus` / `claimDaily` con racha, `addPlaytime` / `claimPlaytime` por día, y la vista con `now`.
  - Los productos de Robux y el premio del Cronómetro entregan cápsulas a la Mochila.
  - Nuevo `RewardService`, que suma el tiempo jugado y avisa de los premios.
  - `ActionService`: acciones `openCapsule`, `claimDaily` y `claimPlaytime`.
  - Interfaz: panel «Premios», cápsulas en la Mochila y Criadero con cápsulas.
  - · Verificación: revisión estática ejecutada (22 scripts, 88 `require`, 0 errores).
- **2026-11-20 · DEV-009 · Paso 3 — Pruebas.** 3 pruebas nuevas: cápsulas y Cósmica, racha diaria, y tiempo jugado. Se ajustó la de productos, porque la cápsula ahora va a la Mochila. Total: 37 bloques. · Verificación: pendiente en Studio.
- **2026-11-20 · DEV-009 · Paso 4 — Documentación y cierre.** GDD §15.7, Plan de Pruebas §16, propuesta DEC-011, memorias y Backlog. La fila DEV-009 pasa a Completada. · Verificación: revisión de archivos.

---

## 11. DEV-010 — Base en media luna con muro frontal

- **Responsable:** Jhonn · **Revisor:** Zadiel; Cuenta B revisa la distribución · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-010 · Paso 1 — Prueba de DEV-009 y dirección.** Jhonn probó DEV-009 y pidió 6 jugadores y 6 plots en media luna, más amplios, con la caminadora delante y el taller al fondo, y un muro frontal con las estaciones y una abertura para correr. Reserva subida en `7bd2dda`. · Verificación: reportada por Jhonn.
- **2026-11-20 · DEV-010 · Paso 2 — Código.**
  - `PlotService` rehecho: 6 plots en arco (radio 95, de 200° a 340°) orientados con `CFrame.lookAt` hacia la plaza, de 34 × 40, con la caminadora delante, las vitrinas (hasta 15) y el taller al fondo. Tiene un gancho `shouldMoveToPlot` para la introducción de DEV-011.
  - `WorldService`: muro frontal con abertura de 28 studs y cartel «SALIDA», `WallSlots` para 4 estaciones, estación nueva «Tienda Robux», `PlazaCenter`, mapa más ancho (±130) y fondo en −205.
  - `BossService` y `PetService` se colocan en el muro.
  - Interfaz: los menús que se abren desde el HUD (Mochila, Robux, Premios) ya no se cierran al alejarse.
  - · Verificación: comprobación geométrica en Python (0 solapamientos, todo dentro del mapa, estaciones y aparición libres) y revisión estática (0 errores).
- **2026-11-20 · DEV-010 · Paso 3 — Cierre.** GDD §15.8, Plan de Pruebas §17, propuesta DEC-012 y memorias. La fila DEV-010 pasa a Completada. Las pruebas automáticas siguen siendo 37 porque la distribución no cambia reglas de `PlayerLogic`. · Verificación: revisión de archivos.

---

## 12. DEV-011 — Historia inicial, pieza del legado, tutorial e ingreso pasivo del 30%

- **Responsable:** Jhonn · **Revisor:** Zadiel; Cuenta B revisa historia y textos · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-011 · Paso 1 — Dirección y reserva.** Jhonn pide una cinemática de historia, una pieza luminosa de alta relojería que el jugador conserva, un tutorial completo y que exhibir dé el 30% del valor. Se proponen nombres ficticios en lugar de las marcas Patek Philippe y Graff. Reserva subida en `8b39674`. · Verificación: ejecutada.
- **2026-11-20 · DEV-011 · Paso 2 — Datos y reglas.**
  - `GameData`: pieza `legacy` (protegida), `LegacyPieces`, `IntroStory`, Reloj del Legado, tutorial de 6 pasos y rareza Herencia. Se quita el campo `income` de los relojes.
  - `Config`: `PLOT_INCOME_PERCENT` = 0,30, `PLOT_INCOME_PERIOD_SECONDS` = 600 y `LEGACY_CLAIM_DISTANCE`.
  - `PlayerLogic`: `claimLegacy`, `legacyPiece`, `introDone`, ingreso pasivo con `incomeRemainder`, `watchIncomePerMinute` y `museumIncomePerMinute`. Las piezas protegidas no se venden, ni se tiran, ni se entregan, ni ocupan espacio. El tutorial empieza tras la introducción y se añade la medida `trained10`.
  - · Verificación: revisión estática.
- **2026-11-20 · DEV-011 · Paso 3 — Servidor y cliente.**
  - Acción `claimLegacy`, solo cerca de la aparición y una vez.
  - `PlotService` deja al jugador en la plaza hasta terminar la introducción.
  - `WorldService.SpawnPosition`.
  - Nuevo módulo de cliente `Intro`: cinemática con «Saltar», cámara y pieza luminosa local.
  - Guía del tutorial hacia la caminadora propia.
  - La interfaz muestra el ingreso por minuto y oculta las acciones sobre la herencia.
  - · Verificación: revisión estática (23 scripts, 0 errores).
- **2026-11-20 · DEV-011 · Paso 4 — Pruebas.** Se actualizan las pruebas del museo y del tutorial y se añaden 3 nuevas: pieza del legado, Reloj del Legado e ingreso del 30%. Total: 40 bloques. · Verificación: pendiente en Studio.
- **2026-11-20 · DEV-011 · Paso 5 — Cierre.** GDD §15.9, Plan de Pruebas §18, propuesta DEC-013 y memorias. La fila DEV-011 pasa a Completada. · Verificación: revisión de archivos.

---

## 13. DEV-012 — Ingreso pasivo cada 30 segundos

- **Responsable:** Jhonn · **Revisor:** Zadiel · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-012 · Paso 1 — Dirección y reserva.** Jhonn pide que el 30% se pague cada 30 s en lugar de cada 10 min. Se le avisa del efecto: el reloj recupera su valor en unos 100 s. Reserva subida en `f0409e9`. · Verificación: ejecutada.
- **2026-11-20 · DEV-012 · Paso 2 — Cambio.** `Config.PLOT_INCOME_PERIOD_SECONDS` = 30. Se ajustan los textos del tutorial (paso 5) y del panel del plot, que ahora muestra segundos. · Verificación: revisión estática sin errores. Las pruebas usan los valores de `Config`, así que no cambian (40 bloques, pendientes en Studio).
- **2026-11-20 · DEV-012 · Paso 3 — Cierre.** GDD §15.9 (nota de actualización), propuesta DEC-014 y memoria de Economía. La fila DEV-012 pasa a Completada. · Verificación: revisión de archivos.

---

## 14. DEV-013 — HUD multiplataforma, ruleta diaria, ajustes y capacidad de carga

- **Responsable:** Jhonn · **Revisor:** Zadiel; Michael y Einell revisan el HUD (ruta de Cuenta B) · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · DEV-013 · Paso 1 — Dirección y reserva.** Jhonn pide ordenar el HUD para móvil, PC, consola y tablet, con dinero, velocidad, premios, ruleta diaria, Robux y ajustes, y un puesto de capacidad de carga (máximo 4 con 3 mejoras). Reserva subida en `4295a93`. · Verificación: ejecutada.
- **2026-11-20 · DEV-013 · Paso 2 — Reglas.**
  - `Config`: `BASE_CARRY` = 1, producto `extraSpin` y `MAX_EXTRA_SPINS`.
  - `GameData`: mejora `carry` (3 niveles), `SpinPrizes`, `Settings` y producto de giro extra.
  - `PlayerLogic`: `carryCapacity` (limita `stealPart`), `spinStatus` / `rollSpin` / `spinWheel`, `getSetting` / `setSetting` / `validSetting`, recompensa `trained` y datos `spin` y `settings` con reparación.
  - · Verificación: revisión estática.
- **2026-11-20 · DEV-013 · Paso 3 — Servidor.** Puesto de Carga en el muro (`WallSlots.carry`). `ActionService`: acciones `buyCarryUpgrade`, `spinWheel` y `setSetting`; las respuestas pueden incluir un dato extra (el premio de la ruleta). · Verificación: revisión estática.
- **2026-11-20 · DEV-013 · Paso 4 — Interfaz.**
  - HUD rehecho: tarjetas a la izquierda, objetivo y avisos arriba al centro, y barra de 5 botones con «!» a la derecha.
  - `UIScale` según la pantalla, la consola y el ajuste de tamaño.
  - Atajos de teclado y mando; la cruceta se reserva a la navegación cuando hay un menú abierto.
  - Menús nuevos: Ruleta (con animación y resultado que se conserva al redibujar), Ajustes y Puesto de Carga.
  - La guía y las notificaciones respetan los ajustes; «Ver historia» repite la cinemática.
  - · Verificación: revisión estática sin errores.
- **2026-11-20 · DEV-013 · Paso 5 — Pruebas.** 3 pruebas nuevas: carga, ruleta y ajustes. Se adaptaron las de robo de DEV-003 a la carga por viaje. Total: 43 bloques. · Verificación: pendiente en Studio.
- **2026-11-20 · DEV-013 · Paso 6 — Cierre.** GDD §15.10, Plan de Pruebas §20, propuesta DEC-015 y memorias. La fila DEV-013 pasa a Completada. · Verificación: revisión de archivos.

---

## 15. ART-001 — Pipeline de arte y primeros assets

- **Responsable:** Jhonn (después Michael y Einell) · **Revisor:** Michael y Einell; Zadiel (parte técnica) · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · ART-001 · Paso 1 — Revisión.** En el repositorio no había herramientas de arte definidas: la tabla de Recursos solo tenía Roblox Studio, Obsidian, Git, GitHub y Claude Code, y el estilo visual estaba «Pendiente». La memoria del área 12 citaba Blender, Substance, Krita y Audacity. En la PC están instalados Blender 5.3, Krita, Audacity 4 y Material Maker 1.8 (portable); Substance no. · Verificación: ejecutada.
- **2026-11-20 · ART-001 · Paso 2 — Dirección y reserva.** Jhonn elige el estilo low-poly propuesto, para detallar después, y lleva el arte por ahora; luego pasará a Michael y Einell. Reserva subida en `630fb6c`. · Verificación: ejecutada.
- **2026-11-20 · ART-001 · Paso 3 — Generadores.** `art/blender/scripts/arte_comun.py` (paleta de 16 colores, material único, primitivas, unión, exportación FBX y conteo de triángulos), `generar_todo.py` y `vista_previa.py`. · Verificación: **ejecutada con Blender 5.3 en modo consola**. `mdl_caminadora` tiene 152 triángulos y `mdl_capsula_laton` 328; se exportaron sus FBX y `tex_paleta.png`, y se renderizaron vistas previas revisadas visualmente.
- **2026-11-20 · ART-001 · Paso 4 — Documentación.** Nueva nota [[Pipeline-de-Arte]] (herramientas, estilo, paleta, carpetas, formatos, nombres, flujo hasta Studio y lista de assets con prioridades). También se actualizaron la tabla de herramientas de Recursos, el estilo en [[Diseño-del-Mundo]], `art/README.md`, el `.gitignore` (temporales de Blender, Krita y Audacity), el Dashboard, las memorias 05 y 12 y la propuesta DEC-016. · Verificación: revisión de archivos.
- **2026-11-20 · ART-001 · Paso 5 — Cierre.** La fila ART-001 pasa a Completada. Pendiente: importar los FBX en la place oficial (hay que publicarla primero) y hacer la tarea de código que cambie las piezas provisionales por los modelos de `ServerStorage/Assets`. · Verificación: revisión de archivos.

---

## 16. ART-002 — Modelos low-poly de prioridad 1

- **Responsable:** Jhonn · **Revisor:** Michael y Einell; Zadiel (técnica) · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · ART-002 · Paso 1 — Reserva.** Subida en `fc9d17e`. · Verificación: ejecutada.
- **2026-11-20 · ART-002 · Paso 2 — Generadores.** `arte_comun.py` recibe `cono`, `anillo` y `prisma_triangular` (tejado construido por vértices). Nuevo `modelos_prioridad1.py` con 25 constructores en las medidas de las piezas provisionales. `generar_todo.py` acepta una lista de modelos. `vista_previa.py` crea la hoja de contactos con fondo blanco. · Verificación: **ejecutada con Blender 5.3**. 27 modelos exportados (con los 2 de ART-001), de 24 a 524 triángulos.
- **2026-11-20 · ART-002 · Paso 3 — Revisión visual.** Hoja de contactos revisada: casas por zona distinguibles, estaciones con cartel y Cronómetro con esfera, y piezas reconocibles. La primera hoja salió con fondo negro y colores oscuros por la transparencia; se corrigió. · Verificación: ejecutada.
- **2026-11-20 · ART-002 · Paso 4 — Cierre.** Lista de assets de [[Pipeline-de-Arte]] actualizada, con notas de importación (frente hacia −Y, casas con `PreciseConvexDecomposition`, piezas pequeñas sin colisión). Memoria del área 12 actualizada. La fila ART-002 pasa a Completada. · Verificación: revisión de archivos.

---

## 17. ART-003 — Modelos low-poly de prioridad 2

- **Responsable:** Jhonn · **Revisor:** Michael y Einell; Zadiel (técnica) · **Flujo:** directo en `main` (DEC-009)

### Registro de pasos

- **2026-11-20 · ART-003 · Paso 1 — Reserva.** Subida en `c9ce1e9`. · Verificación: ejecutada.
- **2026-11-20 · ART-003 · Paso 2 — Generadores (`e0cf589`).** Nuevo `modelos_prioridad2.py`:
  - cápsulas de Plata, Oro y Cósmica (con estrellas);
  - 6 relojes con esfera, agujas y detalles (sub-esferas, rubíes, diamantes, bisel);
  - 3 piezas del legado ficticias (espiral, corona, rotor arcoíris);
  - 9 mascotas (ratón de cuerda, gato engranaje, zorro con monóculo, halcón, dragón, fénix, titán, Señor del Tiempo y Mascota Suprema).

  · Verificación: **ejecutada con Blender 5.3**. 21 modelos de 72 a 488 triángulos (48 en total). Hoja de contactos revisada.
- **2026-11-20 · ART-003 · Paso 3 — Nota movida.** Zadiel movió desde Obsidian la nota del pipeline a `art/Pipeline-de-Arte.md` (`c66f57e`). Se respeta la nueva ubicación: la lista se actualiza allí y se corrige el enlace de `art/README.md`. Los enlaces `[[Pipeline-de-Arte]]` siguen funcionando porque buscan la nota por nombre. · Verificación: ejecutada (`git log`, `git diff -M`).
- **2026-11-20 · ART-003 · Paso 4 — Cierre.** La fila ART-003 pasa a Completada. · Verificación: revisión de archivos.

