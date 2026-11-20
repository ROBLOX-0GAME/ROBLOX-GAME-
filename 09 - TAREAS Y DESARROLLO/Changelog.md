
# 📝 CHANGELOG — BUILD A WATCH!

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
- **2026-11-20 · DEV-001 · Paso 9 — Documentación.** `juego/README.md`, `.gitignore` (`juego/build/`, bloqueos de Studio), [[Arquitectura-General]] §13, [[Plan-de-Pruebas]] §9, [[Registro-de-Decisiones]] (DEC-001 y DEC-002 como propuestas), memorias de 03, 07 y 09, enlace en [[Dashboard]] y estado en [[Backlog]]. · Verificación: ejecutada (revisión de archivos).
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
3. Revisión de Zadiel y aprobación de textos y premios (DEC-003).

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
