
# 🧪 PLAN DE PRUEBAS Y CONTROL DE CALIDAD

## 1. Propósito

Establecer los procedimientos para comprobar la calidad, estabilidad, seguridad y rendimiento de Roblox Game Studio.

## 2. Tipos de pruebas

### 2.1 Pruebas funcionales
Comprobar que cada sistema cumple su función.

- Movimiento.
- Combate.
- Habilidades.
- Inventario.
- Economía.
- Progresión.
- Misiones.
- Guardado.
- Interfaz.

### 2.2 Pruebas de integración
Comprobar que los sistemas funcionan correctamente entre sí.

- Combate y habilidades.
- Inventario y equipamiento.
- Economía y tiendas.
- Misiones y recompensas.
- Progresión y desbloqueos.
- Guardado y carga de datos.

### 2.3 Pruebas multijugador
- Conexión de jugadores.
- Entrada y salida de servidores.
- Sincronización.
- Cooperación.
- Comunicación cliente-servidor.
- Comportamientos simultáneos.

### 2.4 Pruebas de rendimiento
- Uso de memoria.
- Rendimiento de scripts.
- Física.
- Carga de recursos.
- Estabilidad con varios jugadores.

### 2.5 Pruebas de seguridad
- Validación de solicitudes.
- Protección de eventos remotos.
- Manipulación de datos.
- Transacciones.
- Prevención de exploits.

### 2.6 Pruebas de interfaz
- Navegación.
- Legibilidad.
- Controles.
- Adaptación a diferentes dispositivos.
- Notificaciones.

## 3. Registro de errores

Cada error debe documentarse con esta plantilla.

### BUG-001 — Nombre del error

- **Fecha:** Pendiente.
- **Prioridad:** Media.
- **Estado:** Abierto.
- **Responsable:** Pendiente.
- **Sistema afectado:** Pendiente.

**Descripción:**

Explicar qué sucede.

**Pasos para reproducir:**

1. Pendiente.
2. Pendiente.
3. Pendiente.

**Resultado esperado:**

Pendiente.

**Resultado obtenido:**

Pendiente.

**Evidencias:**

Capturas, registros o vídeos.

**Solución aplicada:**

Pendiente.

**Verificación:**

Pendiente.

## 4. Clasificación de errores

- **Crítico:** impide jugar o compromete datos o seguridad.
- **Alto:** afecta gravemente una funcionalidad.
- **Medio:** provoca problemas funcionales limitados.
- **Bajo:** problema visual o de impacto reducido.

## 5. Criterios de aceptación

Una tarea podrá considerarse completada cuando:

- Cumpla sus requisitos.
- Supere las pruebas correspondientes.
- No introduzca errores críticos conocidos.
- Se hayan comprobado sus dependencias.
- Los cambios estén documentados.
- Haya sido revisada cuando corresponda.

## 6. Procedimiento de pruebas

1. Identificar el sistema que se probará.
2. Definir los resultados esperados.
3. Ejecutar las pruebas.
4. Registrar los errores.
5. Corregir los problemas.
6. Repetir las pruebas.
7. Documentar el resultado final.

## 7. Responsabilidades

- Los desarrolladores prueban sus propios cambios.
- Los responsables de cada área revisan sus sistemas.
- El equipo humano supervisa la calidad general.
- Los agentes IA documentan las pruebas y resultados realizados.
- Ningún agente debe afirmar que una prueba pasó si no la ejecutó.

## 8. Documentos relacionados

- [[Dashboard]]
- [[GDD]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Multiplayer]]
- [[Backlog]]
- [[Registro-de-Decisiones]]

---

**Estado:** Borrador inicial
**Aprobación:** Pendiente del equipo

## 9. Pruebas de DEV-001

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática `python game/tools/build.py --check` (bloques, `require`, campos) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 13 pruebas de `PlayerLogic` (`game/src/ServerScriptService/Server/Tests`) al pulsar Play en Studio | Automática | Pendiente: no ejecutada todavía |
| Bucle completo: recoger → fabricar → vender/exhibir → mejorar | Manual en Studio | **Ejecutada 2026-11-20 por Jhonn: funcional; errores menores por detallar** |
| Guardado: salir y volver a entrar conserva el progreso (con acceso a API activado) | Manual en Studio | Pendiente |
| Controles con mando y en el emulador móvil de Studio | Manual | Pendiente |
| 2+ jugadores (Test → Clients and Servers): cajas compartidas y sin errores | Multijugador | Pendiente |

Registra aquí el resultado real de cada prueba al ejecutarla.

### BUG-001 — La mochila se llena sin piezas para ningún reloj (bloqueo)

- **Fecha:** 2026-11-20. **Prioridad:** Alta. **Estado:** Corregido, pendiente de verificar en Studio. **Responsable:** Jhonn. **Sistema afectado:** Mochila / economía (DEV-001).

**Descripción:** al recoger cajas, la mochila (20 piezas) se llena con una mezcla que no alcanza para fabricar ningún reloj. Como las piezas no se pueden vender ni tirar, el jugador queda bloqueado.

**Pasos para reproducir:** 1. Entrar con datos nuevos. 2. Recoger cajas hasta llenar la mochila. 3. Abrir el Taller: ningún reloj se puede fabricar.

**Resultado esperado:** siempre debe existir una salida (fabricar, vender o tirar piezas).

**Resultado obtenido:** mochila llena y sin acciones posibles.

**Evidencias:** reportado por Jhonn en prueba manual en Studio; sin errores en Output.

**Solución aplicada (2026-11-20):** las piezas sueltas se pueden **vender en la Tienda** (2 monedas las comunes, 6 las poco comunes y 25 el rubí) y **tirar desde la Mochila** en cualquier lugar. El aviso de mochila llena explica ambas salidas. Los precios son bajos para que fabricar siempre rinda más; lo comprueba una prueba automática.

**Verificación:** 2 pruebas nuevas en `PlayerLogic.spec.luau` (pendientes de ejecutar en Studio) y revisión estática sin errores. Falta repetir los pasos para reproducir en Studio.

## 10. Pruebas de DEV-002 (tutorial)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática `python game/tools/build.py --check` | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 2 pruebas de tutorial en `PlayerLogic.spec.luau` (17 en total) | Automática | Pendiente |
| Completar los 5 objetivos con datos nuevos; premios recibidos una sola vez | Manual en Studio | Pendiente |
| La guía apunta al destino correcto, se oculta al llegar y vuelve tras reaparecer | Manual en Studio | Pendiente |
| Corrección de BUG-001: vender piezas en la Tienda y tirarlas desde la Mochila | Manual en Studio | Pendiente |

## 11. Pruebas de DEV-003 (robo por zonas)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 25 pruebas de `PlayerLogic` | Automática | Pendiente (Play en Studio) |
| Robar en la zona 1 y llegar a la base: el botín pasa a la mochila | Manual | Pendiente |
| Dejarse atrapar: se pierde solo el botín, no lo guardado | Manual | Pendiente |
| Reiniciar el personaje con botín encima: se pierde el botín | Manual | Pendiente |
| La puerta de la zona 2 bloquea con velocidad 16 y deja pasar con 18 | Manual | Pendiente |
| 2 jugadores roban la misma casa: el dueño persigue a uno y luego al otro | Multijugador | Pendiente |
| El dueño no se atasca al salir de la casa | Manual | Pendiente |

## 12. Pruebas de DEV-004 (Cronómetro Maestro)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 27 pruebas de `PlayerLogic` | Automática | Pendiente |
| A los 90 s llega el aviso de avería y el reloj echa humo | Manual | Pendiente |
| Llegar a la meta: monedas = 12 × puntos aportados | Manual | Pendiente |
| Dejar que se acabe el tiempo: se devuelven las piezas | Manual | Pendiente |
| 2 jugadores aportan; la meta escala a 50 puntos | Multijugador | Pendiente |

## 13. Pruebas de DEV-005 (mascotas)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 30 pruebas de `PlayerLogic` | Automática | Pendiente |
| Abrir un Huevo de Latón: cobra 500 y la mascota aparece junto al personaje | Manual | Pendiente |
| Equipar un Zorro: la puerta del Barrio Obrero se vuelve verde | Manual | Pendiente |
| Reaparecer: las mascotas vuelven a aparecer | Manual | Pendiente |
| Botones de mascotas en pantalla de móvil (3 botones por fila) | Manual | Pendiente |

## 14. Pruebas de DEV-006 (velocidad y Robux)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 35 pruebas de `PlayerLogic` | Automática | Pendiente |
| Entrenar en la Caminadora Básica: el HUD sube la velocidad entrenada; alejarse detiene | Manual | Pendiente |
| Con `STUDIO_GRANT_ALL_PASSES = true`: Mascota Suprema equipada, Turbo disponible, +25% de velocidad | Manual | Pendiente |
| Compra de prueba de un producto en Studio: se entrega una sola vez | Manual | Pendiente (requiere IDs reales) |
| Tienda Robux muestra «Próximamente» con IDs en 0 | Manual | Pendiente |

## 15. Pruebas de DEV-008 (plot personal)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`python game/tools/build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 34 bloques de prueba de `PlayerLogic` | Automática | Pendiente (Play en Studio) |
| Al entrar se asigna un plot con tu nombre y apareces delante | Manual | Pendiente |
| Fabricar en el taller del plot; exhibir y retirar en las vitrinas (se ven los relojes) | Manual | Pendiente |
| Mejorar vitrinas: aparecen 2 vitrinas más | Manual | Pendiente |
| Entrenar en la caminadora del plot; mejorarla sube el multiplicador del HUD | Manual | Pendiente |
| Otro jugador no puede usar tu taller, tus vitrinas ni tu caminadora | Multijugador | Pendiente |
| Al salir, el plot queda «Libre» | Multijugador | Pendiente |

## 16. Pruebas de DEV-009 (cápsulas y recompensas)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`python game/tools/build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 37 bloques de prueba de `PlayerLogic` | Automática | Pendiente (Play en Studio) |
| Al entrar avisa de la recompensa diaria; «Premios» → Reclamar da 250 monedas | Manual | Pendiente |
| A los 5 minutos de juego avisa y se reclama el premio; el botón pasa a «Reclamado» | Manual | Pendiente |
| Comprar y abrir una Cápsula de Latón en el Criadero | Manual | Pendiente |
| Abrir una cápsula guardada desde la Mochila | Manual | Pendiente |
| La Cápsula Cósmica muestra «Próximamente» mientras su ID sea 0 | Manual | Pendiente |

## 17. Pruebas de DEV-010 (base en media luna)

| Prueba | Tipo | Estado |
|---|---|---|
| Comprobación geométrica de los 6 plots (sin solapes, dentro del mapa) | Automática (Python) | **Ejecutada 2026-11-20: correcta** |
| Revisión estática (`python game/tools/build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| Se ven 6 plots en media luna mirando a la plaza; el tuyo tiene tu nombre | Manual | Pendiente |
| En tu plot: caminadora delante, vitrinas en el centro, taller al fondo | Manual | Pendiente |
| Muro frontal con abertura; Tienda, Robux, Criadero y Cronómetro pegados al muro | Manual | Pendiente |
| Salir por la abertura lleva al camino de las zonas; al volver se guarda el botín | Manual | Pendiente |

## 18. Pruebas de DEV-011 (historia, legado y tutorial)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`python game/tools/build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 40 bloques de prueba de `PlayerLogic` | Automática | Pendiente (Play en Studio) |
| Al entrar: pantalla negra con 4 frases y la cámara baja hasta el jugador; «Saltar» funciona | Manual | Pendiente |
| Aparece una pieza luminosa delante; al recogerla sale el mensaje con su nombre | Manual | Pendiente |
| La Mochila muestra la herencia sin botones de tirar; la Tienda y el Cronómetro no la ofrecen | Manual | Pendiente |
| El tutorial empieza en «entrenar» y la guía apunta a tu caminadora | Manual | Pendiente |
| Al exhibir un reloj, el HUD muestra «+X monedas/min» y las monedas suben poco a poco | Manual | Pendiente |

## 19. Pruebas de DEV-012 (ingreso cada 30 s)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática | Automática | **Ejecutada 2026-11-20: 0 errores** |
| Exhibir un Reloj de bolsillo (60): el HUD muestra +36 monedas/min y las monedas suben cada 10 s | Manual | Pendiente |

## 20. Pruebas de DEV-013 (HUD, ruleta, ajustes y carga)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática (`python game/tools/build.py`) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 43 bloques de prueba de `PlayerLogic` | Automática | Pendiente (Play en Studio) |
| HUD en el emulador de Studio (Test → Device: teléfono, tablet, PC): nada se superpone y los botones no tapan el salto | Manual | Pendiente |
| Atajos B / P / R / M / O en PC y cruceta en mando | Manual | Pendiente |
| Ruleta: «!» al entrar; girar anima y muestra el premio; segundo giro bloqueado | Manual | Pendiente |
| Ajustes: desactivar la guía la oculta; Tamaño Grande agranda el HUD; «Ver historia» repite la cinemática | Manual | Pendiente |
| Puesto de Carga: con carga 1 no se puede robar una segunda pieza en el mismo viaje; tras mejorar, sí | Manual | Pendiente |

## 21. Pruebas de DEV-014 (arte en el juego)

| Prueba | Tipo | Estado |
|---|---|---|
| Revisión estática y nombres de assets contra los FBX | Automática | **Ejecutada 2026-11-20: 0 errores; todos los nombres existen** |
| 47 bloques de prueba (43 `PlayerLogic` + 4 `AssetLibrary`) | Automática | Pendiente (Play en Studio) |
| Sin carpeta `Assets`: el juego se ve igual que antes (piezas provisionales) | Manual | Pendiente |
| Con `mdl_caminadora` en `ReplicatedStorage/Assets`: aparece en cada plot, apoyada en el suelo y mirando a la plaza | Manual | Pendiente (requiere importar) |
| Casas con modelo: se puede entrar por la puerta y robar | Manual | Pendiente |
| Con un ID en `Config.SOUND_IDS.robar`: suena al robar | Manual | Pendiente (requiere subir audio) |

## 22. Pruebas de DEV-015 (errores que impedían jugar)

| Prueba | Tipo | Estado |
|---|---|---|
| Búsqueda de cadenas sin cerrar en los 25 scripts de `game/src` | Automática (script) | **Ejecutada 2026-11-20: solo `Ui.luau:766`; corregida con `
`** |
| `build.py --check` detecta la cadena sin cerrar en el código anterior | Automática | **Ejecutada 2026-11-20: «Revisión fallida: 1 error»** |
| `build.py` con el arreglo | Automática | **Ejecutada 2026-11-20: sin errores; place generada** |
| `AssetLibrary.place` sin `parent` devuelve una copia viva (causa de «place apoya la base en el suelo») | Revisión de código | **Corregido y confirmado en Play (DEV-016, 2026-11-20)**: la prueba pasa |
| 47/47 pruebas en Play | Automática (Studio) | **Ejecutada 2026-11-20 (DEV-016): 47 correctas, 0 fallidas** con el código de `main` cargado en la place (versión 13) |
| Cliente: HUD, menús e historia inicial cargan sin errores en Output | Manual (Studio) | **Ejecutada 2026-11-20 (DEV-016)**: `BuildAWatchUI` e `Introduccion` cargan; Output sin errores |
| Origen de `rbxassetid://203785492` («Asset type does not match») | Investigación (Studio) | **No se repite** en el Play de DEV-016 (Output sin errores); no se buscó su origen |

### BUG-002 — El cliente no carga la interfaz (`Ui.luau:766: Malformed string`)

- **Gravedad:** crítica (bloquea jugar). **Origen:** `a644eac` (DEV-011). **Detectado:** ART-008 (Play en Studio). **Corregido:** DEV-015 (`dda2573`).
- **Causa:** salto de línea real dentro de una cadena entre comillas (texto de la pieza del legado). `build.py` no lo veía; ahora sí.

### BUG-003 — Falla la prueba «place apoya la base en el suelo»

- **Gravedad:** baja (solo la prueba; el juego siempre pasa `parent`). **Corregido:** DEV-015 (`dda2573`).
- **Causa:** sin `parent`, `AssetLibrary.dress` dejaba la copia dentro del ancla temporal y `place` la destruía con ella.

## 23. Pruebas de DEV-017 (jefe y zonas 2 a 5)

Play en la place oficial el 2026-11-20 con el MCP de Studio. Para ir rápido, el personaje se mueve por script (teletransporte); las reglas las valida el servidor.

| Prueba | Tipo | Estado |
|---|---|---|
| Zona 2 (velocidad mínima 18) con velocidad 19: robar | Manual (Studio) | **Ejecutada: correcta** (20 robos, persecución y guardado en la base) |
| Zonas 3, 4 y 5 con velocidad 19, saltando la puerta: robar | Manual (Studio) | **Ejecutada: el servidor rechaza** («Necesitas velocidad 22/28/34…») y la pieza no se entrega |
| Cronómetro: aportes suman puntos según la rareza (común 1, poco común 3) | Manual (Studio) | **Ejecutada: correcta** |
| Cronómetro: la pieza del legado no se entrega | Manual (Studio) | **Ejecutada: rechazada** |
| Cronómetro sin llegar a la meta (21/30): devolución de piezas | Manual (Studio) | **Ejecutada: devuelve las 19 piezas** |
| Cronómetro reparado (30/30): premio de 12 monedas por punto y cápsula con 20 puntos o más | Manual (Studio) | **Ejecutada: +360 monedas y +1 Cápsula de Latón** |
| Output durante la partida | Manual (Studio) | 47/47 pruebas; solo aparece «Asset content representation is being generated» para `tex_paleta` (129172292521580, subida en ART-013, aún en proceso en Roblox). Sin errores de código |

## 24. Pruebas de DEV-018 (iconos y sonidos)

Play en la place oficial (versión 17) el 2026-11-20 con los IDs de ART-013 en `Config`.

| Prueba | Tipo | Estado |
|---|---|---|
| `Config` de la place igual a `main` | Automática (hash) | **Ejecutada: idéntico** |
| Iconos del HUD cargan | Manual (Studio) | **Ejecutada: 6 imágenes del HUD con `IsLoaded = true`**; captura con Mochila, Premios, Ruleta, Robux y Ajustes visibles |
| Sonidos suenan | Manual (Studio) | **Falla: BUG-004.** Los 10 dan «User is not authorized to access Asset» / «La experiencia no tiene permiso de acceso» |

### BUG-004 — Los sonidos no tienen permiso en la experiencia

- **Gravedad:** media (el juego funciona, pero sin sonido). **Detectado:** DEV-018.
- **Causa:** los 10 audios los subió la cuenta zadiel799 y la experiencia (universo 10778093657) es de Lubu465. Los audios necesitan permiso explícito para usarse en una experiencia de otro dueño (las imágenes no).
- **Arreglo (Zadiel, dueño de los audios):** Creator Dashboard → cada audio → *Permissions* → dar acceso a la experiencia 10778093657, o hacer clic en «compartir el acceso» en el Output de Studio con su cuenta. Otra opción: que Jhonn vuelva a subirlos con su cuenta y se cambien los IDs. Después, comprobar en Play.

## 25. Pruebas de DEV-019 (pases y productos de Robux)

| Prueba | Tipo | Estado |
|---|---|---|
| 15 pases y 7 productos creados en el universo 10778093657, a la venta y con su precio | Open Cloud (lista) | **Ejecutada 2026-11-20: los 15 pases aparecen con el precio de DEC-023**; los 7 productos se crearon con respuesta 200 |
| Scripts de la place = `main` (Config, GameData, PlayerLogic, prueba y Ui) | Automática (hash) | **Ejecutada: idénticos** |
| Pruebas automáticas, incluida la nueva de DEC-023 | Automática (Studio) | **Ejecutada: 48 correctas, 0 fallidas** |
| `buyProduct` abre la compra (Bolsa y Giro extra) | Manual (Studio) | **Ejecutada: «Abriendo la compra…»**; no se compró nada |
| `buyPass` con la cuenta dueña | Manual (Studio) | **Ejecutada: «Ya tienes el pase»**, porque el creador de la experiencia posee sus pases. Falta probar la compra con otra cuenta en un servidor real |
| `GetProductInfo` de Entrenamiento ×512 y Bolsa | Manual (Studio) | **Ejecutada: 1.199 R$ en venta y 25 R$** |
