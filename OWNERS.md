# Propiedad de áreas y rutas

Este archivo asigna responsabilidad de trabajo; no concede permiso para saltarse la reserva de rutas. Las reservas de ACTIVE_TASKS.md se aplican a cada cambio, que se sube directamente a main (DEC-009).

## Cuenta A — Claude 1

Administrada por Jhonn y Zadiel. Jhonn y Zadiel son responsables y revisores de coordinación central.

Lidera gameplay, sistemas, economía, progresión, arquitectura técnica, servidor y Git/Obsidian.

Rutas principales:
- .claude/rules/arquitectura.md
- .claude/rules/backlog.md
- .claude/rules/economia-progresion.md
- .claude/rules/multijugador.md
- .claude/rules/sistemas.md
- .claude/rules/testing.md
- 03 - ARQUITECTURA TECNICA/
- 04 - SISTEMAS DEL JUEGO/
- 07 - ECONOMIA Y PROGRESION/
- 08 - MULTIJUGADOR/ (liderazgo de servidor y seguridad)
- 11 - TESTING Y BUGS/ (pruebas técnicas)
- game/src/ServerScriptService/
- game/src/ReplicatedStorage/Shared/

## Cuenta B — Claude 2

Administrada por Michael y Einell.

Lidera mundo, narrativa, personajes, dirección visual, contenido y experiencia de usuario.

Rutas principales:
- .claude/rules/vision.md
- .claude/rules/mundo-contenido.md
- .claude/rules/ui-ux.md
- 01 - VISION DEL JUEGO/
- 05 - MUNDO Y CONTENIDO/
- 06 - INTERFAZ Y EXPERIENCIA/
- game/src/StarterPlayer/StarterPlayerScripts/

## Revisión cruzada por área

- Cuenta A lidera sistemas y técnica; Cuenta B revisa claridad, impacto para el jugador y experiencia.
- Cuenta B lidera mundo, narrativa y UX; Cuenta A revisa dependencias técnicas, seguridad y rendimiento.
- La persona responsable y su revisor se identifican en Backlog.md. La revisión se hace sobre los commits ya subidos a main.
- Las tareas que afectan ambas áreas requieren revisión de ambas parejas.

## Rutas compartidas

Requieren coordinación y reserva explícita:
- .claude/CLAUDE.md, prompts de inicio y reglas generales.
- .claude/rules/centro-control.md.
- 00 - CENTRO DE CONTROL/.
- 02 - GAME DESIGN DOCUMENT/.
- 09 - TAREAS Y DESARROLLO/.
- 10 - DECISIONES DEL EQUIPO/.
- OWNERS.md y ACTIVE_TASKS.md.
- .github/.
- .gitignore.
- game/default.project.json y game/rokit.toml.
- game/README.md.
- game/src/ReplicatedStorage/Shared/.

La propiedad de Recursos y Referencias depende del área de la herramienta o material documentado.

## Límites de GitHub

La asignación anterior refleja nombres y parejas del equipo. No se inventan usuarios ni equipos de GitHub para CODEOWNERS; los handles de Michael y Einell no están registrados en la documentación revisada. Los cambios sustantivos de todos los colaboradores deben pasar por Pull Request y revisión humana.

## Cobertura del repositorio y permisos

- Las rutas listadas arriba asignan áreas. Todo archivo o carpeta no listado se considera compartido hasta que Backlog.md indique responsable y ACTIVE_TASKS.md reserve la ruta.
- Por DEC-009, Claude y el equipo trabajan directamente en `main`, sin Pull Request, respetando las reservas de ACTIVE_TASKS.md. `main` no tiene protección de rama; nunca se usa force push.
- La política solicitada es que solo Jhonn, Zadiel, Michael y Einell tengan permiso de escritura. Asigna Write únicamente a sus cuatro cuentas, configura el permiso base de la organización como Read, y limita Admin a las personas necesarias de ese mismo grupo. Los propietarios de la organización conservan privilegios administrativos.
- Para evitar borrado por miembros, la organización debe desactivar el permiso de miembros para borrar o transferir repositorios; el ajuste es organizacional y los propietarios de la organización pueden seguir borrándolos. Para impedir borrar la rama `main`, activa la protección de rama o ruleset contra eliminación.
- Estado comprobado para INFRA-001: el repositorio es público; GitHub confirmó a Zadiel (`zadiel799-lang`) y Jhonn (`jhonnhughesmadrigal-cmd`) como administradores del repositorio. `main` no tenía protección activa. La conexión no expone la lista de colaboradores ni permite cambiar los permisos, reglas de rama o ajustes de borrado.
- La configuración de acceso no se considera aplicada hasta añadir los @handles exactos de Michael y Einell y guardar los ajustes en GitHub. No se inventan handles ni se cambia la visibilidad pública del repositorio.

## Navegación en Obsidian

[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA|Protocolo de trabajo]] · [[09 - TAREAS Y DESARROLLO/Backlog|Backlog]] · [[ACTIVE_TASKS|Reservas activas]]
