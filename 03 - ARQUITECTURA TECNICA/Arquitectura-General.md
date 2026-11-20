
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

### Entorno de trabajo por dispositivo

- Roblox Studio se instalará manualmente en las PC Windows destinadas al desarrollo.
- La MacBook se usará para Obsidian y tareas escolares; no se planifica el desarrollo de Roblox Studio en ella.
- El repositorio GitHub conectado actualmente contiene la bóveda de Obsidian, no el place ni el código fuente del juego.
- Antes de programar, registra aquí la ruta o repositorio del proyecto, confirma que abre en Roblox Studio en una PC de desarrollo y documenta la rama y el flujo de publicación.

## 3. Arquitectura general

La arquitectura deberá separar claramente:

- Cliente.
- Servidor.
- Módulos compartidos.
- Servicios del juego.
- Sistemas de datos.
- Interfaces.

La implementación específica está pendiente de diseño.

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

---

**Estado:** Borrador inicial  
**Aprobación técnica:** Pendiente

## 13. Implementación inicial (DEV-001) — propuesta en revisión

- **Ruta del proyecto:** `C:\Users\Cliente001\Desktop\ROBLOX-GAME-` (PC de Jhonn). Código en `juego/`; place base de Studio: `Proyecto Roblox Studio.rbxl` (sin cambios).
- **Flujo:** el código vive en `juego/src` (texto, Git). `python juego/build.py` lo revisa y genera `juego/build/BuildAWatch.rbxlx`. Compatible con Rojo (`juego/default.project.json`).
- **Cliente / servidor / compartido:** `ReplicatedStorage.Shared` (Config, GameData, PlayerLogic), `ServerScriptService.Server` (Main + Services + Tests), `StarterPlayerScripts.Client` (Main + Ui).
- **Comunicación:** `ReplicatedStorage.Remotes` — `Action` (RemoteFunction, cliente → servidor, única entrada de acciones), `State`, `Notify`, `OpenPanel` (RemoteEvent, servidor → cliente). Validación: tipos, límite de solicitudes, distancia a la estación y reglas de `PlayerLogic`.
- **Datos:** DataStore `BuildAWatch_PlayerData_v1`, clave `player_<UserId>`, formato `{ data, lock }`. Bloqueo de sesión de 300 s, autoguardado de 120 s, guardado al salir y en `BindToClose`, reparación de datos con `PlayerLogic.reconcile`. Si la carga falla en un servidor real, se expulsa al jugador para no sobrescribir su progreso.
- **Mapa:** generado por código (`WorldService`); la Cuenta B puede sustituir lo visual conservando estaciones y ProximityPrompt.
- Detalle y uso: `juego/README.md`. Historial: [[Changelog]]. Decisiones propuestas: [[Registro-de-Decisiones]] DEC-001 y DEC-002.
