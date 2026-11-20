# Propiedad de áreas y rutas

Este archivo asigna responsabilidad de trabajo; no concede permiso para saltarse la reserva de rutas. ACTIVE_TASKS.md y el control de Pull Requests se aplican a cada cambio.

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
- La persona responsable y su revisor se identifican en Backlog.md y en el Pull Request.
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

La asignación anterior refleja nombres y parejas del equipo. No se inventan usuarios ni equipos de GitHub para CODEOWNERS; el repositorio no tiene esos handles registrados en la documentación revisada. La aprobación general de Pull Requests se configura como mínimo una aprobación humana. Si el equipo comparte sus handles, se podrá añadir una regla CODEOWNERS específica.


## Cobertura del repositorio y permisos

- Las rutas listadas arriba asignan áreas. Todo archivo o carpeta no listado se considera compartido hasta que Backlog.md indique responsable y ACTIVE_TASKS.md reserve la ruta.
- Claude nunca edita la rama main directamente. Los cambios llegan por Pull Request con una aprobación humana y los checks obligatorios.
- Política de acceso solicitada: solo Jhonn, Zadiel, Michael y Einell deben tener permiso de escritura; limita administración y borrado de repositorio a propietarios autorizados. Esa política todavía requiere ajuste en GitHub Settings y confirmación de los cuatro @handles.
- Los nombres del equipo no bastan para CODEOWNERS o para cambiar permisos; no se inventan handles.

## Navegación en Obsidian

[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA|Protocolo de trabajo]] · [[09 - TAREAS Y DESARROLLO/Backlog|Backlog]] · [[ACTIVE_TASKS|Reservas activas]]
