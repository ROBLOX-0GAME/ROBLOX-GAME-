# Tareas activas y reservas de rutas

Registro central de rutas reservadas. Usa rutas exactas o patrones relativos a la raíz del repositorio. La comprobación de GitHub Actions bloquea un Pull Request si edita una ruta reservada por otra tarea.

## Cómo reservar
1. Registra la tarea en 09 - TAREAS Y DESARROLLO/Backlog.md.
2. Crea la rama task/<ID>-<slug>.
3. Añade una fila con las rutas exactas o patrones y estado En desarrollo.
4. Abre un Pull Request de reserva que solo modifique Backlog.md y ACTIVE_TASKS.md. Espera su aprobación e integración antes de editar esas rutas. INFRA-001 fue la excepción única de arranque y combinó registro e implementación en un Pull Request; desde la siguiente tarea, reserva primero y espera su integración.
5. Después de completar el trabajo y las verificaciones, cambia la fila a Completada en el Pull Request final. Si el Pull Request final se integra, la reserva se libera. Los Pull Requests abiertos también se comparan para detectar cambios simultáneos.

## Estados
- En desarrollo, En progreso y Bloqueada: mantienen la reserva.
- En revisión: mantiene la reserva mientras haya un Pull Request abierto para ese ID. El hook local trata En revisión como activa; al integrar el Pull Request final, marca la fila Completada para liberar la ruta.
- Completada o Cancelada: no reserva rutas.
- Si un Pull Request se cierra sin integrar y la tarea continúa, devuelve su estado a En desarrollo.

La configuración compartida `.claude/settings.json` ejecuta un hook antes de cada herramienta Edit/Write de Claude Code. Bloquea `main`, las ramas que no sean `task/<ID>-<slug>`, las rutas no reservadas por la tarea y las rutas reservadas por otra tarea, consultando ACTIVE_TASKS.md de main. Si no puede leer el registro remoto, bloquea la edición. Una reserva debe integrarse antes de tocar su código.

Este control local cubre las herramientas Edit/Write de Claude Code; Bash, editores externos y otras aplicaciones pueden saltárselo. No es un bloqueo del sistema de archivos. La barrera compartida para todos los cambios sigue siendo GitHub Actions y una protección de `main` activa.

## Reservas

| ID | Cuenta | Responsable | Revisor | Rutas reservadas | Estado |
|---|---|---|---|---|---|
| INFRA-001 | Cuenta A | Jhonn y Zadiel | Jhonn y Zadiel; Michael y Einell para revisión transversal | .claude/**<br>.github/**<br>game/**<br>OWNERS.md<br>ACTIVE_TASKS.md<br>.gitignore<br>00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA.md<br>00 - CENTRO DE CONTROL/Dashboard.md<br>03 - ARQUITECTURA TECNICA/Arquitectura-General.md<br>09 - TAREAS Y DESARROLLO/Backlog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>00 - CENTRO DE CONTROL/Memoria-de-Area.md<br>03 - ARQUITECTURA TECNICA/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Memoria-de-Area.md<br>10 - DECISIONES DEL EQUIPO/Memoria-de-Area.md | Completada |
| DEV-007 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/**<br>.gitignore<br>00 - CENTRO DE CONTROL/Dashboard.md<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>03 - ARQUITECTURA TECNICA/Arquitectura-General.md<br>03 - ARQUITECTURA TECNICA/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Lista-de-Sistemas.md<br>07 - ECONOMIA Y PROGRESION/Economia-y-Progresion.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>09 - TAREAS Y DESARROLLO/Memoria-de-Area.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>10 - DECISIONES DEL EQUIPO/Memoria-de-Area.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |

## Protección efectiva de main

La regla se configura en GitHub Settings → Branches / Rulesets. Requiere:
- Pull Request antes de integrar.
- Una aprobación humana; no aceptar autoaprobación del autor del cambio.
- Los controles reservation-check y rojo-build.
- Bloquear actualizaciones directas a main y no permitir bypasses.

La rama main estaba sin protección en la última comprobación. El conector GitHub disponible no permite administrar esa configuración; se activa desde los ajustes del repositorio. Configura PR obligatorio, aprobación humana, `reservation-check`, `rojo-build`, rama actualizada antes de integrar, bloqueo de force push y eliminación de la rama. El workflow ya proporciona los checks requeridos.

El control de solapamientos compara también reservas introducidas por otros Pull Requests abiertos, incluidos los PR que solo reservan rutas. ACTIVE_TASKS.md y Backlog.md son las únicas rutas compartidas que admiten ediciones coordinadas en varios PR; el check limita cada PR a modificar la fila y sección de su propio ID.


## Navegación en Obsidian

[[[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[09 - TAREAS Y DESARROLLO/Backlog|Backlog]] · [[OWNERS|Propiedad de áreas]] · [[00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA|Protocolo]]
]]