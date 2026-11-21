
# 🏗️ ARQUITECTURA TÉCNICA GENERAL

## 1. Propósito

Definir la estructura técnica del proyecto Roblox Game Studio, sus componentes, responsabilidades y criterios de organización.

## 2. Plataforma y tecnología

- **Plataforma:** Roblox
- **Motor:** Roblox Studio
- **Lenguaje principal:** Luau
- **Entorno de desarrollo:** Roblox Studio
- **Control de versiones:** Git y GitHub
- **Documentación:** Obsidian
- **Herramienta de sincronización:** Rojo

### Entorno de trabajo por dispositivo

- Roblox Studio se usa en las PC Windows de desarrollo y en la MacBook de Zadiel.
- La MacBook de Zadiel sirve para todo el trabajo del proyecto (DEC-021, reemplaza a DEC-019): Obsidian y Git, arte (Blender, Material Maker, Krita y Audacity con los scripts de `art/`), Roblox Studio con su MCP y Open Cloud, código con Rojo y pruebas en Play.
- El repositorio GitHub contiene la bóveda de Obsidian y el código fuente en game/. La place oficial es **84500108687089** (universo 10778093657) y se trabaja en ella por Team Create.
- El flujo acordado es parcialmente gestionado: Git contiene código y configuración, y Roblox Studio conserva el place, el mundo y los assets.
- game/default.project.json tiene la place oficial en servePlaceIds desde DEV-016.
- Rojo sirve desde el equipo de desarrollo que se esté usando (PC Windows o MacBook) y su plugin local se conecta a ese servidor; GitHub no mantiene una conexión directa con Studio. En Team Create no se guarda la place a la vez desde dos equipos.
- Consulta [[game/README|Proyecto fuente de Roblox con Rojo]] para instalación, build y sincronización.

## 3. Arquitectura general

El scaffold inicial vive en game/ y separa claramente:

- Cliente.
- Servidor.
- Módulos compartidos.
- Servicios del juego.
- Sistemas de datos.
- Interfaces.

La implementación específica de sistemas está pendiente de diseño y aprobación.

## 4. Organización del código

### Cliente
Responsable de las funcionalidades que se ejecutan en el dispositivo del jugador.

### Servidor
Responsable de la lógica autoritativa, validaciones y estado compartido del juego.

### Módulos compartidos
Contendrán componentes y definiciones que necesiten utilizar tanto el cliente como el servidor.

## 5. Sistemas técnicos

- Sistema de jugadores.
- Sistema de combate.
- Sistema de habilidades.
- Sistema de inventario.
- Sistema de economía.
- Sistema de progresión.
- Sistema de guardado.
- Sistema de enemigos.
- Sistema de misiones.
- Sistema multijugador.
- Sistema de interfaz.

## 6. Comunicación cliente-servidor

Definir los mecanismos de comunicación, validaciones y límites de confianza.

Principio fundamental: el servidor debe validar las acciones importantes del jugador.

## 7. Gestión de datos

- Persistencia.
- Guardado.
- Carga.
- Validación.
- Recuperación ante errores.
- Evolución de estructuras de datos.

Tecnología y diseño detallado pendientes de aprobación.

## 8. Rendimiento y optimización

- Control de uso de memoria.
- Optimización de scripts.
- Gestión de eventos.
- Optimización de física.
- Control de carga de recursos.
- Pruebas de rendimiento.

## 9. Seguridad

- Validación en servidor.
- Protección de eventos remotos.
- Control de datos.
- Prevención de exploits.
- Verificación de transacciones.

## 10. Estándares de desarrollo

- Código modular.
- Responsabilidades claras.
- Nombres consistentes.
- Documentación del código.
- Evitar duplicación innecesaria.
- Probar antes de integrar cambios.

## 11. Decisiones técnicas pendientes

Registrar aquí las decisiones que el equipo todavía debe aprobar.

## 12. Documentos relacionados

- [[Dashboard]]
- [[Vision-General]]
- [[GDD]]
- [[Lista-de-Sistemas]]
- [[Backlog]]
- [[Registro-de-Decisiones]]
- [[Plan-de-Pruebas]]
- [[game/README|Proyecto fuente de Roblox con Rojo]]
- [[03 - ARQUITECTURA TECNICA/Memoria-de-Area|Memoria de Arquitectura]]
- [[OWNERS]]
- [[ACTIVE_TASKS]]

---

**Estado:** Borrador inicial  
**Aprobación técnica:** Pendiente

## 13. Implementación del juego (DEV-007) — propuesta en revisión

- **Código:** `game/src` según DEC-001. Compartido en `ReplicatedStorage/Shared` (Config, GameData, PlayerLogic); servidor en `ServerScriptService/Server` (Main, Services, Tests); cliente en `StarterPlayer/StarterPlayerScripts/Client` (Main, Ui).
- **Compilación:** el control oficial es `rojo build game/default.project.json` (Rojo 7.7.1). Como ayuda local sin Rojo, `python game/tools/build.py` revisa bloques, `require`, campos de módulos y locales usados antes de declararse, y genera `game/build/ROBLOX-GAME.rbxlx`.
- **Pruebas:** `Server/Tests` ejecuta las pruebas de `PlayerLogic` al pulsar Play en Studio (nunca en servidores publicados).
- **Comunicación:** `ReplicatedStorage.Remotes`. `Action` (RemoteFunction) es la única entrada de acciones del cliente. `State`, `Notify` y `OpenPanel` (RemoteEvent) van del servidor al cliente. El servidor valida tipos, límite de solicitudes, distancia a estaciones y reglas de `PlayerLogic`.
- **Datos:** DataStore `BuildAWatch_PlayerData_v1`, formato `{ data, lock }`. Incluye bloqueo de sesión (300 s), autoguardado (120 s), guardado al salir y en `BindToClose`, y reparación con `PlayerLogic.reconcile`. El botín encima y los pases son solo de la sesión.
- **Robux:** `MonetizationService`. Los pases se consultan a Roblox al entrar. Los productos se entregan una sola vez (id de compra guardado) y solo se confirman tras guardar. Los IDs se configuran en `Config` (0 = próximamente).
- **Mundo:** `WorldService`, `HouseService` y `TrainingService` generan piezas funcionales provisionales, marcadas con CollectionService (`Station`, `SpeedGate`, `GuideHouse`, `Treadmill`). El arte final se hará con Krita, Blender, Audacity y Material Maker y podrá sustituirlas conservando etiquetas y atributos.
- Diseño: [[GDD]] §15. Historial: [[Changelog]]. Propuestas: [[Registro-de-Decisiones]] DEC-003 a DEC-008.

## 14. Arte en el juego (DEV-014)

- `ReplicatedStorage/Shared/AssetLibrary`: el código usa los modelos de **`ReplicatedStorage/Assets`** (se importan en la place publicada; no están en Git, según DEC-001) y, si faltan, las piezas provisionales.
- Las piezas provisionales siguen siendo la fuente de colisiones, avisos (ProximityPrompt), etiquetas y lógica; el modelo es solo visual.
- Sonidos por el `RemoteEvent` `Sound`; los IDs están en `Config.SOUND_IDS`. Iconos en `Config.ICON_IDS`.
- Detalle y pasos en [[Pipeline-de-Arte]].

