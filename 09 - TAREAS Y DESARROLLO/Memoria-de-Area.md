# Memoria de área — Producción

> Memoria inicial basada en el formulario y la idea organizada. Las propuestas no son decisiones aprobadas. Mantén esta nota compacta, con enlaces.

## Notas canónicas

[[09 - TAREAS Y DESARROLLO/Backlog]]; [[00 - CENTRO DE CONTROL/Dashboard]]; [[ACTIVE_TASKS]]; [[OWNERS]]; [[00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA]]
- Registro: [[10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones]]

## Respuestas directas y datos base

- El Backlog registra ID, cuenta, responsable, revisor, rutas y criterios. Cada tarea usa task/<ID>-<slug>; ACTIVE_TASKS.md registra reservas. El hook compartido bloquea herramientas Edit/Write en main y rutas no reservadas. reservation-check valida que cada PR solo cambie su propia entrada y detecta rutas solapadas, incluso entre PRs de reserva.

## Pendientes concretos

- Integrar INFRA-001 y activar protección de main para exigir PR, aprobación, checks obligatorios y no permitir force push ni eliminación de rama. Limitar permisos de escritura a las cuatro cuentas exactas y desactivar borrado/transferencia por miembros desde los ajustes de la organización.

## Decisiones aprobadas del área

- DEC-002 fija ramas por tarea, PR obligatorio y una aprobación humana; consulta el registro de decisiones.

## Memoria reciente

- 2026-11-20 · DEV-007 integra DEV-001 a DEV-006 en `game/` (reserva PR #3). Registro paso a paso en [[Changelog]]. Por indicación de Jhonn, Claude solo programa mecánicas; el arte y el sonido se hacen con Krita, Blender, Audacity y Material Maker.
- INFRA-001 está en revisión en [PR #1](https://github.com/ROBLOX-0GAME/ROBLOX-GAME-/pull/1); ambos checks pasaron. Lee [[ACTIVE_TASKS]] antes de tomar rutas.

**Inicio:** 2026-11-19. **Actualización:** al cerrar una tarea del área.
