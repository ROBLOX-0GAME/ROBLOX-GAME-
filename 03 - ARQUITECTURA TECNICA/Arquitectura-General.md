# 🏗️ ARQUITECTURA TÉCNICA GENERAL

## 1. Propósito
Definir la estructura técnica del proyecto Roblox Game Studio, sus componentes, responsabilidades y criterios de organización.

## 2. Plataforma y tecnología
- **Plataforma:** Roblox
- **Motor:** Roblox Studio
- **Lenguaje principal:** Luau
- **Control de versiones:** Git y GitHub
- **Documentación:** Obsidian
- **Herramienta de sincronización:** Rojo

### Entorno de trabajo por dispositivo
- Roblox Studio se instalará manualmente en las PC Windows destinadas al desarrollo.
- La MacBook se usará para Obsidian y tareas escolares.
- El código y la configuración Rojo se guardan en la carpeta game/ de este repositorio.
- El flujo confirmado es parcialmente gestionado: Git guarda el código; Roblox conserva el place, el mundo y los assets.
- El place todavía no existe. No hay placeId disponible.
- game/default.project.json contiene una allowlist servePlaceIds vacía. Rojo puede construir el scaffold, pero la sincronización en vivo queda bloqueada hasta que se apruebe un placeId.
- El servidor de Rojo corre en la PC de desarrollo y el plugin de Roblox Studio se conecta a ese servidor local. GitHub es el repositorio central; no es el servidor de sincronización.

### Preparación inicial
1. Clona este repositorio en una PC Windows de desarrollo.
2. Instala Rokit y ejecuta rokit install desde game/.
3. Instala el plugin con rojo plugin install.
4. Construye el archivo inicial con rojo build default.project.json -o build/ROBLOX-GAME.rbxlx.
5. Cuando el equipo cree el place, anota su placeId aquí y en game/default.project.json dentro de servePlaceIds.
6. Solo después de que la reserva del placeId quede aprobada, ejecuta rojo serve y conecta el plugin de Studio.

Consulta [[game/README|Proyecto fuente de Roblox con Rojo]] para los pasos completos.

## 3. Arquitectura general del código
La estructura inicial separa:
- Código del servidor bajo game/src/ServerScriptService.
- Módulos compartidos bajo game/src/ReplicatedStorage/Shared.
- Scripts del cliente bajo game/src/StarterPlayer/StarterPlayerScripts.

Esta estructura es un scaffold técnico inicial. Los sistemas, datos persistentes, servicios de juego y comunicación cliente-servidor se diseñarán y aprobarán antes de implementarse.

## 4. Principios
- Mantener separadas las responsabilidades de cliente, servidor y módulos compartidos.
- El servidor valida las acciones importantes del jugador.
- Las decisiones de persistencia, seguridad, economía y publicación requieren aprobación humana.
- Los assets y el diseño del mundo siguen siendo gestionados en Roblox Studio.

## 5. Sistemas técnicos previstos
- Jugadores.
- Combate.
- Habilidades.
- Inventario.
- Economía y progresión.
- Guardado.
- Enemigos y misiones.
- Multijugador e interfaz.

La implementación específica sigue pendiente de diseño y aprobación.

## 6. Documentos relacionados
- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Lista-de-Sistemas]]
- [[Backlog]]
- [[Registro-de-Decisiones]]
- [[Plan-de-Pruebas]]
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[game/README|Proyecto fuente de Roblox con Rojo]]

---

**Estado:** Scaffold Rojo preparado; conexión en vivo pendiente de crear el place y aprobar el placeId.
