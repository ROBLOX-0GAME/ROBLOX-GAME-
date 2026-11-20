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

### INFRA-001 — Coordinación de agentes y preparación de Rojo

- **ID:** INFRA-001.
- **Responsable:** Jhonn y Zadiel (Cuenta A).
- **Revisión:** Jhonn y Zadiel; Michael y Einell para cambios transversales.
- **Área:** GitHub, coordinación de archivos y entorno Rojo.
- **Prioridad:** Alta.
- **Estado:** En revisión.
- **Rama:** `task/INFRA-001-coordination-rojo`.
- **Alcance:** crear el registro de propietarios y reservas, las reglas de ramas y revisión, una comprobación de conflictos para Pull Requests, y el scaffold inicial de Rojo en `game/`.
- **Criterios de aceptación:**
  - [x] La propiedad de áreas refleja Cuenta A (Jhonn/Zadiel) y Cuenta B (Michael/Einell); los archivos compartidos exigen coordinación.
  - [x] Cada tarea trabaja en `task/<ID>-<slug>` y reserva rutas antes de editarlas.
  - [x] Una comprobación automatizada bloquea la integración de un Pull Request que cambie rutas reservadas por otra tarea.
  - [x] Claude Code bloquea Edit/Write en main, rutas sin reserva integrada y rutas activas reservadas por otra tarea.
  - [x] Los Pull Requests de reserva que reclaman rutas superpuestas se detectan aunque solo modifiquen el registro central.
  - [x] Los cambios de Backlog.md y ACTIVE_TASKS.md quedan limitados al ID de la tarea del Pull Request.
  - [x] Los Pull Requests usan una plantilla con responsable, revisor, rutas reservadas y verificaciones.
  - [x] `game/default.project.json` puede construir el scaffold; Rojo no permite la sincronización en vivo hasta que se añada el `placeId`.
  - [ ] Activar en GitHub Settings la protección de `main`: Pull Request obligatorio, una aprobación y los controles `reservation-check` y `rojo-build`; bloquear force push y eliminación de la rama.
  - [ ] Limitar escritura a los @handles de las cuatro personas autorizadas; mantener solo las administraciones necesarias dentro de ese grupo.
  - [ ] Desactivar el borrado/transferencia de repositorios por miembros desde los ajustes de la organización.
- **Dependencias:** protección y acceso de GitHub pendientes de ajustes administrativos y confirmación de los @handles de Michael y Einell; la sincronización en vivo espera a que se cree el place y se registre su `placeId`.
- **Documentos relacionados:** [[ACTIVE_TASKS]], [[OWNERS]], [[Protocolo-de-Trabajo-IA]], [[Arquitectura-General]].

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
8. Toda tarea que reserve rutas debe figurar en [[ACTIVE_TASKS]] antes de editarlas.
9. Al finalizar, liberar la reserva y actualizar Backlog dentro del Pull Request de la tarea.

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
- [[ACTIVE_TASKS]]
- [[OWNERS]]
- [[09 - TAREAS Y DESARROLLO/Memoria-de-Area|Memoria de Producción]]

---

**Estado:** Borrador inicial
### DEV-007 — Integrar el juego (DEV-001 a DEV-006) en game/

- **ID:** DEV-007.
- **Cuenta Claude:** Claude 1 — Cuenta A.
- **Responsable:** Jhonn.
- **Revisor:** Zadiel. Michael y Einell revisan `game/src/StarterPlayer/StarterPlayerScripts/` (interfaz, ruta de Cuenta B según OWNERS.md).
- **Área:** Arquitectura técnica, sistemas, economía y progresión.
- **Prioridad:** Alta.
- **Estado:** En revisión (Pull Request final; reserva fusionada en PR #3).
- **Rama:** `task/DEV-007-integracion-juego`.
- **Fecha de creación:** 2026-11-20.

**Descripción:**

Las ramas `task/DEV-001-base-mvp` a `task/DEV-006-velocidad-robux` se hicieron antes de que INFRA-001 llegara a `main` y guardan el código en `juego/`. Esta tarea las integra respetando DEC-001 (código en `game/`) y DEC-002 (ramas, reservas y revisión):

1. Mover el código Luau a `game/src/ReplicatedStorage/Shared`, `game/src/ServerScriptService/Server` y `game/src/StarterPlayer/StarterPlayerScripts/Client`, y retirar los archivos Bootstrap y Placeholder.
2. Mantener la compilación con Rojo 7.7.1 (control `rojo-build`) y adaptar `build.py` para la revisión estática local.
3. Llevar a la bóveda el diseño (GDD §15), Changelog, Plan de Pruebas y memorias, y renumerar las decisiones propuestas para que no choquen con DEC-001 y DEC-002 aprobadas.
4. Al terminar, cerrar las ramas DEV-001 a DEV-006 sin fusionarlas: su contenido llega a `main` por esta tarea.

Contenido que se integra (todo como propuesta, salvo lo aprobado): bucle de robo por 5 zonas con dueños que persiguen y puertas de velocidad; fabricación, venta y museo; tutorial de 5 objetivos; jefe cooperativo Cronómetro Maestro; mascotas con multiplicador de velocidad; caminadoras de entrenamiento; 6 pases y 5 productos con Robux con IDs pendientes. Por indicación de Jhonn, solo se programan mecánicas; el arte y el sonido se harán con Krita, Blender, Audacity y Material Maker.

**Criterios de aceptación:**

- [x] El código vive en `game/src`. La compilación con Rojo la confirma el control `rojo-build` de este PR.
- [x] Revisión estática local sin errores: 20 scripts, 73 `require`. Las 35 pruebas se ejecutan al pulsar Play en Studio y están pendientes de que Jhonn las corra.
- [x] El diseño (GDD §15), el Changelog, el Plan de Pruebas y las memorias están en la bóveda; las decisiones se renumeraron a DEC-003…DEC-008 y siguen como propuestas.
- [ ] Michael o Einell revisan la interfaz; Zadiel revisa el resto.
- [ ] En el Pull Request final, la fila DEV-007 de ACTIVE_TASKS.md queda Completada.

**Dependencias:** INFRA-001 (Completada).

**Documentos relacionados:** [[ACTIVE_TASKS]], [[OWNERS]], [[Registro-de-Decisiones]], [[Arquitectura-General]].
