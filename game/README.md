# Código Roblox con Rojo

Este es el scaffold inicial del código fuente. El place del juego todavía no existe. El flujo confirmado es parcialmente gestionado: Git guarda el código y la configuración; Roblox Studio conserva el place, el mundo y los assets.

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
