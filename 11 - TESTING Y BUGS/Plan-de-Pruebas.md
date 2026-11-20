
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
| Bucle completo: recoger → fabricar → vender/exhibir → mejorar | Manual en Studio | Pendiente |
| Guardado: salir y volver a entrar conserva el progreso (con acceso a API activado) | Manual en Studio | Pendiente |
| Controles con mando y en el emulador móvil de Studio | Manual | Pendiente |
| 2+ jugadores (Test → Clients and Servers): cajas compartidas y sin errores | Multijugador | Pendiente |

Registra aquí el resultado real de cada prueba al ejecutarla.
