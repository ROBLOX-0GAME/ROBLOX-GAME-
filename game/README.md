# Código Roblox con Rojo

Código fuente de BUILD A WATCH! (mecánicas, DEV-001 a DEV-007). El place oficial todavía no existe. El flujo confirmado es parcialmente gestionado: Git guarda el código y la configuración; Roblox Studio conserva el place, el mundo y los assets.

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

## Estructura

- `src/ReplicatedStorage/Shared`: `Config` (cifras de balance y técnicas, PROPUESTA), `GameData` (piezas, relojes, zonas, mascotas, caminadoras y pases), `PlayerLogic` (reglas puras y probadas).
- `src/ServerScriptService/Server`: `Main` y `Services` (datos, mundo, casas y dueños, acciones, museo, jefe, mascotas, entrenamiento, Robux, remotos), además de `Tests`.
- `src/StarterPlayer/StarterPlayerScripts/Client`: `Main` y `Ui` (HUD y menús funcionales; ruta de Cuenta B según OWNERS.md).
- `tools/build.py`: revisión estática y place local sin Rojo.
- `build/`: salida local de place, ignorada por Git.

DEV-007 retiró los archivos Bootstrap y Placeholder de INFRA-001 al llegar el código real.

## Probar sin Rojo

1. `python game/tools/build.py`: revisa el código y genera `game/build/ROBLOX-GAME.rbxlx`.
2. Abre ese archivo en Roblox Studio y pulsa Play. En Output deben aparecer `[BUILD A WATCH!] Servidor iniciado.` y `[Pruebas] N correctas, 0 fallidas`.
3. Opcional: `Config.STUDIO_GRANT_ALL_PASSES = true` activa todos los pases de Robux solo en esa sesión de Studio.
4. El guardado real requiere publicar la experiencia y activar Game Settings → Security → Enable Studio Access to API Services. Sin eso el juego avisa «Modo de prueba».

Lo que se cambie dentro de Studio debe copiarse a `game/src`; si no, se pierde al recompilar.

## Mecánicas (propuesta; diseño en el GDD §15)

1. Robo por 5 zonas, cada una más rica. Para entrar a cada zona hace falta velocidad. Al salir de una casa, el dueño te persigue; si te atrapa, pierdes el botín.
2. Fabricar relojes en el Taller, venderlos en la Tienda o exhibirlos en el Museo, que da ingreso pasivo.
3. Velocidad = (base + mejoras + entrenamiento en caminadoras) × mascotas × pase.
4. Jefe cooperativo: el Cronómetro Maestro.
5. Tutorial de 5 objetivos.
6. Pases y productos con Robux; sus IDs van en `Config` y valen 0 hasta publicarse.

Reglas: el servidor decide todo, las reglas nuevas van en `PlayerLogic` con su prueba, y cada paso se registra en el Changelog.


## Navegación en Obsidian

[[00 - CENTRO DE CONTROL/Dashboard|Dashboard]] · [[03 - ARQUITECTURA TECNICA/Arquitectura-General|Arquitectura técnica]] · [[OWNERS|Responsables]] · [[ACTIVE_TASKS|Reservas de rutas]]
