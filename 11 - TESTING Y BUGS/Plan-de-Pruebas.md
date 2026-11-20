
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
| Revisión estática `python juego/build.py --check` (bloques, `require`, campos) | Automática | **Ejecutada 2026-11-20: 0 errores** |
| 13 pruebas de `PlayerLogic` (`juego/src/server/Tests`) al pulsar Play en Studio | Automática | Pendiente: no ejecutada todavía |
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
| Revisión estática `python juego/build.py --check` | Automática | **Ejecutada 2026-11-20: 0 errores** |
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
