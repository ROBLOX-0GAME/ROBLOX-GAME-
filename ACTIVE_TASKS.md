Registro central de rutas reservadas. Usa rutas exactas o patrones relativos a la raíz del repositorio. La comprobación de GitHub Actions bloquea un Pull Request si edita una ruta reservada por otra tarea.
​
​

Cómo reservar (DEC-009: se trabaja directo en main)
1. Haz `git pull` en main.
2. Registra la tarea en 09 - TAREAS Y DESARROLLO/Backlog.md y añade aquí una fila con las rutas exactas o patrones y estado En desarrollo. Comprueba que ninguna fila activa ya tenga esas rutas.
3. Haz commit de la reserva y súbela a main (`git push`) antes de editar.
4. Claude escribe el ID de la tarea en `.claude/tarea-activa` (archivo local, no se sube) para que el hook le permita editar las rutas reservadas.
5. Al terminar, anota el resultado en la memoria de Obsidian (Memoria-de-Area.md del área), cambia la fila a Completada, haz commit y súbelo a main. Así se libera la reserva.
## Estados
- En desarrollo, En progreso y Bloqueada: mantienen la reserva.
- En revisión: mantiene la reserva.
- Completada o Cancelada: no reserva rutas.
La configuración compartida `.claude/settings.json` ejecuta un hook antes de cada herramienta Edit/Write de Claude Code. En `main`, permite editar solo las rutas reservadas por la tarea escrita en `.claude/tarea-activa` y bloquea las rutas reservadas por otra tarea activa, leyendo este archivo en la copia local de main. ACTIVE_TASKS.md, Backlog.md y `.claude/tarea-activa` siempre se pueden editar para reservar. Las ramas `task/<ID>-<slug>` siguen funcionando, pero ya no son obligatorias.
Este control local cubre las herramientas Edit/Write de Claude Code; Bash, editores externos y Obsidian pueden saltárselo. Las personas también deben revisar las reservas antes de editar una nota.
## Reservas
| ID | Cuenta | Responsable | Revisor | Rutas reservadas | Estado |
|---|---|---|---|---|---|
| INFRA-001 | Cuenta A | Jhonn y Zadiel | Jhonn y Zadiel; Michael y Einell para revisión transversal | .claude/**<br>.github/**<br>game/**<br>OWNERS.md<br>ACTIVE_TASKS.md<br>.gitignore<br>00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA.md<br>00 - CENTRO DE CONTROL/Dashboard.md<br>03 - ARQUITECTURA TECNICA/Arquitectura-General.md<br>09 - TAREAS Y DESARROLLO/Backlog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>00 - CENTRO DE CONTROL/Memoria-de-Area.md<br>03 - ARQUITECTURA TECNICA/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Memoria-de-Area.md<br>10 - DECISIONES DEL EQUIPO/Memoria-de-Area.md | Completada |
| DEV-007 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/**<br>.gitignore<br>00 - CENTRO DE CONTROL/Dashboard.md<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>03 - ARQUITECTURA TECNICA/Arquitectura-General.md<br>03 - ARQUITECTURA TECNICA/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Lista-de-Sistemas.md<br>07 - ECONOMIA Y PROGRESION/Economia-y-Progresion.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>09 - TAREAS Y DESARROLLO/Memoria-de-Area.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>10 - DECISIONES DEL EQUIPO/Memoria-de-Area.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |
| INFRA-002 | Cuenta A | Zadiel | Jhonn; Michael y Einell para revisión transversal | .claude/**<br>.github/**<br>.gitignore<br>AGENTS.md<br>OWNERS.md<br>ACTIVE_TASKS.md<br>game/README.md<br>00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA.md<br>09 - TAREAS Y DESARROLLO/Backlog.md<br>09 - TAREAS Y DESARROLLO/Memoria-de-Area.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>10 - DECISIONES DEL EQUIPO/Memoria-de-Area.md | Completada |
| DEV-008 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/src/**<br>game/tools/**<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Memoria-de-Area.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |
| DEV-009 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/src/**<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Memoria-de-Area.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |
| DEV-010 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/src/**<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Memoria-de-Area.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |
| DEV-011 | Cuenta A | Jhonn | Zadiel; Michael y Einell revisan game/src/StarterPlayer/StarterPlayerScripts (interfaz) | game/src/**<br>02 - GAME DESIGN DOCUMENT/GDD.md<br>02 - GAME DESIGN DOCUMENT/Memoria-de-Area.md<br>04 - SISTEMAS DEL JUEGO/Memoria-de-Area.md<br>07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md<br>09 - TAREAS Y DESARROLLO/Changelog.md<br>10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md<br>11 - TESTING Y BUGS/Plan-de-Pruebas.md | Completada |
## main sin protección (DEC-009)
Por DEC-009, `main` no tiene protección de rama: se sube directamente, sin Pull Request ni aprobación. Nunca uses force push. Si alguien abre un Pull Request de forma opcional, GitHub Actions sigue ejecutando `reservation-check` y `rojo-build`.

## Navegación en Obsidian
[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[09 - TAREAS Y DESARROLLO/Backlog|Backlog]] · [[OWNERS|Propiedad de áreas]] · [[00 - CENTRO DE CONTROL/Protocolo-de-Trabajo-IA|Protocolo]]
