# Código Roblox con Rojo

Este es el scaffold inicial del código fuente. El place del juego todavía no existe. El flujo confirmado es parcialmente gestionado: Git guarda el código y la configuración; Roblox Studio conserva el place, el mundo y los assets.

## Coordinación de edición entre los dos Claude Code

La configuración compartida `.claude/settings.json` ejecuta un control antes de las herramientas Edit/Write. Bloquea ediciones en `main`, fuera de una reserva integrada en ACTIVE_TASKS.md, o sobre rutas ocupadas por otra tarea. Primero registra la tarea en el [[09 - TAREAS Y DESARROLLO/Backlog]] y [[ACTIVE_TASKS|ACTIVE_TASKS]], abre un PR de reserva y espera a que se integre. El hook consulta el registro en `main` y falla de forma cerrada si no puede leerlo.

Este control actúa sobre Edit/Write de Claude Code. No bloquea programas externos ni comandos Bash que escriban archivos; la regla de Pull Request, GitHub Actions y la protección de `main` son las barreras de integración. En la PC Windows se necesita Git for Windows con Bash y Python 3.10 o posterior para que el hook funcione. No se debe usar un editor externo para evadir una reserva.

[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[OWNERS|Propiedad de áreas]] · [[ACTIVE_TASKS|Reservas activas]]

## Protección hasta crear el place

default.project.json declara servePlaceIds como una lista vacía. Rojo solo sincroniza en vivo con IDs enumerados, así que mientras la lista esté vacía no conectes el plugin a ningún place. La construcción local del scaffold sigue disponible.

Cuando el equipo cree el place:
1. Registra el placeId aprobado en 03 - ARQUITECTURA TECNICA/Arquitectura-General.md.
2. Añade ese ID a servePlaceIds en default.project.json mediante un Pull Request revisado.
3. Clona o actualiza el repositorio en la PC Windows destinada al desarrollo.
4. Instala Rokit y ejecuta rokit install desde game/.
5. Instala el plugin con rojo plugin install.
6. Construye con rojo build default.project.json --output build/ROBLOX-GAME.rbxlx.
7. Abre el place correcto en Roblox Studio.
8. Ejecuta rojo serve default.project.json y conecta el plugin local de Rojo.
9. Revisa el destino y la previsualización de cambios antes de aceptar la sincronización.

El servidor local de Rojo y Roblox Studio deben ejecutarse en la misma PC para usar localhost. GitHub almacena el repositorio, pero no mantiene abierta esa conexión local.

## Estructura inicial

- src/ReplicatedStorage/Shared: módulos compartidos.
- src/ServerScriptService: scripts del servidor.
- src/StarterPlayer/StarterPlayerScripts: scripts del cliente.
- build/: salida local de place, ignorada por Git.

Los archivos Bootstrap y Placeholder no implementan mecánicas. Se retirarán o sustituirán cuando la arquitectura del juego se apruebe.


## Navegación en Obsidian

[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[03 - ARQUITECTURA TECNICA/Arquitectura-General|Arquitectura técnica]] · [[OWNERS|Responsables]] · [[ACTIVE_TASKS|Reservas de rutas]]
