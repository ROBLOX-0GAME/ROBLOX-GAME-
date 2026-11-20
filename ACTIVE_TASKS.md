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
- En revisión: mantiene la reserva mientras haya un Pull Request abierto para ese ID.
- Completada o Cancelada: no reserva rutas.
- Si un Pull Request se cierra sin integrar y la tarea continúa, devuelve su estado a En desarrollo.

El control automatizado solo impide integrar Pull Requests incompatibles; no bloquea la edición local antes de crear una rama. Mantén la reserva antes de empezar.

## Reservas

| ID | Cuenta | Responsable | Revisor | Rutas reservadas | Estado |
|---|---|---|---|---|---|
| INFRA-001 | Cuenta A | Jhonn y Zadiel | Jhonn y Zadiel; Michael y Einell para revisión transversal | .claude/**<br>.github/**<br>game/**<br>OWNERS.md<br>ACTIVE_TASKS.md<br>.gitignore<br>00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA.md<br>00 - CENTRO DE CONTROL/Dashboard.md<br>03 - ARQUITECTURA TECNICA/Arquitectura-General.md<br>09 - TAREAS Y DESARROLLO/Backlog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md | En revisión |

## Protección efectiva de main

La regla se configura en GitHub Settings → Branches / Rulesets. Requiere:
- Pull Request antes de integrar.
- Una aprobación humana; no aceptar autoaprobación del autor del cambio.
- Los controles coordination / reservation-check y coordination / rojo-build.
- Bloquear actualizaciones directas a main y no permitir bypasses.

La rama main estaba sin protección en la última comprobación. El conector GitHub disponible no permite administrar esa configuración; se activa desde los ajustes del repositorio. El workflow ya está preparado para proporcionar los controles requeridos.
