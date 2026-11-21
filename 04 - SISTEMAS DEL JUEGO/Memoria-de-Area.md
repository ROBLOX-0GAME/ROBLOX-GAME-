# Memoria de área — Sistemas

> Memoria inicial basada en el formulario y la idea organizada. Las propuestas no son decisiones aprobadas. Mantén esta nota compacta, con enlaces.

## Notas canónicas

[[04 - SISTEMAS DEL JUEGO/Lista-de-Sistemas]]; [[02 - GAME DESIGN DOCUMENT/GDD]]
- Registro: [[10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones]]

## Respuestas directas y datos base

- La idea incluye fuerza/velocidad/salto, herramientas, piezas, fabricación, venta, museo pasivo y pequeño bono de suerte, mascotas y compras opcionales.

## Pendientes concretos

- Fórmulas, capacidad, precios, tasas y catálogo.

## Decisiones aprobadas del área

- Añade una decisión solo tras aprobación humana y registro canónico.

## Memoria reciente

- 2026-11-21 · DEV-027 (Jhonn): el aviso de robo muestra ya las monedas multiplicadas que se cobrarán al guardar; `PlayerLogic.piecesText` para «1 pieza / N piezas». Probados en Play: carga, cierre de zona con botín, avisos de piezas raras, prefijo [VIP] y ganancia offline ([[Plan-de-Pruebas]] §33). BUG-004 (sonidos) lo arregla Zadiel. Datos de Jhonn reiniciados. Place v35.
- 2026-11-21 · DEV-026 (Jhonn): BUG de la mesa que se cerraba sola (el cliente tomaba la mesa de un plot libre; `stationById` ahora prioriza la propia). DEC-031: 12 relojes de lujo, uno exclusivo por zona (1 a 12) con el material de su zona; los 6 generales salen al azar. El reinicio de zona ahora renueva también las piezas antiguas durante la avería. Recorrido completo de mecánicas en Play, place v34 ([[Plan-de-Pruebas]] §32). El Renacer queda aparcado por decisión de Jhonn.
- 2026-11-21 · DEV-025 (Jhonn): DEC-028. Las casas dan piezas de reloj `reloj.clase.rareza` (Caja, Calibre, Esfera, Manecillas) con 12 rarezas; desde la zona 3, un reloj exclusivo por zona (16 relojes). Mesa de armado en el plot: 4 marcos en orden, bandeja por reloj o rareza; cada pieza ajena: −1 rareza y −25 %. Relojes guardados con clave `id|rareza|ajenas` (los antiguos cuentan como Común). Piezas antiguas solo durante el Cronómetro (`HouseService.setBossParts`). Place v32, 52/52 ([[Plan-de-Pruebas]] §31). Arte: [[PROMPT_PIEZAS_RELOJ_ZADIEL]] (ART-018).
- 2026-11-21 · DEV-023 (Jhonn): DEC-029. `RaceService` cierra la zona cada 5 min (30 s de aviso, vuelta a la plaza, piezas renovadas con `HouseService.resetAll`, reapertura a los 10 s). Las piezas ya no reaparecen solas. `GameData.Rarities` con 12 rarezas; aviso global (`Net.announce`, remoto `Announce`) desde Mítico. Place versión 28.

- 2026-11-21 · DEV-020/DEV-021 (Jhonn): código en la place (versión 25) y probado: 50/50 pruebas; base 50, casa 40 y zona según la curva; el dueño despierta a los 15 s. La mejora de mochila pasó al puesto «Mochila y Carga». Dudas en [[Recomendaciones-Claude]].

- 2026-11-20 · DEV-018 (Jhonn): IDs de los 8 iconos y los 10 sonidos de ART-013 en `Config.ICON_IDS` y `Config.SOUND_IDS`, cargados en la place (versión 17, sin publicar). Los iconos se ven en el HUD. Los sonidos no suenan por permisos (BUG-004): los audios de otra cuenta necesitan acceso concedido a la experiencia 10778093657. Lo aprendido: las imágenes de un colaborador cargan, pero los audios no sin ese permiso.

- 2026-11-20 · DEV-017 (Jhonn): en Play, el servidor rechaza robar en zonas sin la velocidad mínima aunque se salte la puerta. El Cronómetro suma puntos por rareza, protege la pieza del legado, devuelve las piezas si falla y paga 12 monedas por punto más una cápsula de latón con 20 puntos o más. Sin bugs nuevos. Detalle en [[Plan-de-Pruebas]] §23.

- 2026-11-20 · DEV-016 (Jhonn): la place oficial tenía el código anterior a DEV-015 (solo `Ui` y `AssetLibrary` eran distintos de `main`). Se cargaron con el MCP de Studio (`ScriptEditorService`), se puso `84500108687089` en `servePlaceIds` y la place se guardó en Roblox (**versión 13**, sin publicar). Play: 47/47 pruebas, cliente con `BuildAWatchUI` y consola sin errores. Bucle recorrido con resultado real: pieza del legado, recompensa diaria, ruleta, premio por tiempo, cápsula de latón y mascota, robo en la zona 1 (límite de 1 por viaje), persecución y guardado en la base, venta, mejora de velocidad, mejora de vitrinas, fabricación del reloj de bolsillo, exhibición e ingreso pasivo (+18 monedas en 30 s), caminadora (entrena y para) y avería del Cronómetro (expira sin aportes). **Studio ya tiene acceso a DataStore**: las pruebas guardan datos reales de la cuenta de prueba. No se probaron el jefe con aportes, las zonas 2 a 5, los pases ni los productos de Robux (sus IDs siguen en 0).

- 2026-11-20 · DEV-014: `AssetLibrary` (find, dress y place) y el `RemoteEvent` `Sound` conectan modelos, decoración, sonidos e iconos con respaldo provisional. DEC-017.
- 2026-11-20 · DEV-013: acciones `buyCarryUpgrade`, `spinWheel` y `setSetting`; `PlayerLogic.carryCapacity` limita el robo por viaje; las respuestas de acción llevan `extra`.
- 2026-11-20 · DEV-011: módulo de cliente `Intro` (cinemática y pieza local), acción `claimLegacy` y `PlotService.shouldMoveToPlot` según `introDone`.
- 2026-11-20 · DEV-010: `PlotService` con plots en arco (`CFrame.lookAt` hacia `WorldService.PlazaCenter`); `WorldService.WallSlots` coloca las estaciones en el muro frontal.
- 2026-11-20 · DEV-009: `RewardService` (tiempo jugado y avisos), inventario de cápsulas y acciones `openCapsule`, `claimDaily` y `claimPlaytime`.
- 2026-11-20 · DEV-008: `PlotService` (10 plots, solo el dueño) y `TrainingService` con la caminadora del plot. Se retiraron el Taller, el Museo y las caminadoras compartidos.
- Al cerrar tareas, anota decisión/estado, fecha, responsable, fuente y enlaces. Resume; no copies conversaciones.

**Inicio:** 2026-11-19. **Actualización:** al cerrar una tarea del área.
