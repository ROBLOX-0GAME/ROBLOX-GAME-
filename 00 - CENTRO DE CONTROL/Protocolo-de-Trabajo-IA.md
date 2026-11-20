# 🤖 PROTOCOLO DE TRABAJO DE LOS AGENTES IA

## 1. Propósito
Coordinar las dos cuentas Claude Code, conservar trabajo concurrente y llevar cambios revisados a main.

## 2. Organización
- Cuenta A — Claude 1, administrada por Jhonn y Zadiel. Lidera gameplay, sistemas, economía, progresión, arquitectura técnica y la integración Git/Obsidian.
- Cuenta B — Claude 2, administrada por Michael y Einell. Lidera mundo, narrativa, personajes, dirección visual, contenido y UX.
- Cada tarea del Backlog identifica una persona responsable y un revisor. Las tareas transversales requieren revisión de ambas parejas.
- Cuenta A coordina la integración. Nadie aprueba su propio Pull Request.

## 3. Registro y reserva de rutas
Cada tarea usa un ID, una rama y rutas concretas.
1. Registra la tarea en Backlog.md con objetivo, responsable, cuenta, revisor, prioridad, estado, dependencias y aceptación.
2. Revisa OWNERS.md para identificar el área responsable.
3. Crea la rama task/<ID>-<slug>.
4. Añade la fila en ACTIVE_TASKS.md con rutas exactas o patrones, responsables y estado En desarrollo.
5. Abre un Pull Request de reserva que solo cambie Backlog.md y ACTIVE_TASKS.md. Espera aprobación e integración en main.
6. Solo después de integrar la reserva, modifica las rutas reservadas.
7. El control file-reservations valida los cambios de cada Pull Request. Una ruta que choque con una reserva ajena detiene la integración.
8. Una reserva En desarrollo o Bloqueada se mantiene activa. En el Pull Request final cambia su estado a Completada. Al fusionarse, la reserva queda liberada. Si un Pull Request de implementación se cierra sin fusionar, restablece la reserva a En desarrollo o márcala Cancelada.

La automatización actúa como puerta de integración: no puede impedir que alguien edite un archivo localmente ni reemplaza la reserva previa.

## 4. Flujo de ramas y Pull Requests
- Usa una rama por tarea, nunca una rama permanente por Claude.
- Actualiza la rama desde main antes de abrir el Pull Request.
- Todo cambio se integra mediante Pull Request a main.
- El Pull Request incluye ID, responsable, revisor, rutas reservadas, resumen, criterios de aceptación y verificaciones.
- Se requiere una aprobación humana de otra persona y que pasen los controles file-reservations y rojo-build.
- No hagas push directo a main, force push ni merge. La persona integradora autorizada de Cuenta A integra después de la revisión.
- Las reglas de GitHub para proteger main deben exigir Pull Request, una aprobación y ambos controles. La configuración efectiva se activa en Settings del repositorio.

## 5. Conflictos
- Si una ruta aparece reservada por otra tarea, no la edites.
- Si dos cambios abiertos modifican la misma ruta, el control automático no permite integrar ambos a la vez.
- Coordina una nueva reserva o elige una tarea independiente. Nunca descartes cambios para eliminar un conflicto.
- No uses force push. Conserva y compara las versiones.

## 6. Roblox Studio y Rojo
- El repositorio incluye el scaffold de código en game/. Git es la fuente del código; Roblox Studio conserva el place, el mundo y los assets.
- Rojo usa un servidor local y el plugin de Studio; no es una conexión directa desde GitHub a Studio.
- El place todavía no existe. game/default.project.json tiene servePlaceIds vacío, así que no sincronices en vivo.
- Una vez creado el place, registra su placeId en Arquitectura-General.md y añade el ID a servePlaceIds en un Pull Request revisado.
- Instala Rojo y el plugin en las PC Windows de desarrollo, siguiendo game/README.md.

## 7. Autoridad y límites
Pide aprobación humana para cambiar decisiones aprobadas, arquitectura general, datos persistentes, dependencias importantes, permisos o publicación. No guardes credenciales y no declares pruebas que no ejecutaste.

## 8. Informe de cierre
Informa qué cambió, rutas afectadas, responsable y revisor, rama, commit y Pull Request, verificaciones ejecutadas, conflictos y próximos pasos. Actualiza Backlog y libera la reserva.

---

**Agentes:** Claude 1/Cuenta A y Claude 2/Cuenta B
**Responsables:** Jhonn, Zadiel, Michael y Einell
**Estado:** Protocolo operativo propuesto para revisión del equipo
