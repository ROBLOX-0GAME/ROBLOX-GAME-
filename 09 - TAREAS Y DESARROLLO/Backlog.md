
# 📋 BACKLOG — PRODUCCIÓN Y DESARROLLO

## 1. Propósito

Centralizar las tareas, mejoras, errores y objetivos de desarrollo de Roblox Game Studio.

## 2. Estados de las tareas

- **Pendiente:** todavía no iniciada.
- **En progreso:** actualmente en desarrollo.
- **En revisión:** esperando revisión.
- **Bloqueada:** depende de otra tarea o decisión.
- **Completada:** finalizada y verificada.

## 3. Prioridades

- **Crítica:** bloquea el proyecto o compromete su funcionamiento.
- **Alta:** necesaria para el desarrollo principal.
- **Media:** importante, pero no urgente.
- **Baja:** mejora opcional.

## 4. Organización de tareas

### Cuenta A — Gameplay, systems e implementación técnica
Responsables de la cuenta: Zadiel y Jhonn.

Áreas principales:
- Loop, mecánicas, habilidades y crafting.
- Inventario, progresión y economía.
- Implementación técnica de Roblox.

### Cuenta B — World & presentation
Responsables de la cuenta: Michael y Einell.

Áreas principales:
- Mundo, narrativa y personajes.
- Dirección visual, assets y contenido.
- Experiencia de usuario (UX).

Ambas cuentas pueden colaborar en otras áreas cuando la tarea lo requiera. Registra una persona responsable y una revisora por tarea; las tareas transversales requieren revisión de ambas parejas.

## 5. Tareas pendientes

### Diseño
- [ ] Definir concepto principal del juego.
- [ ] Aprobar los pilares de diseño.
- [ ] Definir el alcance del MVP.
- [ ] Diseñar el bucle principal de gameplay.

### Arquitectura y entorno de desarrollo
- [ ] Instalar Roblox Studio manualmente en las PC Windows destinadas al desarrollo; la MacBook se reserva para Obsidian y tareas escolares.
- [ ] Abrir o identificar el place/proyecto fuente en una PC de desarrollo y registrar su ruta o repo en Arquitectura-General.md.
- [ ] Definir estructura definitiva del proyecto.
- [ ] Establecer estándares de código.
- [ ] Diseñar arquitectura de sistemas.
- [ ] Definir estrategia de guardado.

### Gameplay
- [ ] Diseñar movimiento.
- [ ] Diseñar combate.
- [ ] Diseñar habilidades.
- [ ] Diseñar enemigos y jefes.

### Mundo
- [ ] Definir regiones.
- [ ] Diseñar zonas.
- [ ] Diseñar NPC.
- [ ] Diseñar misiones.

### Sistemas
- [ ] Diseñar inventario.
- [ ] Diseñar economía.
- [ ] Diseñar progresión.
- [ ] Diseñar multijugador.

### Infraestructura
- [ ] Definir pruebas.
- [ ] Establecer controles de seguridad.
- [ ] Establecer procedimientos de integración.
- [ ] Preparar documentación técnica.

## 5.1 Tareas registradas

### DEV-001 — Base técnica y bucle principal jugable (MVP) de BUILD A WATCH!

- **ID:** DEV-001
- **Responsable:** Jhonn (Cuenta A)
- **Cuenta Claude:** Claude 1 — Cuenta A
- **Revisor:** Zadiel (Cuenta A); Cuenta B revisa lo visible para el jugador (mapa, HUD y textos).
- **Área:** Arquitectura técnica, sistemas, economía y progresión.
- **Prioridad:** Alta.
- **Estado:** En revisión (falta la prueba en Studio).
- **Rama:** `task/DEV-001-base-mvp`
- **Fecha de creación:** 2026-11-20.

**Descripción:**

Crear el código fuente del juego (Luau, estructura compatible con Rojo) dentro de `juego/` e implementar el bucle principal propuesto: recoger cajas de piezas → fabricar relojes → vender o exhibir en el museo → comprar mejoras. Todas las cifras de balance son propuestas.

**Rutas:**

- `juego/` (código, proyecto Rojo y script de compilación).
- `09 - TAREAS Y DESARROLLO/Backlog.md`, `09 - TAREAS Y DESARROLLO/Changelog.md`, `09 - TAREAS Y DESARROLLO/Memoria-de-Area.md`.
- `03 - ARQUITECTURA TECNICA/Arquitectura-General.md`, `03 - ARQUITECTURA TECNICA/Memoria-de-Area.md`.
- `07 - ECONOMIA Y PROGRESION/Memoria-de-Area.md`, `11 - TESTING Y BUGS/Plan-de-Pruebas.md`, `10 - DECISIONES DEL EQUIPO/Registro-de-Decisiones.md`, `00 - CENTRO DE CONTROL/Dashboard.md`, `.gitignore`.

**Criterios de aceptación:**

- [x] El código vive en texto dentro de Git, separado en cliente, servidor y módulos compartidos.
- [x] El servidor valida todas las acciones (distancia, inventario, nivel, monedas y límite de solicitudes). *Implementado; falta comprobarlo en Studio.*
- [x] Los datos se guardan con DataStore: reintentos, bloqueo de sesión, autoguardado y guardado al cerrar el servidor. *Implementado; falta comprobarlo en Studio.*
- [x] Todas las acciones se completan con teclado, mando y pantalla táctil (ProximityPrompt y botones). *Implementado; falta comprobarlo con mando y en móvil.*
- [x] Hay pruebas automáticas de la lógica que se ejecutan en Studio (13 pruebas; aún no ejecutadas).
- [x] Cada paso del proceso queda registrado en [[Changelog]].
- [ ] Jhonn abre la place compilada en Studio, ejecuta Play y confirma que las pruebas pasan y que el bucle funciona.
- [ ] El equipo aprueba o corrige las cifras de balance.

**Dependencias:**

Roblox Studio instalado en la PC Windows de desarrollo. Python 3 para compilar la place, o Rojo (opcional) para sincronizar en vivo.

**Documentos relacionados:**

[[Changelog]], [[Arquitectura-General]], [[Economia-y-Progresion]], [[Plan-de-Pruebas]], [[Registro-de-Decisiones]].

### DEV-002 — Tutorial guiado para jugadores nuevos

- **ID:** DEV-002
- **Responsable:** Jhonn (Cuenta A)
- **Cuenta Claude:** Claude 1 — Cuenta A
- **Revisor:** Zadiel; Cuenta B revisa textos y la guía visual.
- **Área:** Sistemas (misiones), UI/UX.
- **Prioridad:** Alta.
- **Estado:** En revisión (falta la prueba en Studio).
- **Rama:** `task/DEV-002-tutorial` (sale de `task/DEV-001-base-mvp`; fusionar DEV-001 primero).
- **Fecha de creación:** 2026-11-20.

**Descripción:**

Cinco objetivos en orden que enseñan el bucle principal: recoger 5 cajas → fabricar un reloj → vender → exhibir → comprar una mejora. Cada objetivo da monedas. El HUD muestra el objetivo y su progreso, y una línea luminosa apunta al destino. Textos y premios son propuesta.

**Rutas:** `juego/src/shared/GameData.luau`, `juego/src/shared/PlayerLogic.luau`, `juego/src/server/Services/DataService.luau`, `juego/src/server/Tests/PlayerLogic.spec.luau`, `juego/src/client/Ui.luau` y notas de 02, 09, 10 y 11.

**Criterios de aceptación:**

- [x] Los objetivos se completan en orden y cada premio se paga una sola vez (servidor).
- [x] El progreso del tutorial se guarda; las partidas anteriores lo reciben sin perder datos.
- [x] El HUD muestra objetivo, progreso y premio; la guía apunta al destino y se oculta al llegar.
- [x] 2 pruebas automáticas nuevas.
- [ ] Jhonn completa el tutorial en Studio con datos nuevos.
- [ ] El equipo aprueba textos, orden y premios.

**Dependencias:** DEV-001.

**Documentos relacionados:** [[Changelog]], [[GDD]], [[Plan-de-Pruebas]], [[Registro-de-Decisiones]].

### DEV-003 — Robo por zonas con persecución (nuevo bucle principal)

- **ID:** DEV-003 · **Responsable:** Jhonn · **Cuenta Claude:** Claude 1 — Cuenta A · **Revisor:** Zadiel; Cuenta B revisa mapa y casas.
- **Área:** Gameplay, sistemas, economía. **Prioridad:** Crítica (define el juego). **Estado:** En revisión (falta la prueba en Studio).
- **Rama:** `task/DEV-003-robo-zonas` (encadenada: DEV-001 → DEV-002 → DEV-003). **Fecha:** 2026-11-20.

**Descripción:** reemplaza las cajas por 5 zonas con 20 casas, piezas robables por rareza, botín que se pierde si te atrapan, dueños que persiguen y puertas de velocidad. Diseño en [[GDD]] §15.

**Rutas:** `juego/src/shared/{Config,GameData,PlayerLogic}.luau`, `juego/src/server/Services/{WorldService,HouseService,OwnerNpc}.luau`, `juego/src/server/Main.server.luau`, `juego/src/server/Tests/PlayerLogic.spec.luau`, `juego/src/client/{Ui,Main.client}.luau`; se elimina `PartSpawner.luau`.

**Criterios de aceptación:**

- [x] 5 zonas, cada una más exigente y con mejores piezas; puertas de velocidad por jugador.
- [x] Robar → botín → persecución al salir → guardar en la base o perderlo al ser atrapado.
- [x] El servidor valida zona, distancia y espacio; el botín no se guarda entre sesiones.
- [x] 4 pruebas nuevas (25 en total).
- [ ] Prueba en Studio: robar en la zona 1, escapar, ser atrapado, cruzar una puerta tras mejorar la velocidad.
- [ ] El equipo aprueba zonas y cifras (DEC-004).

### DEV-004 — Jefe cooperativo: Cronómetro Maestro

- **ID:** DEV-004 · **Responsable:** Jhonn · **Cuenta Claude:** Claude 1 — Cuenta A · **Revisor:** Zadiel.
- **Área:** Sistemas, multijugador, economía. **Prioridad:** Media. **Estado:** En revisión (falta la prueba en Studio).
- **Rama:** `task/DEV-004-jefe-cronometro` (sale de DEV-003). **Fecha:** 2026-11-20.

**Descripción:** evento periódico en el que todos los jugadores del servidor entregan piezas para reparar el Cronómetro Maestro. Diseño en [[GDD]] §15.3.

**Rutas:** `juego/src/shared/{Config,GameData,PlayerLogic}.luau`, `juego/src/server/Services/{BossService,ActionService}.luau`, `juego/src/server/Main.server.luau`, `juego/src/server/Tests/PlayerLogic.spec.luau`, `juego/src/client/Ui.luau`.

**Criterios de aceptación:**

- [x] Ciclo funcionando → averiado → reparado o fallido, con aviso a todo el servidor.
- [x] Entregas validadas en el servidor; premio por punto si se repara; reembolso si falla.
- [x] El menú muestra tiempo, progreso y aporte propio, y se actualiza solo.
- [x] 2 pruebas nuevas (27 en total).
- [ ] Prueba en Studio con 2 jugadores (Test → Clients and Servers).
- [ ] El equipo aprueba tiempos, meta y premios (DEC-005).

## 6. Plantilla para nuevas tareas

### Nombre de la tarea

- **ID:** Pendiente.
- **Responsable:** Pendiente.
- **Área:** Pendiente.
- **Prioridad:** Media.
- **Estado:** Pendiente.
- **Fecha de creación:** Pendiente.

**Descripción:**

Pendiente.

**Criterios de aceptación:**

- [ ] Pendiente.

**Dependencias:**

Pendiente.

**Documentos relacionados:**

Pendiente.

## 7. Reglas de producción

1. Toda tarea debe tener un objetivo claro.
2. Las tareas deben tener criterios de aceptación.
3. Los cambios importantes deben revisarse.
4. No se deben sobrescribir cambios de otros integrantes.
5. Las tareas bloqueadas deben documentar su causa.
6. Las tareas completadas deben verificarse antes de cerrarse.
7. Las decisiones importantes deben registrarse.

## 8. Documentos relacionados

- [[Dashboard]]
- [[GDD]]
- [[Arquitectura-General]]
- [[Lista-de-Sistemas]]
- [[Diseño-del-Mundo]]
- [[Registro-de-Decisiones]]
- [[Plan-de-Pruebas]]
- [[Equipo-y-Responsabilidades]]
- [[Protocolo-de-Trabajo-IA]]

---

**Estado:** Borrador inicial
